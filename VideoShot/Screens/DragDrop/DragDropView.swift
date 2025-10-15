//
//  DragDropView.swift
//  FreezeFrame
//
//  Created by admin on 30/9/25.
//

import Cocoa
import SnapKit

final class DragDropView: BaseView {
    
    private lazy var imageContainerView: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.contents = NSImage(resource: .import)
        view.layer?.contentsGravity = .resizeAspect
        return view
    }()
    
    private lazy var descriptionLabel: NSTextField = {
        let label = NSTextField()
        label.isEditable = false
        label.isBezeled = false
        label.drawsBackground = false
        label.isSelectable = false
        label.alignment = .center
        label.attributedStringValue = buildDescription()
        return label
    }()
    
    var onFilesDropped: (([URL]) -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configureUI()
        registerForDraggedTypes([.fileURL])

        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(openFilePicker))
        addGestureRecognizer(clickGesture)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([.fileURL])
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let items = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] else {
            return false
        }

        let supportedExtensions = Constants.allowedVideoTypes
        let validURLs = items.filter { supportedExtensions.contains($0.pathExtension.lowercased()) }

        if !validURLs.isEmpty {
            onFilesDropped?(validURLs)
            return true
        }

        return false
    }
    
    override func layout() {
        super.layout()
        updateRectangleDividerPath()
    }
    
    @objc private func openFilePicker() {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = Constants.allowedVideoTypes
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false

        panel.begin { [weak self] result in
            if result == .OK {
                self?.onFilesDropped?(panel.urls)
            }
        }
    }
}

private extension DragDropView {
    func configureUI() {
        addSubview(imageContainerView)
        addSubview(descriptionLabel)
        addSubview(dividerView)
        dividerView.layer?.addSublayer(dividerShapeLayer)
        
        dividerView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(60)
            make.horizontalEdges.bottom.equalToSuperview().inset(32)
        }
        
        imageContainerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-16)
            make.width.equalTo(142)
            make.height.equalTo(180)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(imageContainerView.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
        }
    }
    
    // TODO: - Локализация
    func buildDescription() -> NSAttributedString {
        let fullText = "select_video_drag_drop".localized
        let baseFont = NSFont.systemFont(ofSize: 16, weight: .semibold)

        let attributed = NSMutableAttributedString(string: fullText, attributes: [
            .font: baseFont,
            .foregroundColor: NSColor.white
        ])

        return attributed
    }
    
    func updateRectangleDividerPath() {
        guard dividerView.bounds.width > 0, dividerView.bounds.height > 0 else { return }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let rect = dividerView.bounds
        let path = CGPath(rect: rect, transform: nil)
        
        dividerShapeLayer.path = path
        dividerShapeLayer.frame = rect
        
        CATransaction.commit()
    }
}
