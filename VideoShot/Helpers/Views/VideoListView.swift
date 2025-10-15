//
//  VideoListView.swift
//  FreezeFrame
//
//  Created by admin on 4/10/25.
//

import AppKit
import AVFoundation
import SnapKit

final class VideoListView: BaseView {

    // MARK: - Callbacks

    var onTapAddVideo: (() -> Void)?
    var onSelectVideo: ((URL) -> Void)?
    var onDeleteVideo: ((URL) -> Void)?

    // MARK: - Private Properties

    private var videoURLs: [URL] = []
    private var selectedIndexPath: IndexPath?

    // MARK: - Views

    private lazy var addVideoView: AddVideoButton = .init()

    private lazy var collectionView: NSCollectionView = {
        let layout = NSCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = NSSize(width: 140, height: 80)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8

        let cv = NSCollectionView()
        cv.collectionViewLayout = layout
        cv.backgroundColors = [.clear]
        cv.isSelectable = true
        cv.delegate = self
        cv.dataSource = self
        cv.register(VideoThumbnailItem.self,
                    forItemWithIdentifier: VideoThumbnailItem.identifier)
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
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    // MARK: - Helpers

    func addVideo(_ url: URL) {
        videoURLs.insert(url, at: .zero)
        collectionView.reloadData()
    }

    func removeVideo(_ url: URL) {
        if let index = videoURLs.firstIndex(of: url) {
            videoURLs.remove(at: index)
            collectionView.reloadData()
        }
    }
    
    func nextAvailableVideo(after url: URL) -> URL? {
        guard let index = videoURLs.firstIndex(of: url) else { return nil }
        
        if index + 1 < videoURLs.count {
            return videoURLs[index + 1]
        }
        
        if index > 0 {
            return videoURLs[index - 1]
        }
        
        return nil
    }

    var hasOnlyOneVideo: Bool {
        videoURLs.count == 1
    }

    func selectFirstVideo() {
        guard !videoURLs.isEmpty else { return }
        let firstIndexPath = IndexPath(item: 0, section: 0)
        collectionView.selectItems(at: [firstIndexPath], scrollPosition: [])
        selectedIndexPath = firstIndexPath
    }
    
    func selectVideo(_ url: URL) {
        guard let index = videoURLs.firstIndex(of: url) else { return }
        let indexPath = IndexPath(item: index, section: 0)
        selectedIndexPath = indexPath
        collectionView.selectItems(at: [indexPath], scrollPosition: .centeredHorizontally)
        onSelectVideo?(url)
    }
    
    func getVidesURLs() -> [URL] {
        videoURLs
    }
}

// MARK: - UI Setup

private extension VideoListView {
    func configureUI() {
        wantsLayer = true
        layer?.backgroundColor = .clear

        addSubview(addVideoView)
        addSubview(scrollView)

        addVideoView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.verticalEdges.equalToSuperview()
            make.width.equalTo(65)
        }

        scrollView.snp.makeConstraints { make in
            make.leading.equalTo(addVideoView.snp.trailing).offset(8)
            make.trailing.equalToSuperview()
            make.verticalEdges.equalToSuperview()
        }

        addVideoView.onTap = { [weak self] in
            self?.onTapAddVideo?()
        }
    }
}

// MARK: - NSCollectionViewDataSource

extension VideoListView: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoURLs.count
    }

    func collectionView(_ collectionView: NSCollectionView,
                        itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(
            withIdentifier: VideoThumbnailItem.identifier,
            for: indexPath
        ) as! VideoThumbnailItem

        let url = videoURLs[indexPath.item]
        item.configure(with: url)

        // TODO: - Локализация
        
        item.onDelete = { [weak self] in
            guard let self else { return }
            let alert = NSAlert()
            alert.messageText = "delete_video_confirm".localized
            alert.informativeText = "this_action_cannot_be_undone".localized
            alert.alertStyle = .warning
            alert.addButton(withTitle: "delete".localized)
            alert.addButton(withTitle: "cancel".localized)
            
            if alert.runModal() == .alertFirstButtonReturn {
                onDeleteVideo?(url)
                removeVideo(url)
            }
        }
        
        return item
    }
}

// MARK: - NSCollectionViewDelegate

extension VideoListView: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else { return }
        selectedIndexPath = indexPath
        onSelectVideo?(videoURLs[indexPath.item])
    }
}
