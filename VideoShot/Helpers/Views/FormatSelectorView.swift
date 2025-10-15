//
//  FormatSelectorView.swift
//  FreezeFrame
//
//  Created by admin on 4/10/25.
//

import AppKit
import SnapKit

final class FormatSelectorView: BaseView {
    
    var onSelectFormat: ((String) -> Void)?
    
    private lazy var jpgButton: NSButton = createButton(title: "JPG")
    private lazy var pngButton: NSButton = createButton(title: "PNG")
    private lazy var heicButton: NSButton = createButton(title: "HEIC")
    private lazy var tiffButton: NSButton = createButton(title: "TIFF")
    private lazy var gifButton: NSButton = createButton(title: "GIF")
    private lazy var pdfButton: NSButton = createButton(title: "PDF")
    
    private lazy var buttons: [NSButton] = [jpgButton, pngButton, heicButton, tiffButton, gifButton, pdfButton]
    
    private(set) var selectedFormat: String = "JPG" {
        didSet {
            onSelectFormat?(selectedFormat)
            updateButtonStyles()
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
        selectedFormat = "JPG"
        updateButtonStyles()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        selectedFormat = "JPG"
        updateButtonStyles()
    }
    
    private func createButton(title: String) -> NSButton {
        let button = NSButton(title: title, target: self, action: #selector(buttonTapped(_:)))
        button.wantsLayer = true
        button.isBordered = false
        button.layer?.cornerRadius = 4
        button.font = NSFont.systemFont(ofSize: 12, weight: .medium)
        return button
    }
    
    private func setupUI() {
        let stack = NSStackView(views: buttons)
        stack.orientation = .horizontal
        stack.spacing = 8
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(20)
        }
        
        buttons.forEach { $0.snp.makeConstraints { make in make.width.equalTo(40); make.height.equalTo(20) } }
    }
    
    @objc private func buttonTapped(_ sender: NSButton) {
        selectedFormat = sender.title
    }
    
    private func updateButtonStyles() {
        for button in buttons {
            if button.title == selectedFormat {
                button.layer?.backgroundColor = NSColor.firstGradient.cgColor
                button.attributedTitle = NSAttributedString(
                    string: button.title,
                    attributes: [.foregroundColor: NSColor.white]
                )
            } else {
                button.layer?.backgroundColor = NSColor(white: 1, alpha: 0.7).cgColor
                button.attributedTitle = NSAttributedString(
                    string: button.title,
                    attributes: [.foregroundColor: NSColor.black]
                )
            }
        }
    }
}
