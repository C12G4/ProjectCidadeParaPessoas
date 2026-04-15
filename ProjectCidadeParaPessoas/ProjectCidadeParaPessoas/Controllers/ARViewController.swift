//
//  ARController.swift
//  ProjectCidadeParaPessoas
//
//  Created by Jonas Fernando Nascimento Melo on 30/03/26.
//

import UIKit
import RealityKit
import CoreLocation

class ARViewController: UIViewController {
    let audioService = AudioService()
    let customARViewModel = CustomARViewModel()
    let geoService = GeoSerive()

    private let recordingSavedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemGray4.withAlphaComponent(0.95)
        view.layer.cornerRadius = 32
        view.alpha = 0
        return view
    }()

    let customARView: CustomARView = {
        let view = CustomARView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let audioButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let configImage = UIImage.SymbolConfiguration(pointSize: 40)
        let image = UIImage(systemName: "microphone.fill", withConfiguration: configImage)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        
        var config = UIButton.Configuration.plain()
        
        config.image = image
        config.imagePlacement = .all
        config.background.backgroundColor = UIColor(named: "ButtonColor")
        config.background.cornerRadius = 1000
        config.imagePadding = 12.88
        
        button.configuration = config
        return button
    }()
    
    let searchButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        var configImage = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
        let image = UIImage(systemName: "magnifyingglass", withConfiguration: configImage)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        
        var config = UIButton.Configuration.plain()
        
        config.image = image
        config.imagePlacement = .all
        config.background.backgroundColor = UIColor(named: "ButtonColor")
        config.background.cornerRadius = 1000
        config.imagePadding = 12.88
        
        button.configuration = config
        return button
    }()
    
    let shareButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let configImage = UIImage.SymbolConfiguration(pointSize: 20)
        let image = UIImage(systemName: "square.and.arrow.up", withConfiguration: configImage)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        
        var config = UIButton.Configuration.plain()
        
        config.image = image
        config.imagePlacement = .all
        config.background.backgroundColor = UIColor(named: "ButtonColor")
        config.background.cornerRadius = 1000
        config.imagePadding = 12.88
        
        button.configuration = config
        return button
    }()
    
    let libraryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let configImage = UIImage.SymbolConfiguration(pointSize: 20)
        let image = UIImage(systemName: "book.fill", withConfiguration: configImage)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        
        var config = UIButton.Configuration.plain()
        
        config.image = image
        config.imagePlacement = .all
        config.background.backgroundColor = UIColor(named: "ButtonColor")
        config.background.cornerRadius = 1000
        config.imagePadding = 12.88
        
        button.configuration = config
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
        audioService.audioInit()
        audioService.onRecordingStateChanged = { [weak self] isRecording in
            DispatchQueue.main.async {
                self?.setAudioButtonRecordingState(isRecording: isRecording)
            }
        }
        setAudioButtonRecordingState(isRecording: false)
        
        customARViewModel.renderAllMemories(arView: customARView)
    }
    
    func setupController() {
        //configure view
        audioButton.layer.zPosition = 10
        let tapGesture = UITapGestureRecognizer(target: customARView,
                                                action: #selector(customARView.handleTap))
        customARView.defineAudioService(audioService: audioService)
        customARView.addGestureRecognizer(tapGesture)
        //add subviews
        view.addSubview(customARView)
        view.addSubview(audioButton)
        view.addSubview(searchButton)
        
        view.addSubview(libraryButton)
        view.addSubview(shareButton)
        view.addSubview(recordingSavedView)

        //target
        shareButton.addTarget(self, action: #selector(share(_:)), for: .touchUpInside)
        libraryButton.addTarget(self, action: #selector(openLibrary(_:)), for: .touchUpInside)
        
        // addTarget
        searchButton.addTarget(self, action: #selector(playAudio(_:)), for: .touchUpInside)
        
        audioButton.addTarget(self, action: #selector(recordTouchDown(_:)), for: .touchDown)
        audioButton.addTarget(self, action: #selector(recordTouchUpInside(_:)), for: .touchUpInside)
        audioButton.addTarget(self, action: #selector(recordTouchUpOutside(_:)), for: .touchUpOutside)
        audioButton.addTarget(self, action: #selector(recordTouchCancel(_:)), for: .touchCancel)
    
        // add constrains
        NSLayoutConstraint.activate([
            customARView.topAnchor.constraint(equalTo: view.topAnchor),
            customARView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customARView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            customARView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            audioButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 101.38),
            audioButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32.25),
            audioButton.widthAnchor.constraint(equalToConstant: 78),
            audioButton.heightAnchor.constraint(equalToConstant: 78),
            
            searchButton.leadingAnchor.constraint(equalTo: audioButton.trailingAnchor, constant: 32.65),
            searchButton.bottomAnchor.constraint(equalTo: audioButton.bottomAnchor),
            searchButton.widthAnchor.constraint(equalToConstant: 78),
            searchButton.heightAnchor.constraint(equalToConstant: 78),

            libraryButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 64),
            libraryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            libraryButton.widthAnchor.constraint(equalToConstant: 52),
            libraryButton.heightAnchor.constraint(equalToConstant: 52),            

            recordingSavedView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordingSavedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            recordingSavedView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -8),
            recordingSavedView.heightAnchor.constraint(equalToConstant: 24),

            shareButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 64),
            shareButton.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: 82),
            shareButton.widthAnchor.constraint(equalToConstant: 52),
            shareButton.heightAnchor.constraint(equalToConstant: 52),
        ])
    }
    
    @objc func recordTouchDown(_ sender: Any) {
        audioService.startRecording()
    }

    @objc func recordTouchUpInside(_ sender: Any) {
        audioService.stopRecordingIfNeeded()
        creatARObj()
    }

    @objc func recordTouchUpOutside(_ sender: Any) {
        audioService.stopRecordingIfNeeded()
        creatARObj()

    }

    @objc func recordTouchCancel(_ sender: Any) {
        audioService.stopRecordingIfNeeded()
        creatARObj()
    }

    private func setAudioButtonRecordingState(isRecording: Bool) {
        let configImage = UIImage.SymbolConfiguration(pointSize: 40)
        let tintColor: UIColor = isRecording ? .systemGreen : .white
        let image = UIImage(systemName: "microphone.fill", withConfiguration: configImage)?
            .withTintColor(tintColor, renderingMode: .alwaysOriginal)

        guard var config = audioButton.configuration else { return }
        config.image = image
        audioButton.configuration = config
    }
    
    @objc func playAudio(_ sender: Any) {
        audioService.playAudio(sender)
    }

    func creatARObj() {
        let id = UUID()
        let stringID = id.uuidString
        customARView.anchor.addChild(customARViewModel.creatObj(color: .purple, cameraTransform : customARView.cameraTransform, id: stringID))
        
        if let audioPath = audioService.getAudioFilePath() {
            let location = geoService.getActualLocation() ?? CLLocation(latitude: 0, longitude: 0)
            _ = CoreDataService.shared.createCard(
                name: "Audio \(Date().formatted(date: .abbreviated, time: .shortened))",
                id: id,
                lat: location.coordinate.latitude,
                longe: location.coordinate.longitude,
                audio: audioPath,
                compartilhado: false
            )
            showRecordingSavedFeedback()
        }
    }

    private func showRecordingSavedFeedback() {
        recordingSavedView.layer.removeAllAnimations()
        recordingSavedView.alpha = 1

        let bounce = CAKeyframeAnimation(keyPath: "transform.translation.y")
        // O primeiro valor é o quando ele fica fora da tela e quanto maior mais "forte" ele sobe
        // Os valores negativos deixam o bounce mais suave
        bounce.values = [18, -3, 0, -1, 0, 18]
        bounce.keyTimes = [0, 0.35, 0.55, 0.7, 0.82, 1]
        bounce.duration = 0.55
        bounce.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        bounce.fillMode = .forwards
        bounce.isRemovedOnCompletion = false
        recordingSavedView.layer.add(bounce, forKey: "recordingSavedBounce")

        UIView.animate(withDuration: 0.18, delay: 0.57, options: [.curveEaseOut]) {
            self.recordingSavedView.alpha = 0
        } completion: { _ in
            self.recordingSavedView.layer.removeAnimation(forKey: "recordingSavedBounce")
        }
    }
    
    @objc func share(_ sender: Any) {
        // compartilha o ultimo relato salvo (texto + localização + áudio)
        // o audio vai junto em bytes para funcionar em outro app/dispositivo
        let cards = CoreDataService.shared.fetchAllCards()
        guard let card = cards.last,
              let name = card.name,
              let audioStoredValue = card.audio else { return }

        // pega a URL real do áudio no app atual e le o conteudo do arquivo
        let audioURL = audioService.resolveAudioURL(from: audioStoredValue)
        let audioData = try? Data(contentsOf: audioURL)

        // monta um payload com tudo e exporta como .person
        let item = PersonObject(person: Person(
            name: name,
            id: card.id ?? UUID(),
            lat: card.lat,
            longe: card.longe,
            audio: URL(fileURLWithPath: audioStoredValue).lastPathComponent,
            compartilhado: true,
            audioData: audioData
        ))

        // abre a sheet de compartilhamento
        let ac = UIActivityViewController(activityItems: [item], applicationActivities: nil)
        present(ac, animated: true)
    }
    
    @objc func openLibrary(_ sender: Any) {
        let libraryVC = LibraryViewController(audioService: audioService)
        if let sheet = libraryVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(libraryVC, animated: true)
    }
    
    func openCube(name: String, audio: String, date: String) {
        let audioSheet = AudioSheetController()
        audioSheet.nameLabel.text = name
        audioSheet.audioUrl = audio
        audioSheet.dateLabel.text = date
        if let cubeSheet = audioSheet.sheetPresentationController {
            cubeSheet.detents = [.medium(), .large()]
            cubeSheet.prefersGrabberVisible = true
        }
        present(audioSheet, animated: true)
    }
}
