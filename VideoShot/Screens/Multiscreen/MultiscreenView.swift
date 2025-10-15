//
//  MultiscreenView.swift
//  FreezeFrame
//
//  Created by admin on 5/10/25.
//

import AppKit
import SnapKit

protocol MultiscreenViewDelegate: AnyObject {
    func multiscreenViewDidTapBack(_ view: MultiscreenView)
    func multiscreenViewDidTapDeleteAll(_ view: MultiscreenView)
    func multiscreenView(_ view: MultiscreenView, didTapDidSaveImages images: [NSImage])
    func multiscreenViewDidTapPremium(_ view: MultiscreenView)
    func multiscreenViewDidTapFilter(_ view: MultiscreenView)
    func multiScreenViewDidTapExport(_ view: MultiscreenView)
    func multiScreenViewDidTapExportAll(_ view: MultiscreenView)
    func multiscreenView(_ view: MultiscreenView?, DidUpdateImages images: [NSImage])
}

final class MultiscreenView: BaseView {
    
    // MARK: - Properties
    
    weak var delegate: MultiscreenViewDelegate?
    private var originalImage: NSImage?
    private var images: [NSImage] = []
    
    // MARK: - Views
    
    let backgroundBlurView: NSVisualEffectView = {
        let blur = NSVisualEffectView()
        blur.blendingMode = .behindWindow
        blur.state = .active
        return blur
    }()
    
    private lazy var backImageView: NSImageView = .init(image: .backChevron)
    private lazy var backLabel: NSTextField = createLabel(
        text: "back".localized,
        font: .systemFont(ofSize: 14, weight: .regular),
        color: .white
    )
    private lazy var backStakView: NSStackView = {
        let stackView = NSStackView(views: [backImageView, backLabel])
        stackView.spacing = 4
        stackView.orientation = .horizontal
        let gesture = NSClickGestureRecognizer(target: self, action: #selector(backTapped))
        stackView.addGestureRecognizer(gesture)
        return stackView
    }()
    
    private lazy var titleLabel = createLabel(
        text: Constants.appName,
        font: .systemFont(ofSize: 14, weight: .regular),
        color: .white
    )
    
    private lazy var premiumButton: PremiumButton = {
        let button = PremiumButton()
        button.bezelStyle = .regularSquare
        button.isBordered = false
        return button
    }()
    
    private lazy var mainImageView: NSImageView = .init()
    private lazy var panelView: PanelView = .init()
    
    private lazy var collectionView: NSCollectionView = {
        let layout = NSCollectionViewFlowLayout()
        layout.itemSize = NSSize(width: 158, height: 80)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.scrollDirection = .vertical
        
        let cv = NSCollectionView()
        cv.collectionViewLayout = layout
        cv.backgroundColors = [.clear]
        cv.isSelectable = true
        cv.delegate = self
        cv.dataSource = self
        cv.register(PhotoThumbnailItem.self,
                    forItemWithIdentifier: PhotoThumbnailItem.identifier)
        return cv
    }()
    
    private lazy var scrollView: NSScrollView = {
        let scroll = NSScrollView()
        scroll.hasHorizontalScroller = true
        scroll.drawsBackground = false
        scroll.documentView = collectionView
        return scroll
    }()
    
    // MARK: - Init
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configureUI()
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
        setupUI()
    }
    
    // MARK: - Layout
    
    override func layout() {
        super.layout()
        updateDividerPath()
    }
    
    private func setupUI() {
        addSubview(mainImageView)
    }
    
    
    // MARK: - helpers
    
    func updateCurrentImage(_ image: NSImage?) {
        mainImageView.image = image
        originalImage = image
    }
    
