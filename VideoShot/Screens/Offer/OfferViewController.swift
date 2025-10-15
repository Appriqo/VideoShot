//
//  OfferViewController.swift
//  FreezeFrame
//
//  Created by admin on 4/10/25.
//

import AppKit
import SnapKit
import RevenueCat

final class OfferViewController: NSViewController {
    
    // MARK: - Properties
    
    var currentPeriod: PeriodType = .month {
        didSet {
            Task { @MainActor in
                    let products = products()
                    let isTrial = await PurchaseManager.shared.isTrialActiveForUser()
                    updateDescription(isTrial: isTrial, products: products)
                }
        }
    }
    
    var isUS: Bool {
        if #available(macOS 13, *) {
            return Locale.current.region?.identifier == "US"
        } else {
            return Locale.current.regionCode == "US"
        }
    }
    
    // MARK: - Views
    
    private lazy var overlayView: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.25).cgColor
        view.isHidden = true
        view.layer?.cornerRadius = 14
        
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        return view
    }()
    
    private lazy var activityIndicator: NSProgressIndicator = {
        let indicator = NSProgressIndicator()
        indicator.style = .spinning
        indicator.controlSize = .regular
        indicator.isDisplayedWhenStopped = false
        indicator.startAnimation(nil)
        return indicator
    }()
    
    private lazy var backgroundImageView: NSImageView = {
        let imageView = NSImageView()
        imageView.image = .offerCover
        return imageView
    }()
    
    private lazy var containerBackgroundView: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.offerBackground.cgColor
        view.layer?.cornerRadius = 14
        return view
    }()
    
    private lazy var titleHeaderLabel = createLabel(text: "discover_new_experiences".localized)
    
    private lazy var closeButton = createButton(
        with: "continue_for_free".localized,
        font: .systemFont(ofSize: 12, weight: .regular),
        textColor: .offerGray
    )
    
    private lazy var featuresView: FeatureListView = .init()
    
    private lazy var subscriptionView: SubscriptionView = .init()
    private lazy var buyButton: PremiumGradientButton = {
        let button = PremiumGradientButton()
        button.firstColor = NSColor(resource: .firstGradient)
        button.secondColor = NSColor(resource: .secondGradient)
        button.cornerRadius = 12
        button.attributedTitle = button.attributedTitle(with: "start_trial".localized, color: .white)
        return button
    }()
    
    private lazy var descriptionBuyButton: NSTextField = createLabel(
        text: "you_can_cancel_subscription_anytime".localized,
        font: .systemFont(ofSize: 12),
        color: .offerGray
    )
    
    private lazy var termOfUseButton: NSButton = {
        let button = NSButton()
        button.isBordered = false
        button.wantsLayer = true
        button.bezelStyle = .regularSquare
        button.alignment = .center
        button.setButtonType(.momentaryChange)

        let baseFont = NSFont.systemFont(ofSize: 13)
        let symbolFont = NSFont.systemFont(ofSize: 13, weight: .regular)

        let attributedString = NSMutableAttributedString()

        let title = NSAttributedString(string: "terms_of_use".localized, attributes: [
            .foregroundColor: NSColor.offerGray,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: baseFont
        ])
        attributedString.append(title)

        let spacer = NSAttributedString(string: "  ", attributes: [
            .font: baseFont,
            .foregroundColor: NSColor.offerGray
        ])
        attributedString.append(spacer)

        let symbol = NSAttributedString(string: "􀆈", attributes: [
            .foregroundColor: NSColor.offerGray,
            .font: symbolFont,
            .baselineOffset: -1
        ])
        attributedString.append(symbol)

        button.attributedTitle = attributedString
        button.attributedAlternateTitle = attributedString

        return button
    }()
    
    private lazy var tosDescriptionLabel: NSTextField = createLabel(
        text: String(format: "subscription.1month.trial".localized, "-"),
        font: .systemFont(ofSize: 14),
        color: .offerGray,
        alignment: .left
    )
    
    private lazy var scrollView: NSScrollView = {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var contentView: NSView = {
        let view = NSView()
        view.wantsLayer = true
        return view
    }()
    
    private lazy var privacyPolicyButton: NSButton = createButtonWithUnderline(
        title: "privacy_policy".localized,
        font: .systemFont(ofSize: 12),
        color: .offerGray
    )
    
    private lazy var tosButton: NSButton = createButtonWithUnderline(
        title: "terms_of_use".localized,
        font: .systemFont(ofSize: 12),
        color: .offerGray
    )
    
    
    private lazy var restoreButton: NSButton = createButtonWithUnderline(
        title: "restore_purchase".localized,
        font: .systemFont(ofSize: 12),
        color: .offerGray
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        view.layoutSubtreeIfNeeded()
        subscriptionView.setSelected(by: currentPeriod)
        updateProducts()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        buyButton.startAnimatingGradient()
        AnalyticsManager.shared.logEvent("show.offer")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func updateReachabilityStatus() {
        if PurchaseManager.shared.products.isEmpty {
            PurchaseManager.shared.fetchProducts {
                PurchaseManager.shared.checkSubscriptionStatus()
                DispatchQueue.main.async { [weak self] in
                    self?.updateProducts()
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.updateProducts()
            }
        }
    }
}

// MARK: - Loader

private extension OfferViewController {
    
    func startLoader() {
        DispatchQueue.main.async { [weak self] in
            self?.overlayView.isHidden = false
            self?.activityIndicator.startAnimation(nil)
        }
    }
    
    func stopLoader() {
        DispatchQueue.main.async { [weak self] in
            self?.overlayView.isHidden = true
            self?.activityIndicator.stopAnimation(nil)
        }
    }
    
    func checkConnectionAndProceed(action: @escaping () -> Void) {
        if !ReachabilityManager.shared.isConnected {
            let alert = NSAlert()
            alert.messageText = "no.internet.connection".localized
            alert.informativeText = "check.connection.and.try.again".localized
            alert.alertStyle = .warning
            alert.addButton(withTitle: "ok".localized)
            alert.runModal()
            return
        }
        action()
    }
}

private extension OfferViewController {
    func configureUI() {
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        
        titleHeaderLabel.textColor = .black
        titleHeaderLabel.font = .systemFont(ofSize: 24, weight: .bold)
        closeButton.font = .systemFont(ofSize: 12, weight: .regular)
        closeButton.wantsLayer = true
        
        setupViews()
        setupConstraints()
        setupTargets()
        setupDelegate()
        addObservers()
    }
    
    func setupViews() {
        view.addSubview(backgroundImageView)
        view.addSubview(containerBackgroundView)
        containerBackgroundView.addSubview(scrollView)
        
        scrollView.documentView = contentView
        
        contentView.addSubview(titleHeaderLabel)
        contentView.addSubview(closeButton)
        contentView.addSubview(featuresView)
        contentView.addSubview(subscriptionView)
        contentView.addSubview(buyButton)
        contentView.addSubview(descriptionBuyButton)
        contentView.addSubview(termOfUseButton)
        contentView.addSubview(tosDescriptionLabel)
        contentView.addSubview(privacyPolicyButton)
        contentView.addSubview(tosButton)
        contentView.addSubview(restoreButton)
        containerBackgroundView.addSubview(overlayView)
    }
    
    func setupConstraints() {
        backgroundImageView.snp.makeConstraints { make in
            make.verticalEdges.trailing.equalToSuperview()
            make.width.equalTo(325)
        }
        
        containerBackgroundView.snp.makeConstraints { make in
            make.verticalEdges.leading.equalToSuperview()
            make.width.equalTo(400)
        }
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        titleHeaderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Locale.isRU || Locale.isFR ? 16 : 24)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(titleHeaderLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        
        featuresView.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(190)
        }
        
        subscriptionView.snp.makeConstraints { make in
            make.height.equalTo(92)
            make.horizontalEdges.equalToSuperview().inset(24)
            make.top.equalTo(featuresView.snp.bottom).offset(0)
        }
        
        buyButton.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.width.equalTo(256)
            make.centerX.equalToSuperview()
            make.top.equalTo(subscriptionView.snp.bottom).offset(12)
        }
        
        descriptionBuyButton.snp.makeConstraints { make in
            make.top.equalTo(buyButton.snp.bottom).offset(Locale.isRU || Locale.isFR ? 3 : 6)
            make.centerX.equalToSuperview()

        }
        
        termOfUseButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionBuyButton.snp.bottom).offset(Locale.isRU || Locale.isFR ? 3 : 6)
            make.centerX.equalToSuperview()
        }
        
        tosDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(termOfUseButton.snp.bottom).offset(32)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        
        privacyPolicyButton.snp.makeConstraints { make in
            make.top.equalTo(tosDescriptionLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
        
        tosButton.snp.makeConstraints { make in
            make.top.equalTo(privacyPolicyButton.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        restoreButton.snp.makeConstraints { make in
            make.top.equalTo(tosButton.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
        }
        overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setupTargets() {
        closeButton.target = self
        closeButton.action = #selector(closeTapped)
        termOfUseButton.target = self
        termOfUseButton.action = #selector(termOfUseTapped)
        buyButton.target = self
        buyButton.action = #selector(buyTapped)
        tosButton.target = self
        tosButton.action = #selector(tosTapped)
        restoreButton.target = self
        restoreButton.action = #selector(restoreTapped)
        privacyPolicyButton.target = self
        privacyPolicyButton.action = #selector(privacyPolicyTapped)
    }
    
    func setupDelegate() {
        subscriptionView.delegate = self
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(subscriptionsVerified),
            name: .subscriptionsVerified,
            object: nil
        )
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateReachabilityStatus),
                                               name: .internetConnectionRestored,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(purchaseSucceeded),
                                               name: .purchaseSuccess,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(purchaseCancelled),
                                               name: .purchaseCancelled,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(purchaseFailed),
                                               name: .purchaseFailed,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(restoreSuccess),
                                               name: .restoreSuccess,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(restoreFailed),
                                               name: .restoreFailed,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(nothingRestore),
                                               name: .nothingToRestore,
                                               object: nil)
    }
    
    func updateProducts() {
        Task { @MainActor in
            let products = products()
            let isTrial = await PurchaseManager.shared.isTrialActiveForUser()
            
            subscriptionView.hideTrialShield(!isTrial)
            subscriptionView.updatePrice(products.weekly?.localizedPriceString,
                                         products.monthly?.localizedPriceString)
            
            updateDescription(isTrial: isTrial, products: products)
        }
    }
    
    @MainActor
    func updateDescription(isTrial: Bool, products: (weekly: StoreProduct?, monthly: StoreProduct?)) {
        switch currentPeriod {
        case .week:
            tosDescriptionLabel.stringValue = String(format: "subscription.1week".localized, products.weekly?.localizedPriceString ?? "-")
            buyButton.attributedTitle = buyButton.attributedTitle(with: "continue".localized, color: .white)
            
        case .month:
            let textWithTrial = String(format: "subscription.1month.trial".localized, products.monthly?.localizedPriceString ?? "-")
            let textWithoutTrial = String(format: "subscription.1month".localized, products.monthly?.localizedPriceString ?? "-")
            
            tosDescriptionLabel.stringValue = isTrial ? textWithTrial : textWithoutTrial
            buyButton.attributedTitle = buyButton.attributedTitle(
                with: isTrial ? "start_trial".localized : isUS ? "subscribe".localized : "continue".localized,
                color: .white
            )
        }
    }
    
    func products() -> (weekly: StoreProduct?, monthly: StoreProduct?) {
        let weeklyProduct = PurchaseManager.shared.product(with: .weekly)
        let monthlyProduct = PurchaseManager.shared.product(with: .monthly)
        return (weekly: weeklyProduct, monthly: monthlyProduct)
    }
    
    @objc
    private func purchaseFailed() {
        stopLoader()
    }
    
    @objc
    private func purchaseSucceeded() {
        stopLoader()
    }
    
    @objc
    private func purchaseCancelled() {
        stopLoader()
    }
    
    @objc
    private func restoreSuccess() {
        stopLoader()
    }
    
    @objc
    private func restoreFailed() {
        stopLoader()
    }
    
    @objc
    private func nothingRestore() {
        stopLoader()
    }
    
    @objc
    private func closeTapped() {
        AnalyticsManager.shared.logEvent("close.offer")
        dismiss(self)
    }
    
    @objc
    private func termOfUseTapped() {
        guard let documentView = scrollView.documentView else { return }
        
        let bottomPoint = NSPoint(x: 0, y: -documentView.bounds.height + scrollView.contentView.bounds.height)
        
        scrollView.contentView.scroll(to: bottomPoint)
        scrollView.reflectScrolledClipView(scrollView.contentView)
        AnalyticsManager.shared.logEvent("offer.tos.scrolled")
    }
    
    @objc
    private func buyTapped() {
        AnalyticsManager.shared.logEvent("offer.buy", properties: ["period": currentPeriod.rawValue])
        checkConnectionAndProceed { [weak self] in
            guard let self else { return }
            startLoader()
            if currentPeriod == .month {
                PurchaseManager.shared.purchaseMonthly()
            } else {
                PurchaseManager.shared.purchaseWeekly()
            }
        }
    }
    
    @objc
    private func tosTapped() {
        AnalyticsManager.shared.logEvent("offer.tos")
        guard let url = URL(string: "https://appriqo.com/videoshot/tos") else { return }
        NSWorkspace.shared.open(url)
    }
 
    @objc
    private func privacyPolicyTapped() {
        AnalyticsManager.shared.logEvent("offer.privacyPolicy")
        guard let url = URL(string: "https://appriqo.com/videoshot/privacy-policy") else { return }
        NSWorkspace.shared.open(url)
    }
    
    @objc
    private func restoreTapped() {
        AnalyticsManager.shared.logEvent("offer.restore")
        PurchaseManager.shared.restorePurchases()
    }
    
    @objc
    func subscriptionsVerified() {
        AnalyticsManager.shared.logEvent("close.purchase/restore.offer")
        guard PurchaseManager.shared.isFree else { return }
        dismiss(self)
    }
}

// MARK: - Private methods

private extension OfferViewController {
    func createLabel(
        text: String,
        font: NSFont = .systemFont(ofSize: 14),
        color: NSColor = .labelColor,
        alignment: NSTextAlignment = .center
    ) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = font
        label.textColor = color
        label.alignment = alignment
        label.lineBreakMode = .byWordWrapping
        label.maximumNumberOfLines = 0
        return label
    }
    
    func createButton(with title: String, font: NSFont, textColor: NSColor) -> NSButton {
        let button = NSButton(title: "", target: nil, action: nil)
        button.bezelStyle = .inline
        button.isBordered = false
        button.imagePosition = .noImage
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: textColor,
            .font: font
        ]
        
        button.attributedTitle = NSAttributedString(string: title, attributes: attributes)
        
        return button
    }
    
    func createButtonWithUnderline(
        title: String,
        font: NSFont = .systemFont(ofSize: 13),
        color: NSColor = .labelColor,
        alignment: NSTextAlignment = .center,
        underline: Bool = true
    ) -> NSButton {
        let button = NSButton()
        button.isBordered = false
        button.wantsLayer = true
        button.bezelStyle = .regularSquare
        button.setButtonType(.momentaryChange)
        button.alignment = alignment

        let underlineStyle = underline ? NSUnderlineStyle.single.rawValue : NSUnderlineStyle().rawValue

        let attributedTitle = NSAttributedString(string: title, attributes: [
            .foregroundColor: color,
            .font: font,
            .underlineStyle: underlineStyle
        ])

        button.attributedTitle = attributedTitle
        button.attributedAlternateTitle = attributedTitle

        return button
    }
}

extension OfferViewController: SubscriptionViewDelegate {
    func subscriptionView(_ view: SubscriptionView, didSelect period: PeriodType) {
        currentPeriod = period
        buyTapped()
    }
}
