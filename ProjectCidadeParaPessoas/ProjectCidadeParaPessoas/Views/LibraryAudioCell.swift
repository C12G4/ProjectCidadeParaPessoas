//
//  LibraryAudioCell.swift
//  ProjectCidadeParaPessoas
//
//  Created by Enzo Ferroni on 15/04/26.
//

import UIKit
import AVFoundation

// MARK: - Liquid Glass Button
class LiquidGlassButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLiquidGlass()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLiquidGlass()
    }
    
    private func setupLiquidGlass() {
        // Configure button with white transparent background
        backgroundColor = UIColor.white.withAlphaComponent(0.35)
        tintColor = UIColor(named: "OffBlackColor") ?? .label
        layer.cornerRadius = 20
        layer.cornerCurve = .continuous
        layer.borderWidth = 0
        clipsToBounds = true
    }
}

class LibraryAudioCell: UITableViewCell {
    let cardContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 26
        view.clipsToBounds = true
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = UIColor(named: "OffBlackColor") ?? .label
        label.numberOfLines = 1
        return label
    }()

    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = (UIColor(named: "ButtonColor") ?? .secondaryLabel).withAlphaComponent(0.9)
        label.numberOfLines = 1
        return label
    }()

    let expandableContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    let shareButtonContainer: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.glass()
        config.image = UIImage(systemName: "square.and.arrow.up")
        config.baseForegroundColor = UIColor(named: "OffBlackColor") ?? .label
        config.baseBackgroundColor = .clear
        config.cornerStyle = .capsule
        config.contentInsets = .zero
        button.backgroundColor = .clear
        button.configuration = config
        button.isHidden = true
        return button
    }()

    let playPillView: UIButton = {
        let button = LiquidGlassButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()

    let playIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "play.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = UIColor(named: "OffBlackColor") ?? .label
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    var onPlayPauseToggle: (() -> Void)?

    let timerView: PlaybackTimerView = {
        let view = PlaybackTimerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let waveformView: AudioWaveformView = {
        let view = AudioWaveformView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var expandedHeightConstraint: NSLayoutConstraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        stopPlaybackUI()
        setExpanded(false)
    }

    func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        accessoryType = .none

        contentView.addSubview(cardContainer)
        cardContainer.addSubview(titleLabel)
        cardContainer.addSubview(subtitleLabel)
        cardContainer.addSubview(shareButtonContainer)
        cardContainer.addSubview(expandableContainer)

        expandableContainer.addSubview(waveformView)
        expandableContainer.addSubview(playPillView)

        playPillView.addSubview(timerView)
        playPillView.addSubview(playIconView)

        shareButtonContainer.layer.cornerCurve = .continuous
        playPillView.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)

        expandedHeightConstraint = expandableContainer.heightAnchor.constraint(equalToConstant: 0)
        expandedHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            cardContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            cardContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            cardContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            titleLabel.topAnchor.constraint(equalTo: cardContainer.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: shareButtonContainer.leadingAnchor, constant: -12),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            shareButtonContainer.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -2),
            shareButtonContainer.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -18),
            shareButtonContainer.widthAnchor.constraint(equalToConstant: 36),
            shareButtonContainer.heightAnchor.constraint(equalToConstant: 36),

            expandableContainer.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 10),
            expandableContainer.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
            expandableContainer.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
            expandableContainer.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor),

            waveformView.centerYAnchor.constraint(equalTo: expandableContainer.centerYAnchor, constant: -6),
            waveformView.leadingAnchor.constraint(equalTo: expandableContainer.leadingAnchor, constant: 34),
            waveformView.trailingAnchor.constraint(equalTo: expandableContainer.trailingAnchor, constant: -34),
            waveformView.heightAnchor.constraint(equalToConstant: 44),

            playPillView.trailingAnchor.constraint(equalTo: expandableContainer.trailingAnchor, constant: -14),
            playPillView.bottomAnchor.constraint(equalTo: expandableContainer.bottomAnchor, constant: -16),
            playPillView.heightAnchor.constraint(equalToConstant: 40),

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

    func configure(card: Card, isExpanded: Bool, row: Int) {
        let cardColors: [UIColor] = [
            UIColor(named: "TertiaryColor") ?? .systemGray5,
            UIColor(named: "SecondaryColor") ?? .systemGray4,
            UIColor(named: "AccentColor") ?? .systemGray3
        ]
        let color = cardColors[row % cardColors.count]
        cardContainer.backgroundColor = color

        titleLabel.text = card.name ?? "Nome da Pessoa"

        if let date = card.date {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "pt_BR")
            formatter.dateFormat = "dd 'de' MMMM, yyyy"
            subtitleLabel.text = formatter.string(from: date).capitalized
        }
        else {
            subtitleLabel.text = ""
        }

        setExpanded(isExpanded)
    }

    func setExpanded(_ expanded: Bool) {
        expandedHeightConstraint?.constant = expanded ? 260 : 0
        expandableContainer.alpha = expanded ? 1 : 0
        expandableContainer.isHidden = !expanded
        shareButtonContainer.isHidden = !expanded
        playPillView.isHidden = !expanded
    }

    func startPlaybackUI(with player: AVAudioPlayer, seed: Int) {
        waveformView.setAnimationSeed(seed)
        waveformView.setProgress(0)
        waveformView.startAnimating()
        updatePlayPauseIcon(isPlaying: true)
        timerView.onProgressChanged = { [weak self] progress in
            self?.waveformView.setProgress(progress)
        }
        timerView.start(with: player)
    }

    func stopPlaybackUI() {
        timerView.stop()
        waveformView.stopAnimating()
        updatePlayPauseIcon(isPlaying: false)
    }

    func updatePlayPauseIcon(isPlaying: Bool) {
        let iconName = isPlaying ? "pause.fill" : "play.fill"
        playIconView.image = UIImage(systemName: iconName)
    }

    @objc func playPauseButtonTapped() {
        onPlayPauseToggle?()
    }
}