    private func applyFilter(_ name: String, to image: NSImage) -> NSImage? {
           switch name {
           case "Noir": return image.applyingFilter("CIPhotoEffectNoir")
           case "Sepia": return image.applyingFilter("CISepiaTone", parameters: [kCIInputIntensityKey: 0.9])
           case "Mono": return image.applyingFilter("CIPhotoEffectMono")
           case "Fade": return image.applyingFilter("CIPhotoEffectFade")
           case "Vibrance": return image.applyingFilter("CIVibrance", parameters: ["inputAmount": 0.8])
           case "Bloom": return image.applyingFilter("CIBloom", parameters: [
               kCIInputIntensityKey: 0.6,
               kCIInputRadiusKey: 5.0
           ])
           case "Chrome": return image.applyingFilter("CIPhotoEffectChrome")
           case "Instant": return image.applyingFilter("CIPhotoEffectInstant")
           case "Process": return image.applyingFilter("CIPhotoEffectProcess")
           default: return image
           }
       }
    
    
    @objc private func resetToDefaults() {
            mainImageView.image = originalImage
        }
    
    func updateCollectionImages(_ images: [NSImage], selectedIndex: Int = 0) {
        self.images = images
        collectionView.reloadData()
        
        guard !images.isEmpty else {
            mainImageView.image = nil
            return
        }
        
        let safeIndex = min(max(selectedIndex, 0), images.count - 1)
        let indexPath = IndexPath(item: safeIndex, section: 0)
        
        updateCurrentImage(images[safeIndex])
        collectionView.selectItems(at: [indexPath], scrollPosition: .centeredVertically)
    }
    
    func getCurrentImage() -> NSImage? {
        mainImageView.image
    }
    
    func getIndex() -> Int {
        return collectionView.selectionIndexPaths.first?.item ?? .zero
    }
}

private extension MultiscreenView {
    func configureUI() {
        wantsLayer = true
        layer?.backgroundColor = .clear
        mainImageView.wantsLayer = true
        mainImageView.layer?.cornerRadius = 12
        mainImageView.layer?.borderWidth = 1
        mainImageView.layer?.borderColor = NSColor.separatorColor.cgColor
        mainImageView.layer?.backgroundColor = NSColor(resource: .blackBackgound).cgColor
        panelView.delegate = self
        
        setupViews()
        setupConstraints()
        setupTargets()
    }
    
    func setupViews() {
        addSubview(backgroundBlurView)
        addSubview(backStakView)
        addSubview(titleLabel)
        addSubview(premiumButton)
        addSubview(mainImageView)
        addSubview(panelView)
        addSubview(scrollView)
        addSubview(dividerView)
        dividerView.layer?.addSublayer(dividerShapeLayer)
    }
    
    func setupConstraints() {
        backgroundBlurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backStakView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().inset(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(8)
        }
        
        premiumButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.height.equalTo(18)
            make.width.equalTo(74)
            make.trailing.equalToSuperview().inset(16)
        }
        
        mainImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(38)
            make.leading.equalToSuperview().inset(16)
            make.width.equalTo(640)
            make.height.equalTo(280)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(mainImageView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }
        
        dividerView.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.top.equalTo(mainImageView.snp.top)
            make.bottom.equalTo(mainImageView.snp.bottom)
            make.leading.equalTo(mainImageView.snp.trailing).offset(16)
        }
        
        panelView.snp.makeConstraints { make in
            make.top.equalTo(dividerView.snp.top)
            make.bottom.equalTo(dividerView.snp.bottom)
            make.leading.equalTo(dividerView.snp.leading).offset(8)
            make.trailing.equalToSuperview().inset(16)
        }
    }
    
    func setupTargets() {
        premiumButton.target = self
        premiumButton.action = #selector(premiumTapped)
    }
    
    // MARK: - Selectors
    
    @objc func backTapped() {
        delegate?.multiscreenViewDidTapBack(self)
    }
    
    @objc func premiumTapped() {
        delegate?.multiscreenViewDidTapPremium(self)
    }
}

// MARK: - Collection Data Source & Delegate

