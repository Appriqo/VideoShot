//
//  SubscriptionView.swift
//  FreezeFrame
//
//  Created by admin on 20/9/25.
//

import AppKit
import SnapKit

enum PeriodType: Int {
    case week = 1
    case month
}

protocol SubscriptionViewDelegate: AnyObject {
    func subscriptionView(_ view: SubscriptionView, didSelect period: PeriodType)
}

final class SubscriptionView: BaseView {
    
    // MARK: - Properties
    
    weak var delegate: SubscriptionViewDelegate?
    private var selectedPeriod: PeriodView?
    
    // MARK: - Views
    
    private lazy var period1: PeriodView = .init()
    private lazy var period2: PeriodView = .init()
    
    private lazy var stackView: NSStackView = {
       let stackView = NSStackView(views: [period1, period2])
        stackView.orientation = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 14
        return stackView
    }()

    // MARK: - Init
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSelected(by period: PeriodType) {
        [period1, period2].forEach { $0.setSelected(false) }

        switch period {
        case .week:
            period1.setSelected(true)
            selectedPeriod = period1
        case .month:
            period2.setSelected(true)
            selectedPeriod = period2
        }
    }
    
    func hideTrialShield(_ isHiiden: Bool) {
        period2.hideShield(isHiiden)
    }
    
    func updatePrice(_ leftPeriodPrice: String?, _ rightPeriodPrice: String?) {
        period1.updatePriceText(leftPeriodPrice)
        period2.updatePriceText(rightPeriodPrice)
    }
}

private extension SubscriptionView {
    func configureUI() {
        wantsLayer = true
        setupViews()
        setupConstraints()
        setupTargets()
        setupTexts()
        
        period1.hideShield(true)
        period1.tagType = .week
        period2.tagType = .month
    }
    
    func setupViews() {
        addSubview(period1)
        addSubview(period2)
    }
    
    func setupConstraints() {
        period1.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.leading.equalToSuperview().inset(8)
            make.width.equalTo(160)
        }
        
        period2.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.trailing.equalToSuperview().inset(8)
            make.width.equalTo(160)
        }
    }
    
    func setupTargets() {
        [period1, period2].forEach { period in
            let gesture = NSClickGestureRecognizer(target: self, action: #selector(periodTapped(_:)))
            period.addGestureRecognizer(gesture)
        }
    }
    
    func setupTexts() {
        period1.updatePeriodText("one_week".localized)
        period2.updatePeriodText("one_month".localized)
        period2.updateShieldText("three_days_free".localized)
    }
    
    // MARK: - Selectors
    
    @objc
    func periodTapped(_ sender: NSClickGestureRecognizer) {
        guard let tapped = sender.view as? PeriodView else { return }

        selectedPeriod?.setSelected(false)
        tapped.setSelected(true)
        selectedPeriod = tapped

        delegate?.subscriptionView(self, didSelect: tapped.tagType ?? .month)
    }
}
