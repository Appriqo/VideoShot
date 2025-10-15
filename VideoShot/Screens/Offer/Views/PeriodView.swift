//
//  PeriodView.swift
//  FreezeFrame
//
//  Created by admin on 20/9/25.
//

import AppKit
import SnapKit

final class PeriodView: BaseView {
    
    // MARK: - Properties
    
    var tagType: PeriodType?
    
    private(set) var isSelected: Bool = false
    private let shieldGradientBorder = CAGradientLayer()
    private let periodGradientBorder = CAGradientLayer()
    
    // MARK: - Views
    
    private lazy var shieldContainerView: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        view.layer?.cornerRadius = 6
        return view
    }()
    
    private lazy var shieldLabel: NSTextField = createLabel(
        text: "-",
        font: .systemFont(ofSize: 14, weight: .medium),
        color: .black,
        alignment: .center
    )
    
    private lazy var periodContainerView: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor(white: 0, alpha: 0.05).cgColor
        view.layer?.cornerRadius = 10
        return view
    }()
    
    private lazy var periodLabel: NSTextField = createLabel(
        text: "-",
        font: .systemFont(ofSize: 16, weight: .medium),
        color: .black,
        alignment: .center
    )
    
    private lazy var priceLabel: NSTextField = createLabel(
        text: "-",
        font: .systemFont(ofSize: 14, weight: .regular),
        color: .offerGray,
        alignment: .center
    )
    
    // MARK: - Init
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func hideShield(_ isHidden: Bool) {
        shieldContainerView.isHidden = isHidden
    }
    
    func setSelected(_ selected: Bool) {
        isSelected = selected
        periodContainerView.layer?.backgroundColor = isSelected ? .white : NSColor(white: 0, alpha: 0.05).cgColor
        periodLabel.textColor = isSelected ? .black : NSColor(white: 0, alpha: 0.75)
        updateGradientBorderIfNeeded()
    }
    
    func updateShieldText(_ text: String) {
        shieldLabel.stringValue = text
    }
    
    func updatePeriodText(_ text: String) {
        periodLabel.stringValue = text
    }
    
    func updatePriceText(_ text: String?) {
        priceLabel.stringValue = text ?? ""
    }

    override func layout() {
        super.layout()
        updateGradientBorder(
            for: shieldContainerView,
            gradientLayer: shieldGradientBorder,
            cornerRadius: 6,
            borderWidth: 2
        )
    }
}

private extension PeriodView {
    func configureUI() {
        wantsLayer = true
        setupViews()
        setupConstraints()
        setupTargets()
    }
    
    func setupViews() {
        addSubview(shieldContainerView)
        shieldContainerView.addSubview(shieldLabel)
        addSubview(periodContainerView)
        periodContainerView.addSubview(periodLabel)
        periodContainerView.addSubview(priceLabel)
    }
    
    func setupConstraints() {
        periodContainerView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.height.equalTo(60)
        }
        
        shieldContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(8)
            make.height.equalTo(25)
        }
        
        shieldLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.centerY.equalToSuperview().offset(-1)
        }
        
        periodLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.horizontalEdges.equalToSuperview().inset(10)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(10)
            make.horizontalEdges.equalToSuperview().inset(10)
            
        }
    }
    
    func setupTargets() {
        
    }
    
    private func updateGradientBorderIfNeeded() {
        if isSelected {
            updateGradientBorder(
                for: periodContainerView,
                gradientLayer: periodGradientBorder,
                cornerRadius: 10,
                borderWidth: 2
            )
        } else {
            periodGradientBorder.removeFromSuperlayer()
        }
    }
    
    private func updateGradientBorder(for view: NSView,
                                      gradientLayer: CAGradientLayer,
                                      cornerRadius: CGFloat,
                                      borderWidth: CGFloat) {
        gradientLayer.removeFromSuperlayer()
        
        gradientLayer.frame = view.bounds
        gradientLayer.cornerRadius = cornerRadius
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = [
            NSColor(resource: .firstGradient).cgColor,
            NSColor(resource: .secondGradient).cgColor
        ]
        
        let shape = CAShapeLayer()
        let inset = borderWidth / 2
        let rect = view.bounds.insetBy(dx: inset, dy: inset)
        shape.path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
        shape.lineWidth = borderWidth
        shape.fillColor = nil
        shape.strokeColor = NSColor.black.cgColor
        
        gradientLayer.mask = shape
        view.layer?.addSublayer(gradientLayer)
    }
}
