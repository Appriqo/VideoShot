//
//  ScreenListView.swift
//  FreezeFrame
//
//  Created by admin on 4/10/25.
//

//
//  ScreenListView.swift
//  FreezeFrame
//
//  Created by admin on 4/10/25.
//

import AppKit
import SnapKit

final class ScreenListView: BaseView {
    
    // MARK: - Properties
    
    var imageTapAction: ((Int, NSImage, [NSImage]) -> Void)?
    
    // MARK: - Views
    
    // TODO: - Локализация
    private lazy var plugImageView: NSImageView = .init(image: .plugPhoto)
    private lazy var plugTextLabel = createLabel(
        text: "take_first_screenshot".localized,
        font: .systemFont(ofSize: 14, weight: .medium),
        color: .white,
        alignment: .center
    )
    
    private lazy var scrollView: NSScrollView = {
        let scrollView = NSScrollView()
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.documentView = tableView
        scrollView.contentInsets = .init(top: -16, left: 0, bottom: 0, right: 0)
        scrollView.scrollerInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
        scrollView.automaticallyAdjustsContentInsets = false
        
        return scrollView
    }()
    
    private lazy var tableView: NSTableView = {
        let tableView = CustomTableView()
        tableView.backgroundColor = .clear
        tableView.rowHeight = 80
        tableView.intercellSpacing = NSSize(width: 0, height: 8)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.selectionHighlightStyle = .none
        tableView.headerView = nil
        tableView.gridStyleMask = []
        tableView.style = .plain
        tableView.focusRingType = .none
        
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("imageColumn"))
        column.resizingMask = []
        tableView.addTableColumn(column)
        tableView.sizeToFit()
        
        return tableView
    }()
    
    // MARK: - Data
    
    private var images: [NSImage] = [] {
        didSet {
            updatePlugVisibility()
            tableView.reloadData()
        }
    }
    
    // MARK: - Init
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    func deleteAllImages() {
        images = []
    }
    
    func getImages() -> [NSImage] {
        images
    }
}

// MARK: - Private methods

private extension ScreenListView {
    func configureUI() {
        wantsLayer = true
        layer?.backgroundColor = .clear
        plugTextLabel.lineBreakMode = .byWordWrapping
        setupViews()
        setupConstraints()
        setupContextMenu()
        updatePlugVisibility()
    }
    
    func setupViews() {
        addSubview(scrollView)
        addSubview(plugImageView)
        addSubview(plugTextLabel)
    }
    
    func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        plugImageView.snp.makeConstraints { make in
            make.width.equalTo(120)
            make.height.equalTo(100)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-16)
        }
        
        plugTextLabel.snp.makeConstraints { make in
            make.top.equalTo(plugImageView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
    }
    
    func updatePlugVisibility() {
        let hasImages = !images.isEmpty
        plugImageView.isHidden = hasImages
        plugTextLabel.isHidden = hasImages
        scrollView.isHidden = !hasImages
    }
    
    func setupContextMenu() {
        let menu = NSMenu()
        let deleteItem = NSMenuItem(title: "delete".localized, action: #selector(deleteSelectedRow), keyEquivalent: "")
        deleteItem.target = self
        menu.addItem(deleteItem)
        tableView.menu = menu
    }
    
    // MARK: - Actions
    
    @objc func deleteSelectedRow() {
        let clickedRow = tableView.clickedRow
        guard clickedRow >= 0, clickedRow < images.count else { return }
        images.remove(at: clickedRow)
    }
}

// MARK: - Helpers

extension ScreenListView {
    func addImage(_ image: NSImage) {
        images.insert(image, at: 0)
    }
    
    func clearImages() {
        images = []
    }
    
    func setupImages(_ images: [NSImage]) {
        self.images = images
    }
}

// MARK: - Layout

extension ScreenListView {
    override func layout() {
        super.layout()
        guard let column = tableView.tableColumns.first else { return }
        let contentWidth = scrollView.contentView.bounds.width
        if column.width != contentWidth {
            column.width = contentWidth
        }
    }
}

// MARK: - NSTableViewDataSource & Delegate

extension ScreenListView: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let id = NSUserInterfaceItemIdentifier("ImageCell")
        var container = tableView.makeView(withIdentifier: id, owner: self) as? NSView
        
        if container == nil {
            container = NSView()
            container?.identifier = id
            
            container?.wantsLayer = true
            container?.layer?.cornerRadius = 8
            container?.clipsToBounds = true
            
            let imageView = AspectFillImageView()
            imageView.wantsLayer = true
            imageView.tag = 100
            container?.addSubview(imageView)
            
            imageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        if let imageView = container?.viewWithTag(100) as? NSImageView {
            imageView.image = images[row]
        }
        
        return container
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        imageTapAction?(row, images[row], images)
        return false
    }
}

// MARK: - CustomTableView (разрешает кликать многократно)
private final class CustomTableView: NSTableView {
    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        let row = row(at: point)
        super.mouseDown(with: event)
    }
    
    override func rightMouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        let row = row(at: point)
        if row >= 0 {
            // Removed selection here to prevent selecting the row on right-click
        }
        super.rightMouseDown(with: event)
    }
}
