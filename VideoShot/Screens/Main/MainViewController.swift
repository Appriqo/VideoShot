//
//  MainViewController.swift
//  FreezeFrame
//
//  Created by admin on 30/9/25.
//

import Cocoa
import AVKit
import RevenueCat

final class MainViewController: NSViewController {
    
    private var currentURL: URL?
    
    private lazy var mainView: MainView = {
        self.view as! MainView
    }()
    
    override func loadView() {
        self.view = MainView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        mainView.updatePremiumState(PurchaseManager.shared.isFree)
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        mainView.delegate = self
        addObservers()
        RateUsManager.shared.trackSessionStart()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Load & Play Video
    
    func loadMedia(from urls: [URL]) {
        guard !urls.isEmpty else { return }
        
        for url in urls {
            mainView.addVideo(url)
        }
        
        if mainView.hasOnlyOneVideo() {
            mainView.selectFirstVideo()
            playVideo(urls.first!)
        } else if let lastURL = urls.last {
            mainView.selectVideo(lastURL)
            playVideo(lastURL)
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
        mainView.updatePremiumState(PurchaseManager.shared.isFree)
    }
    
    private func playVideo(_ url: URL) {
        if currentURL == url {
            mainView.playerView.player?.seek(to: .zero)
            mainView.playerView.player?.play()
            return
        }
        
        let player = AVPlayer(url: url)
        mainView.playerView.player = player
        player.play()
        currentURL = url
    }
    
    func openDragDrop() {
        mainView.playerView.player?.pause()
        mainView.playerView.player = nil
        if let appDelegate = NSApp.delegate as? AppDelegate {
            appDelegate.showDragDropScreen()
        }
    }
    
    private func getCurrentVideoTime() -> Double {
        let playerView = mainView.playerView
        return CMTimeGetSeconds(playerView.player?.currentItem?.duration ?? .zero)
    }
}

extension MainViewController: MainViewDelegate {
    func mainView(_ sender: MainView?, didSelectCurrentImageAt image: NSImage, images: [NSImage], row: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let multiscreenVC = MultiscreenViewController()
            multiscreenVC.preferredContentSize = Constants.appSize
            multiscreenVC.delegate = self
            multiscreenVC.updateImages(image, images, row: row)
            presentAsSheet(multiscreenVC)
        }
    }
    
    func mainView(_ sender: MainView?, didSelectVideoAt url: URL) {
        playVideo(url)
    }
    
    
    func mainView(_ sender: MainView?, didDeleteVideoAt url: URL) {
        if currentURL == url {
            currentURL = nil
        }
        
        if let nextURL = mainView.nextAvailableVideo(after: url) {
            DispatchQueue.main.async { [weak self] in
                self?.mainView.selectVideo(nextURL)
            }
            playVideo(nextURL)
        } else {
            openDragDrop()
        }
    }
    
    func mainViewDidTapAddVideo(_ sender: MainView?) {
        guard mainView.getCountVides() < 2 || PurchaseManager.shared.isFree else {
            showOffer("addVideo.offer")
            return
        }
        let panel = NSOpenPanel()
        panel.allowedFileTypes = Constants.allowedVideoTypes
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        
        panel.begin { [weak self] result in
            guard let self else { return }
            if result == .OK {
                loadMedia(from: panel.urls)
                
                if let lastURL = panel.urls.last {
                    mainView.selectVideo(lastURL)
                    playVideo(lastURL)
                }
            }
        }
    }
    
    func mainViewDidTapTrash(_ sender: MainView?) {
        let alert = NSAlert()
        alert.messageText = "delete_all_images_confirm".localized
        alert.informativeText = "this_action_cannot_be_undone".localized
        alert.alertStyle = .warning
        alert.addButton(withTitle: "delete".localized)
        alert.addButton(withTitle: "cancel".localized)
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            mainView.clearImages()
        }
    }
    