extension MultiscreenView: NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(
            withIdentifier: PhotoThumbnailItem.identifier,
            for: indexPath
        ) as! PhotoThumbnailItem
        
        let image = images[indexPath.item]
        item.configure(with: image)
        
        item.onDelete = { [weak self] in
            guard let self else { return }

            let alert = NSAlert()
            alert.messageText = "delete_image_confirm".localized
            alert.informativeText = "this_action_cannot_be_undone".localized
            alert.alertStyle = .warning
            alert.addButton(withTitle: "delete".localized)
            alert.addButton(withTitle: "cancel".localized)
            
            if alert.runModal() == .alertFirstButtonReturn {
                // сохраняем старый индекс
                let oldIndex = indexPath.item
                self.images.remove(at: oldIndex)
                self.collectionView.reloadData()
                
                guard !self.images.isEmpty else {
                    self.mainImageView.image = nil
                    self.delegate?.multiscreenViewDidTapDeleteAll(self)
                    return
                }

                // выбираем новый индекс (либо предыдущий, либо последний)
                let newIndex = min(oldIndex, self.images.count - 1)
                let newIndexPath = IndexPath(item: newIndex, section: 0)
                self.collectionView.selectItems(at: [newIndexPath], scrollPosition: .centeredVertically)
                self.updateCurrentImage(self.images[newIndex])

                self.delegate?.multiscreenView(self, DidUpdateImages: self.images)
            }
        }
        
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let index = indexPaths.first?.item else { return }
        let image = images[index]
        updateCurrentImage(image)
        collectionView.scrollToItems(at: [IndexPath(item: index, section: 0)], scrollPosition: .centeredVertically)
    }
    
    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        for indexPath in indexPaths {
            if let item = collectionView.item(at: indexPath) as? PhotoThumbnailItem {
                item.view.layer?.borderWidth = 0
            }
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> NSSize {
        let totalSpacing: CGFloat = 8 * 4
        let width = (collectionView.bounds.width - totalSpacing) / 5
        return NSSize(width: width, height: 80)
    }
}

// MARK: - VideoThumbnailItem

extension MultiscreenView: PanelViewDelegate {
    func panelViewDidTapSave(_ panel: PanelView?) {
        delegate?.multiscreenView(self, didTapDidSaveImages: images)
    }
    
    func panelViewDidTapExport(_ panel: PanelView?) {
        delegate?.multiScreenViewDidTapExport(self)
    }
    
    func panelViewDidTapExportAll(_ panel: PanelView?) {
        delegate?.multiScreenViewDidTapExportAll(self)
    }
    
    func panelViewDidTapFlip(_ panel: PanelView?) {
        guard let image = mainImageView.image else { return }
        guard let selectedIndex = collectionView.selectionIndexPaths.first?.item,
              selectedIndex < images.count else { return }

        // Создаём отражённое изображение
        let flipped = NSImage(size: image.size)
        flipped.lockFocus()
        let transform = NSAffineTransform()
        transform.translateX(by: image.size.width, yBy: 0)
        transform.scaleX(by: -1, yBy: 1)
        transform.concat()
        image.draw(at: .zero, from: NSRect(origin: .zero, size: image.size),
                   operation: .sourceOver, fraction: 1)
        flipped.unlockFocus()

        // Обновляем данные
        mainImageView.image = flipped
        images[selectedIndex] = flipped
        updateCurrentImage(flipped)

        // Сохраняем и восстанавливаем выделение
        let indexPath = IndexPath(item: selectedIndex, section: 0)
        collectionView.reloadItems(at: [indexPath])
        DispatchQueue.main.async {
            self.collectionView.selectItems(at: [indexPath], scrollPosition: [])
        }
    }

    func panelViewDidTapRotate(_ panel: PanelView?) {
        guard let image = mainImageView.image else { return }
        guard let selectedIndex = collectionView.selectionIndexPaths.first?.item,
              selectedIndex < images.count else { return }

        let rotated = NSImage(size: NSSize(width: image.size.height, height: image.size.width))
        rotated.lockFocus()
        let transform = NSAffineTransform()
        transform.translateX(by: image.size.height, yBy: 0)
        transform.rotate(byDegrees: 90)
        transform.concat()
        image.draw(at: .zero, from: NSRect(origin: .zero, size: image.size),
                   operation: .sourceOver, fraction: 1)
        rotated.unlockFocus()

        mainImageView.image = rotated
        images[selectedIndex] = rotated
        updateCurrentImage(rotated)

        let indexPath = IndexPath(item: selectedIndex, section: 0)
        collectionView.reloadItems(at: [indexPath])
        DispatchQueue.main.async {
            self.collectionView.selectItems(at: [indexPath], scrollPosition: [])
        }
    }
    
