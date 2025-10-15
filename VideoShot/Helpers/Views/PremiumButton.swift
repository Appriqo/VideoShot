//
//  PremiumButton.swift
//  FreezeFrame
//
//  Created by admin on 4/10/25.
//

import AppKit

final class PremiumButton: NSButton {

    private var trackingArea: NSTrackingArea?
    private let pulseKey = "pulseAnimation"
    private let gradientLayer = CAGradientLayer()

    // MARK: - Init / setup

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    private func commonInit() {
        wantsLayer = true
        isBordered = false
        title = "premium".localized
        font = .systemFont(ofSize: 11, weight: .heavy)
          contentTintColor = .white
        layer?.masksToBounds = true
        layer?.cornerRadius = 6

        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 6
        gradientLayer.masksToBounds = true
        gradientLayer.needsDisplayOnBoundsChange = true
        gradientLayer.contentsScale = window?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 2.0

        gradientLayer.colors = [
            NSColor.firstGradient.cgColor,
            NSColor.secondGradient.cgColor
        ]

        if gradientLayer.superlayer == nil {
            layer?.insertSublayer(gradientLayer, at: 0)
        }
    }

    // MARK: - Tracking area

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        if let existing = trackingArea {
            removeTrackingArea(existing)
        }

        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeInKeyWindow, .inVisibleRect]
        let area = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
        addTrackingArea(area)
        trackingArea = area
    }

    // MARK: - Mouse events

    override func mouseEntered(with event: NSEvent) {
        startPulse()
    }

    override func mouseExited(with event: NSEvent) {
        stopPulse()
    }

    // MARK: - Pulse animation

    private func startPulse() {
        guard layer?.animation(forKey: pulseKey) == nil else { return }

        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1.0
        pulse.toValue = 1.08
        pulse.duration = 0.4
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        layer?.add(pulse, forKey: pulseKey)
    }

    private func stopPulse() {
        layer?.removeAnimation(forKey: pulseKey)
    }

    // MARK: - Layout

    override func layout() {
        super.layout()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer?.cornerRadius ?? 6
        gradientLayer.contentsScale = window?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 2.0
        CATransaction.commit()
        layer?.cornerRadius = gradientLayer.cornerRadius
    }
}