    func mainViewDidTapExport(_ sender: MainView?) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let exportVC = ExportViewController()
            exportVC.preferredContentSize = NSSize(width: 350, height: 300)
            exportVC.setupExportImages(mainView.getImages())
            presentAsSheet(exportVC)
        }
    }
    
    func mainViewDidTapMultiscreen(_ sender: MainView?) {
        guard PurchaseManager.shared.isFree else {
            showOffer("multiscreenshot.offer")
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let multiscreenVC = MultiscreenSettingsViewController()
            multiscreenVC.preferredContentSize = NSSize(width: 350, height: 480)
            multiscreenVC.setupVideoDuration(getCurrentVideoTime())
            
            multiscreenVC.onPrepareFramesCompletion = { frames in
                guard let player = self.mainView.playerView.player,
                      let currentItem = player.currentItem else {
                    return
                }
                
                let asset = currentItem.asset
                let generator = AVAssetImageGenerator(asset: asset)
                generator.appliesPreferredTrackTransform = true
                generator.requestedTimeToleranceBefore = .zero
                generator.requestedTimeToleranceAfter = .zero
                
                self.extractFrames(using: generator, times: frames, to: self.mainView)
            }
            
            presentAsSheet(multiscreenVC)
        }
    }
    
    func mainViewDidTapScreenshot(_ sender: MainView?) {
        guard let player = mainView.playerView.player,
              let currentItem = player.currentItem else { return }
        
        let currentTime = player.currentTime()
        
        let generator = AVAssetImageGenerator(asset: currentItem.asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero
        
        do {
            let cgImage = try generator.copyCGImage(at: currentTime, actualTime: nil)
            let image = NSImage(cgImage: cgImage, size: NSZeroSize)
            mainView.addImage(image)
        } catch {
            print("Ошибка при создании скриншота: \(error)")
        }
        
        RateUsManager.shared.handleScreenButtonTap()
    }
    
    private func extractFrames(using generator: AVAssetImageGenerator, times: [CMTime], to mainView: MainView) {
        guard !times.isEmpty else { return }
        
        let timeValues = times.map { NSValue(time: $0) }
        var extractedImages: [NSImage] = []
        let dispatchGroup = DispatchGroup()
        
        for timeValue in timeValues {
            dispatchGroup.enter()
            generator.generateCGImagesAsynchronously(forTimes: [timeValue]) { _, cgImage, actualTime, result, error in
                defer { dispatchGroup.leave() }
                
                switch result {
                case .succeeded:
                    if let cgImage = cgImage {
                        let image = NSImage(cgImage: cgImage, size: .zero)
                        extractedImages.append(image)
                    }
                @unknown default:
                    break
                }
            }
        }
        
        // Когда все кадры готовы — открываем MultiscreenVC
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self else { return }
            
            // Текущий кадр — первый (или любой другой)
            let currentImage = extractedImages.first
            
            let multiscreenVC = MultiscreenViewController()
            multiscreenVC.preferredContentSize = Constants.appSize
            multiscreenVC.updateImages(currentImage, extractedImages, row: 0)
            self.presentAsSheet(multiscreenVC)
            RateUsManager.shared.didTriggerMultiScreen()
        }
    }
    
    func mainViewDidTapGear(_ sender: MainView?) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let aboutVC = AboutViewController()
            aboutVC.preferredContentSize = NSSize(width: 350, height: 380)
            presentAsSheet(aboutVC)
        }
    }
    
    func mainViewDidTapPremium(_ sender: MainView?) {
        showOffer("premum.offer")
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

// MARK: - MultiscreenViewControllerDelegate

extension MainViewController: MultiscreenViewControllerDelegate {
    func multiscreenViewController(_ viewController: MultiscreenViewController, didSaveImages images: [NSImage]) {
        mainView.setupImages(images)
    }
    
    func multiscreenViewControllerDidDeleteAll(_ viewController: MultiscreenViewController) {
        mainView.deleteAllImages()
    }
}
