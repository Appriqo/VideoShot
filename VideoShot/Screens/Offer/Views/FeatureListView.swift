//
//  FeatureListView.swift
//  FreezeFrame
//
//  Created by admin on 20/9/25.
//

import AppKit
import SnapKit

final class FeatureListView: BaseView {
    
    // MARK: - Views
    
    private let feature1View: FeatureView = .init()
    private let feature2View: FeatureView = .init()
    private let feature3View: FeatureView = .init()
    private let feature4View: FeatureView = .init()

    // MARK: - Init
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension FeatureListView {
    func configureUI() {
        setupTexts()
        setupViews()
        setupConstraints()
    }
    
    func setupTexts() {
        feature1View.setupFeature(title: "frame_exports_full_hd".localized)
        feature2View.setupFeature(title: "export_unlimited_frames".localized)
        feature3View.setupFeature(title: "customizable_multi_frame_extraction".localized)
        feature4View.setupFeature(title: "full_access_to_filters".localized)
    }
    
    func setupViews() {
        [feature1View, feature2View, feature3View, feature4View].forEach {
            addSubview($0)
        }
    }
    
    func setupConstraints() {
        feature1View.snp.makeConstraints { make in
            make.height.equalTo(34)
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
        }
        
        feature2View.snp.makeConstraints { make in
            make.height.equalTo(34)
            make.top.equalTo(feature1View.snp.bottom).offset(14)
            make.horizontalEdges.equalToSuperview()
        }
        
        feature3View.snp.makeConstraints { make in
            make.height.equalTo(34)
            make.top.equalTo(feature2View.snp.bottom).offset(14)
            make.horizontalEdges.equalToSuperview()
        }
        
        feature4View.snp.makeConstraints { make in
            make.height.equalTo(34)
            make.top.equalTo(feature3View.snp.bottom).offset(14)
            make.horizontalEdges.equalToSuperview()
        }
    }
}
