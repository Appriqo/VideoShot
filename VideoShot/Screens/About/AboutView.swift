//
//  AboutView.swift
//  FreezeFrame
//
//  Created by admin on 4/10/25.
//

import AppKit
import SnapKit
import StoreKit

protocol AboutViewDelegate: AnyObject {
    func aboutViewDidTapClose(_ view: AboutView)
}

final class AboutView: BaseView {
    
    // MARK: - Properties
    
    weak var delegate: AboutViewDelegate?
    
    // MARK: - Views
    
    private lazy var closeButton = createButton(with: .xmark)
    private lazy var titleLabel = createLabel(
        text: "settings".localized,
        font: .systemFont(ofSize: 16, weight: .regular),
        color: .white,
        alignment: .center
    )
    
    private lazy var logoImageView: NSImageView = .init(image: .miniLogo)
    private lazy var appName = createLabel(
        text: Constants.appName,
        font: .systemFont(ofSize: 14, weight: .medium),
        color: .white,
        alignment: .center
    )
    
    private lazy var feedbackRow: SettingsRowView = .init()
    private lazy var contactUsRow: SettingsRowView = .init()
    private lazy var rateUsRow: SettingsRowView = .init()
    private lazy var restoreRow: SettingsRowView = .init()
    private lazy var termsOfUseRow: SettingsRowView = .init()
    private lazy var privacyPolicyRow: SettingsRowView = .init()
    
    // MARK: - Init
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configureUI()
    }
    
    @MainActor required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    // MARK: - Helpers
    
}

// MARK: - Private methods

private extension AboutView {
    func configureUI() {
        wantsLayer = true
        
        setupViews()
        setupConstraints()
        setupTargets()
        updateText()
    }
    
    func setupViews() {
        addSubview(backgroundBehindView)
        addSubview(closeButton)
        addSubview(titleLabel)
        
        addSubview(logoImageView)
        addSubview(appName)
        
        [contactUsRow,
         rateUsRow,
         restoreRow,
         termsOfUseRow,
         privacyPolicyRow].forEach { addSubview($0) }
    }
    
    func updateText() {
        contactUsRow.updateRow(withTitle: "contact_us".localized)
        rateUsRow.updateRow(withTitle: "rate_us".localized)
        restoreRow.updateRow(withTitle: "restore_purchase".localized)
        termsOfUseRow.updateRow(withTitle: "terms_of_use".localized)
        privacyPolicyRow.updateRow(withTitle: "privacy_policy".localized)
    }
    
    func setupConstraints() {
        backgroundBehindView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { make in
            make.size.equalTo(16)
            make.top.trailing.equalToSuperview().inset(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
        }
        
        logoImageView.snp.makeConstraints { make in
            make.size.equalTo(64)
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
        }
        
        appName.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview()
        }
 
        contactUsRow.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(appName.snp.bottom).offset(12)
        }
        
        rateUsRow.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(contactUsRow.snp.bottom)
        }
        
        restoreRow.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(rateUsRow.snp.bottom)
        }
        
        termsOfUseRow.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(restoreRow.snp.bottom)
        }
        
        privacyPolicyRow.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(termsOfUseRow.snp.bottom)
        }
    }
    
    func setupTargets() {
        closeButton.target = self
        closeButton.action = #selector(didTapCloseButton)
        feedbackRow.onTap = {
            print("feedback")
        }
        
        contactUsRow.onTap = {
            AnalyticsManager.shared.logEvent("settings.contactUS")
            guard let url = URL(string: "https://appriqo.com/#contacts") else { return }
            NSWorkspace.shared.open(url)
        }
        
        rateUsRow.onTap = {
            SKStoreReviewController.requestReview()
        }
        
        restoreRow.onTap = {
            AnalyticsManager.shared.logEvent("settings.restore")
            PurchaseManager.shared.restorePurchases()
        }
        
        termsOfUseRow.onTap = {
            AnalyticsManager.shared.logEvent("settings.tos")
            guard let url = URL(string: "https://appriqo.com/videoshot/tos") else { return }
            NSWorkspace.shared.open(url)
        }
        
        privacyPolicyRow.onTap = {
            AnalyticsManager.shared.logEvent("settings.privacyPolicy")
            guard let url = URL(string: "https://appriqo.com/videoshot/privacy-policy") else { return }
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc
    func didTapCloseButton() {
        delegate?.aboutViewDidTapClose(self)
    }
}
