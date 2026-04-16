//
//  PlaybackTimerView.swift
//  ProjectCidadeParaPessoas
//
//  Created by Enzo Ferroni on 14/04/26.
//

import UIKit
import AVFoundation

class PlaybackTimerView: UIView {
    var onProgressChanged: ((Double) -> Void)?

    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .semibold)
        label.textColor = UIColor(named: "OffBlackColor") ?? .black
        label.text = "00:00 / 00:00"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.9
        return label
    }()

    weak var player: AVAudioPlayer?
    var timer: Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    func setupUI() {
        backgroundColor = .clear
        addSubview(label)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        ])
    }

    func start(with player: AVAudioPlayer) {
        self.player = player
        updateLabel()

        timer?.invalidate()
        let timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            self?.updateLabel()
        }
        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        player = nil
        label.text = "00:00 / 00:00"
        onProgressChanged?(0)
    }

    func updateLabel() {
        guard let player else { return }
        let current = formatTime(player.currentTime)
        let total = formatTime(player.duration)
        label.text = "\(current) / \(total)"

        guard player.duration > 0 else {
            onProgressChanged?(0)
            return
        }

        let progress = min(max(player.currentTime / player.duration, 0), 1)
        onProgressChanged?(progress)
    }

    func formatTime(_ time: TimeInterval) -> String {
        guard time.isFinite && !time.isNaN else { return "00:00" }
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    deinit {
        timer?.invalidate()
    }
}