    func panelViewDidTapShare(_ panel: PanelView?) {
        guard let image = mainImageView.image else { return }
        let picker = NSSharingServicePicker(items: [image])
        picker.show(relativeTo: .zero, of: panelView, preferredEdge: .minY)
    }
    
    func panelViewDidTapResetAll(_ panel: PanelView?) {
        let alert = NSAlert()
        alert.messageText = "delete_all_images_confirm".localized
        alert.informativeText = "this_action_cannot_be_undone".localized
        alert.alertStyle = .warning
        alert.addButton(withTitle: "delete_all".localized)
        alert.addButton(withTitle: "cancel".localized)
        
        if let window = self.window {
            alert.beginSheetModal(for: window) { [weak self] response in
                guard let self = self else { return }
                if response == .alertFirstButtonReturn {
                    self.images.removeAll()
                    self.mainImageView.image = nil
                    delegate?.multiscreenViewDidTapDeleteAll(self)
                    self.collectionView.reloadData()
                }
            }
        } else {
            if alert.runModal() == .alertFirstButtonReturn {
                images.removeAll()
                mainImageView.image = nil
                delegate?.multiscreenViewDidTapBack(self)
                collectionView.reloadData()
            }
        }
    }
    
    func panelViewDidTapFilter(_ panel: PanelView?) {
        delegate?.multiscreenViewDidTapFilter(self)
    }
    
    func updatePremiumState(_ isPremium: Bool) {
        premiumButton.isHidden = isPremium
    }
}

// MARK: - Export helpers

private extension MultiscreenView {
    func handleExport(image: NSImage, to url: URL) {
        let ext = url.pathExtension.lowercased()
        var data: Data?

        if ext == "jpg" || ext == "jpeg" {
            data = jpegData(from: image, quality: 0.9)
        } else if ext == "tiff" {
            data = image.tiffRepresentation
        } else {
            data = pngData(from: image)
        }

        guard let imageData = data else {
            presentAlert(title: "export_failed".localized, message: "could_not_create_image_data".localized)
            return
        }

        do {
            try imageData.write(to: url, options: .atomic)
            presentAlert(title: "exported".localized, message: "image_exported_successfully".localized)
        } catch {
            presentAlert(title: "export_failed".localized, message: error.localizedDescription)
        }
    }

    @objc private func applyMono() {
        applyFilter("CIPhotoEffectMono")
    }

    @objc private func applySepia() {
        applyFilter("CISepiaTone", parameters: [kCIInputIntensityKey: 0.8])
    }

    @objc private func applyBlur() {
        applyFilter("CIGaussianBlur", parameters: [kCIInputRadiusKey: 5.0])
    }

    @objc private func applyContrast() {
        applyFilter("CIColorControls", parameters: [kCIInputContrastKey: 1.4])
    }

    private func applyFilter(_ name: String, parameters: [String: Any] = [:]) {
        guard let image = mainImageView.image else { return }
        mainImageView.image = image.applyingFilter(name, parameters: parameters)
    }
    
    func exportAllImages(to directory: URL) {
        delegate?.multiScreenViewDidTapExportAll(self)
    }

    func pngData(from image: NSImage) -> Data? {
        guard let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff) else { return nil }
        return rep.representation(using: .png, properties: [:])
    }

    func jpegData(from image: NSImage, quality: CGFloat) -> Data? {
        guard let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff) else { return nil }
        return rep.representation(using: .jpeg, properties: [.compressionFactor: quality])
    }

    func presentAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .informational

        if let window = self.window {
            alert.beginSheetModal(for: window, completionHandler: nil)
        } else {
            alert.runModal()
        }
    }
}
