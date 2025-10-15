//
//  SettingsRow.swift
//  FreezeFrame
//
//  Created by admin on 4/10/25.
//

import AppKit
import SnapKit

final class SettingsRowView: BaseView {
    
    // MARK: - Propeprties
    
    var onTap: (() -> Void)?
    
    // MARK: - Views
    
    private lazy var titleLabel = createLabel(
        text: "",
        font: .systemFont(ofSize: 14, weight: .regular),
        color: .white
    )
    
    private lazy var chevronImage: NSImageView = .init(image: .rightChevron)
    
    private lazy var divider: NSView = createDivider()
    
    func updateRow(withTitle title: String) {
        titleLabel.stringValue = title
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
}

// MARK: - Private methods

private extension SettingsRowView {
    func configureUI() {
        wantsLayer = true        
        setupViews()
        setupConstraints()
        setupTargets()
    }
    
    func setupViews() {
        addSubview(titleLabel)
        addSubview(chevronImage)
        addSubview(divider)
    }
    
    func setupConstraints() {
        chevronImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(12)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(12)
        }
        
        divider.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.horizontalEdges.equalToSuperview().inset(12)
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
