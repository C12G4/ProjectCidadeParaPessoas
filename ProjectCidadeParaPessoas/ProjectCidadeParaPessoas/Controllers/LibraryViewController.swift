//
//  LibraryViewController.swift
//  ProjectCidadeParaPessoas
//
//  Created by Enzo Ferroni on 08/04/26.
//

import UIKit
import AVFoundation

class LibraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate {
    let audioService: AudioService
    var cards: [Card] = []
    var audioPlayer: AVAudioPlayer?
    var playbackMeterTimer: Timer?
    var expandedIndexPath: IndexPath?
    var playingIndexPath: IndexPath?

    var selector = UISegmentedControl(items: ["Minhas histórias", "Histórias da cidade"])

    let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(LibraryAudioCell.self, forCellReuseIdentifier: "AudioCell")
        table.backgroundColor = UIColor(named: "OffWhiteColor") ?? .systemBackground
        table.separatorStyle = .none
        table.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 18, right: 0)
        return table
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Biblioteca de Conteudos"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = UIColor(named: "OffBlackColor") ?? .label
        return label
    }()
    
    init(audioService: AudioService) {
        self.audioService = audioService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "OffWhiteColor") ?? .systemBackground
        configureSegmentedControl()
        setupUI()
        loadCards()
    }

    func configureSegmentedControl() {
        selector.selectedSegmentIndex = 0
        selector.addTarget(self, action: #selector(numberHasChanged), for: .valueChanged)
        selector.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(selector)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 180
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            selector.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            selector.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            selector.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: selector.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func loadCards() {
        cards = CoreDataService.shared.fetchAllCards()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCell", for: indexPath) as! LibraryAudioCell
        let card = cards[indexPath.row]

        let isExpanded = (expandedIndexPath == indexPath)
        cell.configure(card: card, isExpanded: isExpanded, row: indexPath.row)

        if playingIndexPath == indexPath, let player = audioPlayer, player.isPlaying {
            cell.startPlaybackUI(with: player, seed: card.id?.uuidString.hashValue ?? indexPath.row)
        }
        else {
            cell.stopPlaybackUI()
        }

        cell.onPlayPauseToggle = { [weak self] in
            self?.togglePlayPause(at: indexPath)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }

        let card = cards[indexPath.row]
        guard let audioPath = card.audio else { return }

        let url = audioService.resolveAudioURL(from: audioPath)
        guard FileManager.default.fileExists(atPath: url.path) else { return }

        stopPlaybackUI()

        if expandedIndexPath == indexPath {
            expandedIndexPath = nil
            playingIndexPath = nil
            tableView.reloadRows(at: [indexPath], with: .automatic)
            return
        }

        let previousExpanded = expandedIndexPath
        expandedIndexPath = indexPath
        playingIndexPath = indexPath

        var rowsToReload: [IndexPath] = [indexPath]
        if let previousExpanded, previousExpanded != indexPath {
            rowsToReload.append(previousExpanded)
        }
        tableView.reloadRows(at: rowsToReload, with: .automatic)

        if let player = try? AVAudioPlayer(contentsOf: url) {
            audioPlayer = player
            player.delegate = self
            player.isMeteringEnabled = true
            player.prepareToPlay()
            player.play()
            startPlaybackMetering()

            if let cell = tableView.cellForRow(at: indexPath) as? LibraryAudioCell {
                cell.startPlaybackUI(with: player, seed: card.id?.uuidString.hashValue ?? indexPath.row)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            guard let self = self else {
                completionHandler(true)
                return
            }

            if self.playingIndexPath == indexPath {
                self.stopPlaybackUI()
                self.playingIndexPath = nil
                self.expandedIndexPath = nil
            }

            let card = self.cards[indexPath.row]

            if let audioPath = card.audio {
                let url = audioService.resolveAudioURL(from: audioPath)
                try? FileManager.default.removeItem(at: url)
            }

            CoreDataService.shared.deleteCard(card)
            self.loadCards()
            completionHandler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playbackMeterTimer?.invalidate()
        playbackMeterTimer = nil

        if let playingIndexPath,
           let cell = tableView.cellForRow(at: playingIndexPath) as? LibraryAudioCell {
            cell.waveformView.stopAnimating()
            cell.updatePlayPauseIcon(isPlaying: false)
        }

        player.currentTime = 0
    }

    func startPlaybackMetering() {
        playbackMeterTimer?.invalidate()
        playbackMeterTimer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { [weak self] _ in
            guard let self, let player = self.audioPlayer, player.isPlaying else {
                self?.playbackMeterTimer?.invalidate()
                self?.playbackMeterTimer = nil
                return
            }

            player.updateMeters()
            let avgPower = player.averagePower(forChannel: 0)
            let peakPower = player.peakPower(forChannel: 0)
            let avgNormalized = pow(10, avgPower / 20)
            let peakNormalized = pow(10, peakPower / 20)
            let level = min(1.0, (avgNormalized * 0.75) + (peakNormalized * 0.25))

            guard let playingIndexPath = self.playingIndexPath,
                  let cell = self.tableView.cellForRow(at: playingIndexPath) as? LibraryAudioCell else { return }
            cell.waveformView.addLevel(Float(level))
        }
    }

    func stopPlaybackUI() {
        playbackMeterTimer?.invalidate()
        playbackMeterTimer = nil
        audioPlayer?.stop()
        audioPlayer = nil

        if let playingIndexPath,
           let cell = tableView.cellForRow(at: playingIndexPath) as? LibraryAudioCell {
            cell.stopPlaybackUI()
        }
    }

    func togglePlayPause(at indexPath: IndexPath) {
        if let player = audioPlayer, playingIndexPath == indexPath {
            if player.isPlaying {
                player.pause()
                if let cell = tableView.cellForRow(at: indexPath) as? LibraryAudioCell {
                    cell.updatePlayPauseIcon(isPlaying: false)
                    cell.waveformView.stopAnimating()
                }
                playbackMeterTimer?.invalidate()
            }
            else {
                player.play()
                startPlaybackMetering()
                if let cell = tableView.cellForRow(at: indexPath) as? LibraryAudioCell {
                    cell.updatePlayPauseIcon(isPlaying: true)
                    cell.waveformView.startAnimating()
                }
            }
        }
        else {
            tableView(tableView, didSelectRowAt: indexPath)
        }
    }

    @objc func numberHasChanged(control: UISegmentedControl) {
        stopPlaybackUI()
        expandedIndexPath = nil
        playingIndexPath = nil
        
        switch selector.selectedSegmentIndex {
        case 0:
            cards = CoreDataService.shared.fetchCardByNaoCompartilhado()
            tableView.reloadData()
        case 1:
            cards = CoreDataService.shared.fetchCardByCompartilhado()
            tableView.reloadData()
        default:
            cards = CoreDataService.shared.fetchAllCards()
            tableView.reloadData()
        }
    }
}
