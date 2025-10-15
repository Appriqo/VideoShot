//
//  ExportViewController.swift
//  FreezeFrame
//
//  Created by admin on 4/10/25.
//

import AppKit

enum ImageFormatType {
    case jpg
    case png
    case heic
    case tiff
    case gif
    case pdf
    
    static func searchFormat(from string: String) -> ImageFormatType {
        if string.lowercased() == "heic" {
            .heic
        } else if string.lowercased() == "png" {
            .png
        } else if string.lowercased() == "tiff" {
            .tiff
        } else if string.lowercased() == "gif" {
            .gif
        } else if string.lowercased() == "pdf" {
            .pdf
        } else {
            .jpg
        }
    }
}

import AppKit

final class ExportViewController: NSViewController {
    
    private var images: [NSImage] = []
    private var quality: Int = 70
    private var selectedFormat: ImageFormatType = .jpg
    
    private let exportManager: ImageExportManager
    
    private lazy var exportView: ExportView = {
        self.view as! ExportView
    }()
    
    override func loadView() {
        self.view = ExportView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        exportView.delegate = self
        addObservers()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        exportView.updatePremiumState(PurchaseManager.shared.isFree)
    }
    
    init(with exportManager: ImageExportManager = ImageExportManager()) {
        self.exportManager = exportManager
        super.init(nibName: nil, bundle: nil)
        self.exportManager.delegate = self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupExportImages(_ images: [NSImage]) {
        self.images = images
    }
    
    private func showOffer(_ place: String) {
        AnalyticsManager.shared.logEvent(place)
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let offerVC = OfferViewController()
            offerVC.preferredContentSize = NSSize(width: 700, height: 500)
            presentAsSheet(offerVC)
        }
    }
}

// MARK: - ExportViewDelegate

extension ExportViewController: ExportViewDelegate {
    func exportViewDidShowOffer(_ view: ExportView) {
        showOffer("format.offer")
    }
    
    func exportView(_ view: ExportView?, didChangeFormat format: ImageFormatType) {
        selectedFormat = format
    }
    
    func exportViewDidTapExport(_ view: ExportView) {
        exportManager.exportImages(
            images,
            format: selectedFormat,
            quality: quality
        )
    }
    
    func exportView(_ view: ExportView, didChangeQuality quality: Int) {
        self.quality = quality
        if !PurchaseManager.shared.isFree, quality > 70  {
            self.quality = 70
            view.setupQuality(70)
            showOffer()
        }
    }
    
    func exportViewDidTapClose(_ view: ExportView) {
        dismiss(self)
    }
}

// MARK: - ImageExportManagerDelegate

extension ExportViewController: ImageExportManagerDelegate {
    func exportDidStart() {
        print("Экспорт начат")
    }
    
    func exportDidProgress(_ current: Int, total: Int) {
        print("Прогресс: \(current)/\(total)")
    }
    
    func exportDidComplete(urls: [URL]) {
        showSuccessAlert(count: urls.count)
        dismiss(self)
    }
    
    func exportDidFail(error: ImageExportError) {
        showErrorAlert(error: error)
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(subscriptionsVerified),
            name: .subscriptionsVerified,
            object: nil
        )
    }
    
    private func showSuccessAlert(count: Int) {
        let alert = NSAlert()
        alert.messageText = "export.copleted".localized
        alert.informativeText = String(format: "exported.images".localized, String(count))
        alert.addButton(withTitle: "ok".localized)
        alert.runModal()
    }
    
    private func showErrorAlert(error: ImageExportError) {
        let alert = NSAlert()
        alert.messageText = "export.error".localized
        alert.informativeText = error.localizedDescription
        alert.addButton(withTitle: "ok".localized)
        alert.runModal()
    }
    
    private func showOffer() {
        AnalyticsManager.shared.logEvent("quality.offer")
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let offerVC = OfferViewController()
            offerVC.preferredContentSize = NSSize(width: 700, height: 500)
            presentAsSheet(offerVC)
        }
    }
    
    @objc
    private func subscriptionsVerified() {
        DispatchQueue.main.async { [weak self] in
            self?.exportView.updatePremiumState(PurchaseManager.shared.isFree)
        }
    }
}
