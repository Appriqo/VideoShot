//
//  MultiscreenSettingsView.swift
//  FreezeFrame
//
//  Created by admin on 5/10/25.
//

import AppKit
import SnapKit
import CoreMedia

protocol MultiscreenSettingsViewDelegate: AnyObject {
    func multiscreenSettingsViewDidTapCloseButton(_ view: MultiscreenSettingsView)
    func multiscreenSettingsView(
        _ view: MultiscreenSettingsView,
        didRequestExtractionFor frames: [CMTime]
    )
}

final class MultiscreenSettingsView: BaseView {
    
    // MARK: - Properties
    
    weak var delegate: MultiscreenSettingsViewDelegate?
    
    private var videoDuration: Double = .zero
    private var isExtractAllFramesEnabled = false
    
    // MARK: - Views
    
    private lazy var closeButton = createButton(with: .xmark)
    
    private lazy var titleLabel = createLabel(
        text: "multiple_frames".localized,
        font: .systemFont(ofSize: 16, weight: .regular),
        color: .white,
        alignment: .center
    )
    
    private lazy var extractionLabel = createLabel(
        text: "extraction_settings".localized,
        font: .systemFont(ofSize: 14, weight: .regular),
        color: .white
    )
    
    private lazy var extractionContainerView: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.cornerRadius = 8
        view.layer?.borderWidth = 1
        view.layer?.borderColor = NSColor(resource: .strock).cgColor
        view.layer?.backgroundColor = NSColor(resource: .blackBackgound).cgColor
        return view
    }()
    
    private lazy var intervalTitleLabel = createLabel(text: "interval_between_frames".localized)
    private lazy var intervalTimerLabel = createLabel(text: "1\("seconds_abbr".localized)", alignment: .right)
    private lazy var intervalDivider = createDivider()
    private lazy var intervalSlider: NSSlider = {
        let slider = NSSlider(
            value: 1,
            minValue: 1,
            maxValue: 120,
            target: self,
            action: #selector(intervalValueChanged)
        )
        slider.isContinuous = true
        return slider
    }()
    
    private lazy var numberFramesTitleLabel = createLabel(text: "number_of_frames".localized)
    private lazy var numberResultLabel = createLabel(text: "10", alignment: .right)
    private lazy var numberSlider: NSSlider = {
        let slider = NSSlider(
            value: 10,
            minValue: 1,
            maxValue: 120,
            target: self,
            action: #selector(numberValueChanged)
        )
        slider.isContinuous = true
        return slider
    }()
    
    private lazy var numberDivider = createDivider()
    
    private lazy var extractButton: PremiumGradientButton = {
        let button = PremiumGradientButton()
        button.firstColor = .firstGradient
        button.secondColor = .secondGradient
        button.cornerRadius = 12
        button.attributedTitle = button.attributedTitle(with: "extract".localized, color: .white)
        return button
    }()
    
    private lazy var optionalFeaturesTitleLabel = createLabel(text: "optional_features".localized, color: .white)
    private lazy var extractAllFramesTitleLabel = createLabel(text: "extract_all_frames".localized)
    
    private lazy var framesSwitcher: NSSwitch = {
        let switcher = NSSwitch()
        switcher.target = self
        switcher.action = #selector(framesSwitchChanged)
        return switcher
    }()
    
    private lazy var summaryContainerView: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.cornerRadius = 8
        view.layer?.borderWidth = 1
        view.layer?.borderColor = NSColor(resource: .strock).cgColor
        view.layer?.backgroundColor = NSColor(resource: .lightDark).cgColor
        return view
    }()
    
    private lazy var extractionSummaryTitleLabel = createLabel(text: "extraction_summary".localized, color: .white)
    private lazy var videoDurationLabel = createLabel(text: "video_duration".localized)
    private lazy var durationResultLabel = createLabel(text: "--:--")
    private lazy var estimatedFramesLabel = createLabel(text: "estimated_frames".localized)
    private lazy var framesResultLabel = createLabel(text: "10")
    private lazy var timePerFramesLabel = createLabel(text: "time_per_frame".localized)
    private lazy var timeFramesResultLabel = createLabel(text: "1\("seconds_abbr".localized)")
    
    
    // MARK: - Init
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configureUI()
    }
    
    @MainActor required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    // MARK: - Helpers
    
    func setupVideoDuration(_ duration: Double) {
        videoDuration = duration
        guard !duration.isNaN && duration > 0 else {
            durationResultLabel.stringValue = "--:--"
            return
        }
        
        let totalSeconds = Int(duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        let timeString: String = hours > 0
        ? String(format: "%d:%02d:%02d", hours, minutes, seconds)
        : String(format: "%02d:%02d", minutes, seconds)
        
        durationResultLabel.stringValue = timeString
        recalculateFrames()
    }
}

