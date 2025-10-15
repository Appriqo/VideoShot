//
//  AddVideoButton.swift
//  FreezeFrame
//
//  Created by admin on 4/10/25.
//

import AppKit
import SnapKit

final class AddVideoButton: BaseView {
    
    // MARK: - Propeprties
    
    var onTap: (() -> Void)?
    
    // MARK: - Views
    
    private lazy var plusImageView: NSImageView = .init(image: .plusVideo)
    private lazy var textLabel = createLabel(
        text: "video".localized,
        font: .systemFont(ofSize: 10, weight: .regular),
        color: .white,
        alignment: .center
    )
    
    // MARK: - Init
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configureUI()
    }
    
    @available(*, unavailable)
    @MainActor required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
}

// MARK: - Private methods

private extension AddVideoButton {
    func configureUI() {
        wantsLayer = true
        layer?.borderColor = .white
        layer?.borderWidth = 1
        layer?.cornerRadius = 12
        
        setupViews()
        setupConstraints()
        setupTargets()
    }
    
    func setupViews() {
        addSubview(plusImageView)
        addSubview(textLabel)
    }
    
    func setupConstraints() {
        plusImageView.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
        }
        
        textLabel.snp.makeConstraints { make in
            make.top.equalTo(plusImageView.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview()
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
