//
//  AudioSheetController.swift
//  ProjectCidadeParaPessoas
//
//  Created by Tamires Mendes da Silva on 13/04/26.
//

import UIKit
import AVFoundation
import ObjectiveC

struct CornerConfiguration {
    let topLeftRadius: CGFloat
    let topRightRadius: CGFloat
    let bottomLeftRadius: CGFloat
    let bottomRightRadius: CGFloat

    static func corners(
        topLeftRadius: CGFloat,
        topRightRadius: CGFloat,
        bottomLeftRadius: CGFloat,
        bottomRightRadius: CGFloat
    ) -> CornerConfiguration {
        CornerConfiguration(
            topLeftRadius: topLeftRadius,
            topRightRadius: topRightRadius,
            bottomLeftRadius: bottomLeftRadius,
            bottomRightRadius: bottomRightRadius
        )
    }
}

private var cornerConfigurationKey: UInt8 = 0

extension UIView {
    var cornerConfiguration: CornerConfiguration? {
        get {
            objc_getAssociatedObject(self, &cornerConfigurationKey) as? CornerConfiguration
        }
        set {
            UIView.installCornerConfigurationSwizzle()
            objc_setAssociatedObject(
                self,
                &cornerConfigurationKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    private static let cornerConfigurationSwizzle: Void = {
        let original = #selector(UIView.layoutSubviews)
        let swizzled = #selector(UIView._cornerConfiguration_layoutSubviews)

        guard let originalMethod = class_getInstanceMethod(UIView.self, original),
              let swizzledMethod = class_getInstanceMethod(UIView.self, swizzled) else { return }

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    static func installCornerConfigurationSwizzle() {
        _ = cornerConfigurationSwizzle
    }

    @objc private func _cornerConfiguration_layoutSubviews() {
        _cornerConfiguration_layoutSubviews()

        guard let configuration = cornerConfiguration else { return }

        let path = UIBezierPath(cornerConfiguration: configuration, in: bounds)
        let mask = CAShapeLayer()
        mask.frame = bounds
        mask.path = path.cgPath
        layer.mask = mask
    }
}

private extension UIBezierPath {
    convenience init(cornerConfiguration: CornerConfiguration, in rect: CGRect) {
        self.init()

        let topLeft = max(0, cornerConfiguration.topLeftRadius)
        let topRight = max(0, cornerConfiguration.topRightRadius)
        let bottomLeft = max(0, cornerConfiguration.bottomLeftRadius)
        let bottomRight = max(0, cornerConfiguration.bottomRightRadius)

        let minX = rect.minX
        let minY = rect.minY
        let maxX = rect.maxX
        let maxY = rect.maxY

        move(to: CGPoint(x: minX + topLeft, y: minY))
        addLine(to: CGPoint(x: maxX - topRight, y: minY))

        if topRight > 0 {
            addArc(
                withCenter: CGPoint(x: maxX - topRight, y: minY + topRight),
                radius: topRight,
                startAngle: -.pi / 2,
                endAngle: 0,
                clockwise: true
            )
        }
        else {
            addLine(to: CGPoint(x: maxX, y: minY))
        }

        addLine(to: CGPoint(x: maxX, y: maxY - bottomRight))

        if bottomRight > 0 {
            addArc(
                withCenter: CGPoint(x: maxX - bottomRight, y: maxY - bottomRight),
                radius: bottomRight,
                startAngle: 0,
                endAngle: .pi / 2,
                clockwise: true
            )
        }
        else {
            addLine(to: CGPoint(x: maxX, y: maxY))
        }

        addLine(to: CGPoint(x: minX + bottomLeft, y: maxY))

        if bottomLeft > 0 {
            addArc(
                withCenter: CGPoint(x: minX + bottomLeft, y: maxY - bottomLeft),
                radius: bottomLeft,
                startAngle: .pi / 2,
                endAngle: .pi,
                clockwise: true
            )
        }
        else {
            addLine(to: CGPoint(x: minX, y: maxY))
        }

        addLine(to: CGPoint(x: minX, y: minY + topLeft))

        if topLeft > 0 {
            addArc(
                withCenter: CGPoint(x: minX + topLeft, y: minY + topLeft),
                radius: topLeft,
                startAngle: .pi,
                endAngle: 3 * .pi / 2,
                clockwise: true
            )
        }
        else {
            addLine(to: CGPoint(x: minX, y: minY))
        }

        close()
    }
}

final class AudioSheetController: UIViewController, AVAudioPlayerDelegate {
    private let audioService = AudioService()
    private var audioPlayer: AVAudioPlayer?
    private var meteringTimer: Timer?
    private var didStartAutoPlay = false

    var audioUrl: String = ""

    let squareBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "OffWhiteColor") ?? .systemBackground
        return view
    }()

    let squareMain: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "AccentColor") ?? .systemOrange
        view.cornerConfiguration = .corners(
            topLeftRadius: 40,
            topRightRadius: 0,
            bottomLeftRadius: 0,
            bottomRightRadius: 120
        )
        view.clipsToBounds = true
        return view
    }()