// MARK: - Private methods

private extension MultiscreenSettingsView {
    func configureUI() {
        wantsLayer = true
        
        setupViews()
        setupConstraints()
        setupTargets()
    }
    
    func setupViews() {
        addSubview(backgroundBehindView)
        addSubview(closeButton)
        addSubview(titleLabel)
        addSubview(extractionLabel)
        addSubview(extractionContainerView)
        addSubview(extractButton)
        
        extractionContainerView.addSubview(intervalTitleLabel)
        extractionContainerView.addSubview(intervalTimerLabel)
        extractionContainerView.addSubview(intervalDivider)
        extractionContainerView.addSubview(intervalSlider)
        extractionContainerView.addSubview(numberFramesTitleLabel)
        extractionContainerView.addSubview(numberResultLabel)
        extractionContainerView.addSubview(numberSlider)
        extractionContainerView.addSubview(numberDivider)
        
        extractionContainerView.addSubview(optionalFeaturesTitleLabel)
        extractionContainerView.addSubview(extractAllFramesTitleLabel)
        extractionContainerView.addSubview(framesSwitcher)
        
        extractionContainerView.addSubview(summaryContainerView)
        
        summaryContainerView.addSubview(extractionSummaryTitleLabel)
        summaryContainerView.addSubview(videoDurationLabel)
        summaryContainerView.addSubview(durationResultLabel)
        summaryContainerView.addSubview(estimatedFramesLabel)
        summaryContainerView.addSubview(framesResultLabel)
        summaryContainerView.addSubview(timePerFramesLabel)
        summaryContainerView.addSubview(timeFramesResultLabel)
    }
    
    func setupConstraints() {
        backgroundBehindView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { make in
            make.size.equalTo(16)
            make.top.trailing.equalToSuperview().inset(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.centerX.equalToSuperview()
        }
        
        extractButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(16)
            make.horizontalEdges.equalToSuperview().inset(8)
            make.height.equalTo(48)
        }
        
        extractionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        extractionContainerView.snp.makeConstraints { make in
            make.top.equalTo(extractionLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview().inset(8)
            make.bottom.equalTo(extractButton.snp.top).offset(-16)
        }
        
        intervalTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().inset(8)
        }
        
        intervalTimerLabel.snp.makeConstraints { make in
            make.centerY.equalTo(intervalTitleLabel)
            make.trailing.equalToSuperview().inset(8)
        }
        
        intervalSlider.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(12)
            make.top.equalTo(intervalTitleLabel.snp.bottom).offset(8)
        }
        
        intervalDivider.snp.makeConstraints { make in
            make.top.equalTo(intervalSlider.snp.bottom).offset(8)
            make.height.equalTo(1)
            make.horizontalEdges.equalToSuperview().inset(8)
        }
        
        numberFramesTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(intervalDivider.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(8)
        }
        
        numberResultLabel.snp.makeConstraints { make in
            make.centerY.equalTo(numberFramesTitleLabel)
            make.trailing.equalToSuperview().inset(8)
        }
        
