//
//  MultiscreenViewController.swift
//  FreezeFrame
//
//  Created by admin on 5/10/25.
//

import AppKit

protocol MultiscreenViewControllerDelegate: AnyObject {
    func multiscreenViewControllerDidDeleteAll(_ viewController: MultiscreenViewController)
    func multiscreenViewController(_ viewController: MultiscreenViewController, didSaveImages images: [NSImage])
}

final class MultiscreenViewController: NSViewController {
    
    weak var delegate: MultiscreenViewControllerDelegate?
    
    private var currentImage: NSImage?
    private var images: [NSImage] = []
    
    private lazy var multiscreenView: MultiscreenView = {
        self.view as! MultiscreenView
    }()
    
    override func loadView() {
        self.view = MultiscreenView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        multiscreenView.delegate = self
        addObservers()
        multiscreenView.updatePremiumState(PurchaseManager.shared.isFree)
    }
    
    // MARK: - Helpers
    
    func updateImages(_ currentImage: NSImage?, _ images: [NSImage], row: Int) {
        self.currentImage = currentImage
        self.images = images
        multiscreenView.updateCurrentImage(self.currentImage)
        multiscreenView.updateCollectionImages(images, selectedIndex: row)
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
    
    private func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(subscriptionsVerified),
            name: .subscriptionsVerified,
            object: nil
        )
    }
    
    @objc private func subscriptionsVerified() {
        multiscreenView.updatePremiumState(PurchaseManager.shared.isFree)
    }
}

// MARK: - AboutViewDelegate

extension MultiscreenViewController: MultiscreenViewDelegate {
    func multiScreenViewDidTapExport(_ view: MultiscreenView) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let exportVC = ExportViewController()
            exportVC.preferredContentSize = NSSize(width: 350, height: 300)
            let currentImage = multiscreenView.getCurrentImage() ?? images.first ?? .init()
            exportVC.setupExportImages([currentImage])
            presentAsSheet(exportVC)
        }
    }
    
    func multiScreenViewDidTapExportAll(_ view: MultiscreenView) {
        guard PurchaseManager.shared.isFree else {
            showOffer("exportAll.offer")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let exportVC = ExportViewController()
            exportVC.preferredContentSize = NSSize(width: 350, height: 300)
            exportVC.setupExportImages(images)
            presentAsSheet(exportVC)
        }
    }
    
    func multiscreenView(_ view: MultiscreenView?, DidUpdateImages images: [NSImage]) {
        self.images = images
    }
    
    func multiscreenViewDidTapFilter(_ view: MultiscreenView) {
        guard PurchaseManager.shared.isFree else {
            showOffer("filter.offer")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let filterVC = FilterViewController()
            filterVC.delegate = self
            filterVC.preferredContentSize = NSSize(width: 512, height: 518)
            filterVC.updateCurrentImage(multiscreenView.getCurrentImage())
            presentAsSheet(filterVC)
        }
    }
    
    func multiscreenView(_ view: MultiscreenView, didTapDidSaveImages images: [NSImage]) {
        delegate?.multiscreenViewController(self, didSaveImages: images)
        dismiss(self)
    }
    
    func multiscreenViewDidTapDeleteAll(_ view: MultiscreenView) {
        delegate?.multiscreenViewControllerDidDeleteAll(self)
        dismiss(self)
    }
    
    func multiscreenViewDidTapPremium(_ view: MultiscreenView) {
        showOffer("multiscreen.premium.offer")
    }
    
    func multiscreenViewDidTapBack(_ view: MultiscreenView) {
        dismiss(self)
    }
}

extension MultiscreenViewController: FilterViewControllerDelegate {
    func filterViewControllerDidDismiss(_ viewController: FilterViewController) {}
    
    func filterViewController(_ viewController: FilterViewController, didApply image: NSImage) {
            
        let index = multiscreenView.getIndex()
        print(index)
        
        images[index] = image
           currentImage = image
        DispatchQueue.main.async {
            self.multiscreenView.updateCollectionImages(self.images, selectedIndex: index)
        }
    }
}
