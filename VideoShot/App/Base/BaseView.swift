//
//  BaseView.swift
//  FreezeFrame
//
//  Created by admin on 30/9/25.
//

import AppKit

class BaseView: NSView {
    
    lazy var dividerView: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = nil
        return view
    }()
    
    lazy var dividerShapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = .white
        layer.lineWidth = 1
        layer.lineDashPattern = [4, 4]
        layer.fillColor = nil
        return layer
    }()
    
    let backgroundBehindView: NSVisualEffectView = {
        let blur = NSVisualEffectView()
        blur.blendingMode = .behindWindow
        blur.state = .active
        return blur
    }()
    
    let backgroundView: NSVisualEffectView = {
        let view = NSVisualEffectView()
        view.blendingMode = .withinWindow
        view.material = .hudWindow
        view.state = .active
        view.wantsLayer = true
        view.layer?.cornerRadius = 8
        view.layer?.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        view.layer?.masksToBounds = true
        return view
    }()
    
    func createButton(with image: NSImage?) -> NSButton {
        let button = NSButton()
        button.bezelStyle = .rounded
        button.image = image
        button.isBordered = false
        button.imagePosition = .imageOnly
        return button
    }
    
    func createButton(with title: String) -> NSButton {
        let button = NSButton(title: title, target: nil, action: nil)
        button.bezelStyle = .rounded
        button.isBordered = true
        button.imagePosition = .noImage
        return button
    }
    
    func createDivider(
         color: NSColor = .separatorColor,
         thickness: CGFloat = 1.0
     ) -> NSView {
         let divider = NSView()
         divider.wantsLayer = true
         divider.layer?.backgroundColor = color.cgColor
         
         divider.translatesAutoresizingMaskIntoConstraints = false
         NSLayoutConstraint.activate([
             divider.heightAnchor.constraint(equalToConstant: thickness)
         ])
         
         return divider
     }
    
    func createLabel(
        text: String,
        font: NSFont = .systemFont(ofSize: 14),
        color: NSColor = .labelColor,
        alignment: NSTextAlignment = .left
    ) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = font
        label.textColor = color
        label.alignment = alignment
        label.lineBreakMode = .byTruncatingTail
        return label
    }
    
    func removeExistingGradientLayers(from view: NSView) {
        view.layer?.sublayers?
            .filter { $0 is CAGradientLayer }
            .forEach { $0.removeFromSuperlayer() }
    }
    
    func updateDividerPath() {
        guard dividerView.bounds.height > 0 else { return }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: dividerView.bounds.width / 2, y: 0))
        path.addLine(to: CGPoint(x: dividerView.bounds.width / 2, y: dividerView.bounds.height))
        dividerShapeLayer.path = path
        dividerShapeLayer.frame = dividerView.bounds
        
        CATransaction.commit()
    }
}