        numberSlider.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(12)
            make.top.equalTo(numberFramesTitleLabel.snp.bottom).offset(8)
        }
        
        numberDivider.snp.makeConstraints { make in
            make.top.equalTo(numberSlider.snp.bottom).offset(8)
            make.height.equalTo(1)
            make.horizontalEdges.equalToSuperview().inset(8)
        }
        
        optionalFeaturesTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(numberDivider.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(8)
        }
        
        framesSwitcher.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.top.equalTo(optionalFeaturesTitleLabel.snp.bottom).offset(4)
        }
        
        extractAllFramesTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(framesSwitcher)
            make.leading.equalToSuperview().inset(8)
        }
        
        summaryContainerView.snp.makeConstraints { make in
            make.top.equalTo(framesSwitcher.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(12)
        }
        
        extractionSummaryTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.leading.equalToSuperview().inset(8)
        }
        
        videoDurationLabel.snp.makeConstraints { make in
            make.top.equalTo(extractionSummaryTitleLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().inset(8)
        }
        
        durationResultLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalTo(videoDurationLabel)
        }
        
        estimatedFramesLabel.snp.makeConstraints { make in
            make.top.equalTo(videoDurationLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(8)
        }
        
        framesResultLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalTo(estimatedFramesLabel)
        }
        
        timePerFramesLabel.snp.makeConstraints { make in
            make.top.equalTo(estimatedFramesLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(8)
        }
        
        timeFramesResultLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalTo(timePerFramesLabel)
        }
    }
    
    func setupTargets() {
        closeButton.target = self
        extractButton.target = self
        closeButton.action = #selector(didTapCloseButton)
        extractButton.action = #selector(didTapExtractButton)
    }
    
    func recalculateFrames() {
        guard videoDuration > 0 else {
            framesResultLabel.stringValue = "0"
            extractButton.isEnabled = false
            extractButton.attributedTitle = extractButton.attributedTitle(with: "extract".localized,
                                                                          color: .white)
            return
        }
        
        let interval = intervalSlider.doubleValue
        var frameCount: Int = 0
        
        if isExtractAllFramesEnabled {
            frameCount = Int(videoDuration / interval)
        } else {
            frameCount = min(Int(numberSlider.doubleValue), Int(videoDuration / interval))
        }
        
        framesResultLabel.stringValue = "\(frameCount)"
        
        if frameCount > 0 {
            extractButton.isEnabled = true
            extractButton.attributedTitle = extractButton.attributedTitle(with: "\("extract".localized) \(frameCount)", color: .white)
        } else {
            extractButton.isEnabled = false
            extractButton.attributedTitle = extractButton.attributedTitle(with: "extract".localized, color: .white)
        }
    }
    
    func calculateFrameTimes() -> [CMTime] {
        guard videoDuration > 0 else { return [] }
        
        let interval = intervalSlider.doubleValue
        var times: [CMTime] = []
        
        if isExtractAllFramesEnabled {
            var time: Double = 0
            while time <= videoDuration {
                times.append(CMTime(seconds: time, preferredTimescale: 600))
                time += interval
            }
        } else {
            let framesCount = Int(numberSlider.doubleValue)
            let totalFramesDuration = Double(framesCount - 1) * interval
            let effectiveDuration = min(videoDuration, totalFramesDuration)
            
            var time: Double = 0
            for _ in 0..<framesCount {
                if time <= effectiveDuration {
                    times.append(CMTime(seconds: time, preferredTimescale: 600))
                }
                time += interval
            }
        }
        
        return times
    }
    
    // MARK: - Actions
    
    @objc
    func framesSwitchChanged(_ sender: NSSwitch) {
        isExtractAllFramesEnabled = sender.state == .on
        
        numberSlider.isHidden = isExtractAllFramesEnabled
        numberResultLabel.stringValue = isExtractAllFramesEnabled ? "all".localized : "\(Int(numberSlider.doubleValue))"
        
        recalculateFrames()
    }
    
    @objc
    func didTapCloseButton() {
        delegate?.multiscreenSettingsViewDidTapCloseButton(self)
    }
    
    @objc
    func didTapExtractButton() {
        let frames = calculateFrameTimes()
        delegate?.multiscreenSettingsView(self, didRequestExtractionFor: frames)
    }
    
    @objc
    func intervalValueChanged(_ sender: NSSlider) {
        intervalTimerLabel.stringValue = "\(Int(sender.doubleValue))\("seconds_abbr".localized)"
        timeFramesResultLabel.stringValue = "\(Int(sender.doubleValue))\("seconds_abbr".localized)"
        recalculateFrames()
    }
    
    @objc
    func numberValueChanged(_ sender: NSSlider) {
        numberResultLabel.stringValue = "\(Int(sender.doubleValue))"
        recalculateFrames()
    }
}
