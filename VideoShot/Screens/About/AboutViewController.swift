//
//  AboutViewController.swift
//  FreezeFrame
//
//  Created by admin on 4/10/25.
//

import AppKit

final class AboutViewController: NSViewController {
    
    private lazy var aboutView: AboutView = {
        self.view as! AboutView
    }()
    
    override func loadView() {
        self.view = AboutView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        aboutView.delegate = self
    }
}

// MARK: - AboutViewDelegate

extension AboutViewController: AboutViewDelegate {
    func aboutViewDidTapClose(_ view: AboutView) {
        dismiss(self)
    }
}
