//
//  FilterView.swift
//  FreezeFrame
//
//  Created by admin on 6/10/25.
//

import AppKit
import SnapKit

protocol FilterViewDelegate: AnyObject {
    func filterViewDidTapCloseButton(_ view: FilterView)
    func filterView(_ view: FilterView, didApply image: NSImage)
}

final class FilterView: BaseView {
    
    // MARK: - Properties
    
    weak var delegate: FilterViewDelegate?
    
    private var selectedIndexPath: IndexPath?
    private var originalImage: NSImage?
    private var previewImages: [NSImage] = []
    private var filterNames: [String] = [
        "Original",
        "Noir",
        "Sepia",
        "Mono",
        "Fade",
        "Vibrance",
        "Bloom",
        "Chrome",
        "Instant",
        "Process",
        "Transfer",
        "Vignette",
        "Sharpen",
        "Warm",
        "Cold",
        "Contrast",
        "Exposure",
        "Blur"
    ]
    
    // MARK: - Views
    
    private lazy var mainImageView: NSImageView = .init()
    private lazy var closeButton = createButton(with: .xmark)
    
    private lazy var collectionView: NSCollectionView = {
        let layout = NSCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = NSSize(width: 140, height: 100)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8

        let cv = NSCollectionView()
        cv.collectionViewLayout = layout
        cv.backgroundColors = [.clear]
        cv.isSelectable = true
        cv.delegate = self
        cv.dataSource = self
        cv.register(FilterThumbnaillItem.self,
                    forItemWithIdentifier: FilterThumbnaillItem.identifier)
        return cv
    }()

    private lazy var scrollView: NSScrollView = {
        let scroll = NSScrollView()
        scroll.hasHorizontalScroller = true
        scroll.drawsBackground = false
        scroll.documentView = collectionView
        return scroll
    }()
    
    private lazy var applyButton: PremiumGradientButton = {
        let button = PremiumGradientButton()
        button.firstColor = .firstGradient
        button.secondColor = .secondGradient
        button.cornerRadius = 12
        button.attributedTitle = button.attributedTitle(with: "apply.filters".localized, color: .white)
        return button
    }()
    
    private lazy var titleLabel = createLabel(
        text: "filters".localized,
        font: .systemFont(ofSize: 16, weight: .regular),
        color: .white,
        alignment: .center
    )
    
    
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
    
    func updateCurrentImage(_ image: NSImage?) {
        guard let image else { return }
        mainImageView.image = image
        originalImage = image
        generateFilterPreviews(from: image)
    }
}

// MARK: - Private methods

private extension FilterView {
    func configureUI() {
        wantsLayer = true
        mainImageView.wantsLayer = true
        mainImageView.layer?.cornerRadius = 12
        mainImageView.layer?.borderWidth = 1
        mainImageView.layer?.borderColor = NSColor.separatorColor.cgColor
        mainImageView.layer?.backgroundColor = NSColor(resource: .blackBackgound).cgColor
        
        setupViews()
        setupConstraints()
        setupTargets()
    }
    
    func setupViews() {
        addSubview(backgroundBehindView)
        addSubview(closeButton)
        addSubview(applyButton)
        addSubview(mainImageView)
        addSubview(titleLabel)
        addSubview(scrollView)
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
        
        mainImageView.snp.makeConstraints { make in
            make.height.equalTo(270)
            make.width.equalTo(480)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(mainImageView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(100)
        }
        
        applyButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(16)
            make.horizontalEdges.equalToSuperview().inset(8)
            make.height.equalTo(48)
        }
    }
    
    func setupTargets() {
        closeButton.target = self
        applyButton.target = self
        closeButton.action = #selector(didTapCloseButton)
        applyButton.action = #selector(didTapApplyButton)
    }
    
    @objc
    func didTapCloseButton() {
        delegate?.filterViewDidTapCloseButton(self)
    }
    
    @objc
    func didTapApplyButton() {
        AnalyticsManager.shared.logEvent("apply.filter")
        guard let image = mainImageView.image else { return }
        delegate?.filterView(self, didApply: image)
    }
}

// MARK: - Filter generation

private extension FilterView {
    func generateFilterPreviews(from image: NSImage) {
        previewImages.removeAll()
        for name in filterNames {
            if name == "Original" {
                previewImages.append(image)
            } else if let filtered = applyFilter(name, to: image) {
                previewImages.append(filtered)
            }
        }
        collectionView.reloadData()
    }
    
    func applyFilter(_ name: String, to image: NSImage) -> NSImage? {
        switch name {
        case "Noir":
            return image.applyingFilter("CIPhotoEffectNoir")
        case "Sepia":
            return image.applyingFilter("CISepiaTone", parameters: [kCIInputIntensityKey: 0.9])
        case "Mono":
            return image.applyingFilter("CIPhotoEffectMono")
        case "Fade":
            return image.applyingFilter("CIPhotoEffectFade")
        case "Vibrance":
            return image.applyingFilter("CIVibrance", parameters: ["inputAmount": 0.8])
        case "Bloom":
            return image.applyingFilter("CIBloom", parameters: [
                kCIInputIntensityKey: 0.6,
                kCIInputRadiusKey: 5.0
            ])
        case "Chrome":
            return image.applyingFilter("CIPhotoEffectChrome")
        case "Instant":
            return image.applyingFilter("CIPhotoEffectInstant")
        case "Process":
            return image.applyingFilter("CIPhotoEffectProcess")
        case "Transfer":
            return image.applyingFilter("CIPhotoEffectTransfer")
        case "Vignette":
            return image.applyingFilter("CIVignette", parameters: [
                kCIInputIntensityKey: 0.8,
                kCIInputRadiusKey: 1.5
            ])
        case "Sharpen":
            return image.applyingFilter("CISharpenLuminance", parameters: ["inputSharpness": 0.5])
        case "Warm":
            return image.applyingFilter("CITemperatureAndTint", parameters: [
                "inputNeutral": CIVector(x: 6000, y: 0),
                "inputTargetNeutral": CIVector(x: 7500, y: 0)
            ])
        case "Cold":
            return image.applyingFilter("CITemperatureAndTint", parameters: [
                "inputNeutral": CIVector(x: 6000, y: 0),
                "inputTargetNeutral": CIVector(x: 4000, y: 0)
            ])
        case "Contrast":
            return image.applyingFilter("CIColorControls", parameters: [
                kCIInputContrastKey: 1.4,
                kCIInputSaturationKey: 1.1
            ])
        case "Exposure":
            return image.applyingFilter("CIExposureAdjust", parameters: [kCIInputEVKey: 0.8])
        case "Blur":
            return image.applyingFilter("CIGaussianBlur", parameters: [kCIInputRadiusKey: 3.0])
        default:
            return image
        }
    }
}

// MARK: - NSCollectionViewDataSource

extension FilterView: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int { 1 }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        previewImages.count
    }

    func collectionView(_ collectionView: NSCollectionView,
                        itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(
            withIdentifier: FilterThumbnaillItem.identifier,
            for: indexPath
        ) as! FilterThumbnaillItem

        let image = previewImages[indexPath.item]
        let title = filterNames[indexPath.item]
        item.configure(with: image, title: title)
        return item
    }
}

// MARK: - NSCollectionViewDelegate

extension FilterView: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else { return }
        selectedIndexPath = indexPath
        mainImageView.image = previewImages[indexPath.item]
    }
}
