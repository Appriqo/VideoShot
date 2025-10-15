//
//  DragDropViewController.swift
//  FreezeFrame
//
//  Created by admin on 30/9/25.
//

import Cocoa

final class DragDropViewController: NSViewController {

    var onFilesDropped: (([URL]) -> Void)?

    private lazy var dragDropView: DragDropView = {
        let view = DragDropView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        view.onFilesDropped = { [weak self] urls in
            self?.onFilesDropped?(urls)
        }
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
              self,
              selector: #selector(handleSubscriptionUpdate),
              name: .subscriptionsVerified,
              object: nil
          )
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        NotificationCenter.default.removeObserver(self)
    }

    override func loadView() {
        self.view = dragDropView
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
    
    
    @objc private func handleSubscriptionUpdate() {
        guard !PurchaseManager.shared.isFree else {
            return
        }
        print("DEBUG123")
         showOffer("dragDrop")
    }
}
