//
//  AudioSheetController.swift
//  ProjectCidadeParaPessoas
//
//  Created by Tamires Mendes da Silva on 13/04/26.
//

import UIKit
import AVFoundation

class AudioSheetController: UIViewController, AVAudioPlayerDelegate {
    var audioService = AudioService()
    var audioPlayer: AVAudioPlayer?
    var playbackUpdateTimer: Timer?
    var audioUrl: String = ""
    var didStartAutoPlay = false
    var card: Card?

    var squareBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "OffWhiteColor") ?? .systemBackground
        return view
    }()

    var squareMain: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "AccentColor") ?? .systemOrange
        view.cornerConfiguration = .corners(
            topLeftRadius: .fixed(40),
            topRightRadius: .fixed(0),
            bottomLeftRadius: .fixed(0),
            bottomRightRadius: .fixed(120)
        )
        view.clipsToBounds = true
        return view
    }()

    var waveformView: AudioWaveformView = {
        let view = AudioWaveformView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var textStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()

    var timerView: PlaybackTimerView = {
        let view = PlaybackTimerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        label.text = "Meu relato"
        label.textColor = UIColor(named: "OffBlackColor") ?? .label
        return label
    }()

    var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .thin)
        label.text = ""
        label.textColor = UIColor(named: "OffBlackColor") ?? .label
        return label
    }()

    var exitButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        var config = UIButton.Configuration.glass()
        let configImage = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        config.image = UIImage(systemName: "square.and.arrow.up", withConfiguration: configImage)?.withTintColor(UIColor(named: "OffBlackColor") ?? .label, renderingMode: .alwaysOriginal)
        config.baseForegroundColor = UIColor(named: "OffBlackColor") ?? .label
        config.baseBackgroundColor = .clear
        config.cornerStyle = .capsule
        config.contentInsets = .zero
        button.backgroundColor = .clear
        button.configuration = config
        return button
    }()

    var playPillView: LiquidGlassButton = {
        let button = LiquidGlassButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var playIconView: UIImageView = {
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
        prepareAudioPlayer()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playAudioIfNeeded()
    }

    func configure(name: String, date: String, audioUrl: String, cardObject: Card) {
        nameLabel.text = name
        dateLabel.text = date
        self.audioUrl = audioUrl
        self.card = cardObject
        didStartAutoPlay = false

        if isViewLoaded {
            prepareAudioPlayer()
        }
    }
    
    @objc func shareCard() {
        
        let audioName = card!.audio ?? ""
        let audioURL = audioService.resolveAudioURL(from: audioName)
        let audioData = try? Data(contentsOf: audioURL)

        let person = Person(
            name: card!.name ?? "Untitled Audio",
            id: card!.id ?? UUID(),
            lat: card!.lat,
            longe: card!.longe,
            audio: audioName,
            compartilhado: true,
            audioData: audioData,
            date: card!.date ?? Date()
        )
        let personObject = PersonObject(person: person)

        let activityController = UIActivityViewController(
            activityItems: [personObject],
            applicationActivities: nil
        )
        
        present(activityController, animated: true)
    }

    func setupView() {
        view.backgroundColor = UIColor(named: "OffWhiteColor") ?? .systemBackground

        view.addSubview(squareBackground)
        view.addSubview(squareMain)
        view.addSubview(waveformView)
        view.addSubview(textStack)
        view.addSubview(exitButton)
        view.addSubview(playPillView)

        textStack.addArrangedSubview(nameLabel)
        textStack.addArrangedSubview(dateLabel)

        playPillView.addSubview(timerView)
        playPillView.addSubview(playIconView)
        playPillView.addTarget(self, action: #selector(playPillTapped), for: .touchUpInside)
        exitButton.addTarget(self, action: #selector(shareCard), for: .touchUpInside)

        NSLayoutConstraint.activate([
            squareBackground.topAnchor.constraint(equalTo: view.topAnchor),
            squareBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            squareBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            squareBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            squareMain.topAnchor.constraint(equalTo: squareBackground.topAnchor),
            squareMain.leadingAnchor.constraint(equalTo: squareBackground.leadingAnchor),
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

            timerView.leadingAnchor.constraint(equalTo: playPillView.leadingAnchor, constant: 14),
            timerView.centerYAnchor.constraint(equalTo: playPillView.centerYAnchor),
            timerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),

            playIconView.leadingAnchor.constraint(equalTo: timerView.trailingAnchor, constant: 10),
            playIconView.trailingAnchor.constraint(equalTo: playPillView.trailingAnchor, constant: -12),
            playIconView.centerYAnchor.constraint(equalTo: playPillView.centerYAnchor),
            playIconView.widthAnchor.constraint(equalToConstant: 16),
            playIconView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    
    
    func prepareAudioPlayer() {
        stopPlaybackUI()
        stopPlaybackUpdates()
        audioPlayer?.stop()
        audioPlayer = nil

        let resolvedURL = audioService.resolveAudioURL(from: audioUrl)
        guard FileManager.default.fileExists(atPath: resolvedURL.path),
              let player = try? AVAudioPlayer(contentsOf: resolvedURL) else {
            timerView.stop()
            return
        }

        audioPlayer = player
        audioPlayer?.delegate = self
        audioPlayer?.isMeteringEnabled = true
        audioPlayer?.prepareToPlay()
        updatePlayButton(isPlaying: false)
        let seed = audioUrl.hashValue == Int.min ? 0 : abs(audioUrl.hashValue)
        waveformView.setAnimationSeed(seed)
        waveformView.setProgress(0)
        waveformView.stopAnimating()
        timerView.stop()
    }

    func playAudioIfNeeded() {
        guard !didStartAutoPlay else { return }
        didStartAutoPlay = true
        playAudio()
    }

    @objc func playPillTapped() {
        guard let player = audioPlayer else {
            prepareAudioPlayer()
            playAudio()
            return
        }

        if player.isPlaying {
            player.pause()
            stopPlaybackUpdates()
            waveformView.stopAnimating()
            updatePlayButton(isPlaying: false)
        }
        else {
            playAudio()
        }
    }

    func playAudio() {
        guard let player = audioPlayer else {
            prepareAudioPlayer()
            guard let player = audioPlayer else { return }
            player.play()
            waveformView.startAnimating()
            updatePlayButton(isPlaying: true)
            if timerView.player == nil {
                timerView.onProgressChanged = { [weak self] progress in
                    self?.waveformView.setProgress(progress)
                }
                timerView.start(with: player)
            }
            startPlaybackUpdates()
            return
        }

        if player.currentTime >= player.duration {
            player.currentTime = 0
        }

        player.play()
        waveformView.startAnimating()
        updatePlayButton(isPlaying: true)
        if timerView.player == nil {
            timerView.onProgressChanged = { [weak self] progress in
                self?.waveformView.setProgress(progress)
            }
            timerView.start(with: player)
        }
        startPlaybackUpdates()
    }

    func startPlaybackUpdates() {
        stopPlaybackUpdates()
        playbackUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { [weak self] _ in
            guard let self, let player = self.audioPlayer, player.isPlaying else {
                self?.stopPlaybackUpdates()
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
        RunLoop.main.add(playbackUpdateTimer!, forMode: .common)
    }

    func stopPlaybackUpdates() {
        playbackUpdateTimer?.invalidate()
        playbackUpdateTimer = nil
    }

    func updatePlayButton(isPlaying: Bool) {
        let iconName = isPlaying ? "pause.fill" : "play.fill"
        let configImage = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        playIconView.image = UIImage(systemName: iconName, withConfiguration: configImage)?.withTintColor(UIColor(named: "OffBlackColor") ?? .label, renderingMode: .alwaysOriginal)
    }

    func stopPlaybackUI() {
        timerView.stop()
        waveformView.stopAnimating()
        updatePlayButton(isPlaying: false)
    }

    @objc func exitButtonTapped() {
        stopPlaybackUI()
        stopPlaybackUpdates()
        audioPlayer?.stop()
        dismiss(animated: true)
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopPlaybackUpdates()
        waveformView.stopAnimating()
        updatePlayButton(isPlaying: false)
        player.currentTime = 0
        timerView.updateLabel()
    }
}

#Preview {
    AudioSheetController()
}
