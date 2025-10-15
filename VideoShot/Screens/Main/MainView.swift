//
//  MainView.swift
//  FreezeFrame
//
//  Created by admin on 30/9/25.
//

import AppKit
import SnapKit
import AVKit

protocol MainViewDelegate: AnyObject {
    func mainViewDidTapMultiscreen(_ sender: MainView?)
    func mainViewDidTapScreenshot(_ sender: MainView?)
    func mainViewDidTapGear(_ sender: MainView?)
    func mainViewDidTapPremium(_ sender: MainView?)
    func mainViewDidTapExport(_ sender: MainView?)
    func mainViewDidTapTrash(_ sender: MainView?)
    func mainViewDidTapAddVideo(_ sender: MainView?)
    func mainView(_ sender: MainView?, didSelectVideoAt url: URL)
    func mainView(_ sender: MainView?, didDeleteVideoAt url: URL)
    func mainView(_ sender: MainView?, didSelectCurrentImageAt image: NSImage, images: [NSImage], row: Int)
}

final class MainView: BaseView {
    
    // MARK: - Properties
    
    weak var delegate: MainViewDelegate?
    
    // MARK: - Subviews
    
    lazy var headerView: HeaderView = .init()
    
    let backgroundBlurView: NSVisualEffectView = {
        let blur = NSVisualEffectView()
        blur.blendingMode = .behindWindow
        blur.state = .active
        return blur
    }()
    
    let playerView: AVPlayerView = {
        let player = AVPlayerView()
        player.translatesAutoresizingMaskIntoConstraints = false
        player.controlsStyle = .floating
        player.wantsLayer = true
        player.layer?.cornerRadius = 12
        return player
    }()
    
    private lazy var multiscreenButton: ColoredButton = {
        let button: ColoredButton = .init()
        button.updateButton(.init(resource: .green),
                            text: "multi_snapshot".localized,
                            imageIcon: .init(resource: .multiscreen))
        return button
    }()
    
    private lazy var screenButton: ColoredButton = {
        let button: ColoredButton = .init()
        button.updateButton(.init(resource: .red),
                            text: "snapshot".localized,
                            imageIcon: .init(resource: .shots))
        return button
    }()
    
    private lazy var screenListView: ScreenListView = .init()
    private lazy var videoListView: VideoListView = .init()
    
    // MARK: - Init

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        configureUI()
    }
    
    // MARK: - Layout
    
    override func layout() {
        super.layout()
        updateDividerPath()
    }
    
    // MARK: - Helpers
    
    func getCountVides() -> Int {
        videoListView.getVidesURLs().count
    }
    
    func addImage(_ image: NSImage) {
        screenListView.addImage(image)
    }
    
    func clearImages() {
        screenListView.clearImages()
    }
    
    func addVideo(_ url: URL) {
        videoListView.addVideo(url)
    }
    
    func hasOnlyOneVideo() -> Bool {
        videoListView.hasOnlyOneVideo
    }

    func selectFirstVideo() {
        videoListView.selectFirstVideo()
    }

    func selectVideo(_ url: URL) {
        videoListView.selectVideo(url)
    }
    
    func nextAvailableVideo(after url: URL) -> URL? {
        videoListView.nextAvailableVideo(after: url)
    }
    
    func deleteAllImages() {
        screenListView.deleteAllImages()
    }
    
    func setupImages(_ images: [NSImage] = []) {
        screenListView.setupImages(images)
    }
    
    func getImages() -> [NSImage] {
        screenListView.getImages()
    }
    
    func updatePremiumState(_ isPremium: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.headerView.updatePremiumState(isPremium)
        }
    }
}

// MARK: - Private methods

private extension MainView {
    func configureUI() {
        setupViews()
        setupConstraints()
        setupCallbacks()
    }
    
    func setupViews() {
        addSubview(backgroundBlurView)
        addSubview(headerView)
        addSubview(playerView)
        addSubview(multiscreenButton)
        addSubview(screenButton)
        addSubview(videoListView)
        addSubview(screenListView)
        addSubview(dividerView)
        dividerView.layer?.addSublayer(dividerShapeLayer)
    }
    
    func setupConstraints() {
        backgroundBlurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(28)
        }
        
        playerView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(16)
            make.width.equalTo(640)
            make.height.equalTo(360)
        }
        
        dividerView.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.top.equalTo(headerView.snp.bottom).offset(8)
            make.bottom.equalToSuperview().inset(16)
            make.leading.equalTo(playerView.snp.trailing).offset(16)
        }
        
        multiscreenButton.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.width.equalTo(312)
            make.top.equalTo(playerView.snp.bottom).offset(16)
            make.leading.equalToSuperview().inset(16)
        }
        
        screenButton.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.width.equalTo(312)
            make.top.equalTo(playerView.snp.bottom).offset(16)
            make.leading.equalTo(multiscreenButton.snp.trailing).offset(16)
        }
        
        screenListView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(8)
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
            make.width.equalTo(160)
        }
        
        videoListView.snp.makeConstraints { make in
            make.top.equalTo(screenButton.snp.bottom).offset(16)
            make.leading.equalToSuperview().inset(16)
            make.height.equalTo(80)
            make.trailing.equalTo(dividerView.snp.leading).offset(-16)
        }
    }
    
    func setupCallbacks() {
        headerView.onGearButtonTapped = { [weak self] in
            self?.delegate?.mainViewDidTapGear(self)
        }
        
        headerView.onPremiumButtonTapped = { [weak self] in
            self?.delegate?.mainViewDidTapPremium(self)
        }
        
        headerView.onExportButtonTapped = { [weak self] in
            self?.delegate?.mainViewDidTapExport(self)
        }
        
        headerView.onTrashButtonTapped = { [weak self] in
            self?.delegate?.mainViewDidTapTrash(self)
        }
        
        multiscreenButton.onTap = { [weak self] in
            self?.delegate?.mainViewDidTapMultiscreen(self)
        }
        
        screenButton.onTap = { [weak self] in
            self?.delegate?.mainViewDidTapScreenshot(self)
        }
        
        videoListView.onTapAddVideo = { [weak self] in
            self?.delegate?.mainViewDidTapAddVideo(self)
        }
        
        videoListView.onSelectVideo = { [weak self] url in
            self?.delegate?.mainView(self, didSelectVideoAt: url)
        }
        
        videoListView.onDeleteVideo = { [weak self] url in
            self?.delegate?.mainView(self, didDeleteVideoAt: url)
        }
        
        screenListView.imageTapAction = { [weak self] row, currentImage, images in
            self?.delegate?.mainView(self, didSelectCurrentImageAt: currentImage, images: images, row: row)
        }
    }
}
