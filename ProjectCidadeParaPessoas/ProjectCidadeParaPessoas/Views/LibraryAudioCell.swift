//
//  LibraryAudioCell.swift
//  ProjectCidadeParaPessoas
//
//  Created by Enzo Ferroni on 15/04/26.
//

import UIKit
import AVFoundation

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
        label.font = UIFont.systemFont(ofSize: 33, weight: .bold)
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()

    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 28, weight: .regular)
        label.textColor = UIColor(white: 0.15, alpha: 0.70)
        label.numberOfLines = 1
        return label
    }()

    let expandableContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    let shareButtonContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.28)
        view.layer.cornerRadius = 18
        view.alpha = 0
        return view
    }()

    let shareImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "square.and.arrow.up"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    let playPillView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0.98, alpha: 0.20)
        view.layer.cornerRadius = 20
        view.alpha = 0
        return view
    }()

    let playIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "play.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

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
        cardContainer.addSubview(expandableContainer)

        expandableContainer.addSubview(timerView)
        expandableContainer.addSubview(waveformView)
        expandableContainer.addSubview(playPillView)
        expandableContainer.addSubview(shareButtonContainer)

        playPillView.addSubview(playIconView)
        shareButtonContainer.addSubview(shareImageView)

        expandedHeightConstraint = expandableContainer.heightAnchor.constraint(equalToConstant: 0)
        expandedHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            cardContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            cardContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            cardContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            titleLabel.topAnchor.constraint(equalTo: cardContainer.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -18),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            expandableContainer.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 10),
            expandableContainer.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
            expandableContainer.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
            expandableContainer.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor),

            shareButtonContainer.topAnchor.constraint(equalTo: expandableContainer.topAnchor, constant: 6),
            shareButtonContainer.trailingAnchor.constraint(equalTo: expandableContainer.trailingAnchor, constant: -14),
            shareButtonContainer.widthAnchor.constraint(equalToConstant: 36),
            shareButtonContainer.heightAnchor.constraint(equalToConstant: 36),

            shareImageView.centerXAnchor.constraint(equalTo: shareButtonContainer.centerXAnchor),
            shareImageView.centerYAnchor.constraint(equalTo: shareButtonContainer.centerYAnchor),
            shareImageView.widthAnchor.constraint(equalToConstant: 16),
            shareImageView.heightAnchor.constraint(equalToConstant: 16),

            waveformView.centerYAnchor.constraint(equalTo: expandableContainer.centerYAnchor, constant: -6),
            waveformView.leadingAnchor.constraint(equalTo: expandableContainer.leadingAnchor, constant: 34),
            waveformView.trailingAnchor.constraint(equalTo: expandableContainer.trailingAnchor, constant: -34),
            waveformView.heightAnchor.constraint(equalToConstant: 44),

            playPillView.trailingAnchor.constraint(equalTo: expandableContainer.trailingAnchor, constant: -14),
            playPillView.bottomAnchor.constraint(equalTo: expandableContainer.bottomAnchor, constant: -16),
            playPillView.heightAnchor.constraint(equalToConstant: 40),

            timerView.leadingAnchor.constraint(equalTo: playPillView.leadingAnchor, constant: 14),
            timerView.centerYAnchor.constraint(equalTo: playPillView.centerYAnchor),

            playIconView.leadingAnchor.constraint(equalTo: timerView.trailingAnchor, constant: 10),
            playIconView.trailingAnchor.constraint(equalTo: playPillView.trailingAnchor, constant: -12),
            playIconView.centerYAnchor.constraint(equalTo: playPillView.centerYAnchor),
            playIconView.widthAnchor.constraint(equalToConstant: 16),
            playIconView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    func configure(card: Card, isExpanded: Bool, row: Int) {
        titleLabel.text = card.name ?? "Áudio"

        if let audioPath = card.audio {
            subtitleLabel.text = URL(fileURLWithPath: audioPath).lastPathComponent
        }
        else {
            subtitleLabel.text = ""
        }

        let palette: [UIColor] = [
            UIColor(red: 1.00, green: 0.95, blue: 0.84, alpha: 1.00),
            UIColor(red: 1.00, green: 0.78, blue: 0.35, alpha: 1.00),
            UIColor(red: 1.00, green: 0.62, blue: 0.00, alpha: 1.00),
            UIColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1.00)
        ]

        let baseColor = isExpanded ? palette[2] : palette[min(row % 3, 2)]
        cardContainer.backgroundColor = baseColor

        let isDark = (baseColor == palette[3])
        titleLabel.textColor = isDark ? .white : .black
        subtitleLabel.textColor = isDark ? UIColor(white: 1, alpha: 0.65) : UIColor(white: 0.10, alpha: 0.70)

        setExpanded(isExpanded)
    }

    func setExpanded(_ expanded: Bool) {
        expandedHeightConstraint?.constant = expanded ? 260 : 0
        expandableContainer.alpha = expanded ? 1 : 0
        expandableContainer.isHidden = !expanded
        shareButtonContainer.alpha = expanded ? 1 : 0
        playPillView.alpha = expanded ? 1 : 0
    }

    func startPlaybackUI(with player: AVAudioPlayer, seed: Int) {
        waveformView.setAnimationSeed(seed)
        waveformView.setProgress(0)
        waveformView.startAnimating()
        timerView.onProgressChanged = { [weak self] progress in
            self?.waveformView.setProgress(progress)
        }
        timerView.start(with: player)
    }

    func stopPlaybackUI() {
        timerView.stop()
        waveformView.stopAnimating()
    }
}
