//
//  MultiscreenSettingsViewController.swift
//  FreezeFrame
//
//  Created by admin on 5/10/25.
//

import AppKit
import CoreMedia

final class MultiscreenSettingsViewController: NSViewController {
    
    // MARK: - Properties
    
    var onDismissCompletion: (() -> Void)?
    var onPrepareFramesCompletion: (([CMTime]) -> Void)?
    
    private lazy var multiscreenSettingsView: MultiscreenSettingsView = {
        self.view as! MultiscreenSettingsView
    }()
    
    override func loadView() {
        self.view = MultiscreenSettingsView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        multiscreenSettingsView.delegate = self
    }
    
    // MARK: - Helpers
    
    func setupVideoDuration(_ duration: Double) {
        multiscreenSettingsView.setupVideoDuration(duration)
    }
}

// MARK: - MultiscreenSettingsViewDelegate

extension MultiscreenSettingsViewController: MultiscreenSettingsViewDelegate {
    func multiscreenSettingsView(_ view: MultiscreenSettingsView,
                                 didRequestExtractionFor frames: [CMTime]) {
        dismiss(self)
        onPrepareFramesCompletion?(frames)
    }
    
    func multiscreenSettingsViewDidTapCloseButton(_ view: MultiscreenSettingsView) {
        dismiss(self)
    }
}