    let waveformView: AudioWaveformView = {
        let view = AudioWaveformView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let textStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        label.text = "Meu relato"
        label.textColor = UIColor(named: "OffBlackColor") ?? .label
        return label
    }()

    let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .thin)
        label.text = ""
        label.textColor = UIColor(named: "OffBlackColor") ?? .label
        return label
    }()

    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.text = "00:00"
        label.textColor = UIColor(named: "OffBlackColor") ?? .label
        return label
    }()

    let exitButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        var config = UIButton.Configuration.glass()
        let configImage = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        config.image = UIImage(systemName: "xmark", withConfiguration: configImage)?.withTintColor(UIColor(named: "OffBlackColor") ?? .label, renderingMode: .alwaysOriginal)
        config.baseForegroundColor = UIColor(named: "OffBlackColor") ?? .label
        config.baseBackgroundColor = .clear
        config.cornerStyle = .capsule
        config.contentInsets = .zero
        button.backgroundColor = .clear
        button.configuration = config
        return button
    }()

    let playPillView: LiquidGlassButton = {
        let button = LiquidGlassButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let playIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "play.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = UIColor(named: "OffBlackColor") ?? .label
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        audioService.audioInit()
        configureContent()
        prepareAudioPlayer()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playAudioIfNeeded()
    }

    func configure(name: String, date: String, audioUrl: String) {
        nameLabel.text = name
        dateLabel.text = date
        self.audioUrl = audioUrl
        didStartAutoPlay = false

        if isViewLoaded {
            configureContent()
            prepareAudioPlayer()
        }
    }

    private func setupView() {
        view.backgroundColor = UIColor(named: "OffWhiteColor") ?? .systemBackground

        view.addSubview(squareBackground)
        view.addSubview(squareMain)
        view.addSubview(waveformView)
        view.addSubview(textStack)
        view.addSubview(exitButton)
        view.addSubview(playPillView)

        textStack.addArrangedSubview(nameLabel)
        textStack.addArrangedSubview(dateLabel)

        playPillView.addSubview(timeLabel)
        playPillView.addSubview(playIconView)
        playPillView.addTarget(self, action: #selector(playPillTapped), for: .touchUpInside)
        exitButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            squareBackground.topAnchor.constraint(equalTo: view.topAnchor),
            squareBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            squareBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            squareBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            squareMain.topAnchor.constraint(equalTo: squareBackground.topAnchor),
            squareMain.leadingAnchor.constraint(equalTo: squareBackground.leadingAnchor, constant: -1),
            squareMain.trailingAnchor.constraint(equalTo: squareBackground.trailingAnchor),
            squareMain.bottomAnchor.constraint(equalTo: playPillView.topAnchor, constant: -56),

            textStack.topAnchor.constraint(equalTo: squareMain.topAnchor, constant: 30),
            textStack.leadingAnchor.constraint(equalTo: squareMain.leadingAnchor, constant: 32),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: squareMain.trailingAnchor, constant: -24),

            exitButton.topAnchor.constraint(equalTo: squareMain.topAnchor, constant: 22),
            exitButton.trailingAnchor.constraint(equalTo: squareMain.trailingAnchor, constant: -22),
            exitButton.widthAnchor.constraint(equalToConstant: 56),
            exitButton.heightAnchor.constraint(equalToConstant: 56),

            waveformView.centerXAnchor.constraint(equalTo: squareMain.centerXAnchor),
            waveformView.centerYAnchor.constraint(equalTo: squareMain.centerYAnchor),
            waveformView.widthAnchor.constraint(equalToConstant: 240),
            waveformView.heightAnchor.constraint(equalToConstant: 64),

            playPillView.trailingAnchor.constraint(equalTo: squareBackground.trailingAnchor, constant: -24),
            playPillView.bottomAnchor.constraint(equalTo: squareBackground.bottomAnchor, constant: -24),
            playPillView.heightAnchor.constraint(equalToConstant: 40),
            playPillView.widthAnchor.constraint(greaterThanOrEqualToConstant: 124),

            timeLabel.leadingAnchor.constraint(equalTo: playPillView.leadingAnchor, constant: 14),
            timeLabel.centerYAnchor.constraint(equalTo: playPillView.centerYAnchor),
            timeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 56),

            playIconView.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 10),
            playIconView.trailingAnchor.constraint(equalTo: playPillView.trailingAnchor, constant: -12),
            playIconView.centerYAnchor.constraint(equalTo: playPillView.centerYAnchor),
            playIconView.widthAnchor.constraint(equalToConstant: 16),
            playIconView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    private func configureContent() {
        let seed = audioUrl.hashValue == Int.min ? 0 : abs(audioUrl.hashValue)
        waveformView.setAnimationSeed(seed)
        waveformView.setProgress(0)
        waveformView.stopAnimating()
        updatePlayButton(isPlaying: false)
        timeLabel.textColor = UIColor(named: "OffBlackColor") ?? .label
    }

    private func prepareAudioPlayer() {
        meteringTimer?.invalidate()
        meteringTimer = nil
        audioPlayer?.stop()
        audioPlayer = nil

        let resolvedURL = audioService.resolveAudioURL(from: audioUrl)
        guard FileManager.default.fileExists(atPath: resolvedURL.path),
              let player = try? AVAudioPlayer(contentsOf: resolvedURL) else {
            timeLabel.text = "00:00"
            return
        }

        audioPlayer = player
        audioPlayer?.delegate = self
        audioPlayer?.isMeteringEnabled = true
        audioPlayer?.prepareToPlay()
        timeLabel.text = formattedTime(player.duration)
    }

    @objc private func playPillTapped() {
        guard let player = audioPlayer else {
            prepareAudioPlayer()
            guard let preparedPlayer = audioPlayer else { return }
            startPlayback(using: preparedPlayer)
            return
        }

        if player.isPlaying {
            player.pause()
            stopMetering()
            waveformView.stopAnimating()
            updatePlayButton(isPlaying: false)
        }
        else {
            startPlayback(using: player)
        }
    }

    private func startPlayback(using player: AVAudioPlayer) {
        player.play()
        waveformView.startAnimating()
        updatePlayButton(isPlaying: true)
        startMetering()
    }

    private func playAudioIfNeeded() {
        guard !didStartAutoPlay else { return }
        didStartAutoPlay = true

        if audioPlayer == nil {
            prepareAudioPlayer()
        }

        guard let player = audioPlayer else { return }
        startPlayback(using: player)
    }

    private func startMetering() {
        meteringTimer?.invalidate()
        meteringTimer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { [weak self] _ in
            guard let self, let player = self.audioPlayer, player.isPlaying else {
                self?.stopMetering()
                return
            }

            player.updateMeters()
            let avgPower = player.averagePower(forChannel: 0)
            let peakPower = player.peakPower(forChannel: 0)
            let avgNormalized = pow(10, avgPower / 20)
            let peakNormalized = pow(10, peakPower / 20)
            let level = min(1.0, (avgNormalized * 0.75) + (peakNormalized * 0.25))
            self.waveformView.addLevel(Float(level))
        }
    }

    private func stopMetering() {
        meteringTimer?.invalidate()
        meteringTimer = nil
    }

    private func updatePlayButton(isPlaying: Bool) {
        let iconName = isPlaying ? "pause.fill" : "play.fill"
        let configImage = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        let image = UIImage(systemName: iconName, withConfiguration: configImage)?.withTintColor(UIColor(named: "OffBlackColor") ?? .label, renderingMode: .alwaysOriginal)

        playIconView.image = image
    }

    private func formattedTime(_ time: TimeInterval) -> String {
        guard time.isFinite && !time.isNaN else { return "00:00" }
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    @objc private func exitButtonTapped() {
        stopMetering()
        audioPlayer?.stop()
        dismiss(animated: true)
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopMetering()
        waveformView.stopAnimating()
        updatePlayButton(isPlaying: false)
        timeLabel.text = formattedTime(player.duration)
    }
}

#Preview {
    AudioSheetController()
}
