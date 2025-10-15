//
//  FeatureView.swift
//  FreezeFrame
//
//  Created by admin on 20/9/25.
//

import AppKit
import SnapKit

final class FeatureView: BaseView {
    
    // MARK: - Views
    
    private lazy var featureBadge: NSImageView = {
        let imageView = NSImageView(image: .offerCheckmarkBadge)
        return imageView
    }()
    
    private lazy var titleLabel: NSTextField = createLabel(
        text: "",
        font: .systemFont(ofSize: 16),
        color: .black
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
    
    func setupFeature(title: String) {
        self.titleLabel.stringValue = title
    }
    
}

private extension FeatureView {
    func configureUI() {
        titleLabel.maximumNumberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
        setupViews()
        setupConstraints()
    }
    
    func setupViews() {
        addSubview(featureBadge)
        addSubview(titleLabel)
    }
    
    func setupConstraints() {
        featureBadge.snp.makeConstraints { make in
            make.size.equalTo(34)
            make.top.leading.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(featureBadge.snp.trailing).offset(16)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(featureBadge)
        }
    }
}
