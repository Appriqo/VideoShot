//
//  ExportView.swift
//  FreezeFrame
//
//  Created by admin on 4/10/25.
//

import AppKit
import SnapKit

protocol ExportViewDelegate: AnyObject {
    func exportViewDidTapClose(_ view: ExportView)
    func exportViewDidTapExport(_ view: ExportView)
    func exportView(_ view: ExportView, didChangeQuality quality: Int)
    func exportView(_ view: ExportView?, didChangeFormat format: ImageFormatType)
    func exportViewDidShowOffer(_ view: ExportView)
}

final class ExportView: BaseView {
    
    // MARK: - Properties
    
    weak var delegate: ExportViewDelegate?
    
    // MARK: - Views
    
    private lazy var closeButton = createButton(with: .xmark)
    private lazy var titleLabel = createLabel(
        text: "export_images".localized,
        font: .systemFont(ofSize: 16, weight: .regular),
        color: .white,
        alignment: .center
    )
    
    private lazy var exportButton: PremiumGradientButton = {
        let button = PremiumGradientButton()
        button.firstColor = .firstGradient
        button.secondColor = .secondGradient
        button.cornerRadius = 12
        button.attributedTitle = button.attributedTitle(with: "export".localized, color: .white)
        return button
    }()
    
    private lazy var formatCategoryLabel = createLabel(
        text: "image_format".localized,
        font: .systemFont(ofSize: 14, weight: .regular),
        color: .white
    )
    
    private lazy var imageFormatContainerView: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.cornerRadius = 8
        view.layer?.borderWidth = 1
        view.layer?.borderColor = NSColor(resource: .strock).cgColor
        view.layer?.backgroundColor = NSColor(resource: .blackBackgound).cgColor
        return view
    }()
    
    private lazy var crownImageView: NSImageView = .init(image: .crown)
    
    private lazy var formatLabel = createLabel(text: "format".localized)
    private lazy var qualifyLabel = createLabel(text: "quality".localized)
    private lazy var percentageQualifyLaber = createLabel(text: "70%", alignment: .right)
    private lazy var imageFormatDivider = createDivider()
    private lazy var qualifySlider: NSSlider = {
        let slider = NSSlider(
            value: 70,
            minValue: 0,
            maxValue: 100,
            target: self,
            action: #selector(sliderValueChanged)
        )
        slider.isContinuous = true
        return slider
    }()
    
    private lazy var formatSelectorView: FormatSelectorView = .init()
    
    private lazy var lockButton: NSButton = {
        let button = NSButton()
        button.isBordered = false
        button.title = ""
        button.wantsLayer = true
        button.layer?.backgroundColor = NSColor.black.cgColor
        button.alphaValue = 0.7
        button.layer?.cornerRadius = 12
        button.target = self
        button.action = #selector(didTapLockButton)
        return button
    }()
    
    
    private lazy var lockCrownImageView: NSImageView = .init(image: .crown)

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
    
    func setupQuality(_ quality: Int) {
        qualifySlider.intValue = Int32(quality)
        percentageQualifyLaber.stringValue = "\(quality)%"
    }
    
    func updatePremiumState(_ isPremium: Bool) {
        crownImageView.isHidden = isPremium
        lockButton.isHidden = isPremium
        lockCrownImageView.isHidden = isPremium
    }
    
    @objc
    private func didTapLockButton() {
        delegate?.exportViewDidShowOffer(self)
    }
}

// MARK: - Private methods

private extension ExportView {
    func configureUI() {
        wantsLayer = true
        
        setupViews()
        setupConstraints()
        setupTargets()
    }
    
    func setupViews() {
        addSubview(backgroundBehindView)
        addSubview(closeButton)
        addSubview(titleLabel)
        addSubview(exportButton)
        addSubview(formatCategoryLabel)
        addSubview(imageFormatContainerView)
        
        addSubview(crownImageView)
        
        addSubview(lockButton)
        
        imageFormatContainerView.addSubview(formatLabel)
        imageFormatContainerView.addSubview(formatSelectorView)
        imageFormatContainerView.addSubview(imageFormatDivider)
        imageFormatContainerView.addSubview(qualifyLabel)
        imageFormatContainerView.addSubview(qualifySlider)
        imageFormatContainerView.addSubview(percentageQualifyLaber)
        
        imageFormatContainerView.addSubview(lockButton)
        imageFormatContainerView.addSubview(lockCrownImageView)
    }
    
    func setupConstraints() {
        backgroundBehindView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { make in
            make.size.equalTo(16)
            make.top.trailing.equalToSuperview().inset(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
        }
        
        exportButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(16)
            make.horizontalEdges.equalToSuperview().inset(8)
            make.height.equalTo(48)
        }
        
        formatCategoryLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        imageFormatContainerView.snp.makeConstraints { make in
            make.top.equalTo(formatCategoryLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview().inset(8)
            make.height.equalTo(140)
        }
        
        formatLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.leading.equalToSuperview().inset(8)
        }
        
        formatSelectorView.snp.makeConstraints { make in
            make.top.equalTo(formatLabel.snp.bottom)
            make.height.equalTo(40)
            make.horizontalEdges.equalToSuperview().inset(8)
        }
        
        imageFormatDivider.snp.makeConstraints { make in
            make.top.equalTo(formatSelectorView.snp.bottom)
            make.height.equalTo(1)
            make.horizontalEdges.equalToSuperview().inset(8)
        }
        
        qualifyLabel.snp.makeConstraints { make in
            make.top.equalTo(imageFormatDivider.snp.bottom).offset(12)
            make.leading.equalToSuperview().inset(8)
        }
        
        crownImageView.snp.makeConstraints { make in
            make.centerY.equalTo(percentageQualifyLaber)
            make.trailing.equalTo(percentageQualifyLaber.snp.leading).offset(-8)
        }
        
        percentageQualifyLaber.snp.makeConstraints { make in
            make.centerY.equalTo(qualifyLabel)
            make.trailing.equalToSuperview().inset(8)
        }
        
        qualifySlider.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(12)
            make.top.equalTo(qualifyLabel.snp.bottom).offset(8)
        }
        
        lockButton.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.trailing.equalTo(formatSelectorView.snp.trailing).offset(-32)
            make.centerY.equalTo(formatSelectorView)
            make.width.equalTo(195)
        }
        
        lockCrownImageView.snp.makeConstraints { make in
            make.center.equalTo(lockButton)
        }
    }
    
    func setupTargets() {
        closeButton.target = self
        exportButton.target = self
        closeButton.action = #selector(didTapCloseButton)
        exportButton.action = #selector(didTapExportButton)
        
        formatSelectorView.onSelectFormat = { [weak self] format in
            self?.delegate?.exportView(self, didChangeFormat: .searchFormat(from: format))
        }
    }
    
    @objc
    func didTapCloseButton() {
        delegate?.exportViewDidTapClose(self)
    }
    
    @objc
    func didTapExportButton() {
        delegate?.exportViewDidTapExport(self)
    }
    
    @objc
    func sliderValueChanged(_ sender: NSSlider) {
        let quality = Int(sender.doubleValue)
        percentageQualifyLaber.stringValue = "\(quality)%"
        delegate?.exportView(self, didChangeQuality: quality)
    }
}
