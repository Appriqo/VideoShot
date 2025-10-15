//
//  ColoredButton.swift
//  FreezeFrame
//
//  Created by admin on 4/10/25.
//

import AppKit
import SnapKit

final class ColoredButton: BaseView {
    
    // MARK: - Propeprties
    
    var onTap: (() -> Void)?
    
    // MARK: - Views
    
    private lazy var textLabel = createLabel(text: "",
                                         font: .systemFont(ofSize: 24, weight: .regular),
                                         color: .white,
                                         alignment: .right)
    
    private lazy var imageView: NSImageView = .init()
    
    private lazy var stackView: NSStackView = {
        let stackView = NSStackView(views: [textLabel, imageView])
        stackView.orientation = .horizontal
        stackView.spacing = 4
        return stackView
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
    
    func updateButton(_ backgroundColor: NSColor, text: String, imageIcon: NSImage) {
        layer?.backgroundColor = backgroundColor.cgColor
        textLabel.stringValue = text
        imageView.image = imageIcon
    }
    
    func updateBorderButton(_ color: NSColor = .white, borderWidth: CGFloat = 1) {
        wantsLayer = true
        layer?.borderColor = color.cgColor
        layer?.borderWidth = borderWidth
    }
    
    func updateStyle(textColor: NSColor, font: NSFont) {
        textLabel.textColor = textColor
        textLabel.font = font
    }
}

// MARK: - Private methods

private extension ColoredButton {
    func configureUI() {
        wantsLayer = true
        layer?.cornerRadius = 12
        
        setupViews()
        setupConstraints()
        setupTargets()
    }
    
    func setupViews() {
        addSubview(stackView)
    }
    
    func setupConstraints() {
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
    }
    
    func setupTargets() {
        let click = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        addGestureRecognizer(click)
    }
    
    @objc
    func handleClick(_ sender: NSClickGestureRecognizer) {
        onTap?()
    }
}
