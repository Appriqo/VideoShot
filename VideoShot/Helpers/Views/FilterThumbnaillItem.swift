//
//  FilterThumbnaillItem.swift
//  FreezeFrame
//
//  Created by admin on 6/10/25.
//

import AppKit
import SnapKit

final class FilterThumbnaillItem: NSCollectionViewItem {

    static let identifier = NSUserInterfaceItemIdentifier("FilterThumbnaillItem")

    private let thumbnailImageView: AspectFillImageView = {
        let iv = AspectFillImageView()
        iv.wantsLayer = true
        iv.layer?.cornerRadius = 8
        iv.layer?.masksToBounds = true
        return iv
    }()
    
    private let titleLabel: NSTextField = {
        let label = NSTextField(labelWithString: "")
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.alignment = .center
        return label
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
        titleLabel.stringValue = ""
    }

    private func setupUI() {
        view.addSubview(thumbnailImageView)
        view.addSubview(titleLabel)

        thumbnailImageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(80)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(thumbnailImageView.snp.bottom).offset(4)
            make.horizontalEdges.equalToSuperview().inset(2)
        }
    }

    func configure(with image: NSImage, title: String) {
        thumbnailImageView.image = image
        titleLabel.stringValue = title
    }
}
