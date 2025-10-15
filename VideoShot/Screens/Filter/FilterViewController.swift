//
//  FilterViewController.swift
//  FreezeFrame
//
//  Created by admin on 6/10/25.
//

import AppKit

protocol FilterViewControllerDelegate: AnyObject {
    func filterViewControllerDidDismiss(_ viewController: FilterViewController)
    func filterViewController(_ viewController: FilterViewController, didApply image: NSImage)
}

final class FilterViewController: NSViewController {
    
    // MARK: - Properties
    
    weak var delegate: FilterViewControllerDelegate?
    
    private lazy var filterView: FilterView = {
        self.view as! FilterView
    }()
    
    override func loadView() {
        self.view = FilterView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        filterView.delegate = self
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
    }
    
    // MARK: - Helpers
    
    func updateCurrentImage(_ image: NSImage?) {
        filterView.updateCurrentImage(image)
    }
}

// MARK: - MultiscreenSettingsViewDelegate

extension FilterViewController: FilterViewDelegate {
    func filterView(_ view: FilterView, didApply image: NSImage) {
        delegate?.filterViewController(self, didApply: image)
        dismiss(self)
    }
    
    func filterViewDidTapCloseButton(_ view: FilterView) {
        dismiss(self)
        delegate?.filterViewControllerDidDismiss(self)
    }
}
