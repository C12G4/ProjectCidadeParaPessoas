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
    var meterTimer: Timer?
    var expandedIndexPath: IndexPath?
    var playingIndexPath: IndexPath?
    
    
    var selector = UISegmentedControl(items: ["Minhas histórias", "Histórias da cidade"])
    
    private func configureSegmentedControl(){
        
        selector.selectedSegmentIndex = 0
        selector.addTarget(self, action: #selector(numberHasChanged), for: .valueChanged)
        selector.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    @objc
    func  numberHasChanged(control: UISegmentedControl){
        switch selector.selectedSegmentIndex{
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
    
    let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(LibraryAudioCell.self, forCellReuseIdentifier: "AudioCell")
        table.backgroundColor = .clear
        table.separatorStyle = .none
        return table
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Biblioteca de Conteudos"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
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
        setupUI()
        loadCards()
        configureSegmentedControl()
    }
    
    func setupUI() {
        view.addSubview(tableView)
        view.addSubview(selector)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 20, right: 0)
        
        
        NSLayoutConstraint.activate([
         
            
            tableView.topAnchor.constraint(equalTo: selector.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            selector.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            selector.centerXAnchor.constraint(equalTo: view.centerXAnchor)

            
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCell", for: indexPath) as? LibraryAudioCell else {
            return UITableViewCell()
        }
        let card = cards[indexPath.row]

        let isExpanded = indexPath == expandedIndexPath
        cell.configure(card: card, isExpanded: isExpanded, row: indexPath.row)

        if isExpanded,
           let player = audioPlayer,
           player.isPlaying,
           indexPath == playingIndexPath {
            let seed = card.id?.uuidString.hashValue ?? indexPath.row
            cell.startPlaybackUI(with: player, seed: seed)
        }
        else {
            cell.stopPlaybackUI()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }

        let card = cards[indexPath.row]
        guard let audioPath = card.audio else { return }

        let url = audioService.resolveAudioURL(from: audioPath)
        guard FileManager.default.fileExists(atPath: url.path) else { return }

        let player = try? AVAudioPlayer(contentsOf: url)
        guard let player else { return }

        audioPlayer?.stop()
        stopMetering()
        audioPlayer = player
        audioPlayer?.delegate = self
        audioPlayer?.isMeteringEnabled = true
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()

        let previousExpanded = expandedIndexPath
        expandedIndexPath = indexPath
        playingIndexPath = indexPath

        var indexPathsToReload: [IndexPath] = [indexPath]
        if let previousExpanded, previousExpanded != indexPath {
            indexPathsToReload.append(previousExpanded)
        }

        tableView.reloadRows(at: indexPathsToReload, with: .automatic)
        tableView.performBatchUpdates(nil)

        startMetering(with: player)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            guard let self = self else {
                completionHandler(true)
                return
            }
            let card = self.cards[indexPath.row]
            
            if let audioPath = card.audio {
                let url = self.audioService.resolveAudioURL(from: audioPath)
                try? FileManager.default.removeItem(at: url)

                if self.audioPlayer?.url?.lastPathComponent == url.lastPathComponent {
                    self.audioPlayer?.stop()
                    self.stopPlaybackUI()
                }
            }
            
            CoreDataService.shared.deleteCard(card)

            self.expandedIndexPath = nil
            self.playingIndexPath = nil

            self.loadCards()
            completionHandler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopPlaybackUI()
    }

    func stopPlaybackUI() {
        stopMetering()
        if let playingIndexPath,
           let cell = tableView.cellForRow(at: playingIndexPath) as? LibraryAudioCell {
            cell.stopPlaybackUI()
        }
        playingIndexPath = nil
    }

    func startMetering(with player: AVAudioPlayer) {
        stopMetering()

        meterTimer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { [weak self, weak player] _ in
            guard let self = self, let player = player, player.isPlaying else { return }
            player.updateMeters()
            let averagePower = player.averagePower(forChannel: 0)
            let peakPower = player.peakPower(forChannel: 0)

            let averageLevel = pow(10, averagePower / 20)
            let peakLevel = pow(10, peakPower / 20)

            let combinedLevel = (averageLevel * 0.65) + (peakLevel * 0.35)
            let boostedLevel = min(max(pow(combinedLevel, 0.42), 0), 1)

            if let playingIndexPath = self.playingIndexPath,
               let cell = self.tableView.cellForRow(at: playingIndexPath) as? LibraryAudioCell {
                cell.waveformView.addLevel(Float(boostedLevel))
            }
        }

        if let meterTimer {
            RunLoop.main.add(meterTimer, forMode: .common)
        }
    }

    func stopMetering() {
        meterTimer?.invalidate()
        meterTimer = nil
    }

    deinit {
        stopMetering()
    }
}
