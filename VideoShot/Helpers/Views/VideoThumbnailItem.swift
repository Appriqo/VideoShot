//
//  VideoThumbnailItem.swift
//  FreezeFrame
//
//  Created by admin on 6/10/25.
//

import AppKit
import SnapKit
import AVFoundation

final class VideoThumbnailItem: NSCollectionViewItem {

    static let identifier = NSUserInterfaceItemIdentifier("VideoThumbnailItem")

    var onDelete: (() -> Void)?

    private let thumbnailImageView: AspectFillImageView = {
        let iv = AspectFillImageView()
        iv.wantsLayer = true
        iv.layer?.cornerRadius = 8
        iv.layer?.masksToBounds = true
        return iv
    }()

    private lazy var playImageView: NSImageView = .init(image: .playVideo)
    
    private let deleteButton: NSButton = {
        let btn = NSButton(title: "✕", target: nil, action: nil)
        btn.bezelStyle = .shadowlessSquare
        btn.isBordered = false
        btn.font = .systemFont(ofSize: 11, weight: .medium)
        btn.contentTintColor = .white
        btn.wantsLayer = true
        btn.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.4).cgColor
        btn.layer?.cornerRadius = 8
        return btn
    }()

    override var isSelected: Bool {
        didSet {
            view.layer?.borderWidth = isSelected ? 2 : 0
            view.layer?.borderColor = NSColor.white.cgColor
        }
    }

    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        view.layer?.cornerRadius = 8
        view.layer?.masksToBounds = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
    }

    private func setupUI() {
        view.addSubview(thumbnailImageView)
        view.addSubview(deleteButton)
        thumbnailImageView.addSubview(playImageView)

        thumbnailImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        playImageView.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.center.equalToSuperview()
        }

        deleteButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(4)
            make.size.equalTo(20)
        }

        deleteButton.target = self
        deleteButton.action = #selector(handleDelete)
    }

    func configure(with url: URL) {
        loadThumbnail(from: url)
    }

    private func loadThumbnail(from url: URL) {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        if let cgImage = try? generator.copyCGImage(at: .zero, actualTime: nil) {
            thumbnailImageView.image = NSImage(cgImage: cgImage, size: NSSize(width: 140, height: 80))
        }
    }

    @objc private func handleDelete() {
        onDelete?()
    }
}
