//
//  AudioWaveformView.swift
//  ProjectCidadeParaPessoas
//
//  Created by Enzo Ferroni on 14/04/26.
//

import UIKit

class AudioWaveformView: UIView {
    let barCount: Int = 11
    let minBarHeight: CGFloat = 3
    let maxWaveFactor: CGFloat = 0.90
    let baseProfile: [CGFloat] = [0.46, 0.68, 0.84, 0.94, 1.00, 0.88, 0.74, 0.92, 0.80, 0.64, 0.50]
    var activeProfile: [CGFloat] = []
    var barHeightConstraints: [NSLayoutConstraint] = []
    var playbackProgress: Double = 0
    var levelHistory: [CGFloat] = []
    var smoothedLevel: CGFloat = 0
    var isAnimating: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        activeProfile = baseProfile
        levelHistory = Array(repeating: 0.08, count: barCount)
        setupBars()
        applyHeights(animated: false)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        activeProfile = baseProfile
        levelHistory = Array(repeating: 0.08, count: barCount)
        setupBars()
        applyHeights(animated: false)
    }

    func setAnimationSeed(_ seed: Int) {
        let shift = abs(seed) % barCount
        activeProfile = Array(baseProfile[shift...] + baseProfile[..<shift])
        applyHeights(animated: false)
    }

    func setProgress(_ progress: Double) {
        playbackProgress = min(max(progress, 0), 1)
    }

    func startAnimating() {
        isAnimating = true
    }

    func stopAnimating() {
        isAnimating = false
        playbackProgress = 0
        smoothedLevel = 0
        levelHistory = Array(repeating: 0.03, count: barCount)
        applyHeights(animated: false)
    }

    func addLevel(_ level: Float) {
        guard isAnimating else { return }

        let clamped = CGFloat(min(max(level, 0), 1))
        let boosted = pow(clamped, 0.48)
        let minMotion: CGFloat = 0.02
        let targetLevel = max(boosted, minMotion)
        let attack: CGFloat = 0.84
        let release: CGFloat = 0.30
        let mix = targetLevel > smoothedLevel ? attack : release
        smoothedLevel = (smoothedLevel * (1 - mix)) + (targetLevel * mix)

        levelHistory.removeFirst()
        levelHistory.append(smoothedLevel)
        applyHeights(animated: true)
    }

    func applyHeights(animated: Bool) {
        guard barHeightConstraints.count == barCount else { return }

        let maxHeight = max(bounds.height, 24)
        let waveRange = (maxHeight - minBarHeight) * maxWaveFactor
        let endFade = max(0.70, 1.0 - CGFloat(playbackProgress) * 0.30)

        let update = {
            for index in 0..<self.barCount {
                let profile = self.activeProfile[index]
                let level = self.levelHistory[index]
                let normalized = max(0.01, min(1.0, level * profile))
                let tailFactor = 0.86 + (CGFloat(index) / CGFloat(max(self.barCount - 1, 1))) * 0.14
                let finalLevel = max(0.01, min(1.0, normalized * tailFactor * endFade))
                self.barHeightConstraints[index].constant = self.minBarHeight + finalLevel * waveRange
            }
            self.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 0.04, delay: 0, options: [.curveLinear, .allowUserInteraction], animations: update)
        }
        else {
            update()
        }
    }

    func setupBars() {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 6

        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        for _ in 0..<barCount {
            let bar = UIView()
            bar.translatesAutoresizingMaskIntoConstraints = false
            bar.backgroundColor = .black
            bar.alpha = 0.92
            bar.layer.cornerRadius = 2

            let heightConstraint = bar.heightAnchor.constraint(equalToConstant: minBarHeight)
            let widthConstraint = bar.widthAnchor.constraint(equalToConstant: 4)
            NSLayoutConstraint.activate([heightConstraint, widthConstraint])

            barHeightConstraints.append(heightConstraint)
            stackView.addArrangedSubview(bar)
        }
    }
}
