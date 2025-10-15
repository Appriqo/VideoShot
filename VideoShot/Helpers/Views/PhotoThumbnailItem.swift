//
//  PhotoThumbnailItem.swift
//  FreezeFrame
//
//  Created by admin on 6/10/25.
//

import AppKit
import SnapKit

final class PhotoThumbnailItem: NSCollectionViewItem {
    
    var onDelete: (() -> Void)?
    
    private lazy var imageViewContainer: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.cornerRadius = 8
        view.layer?.masksToBounds = true
        return view
    }()
    
    private lazy var photoImageView: AspectFillImageView = {
        let iv = AspectFillImageView()
        iv.wantsLayer = true
        iv.layer?.cornerRadius = 8
        iv.layer?.masksToBounds = true
        return iv
    }()
    
    private lazy var deleteButton: NSButton = {
        let button = NSButton(image: NSImage(named: NSImage.stopProgressTemplateName) ?? NSImage(),
                              target: self,
                              action: #selector(deleteTapped))
        button.isBordered = false
        button.bezelStyle = .regularSquare
        button.contentTintColor = .white
        button.wantsLayer = true
        button.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.5).cgColor
        button.layer?.cornerRadius = 8
        button.alphaValue = 0
        return button
    }()
    
    override func loadView() {
        self.view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configure(with image: NSImage) {
        photoImageView.image = image
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                view.layer?.borderWidth = 2
                view.layer?.borderColor = NSColor.white.cgColor
            } else {
                view.layer?.borderWidth = 0
            }
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.15
            deleteButton.animator().alphaValue = 1
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.15
            deleteButton.animator().alphaValue = 0
        }
    }
    
}

// MARK: - Private Setup

private extension PhotoThumbnailItem {
    func configureUI() {
        view.wantsLayer = true
        view.layer?.cornerRadius = 8
        view.layer?.masksToBounds = true
        view.layer?.backgroundColor = NSColor(resource: .blackBackgound).cgColor
        
        view.addSubview(imageViewContainer)
        imageViewContainer.addSubview(photoImageView)
        imageViewContainer.addSubview(deleteButton)
        
        imageViewContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        photoImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(6)
            make.size.equalTo(16)
        }
        
        let trackingArea = NSTrackingArea(rect: .zero,
                                          options: [.mouseEnteredAndExited, .inVisibleRect, .activeAlways],
                                          owner: self,
                                          userInfo: nil)
        view.addTrackingArea(trackingArea)
    }

    @objc func deleteTapped() {
        onDelete?()
    }
}

// MARK: - Identifier

extension PhotoThumbnailItem {
    static let identifier = NSUserInterfaceItemIdentifier("PhotoThumbnailItem")
}
