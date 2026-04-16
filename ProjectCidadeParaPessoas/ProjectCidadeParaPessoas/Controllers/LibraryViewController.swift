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
    var onCloseTapped: (() -> Void)?
    var custonARView: CustomARView? = nil
    var custonARViewModel = CustomARViewModel()

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

    let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.glass()
        let configImage = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        config.image = UIImage(systemName: "xmark", withConfiguration: configImage)
        config.baseForegroundColor = UIColor(named: "OffBlackColor") ?? .label
        config.baseBackgroundColor = .clear
        config.cornerStyle = .capsule
        config.contentInsets = .zero
        button.backgroundColor = .clear
        button.configuration = config
        return button
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
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        configureSegmentedControl()
        setupUI()
        loadCards()
    }

    func configureSegmentedControl() {
        selector.selectedSegmentIndex = 0
        selector.addTarget(self, action: #selector(numberHasChanged), for: .valueChanged)
        selector.translatesAutoresizingMaskIntoConstraints = false
        selector.selectedSegmentTintColor = UIColor(named: "OffWhiteColor") ?? .systemBackground
        selector.backgroundColor = .clear

        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "OffBlackColor") ?? .label,
            .font: UIFont.systemFont(ofSize: 13, weight: .regular)
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "OffBlackColor") ?? .label,
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold)
        ]

        selector.setTitleTextAttributes(normalAttributes, for: .normal)
        selector.setTitleTextAttributes(selectedAttributes, for: .selected)
    }
    
    func setupUI() {
        view.addSubview(closeButton)
        view.addSubview(selector)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 180
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 36),
            closeButton.heightAnchor.constraint(equalToConstant: 36),
            
            selector.topAnchor.constraint(equalTo: view.topAnchor, constant: 52),
            selector.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            selector.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: selector.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }

    @objc func closeButtonTapped() {
        onCloseTapped?()
    }
    
    func loadCards() {
        refreshCardsForCurrentSegment()
    }

    func refreshCardsForCurrentSegment() {
        switch selector.selectedSegmentIndex {
        case 0:
            cards = CoreDataService.shared.fetchCardByNaoCompartilhado()
        case 1:
            cards = CoreDataService.shared.fetchCardByCompartilhado()
        default:
            cards = CoreDataService.shared.fetchAllCards()
        }

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

        cell.onShareTapped = { [weak self] in
            self?.shareCard(at: indexPath)
        }

        return cell
    }

    func shareCard(at indexPath: IndexPath) {
        guard cards.indices.contains(indexPath.row) else { return }

        let card = cards[indexPath.row]
        let audioName = card.audio ?? ""
        let audioURL = audioService.resolveAudioURL(from: audioName)
        let audioData = try? Data(contentsOf: audioURL)

        let person = Person(
            name: card.name ?? "Untitled Audio",
            id: card.id ?? UUID(),
            lat: card.lat,
            longe: card.longe,
            audio: audioName,
            compartilhado: true,
            audioData: audioData,
            date: card.date ?? Date()
        )
        let personObject = PersonObject(person: person)

        let activityController = UIActivityViewController(
            activityItems: [personObject],
            applicationActivities: nil
        )

        if let popover = activityController.popoverPresentationController {
            if let cell = tableView.cellForRow(at: indexPath) as? LibraryAudioCell {
                popover.sourceView = cell.shareButtonContainer
                popover.sourceRect = cell.shareButtonContainer.bounds
            }
            else {
                popover.sourceView = view
                popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
            }
        }

        activityController.completionWithItemsHandler = { [weak self] _, completed, _, _ in
            guard let self, completed else { return }
            card.compartilhado = true
            CoreDataService.shared.saveContext()
            self.refreshCardsForCurrentSegment()
        }

        present(activityController, animated: true)
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
            custonARViewModel.deleteAllRenderd(arView: custonARView ?? CustomARView())
            custonARViewModel.renderAllMemories(arView: custonARView ?? CustomARView())
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

        refreshCardsForCurrentSegment()
    }
}
