//
//  LibraryViewController.swift
//  ProjectCidadeParaPessoas
//
//  Created by Enzo Ferroni on 08/04/26.
//

import UIKit
import AVFoundation

class LibraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let audioService: AudioService
    var cards: [Card] = []
    var audioPlayer: AVAudioPlayer?
    
    let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "AudioCell")
        table.backgroundColor = .systemGray6
        return table
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Biblioteca de Conteudos"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
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
        view.backgroundColor = .systemGray5
        setupUI()
        loadCards()
    }
    
    func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCell", for: indexPath)
        let card = cards[indexPath.row]
        
        var config = cell.defaultContentConfiguration()
        config.text = card.name ?? "Áudio"
        
        if let audioPath = card.audio {
            let fileName = URL(fileURLWithPath: audioPath).lastPathComponent
            config.secondaryText = fileName
        } else {
            config.secondaryText = ""
        }
        
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let card = cards[indexPath.row]
        if let audioPath = card.audio {
            let url = audioService.resolveAudioURL(from: audioPath)
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.prepareToPlay()
                    audioPlayer?.play()
                } catch {
                    print("Error playing audio: \(error)")
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            guard let self = self else {
                completionHandler(true)
                return
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
}
