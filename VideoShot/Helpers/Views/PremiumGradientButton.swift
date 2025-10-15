//
//  PremiumGradientButton.swift
//  FreezeFrame
//
//  Created by admin on 4/10/25.
//

import AppKit

final class PremiumGradientButton: NSButton {

    private let gradientLayer = CAGradientLayer()
    private var isAnimating = false

    var firstColor: NSColor = .systemBlue {
        didSet { updateGradientColors() }
    }

    var secondColor: NSColor = .systemGreen {
        didSet { updateGradientColors() }
    }

    var cornerRadius: CGFloat = 6 {
        didSet {
            gradientLayer.cornerRadius = cornerRadius
            layer?.cornerRadius = cornerRadius
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        isBordered = false
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
        isBordered = false
        setup()
    }

    override func layout() {
        super.layout()
        gradientLayer.frame = bounds
    }

    private func setup() {
        layer?.masksToBounds = true
        layer?.addSublayer(gradientLayer)
        font = NSFont.systemFont(ofSize: 16, weight: .medium)
        updateGradientColors()
        setupStaticGradient()
    }

    private func updateGradientColors() {
        gradientLayer.colors = [
            firstColor.cgColor,
            firstColor.blended(withFraction: 0.5, of: secondColor)?.cgColor ?? secondColor.cgColor,
            secondColor.cgColor,
            secondColor.blended(withFraction: 0.5, of: firstColor)?.cgColor ?? firstColor.cgColor,
            firstColor.cgColor
        ]
    }

    private func setupStaticGradient() {
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.locations = [0.0, 0.25, 0.5, 0.75, 1.0]
        gradientLayer.cornerRadius = cornerRadius
        gradientLayer.frame = bounds
    }

    func startAnimatingGradient() {
        guard !isAnimating else { return }
        isAnimating = true

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-2.0 ,-1.5, -1.0, -0.5, 0.0, 0.5, 1.0]
        animation.toValue = [1.0, 1.5, 2.0, 2.5, 3.0]
        animation.duration = 6
        animation.repeatCount = .infinity
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false

        gradientLayer.add(animation, forKey: "gradientFlow")
    }

    func stopAnimatingGradient() {
        isAnimating = false
        gradientLayer.removeAnimation(forKey: "gradientFlow")
    }

    func attributedTitle(with text: String, color: NSColor) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        return NSAttributedString(string: text, attributes: [
            .foregroundColor: color,
            .font: font ?? .systemFont(ofSize: 18),
            .paragraphStyle: paragraph
        ])
    }
}
