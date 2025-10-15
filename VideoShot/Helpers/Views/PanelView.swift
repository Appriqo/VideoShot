//
//  PanelView.swift
//  FreezeFrame
//
//  Created by admin on 5/10/25.
//

import AppKit
import SnapKit

protocol PanelViewDelegate: AnyObject {
    func panelViewDidTapExport(_ panel: PanelView?)
    func panelViewDidTapExportAll(_ panel: PanelView?)
    func panelViewDidTapFlip(_ panel: PanelView?)
    func panelViewDidTapRotate(_ panel: PanelView?)
    func panelViewDidTapShare(_ panel: PanelView?)
    func panelViewDidTapResetAll(_ panel: PanelView?)
    func panelViewDidTapFilter(_ panel: PanelView?)
    func panelViewDidTapSave(_ panel: PanelView?)
}

final class PanelView: BaseView {
    
    weak var delegate: PanelViewDelegate?
    
    private lazy var exportButton: ColoredButton = .init()
    private lazy var exportAllButton: ColoredButton = .init()
    private lazy var shareButton: ColoredButton = .init()
    private lazy var flipButton: ColoredButton = .init()
    private lazy var rotateButton: ColoredButton = .init()
    private lazy var filterButton: ColoredButton = .init()
    private lazy var resetAllButton: ColoredButton = .init()
    private lazy var saveButton: ColoredButton = .init()
    
    private lazy var stackView: NSStackView = {
        let stackView: NSStackView = .init(views: [exportButton, exportAllButton, shareButton, flipButton, rotateButton, filterButton, saveButton, resetAllButton])
        stackView.orientation = .vertical
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // MARK: - Init
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configureUI()
    }
    
    @MainActor required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
}

private extension PanelView {
    func configureUI() {
        wantsLayer = true
        layer?.backgroundColor = .clear
        setupViews()
        setupConstraints()
        setupButtons()
        setupTargets()
    }
    
    func setupViews() {
        addSubview(stackView)
    }
    
    func setupConstraints() {
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setupTargets() {
        exportButton.onTap = { [weak self] in
            self?.delegate?.panelViewDidTapExport(self)
        }
        exportAllButton.onTap = { [weak self] in
            self?.delegate?.panelViewDidTapExportAll(self)
        }
        shareButton.onTap = { [weak self] in
            self?.delegate?.panelViewDidTapShare(self)
        }
        flipButton.onTap = { [weak self] in
            self?.delegate?.panelViewDidTapFlip(self)
        }
        rotateButton.onTap = { [weak self] in
            self?.delegate?.panelViewDidTapRotate(self)
        }
        filterButton.onTap = { [weak self] in
            self?.delegate?.panelViewDidTapFilter(self)
        }
        resetAllButton.onTap = { [weak self] in
            self?.delegate?.panelViewDidTapResetAll(self)
        }
        saveButton.onTap = { [weak self] in
            self?.delegate?.panelViewDidTapSave(self)
        }
    }
    
    func setupButtons() {
        exportButton.updateButton(.blackBackgound, text: "export".localized, imageIcon: .exportOneDocument)
        exportAllButton.updateButton(.blackBackgound, text: "export_all".localized, imageIcon: .exportAll)
        shareButton.updateButton(.blackBackgound, text: "share".localized, imageIcon: .export)
        flipButton.updateButton(.blackBackgound, text: "flip".localized, imageIcon: .flip)
        rotateButton.updateButton(.blackBackgound, text: "rotate".localized, imageIcon: .rotate)
        filterButton.updateButton(.blackBackgound, text: "filters".localized, imageIcon: .filter)
        resetAllButton.updateButton(.init(resource: .red), text: "delete_all".localized, imageIcon: .trashFiles)
        saveButton.updateButton(.init(resource: .green), text: "save".localized, imageIcon: .flip)
        
        exportButton.updateBorderButton(.separatorColor)
        exportAllButton.updateBorderButton(.separatorColor)
        shareButton.updateBorderButton(.separatorColor)
        flipButton.updateBorderButton(.separatorColor)
        rotateButton.updateBorderButton(.separatorColor)
        filterButton.updateBorderButton(.separatorColor)
        resetAllButton.updateBorderButton(.separatorColor)
        saveButton.updateBorderButton(.separatorColor)
        
        
        exportButton.updateStyle(textColor: .white, font: .systemFont(ofSize: 14, weight: .medium))
        exportAllButton.updateStyle(textColor: .white, font: .systemFont(ofSize: 14, weight: .medium))
        shareButton.updateStyle(textColor: .white, font: .systemFont(ofSize: 14, weight: .medium))
        flipButton.updateStyle(textColor: .white, font: .systemFont(ofSize: 14, weight: .medium))
        rotateButton.updateStyle(textColor: .white, font: .systemFont(ofSize: 14, weight: .medium))
        filterButton.updateStyle(textColor: .white, font: .systemFont(ofSize: 14, weight: .medium))
        resetAllButton.updateStyle(textColor: .white, font: .systemFont(ofSize: 14, weight: .medium))
        saveButton.updateStyle(textColor: .white, font: .systemFont(ofSize: 16, weight: .medium))
    }
}
