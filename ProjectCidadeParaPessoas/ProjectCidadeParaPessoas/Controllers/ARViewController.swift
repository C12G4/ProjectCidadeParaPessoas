//
//  ARController.swift
//  ProjectCidadeParaPessoas
//
//  Created by Jonas Fernando Nascimento Melo on 30/03/26.
//

import UIKit
import RealityKit

class ARViewController: UIViewController {
    let audioService = AudioService()
    let customARViewModel = CustomARViewModel()
    
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
        
        let configImage = UIImage.SymbolConfiguration(pointSize: 40)
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
    }
    
    func setupController() {
        //configure view
        audioButton.layer.zPosition = 10
        //add subviews
        view.addSubview(customARView)
        view.addSubview(audioButton)
        view.addSubview(searchButton)
        view.addSubview(audioButton)
        
        view.addSubview(libraryButton)
        view.addSubview(shareButton)
        
        //target
        
        shareButton.addTarget(self, action: #selector(share(_:)), for: .touchUpInside)
        libraryButton.addTarget(self, action: #selector(openLibrary(_:)), for: .touchUpInside)
        
        // addTarget
        searchButton.addTarget(self, action: #selector(playAudio(_:)), for: .touchUpInside)
        
        audioButton.addTarget(self, action: #selector(recordTouchDown(_:)), for: .touchDown)
        audioButton.addTarget(self, action: #selector(recordTouchUpInside(_:)), for: .touchUpInside)
        audioButton.addTarget(self, action: #selector(recordTouchUpOutside(_:)), for: .touchUpOutside)
        audioButton.addTarget(self, action: #selector(recordTouchDragExit(_:)), for: .touchDragExit)
        audioButton.addTarget(self, action: #selector(recordTouchCancel(_:)), for: .touchCancel)
    
        // add constrains
        NSLayoutConstraint.activate([
            customARView.topAnchor.constraint(equalTo: view.topAnchor),
            customARView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customARView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            customARView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            audioButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 102.38),
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
            
            shareButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 120.38),
            shareButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200),
            shareButton.widthAnchor.constraint(equalToConstant: 78),
            shareButton.heightAnchor.constraint(equalToConstant: 78),
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

    @objc func recordTouchDragExit(_ sender: Any) {
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
    func creatARObj(){
        customARView.scene.addAnchor(customARViewModel.creatObj(color: .magenta, cameraTransform: customARView.cameraTransform))
    }
    
    @objc func share(_ sender: Any) {
        
        let items = PersonObject(person: Person(name: "asd", id: UUID(), lat: 0.0, longe: 0.0, audio: "AUDIO"))

        let ac = UIActivityViewController(activityItems: [items] as! [Any], applicationActivities: nil)
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
}
