//
//  HeaderView.swift
//  FreezeFrame
//
//  Created by admin on 4/10/25.
//

import AppKit
import SnapKit

final class HeaderView: BaseView {
    
    var onGearButtonTapped: (() -> Void)?
    var onPremiumButtonTapped: (() -> Void)?
    var onExportButtonTapped: (() -> Void)?
    var onTrashButtonTapped: (() -> Void)?
    
    // MARK: - Views
    
    private lazy var gearButton = createButton(with: .gearSettings)
    private lazy var exportButton = createButton(with: .export)
    private lazy var trashButton = createButton(with: .trash)

    private lazy var premiumButton: PremiumButton = {
        let button = PremiumButton()
        button.bezelStyle = .regularSquare
        button.isBordered = false
        button.isHidden = true
        return button
    }()
    
    private lazy var titleLabel: NSTextField = {
        let label = NSTextField(labelWithString: Constants.appName)
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .white
        label.alignment = .center
        return label
    }()
    
    
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
    
    func updatePremiumState(_ isFree: Bool) {
        premiumButton.isHidden = isFree
    }
}

// MARK: - Private methods

private extension HeaderView {
    func configureUI() {
        wantsLayer = true
        layer?.backgroundColor = .clear
        setupViews()
        setupConstraints()
        setupTargets()
    }
    
    func setupViews() {
        addSubview(premiumButton)
        addSubview(exportButton)
        addSubview(trashButton)
        addSubview(gearButton)
        addSubview(titleLabel)
    }
    
    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        gearButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
 
        trashButton.snp.makeConstraints { make in
            make.right.equalTo(gearButton.snp.left).offset(-8)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
        
        exportButton.snp.makeConstraints { make in
            make.right.equalTo(trashButton.snp.left).offset(-8)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
        
        premiumButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(1)
            make.height.equalTo(18)
            make.width.equalTo(74)
            make.right.equalTo(exportButton.snp.left).offset(-12)
        }
    }
    
    func setupTargets() {
        gearButton.target = self
        premiumButton.target = self
        exportButton.target = self
        trashButton.target = self
        gearButton.action = #selector(gearButtonTapped)
        premiumButton.action = #selector(premiumButtonTapped)
        exportButton.action = #selector(exportButtonTapped)
        trashButton.action = #selector(trashButtonTapped)
    }
    
    @objc
    func premiumButtonTapped() {
        AnalyticsManager.shared.logEvent("premium.header")
        onPremiumButtonTapped?()
    }
    
    @objc
    func gearButtonTapped() {
        AnalyticsManager.shared.logEvent("gear.header")
        onGearButtonTapped?()
    }
    
    @objc
    func exportButtonTapped() {
        AnalyticsManager.shared.logEvent("export.header")
        onExportButtonTapped?()
    }
    
    @objc
    func trashButtonTapped() {
        AnalyticsManager.shared.logEvent("trash.header")
        onTrashButtonTapped?()
    }
}
