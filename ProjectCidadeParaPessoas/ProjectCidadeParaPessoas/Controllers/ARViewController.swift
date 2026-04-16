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
    var libraryViewController: LibraryViewController?
    
    private var libraryBottomConstraint: NSLayoutConstraint?
    private var isLibraryExpanded = false

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
        
        let configImage = UIImage.SymbolConfiguration(pointSize: 30)
        let image = UIImage(systemName: "microphone.fill", withConfiguration: configImage)?.withTintColor(UIColor(named: "AccentColor") ?? .systemBlue, renderingMode: .alwaysOriginal)
        
        var config = UIButton.Configuration.plain()
        config.image = image
        config.imagePlacement = .all
        config.background.backgroundColor = UIColor(named: "ButtonColor")
        config.background.cornerRadius = 50
        config.imagePadding = 16
        
        button.configuration = config
        return button
    }()
    
    private let trapezoidView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "OffWhiteColor") ?? .systemGray6
        view.layer.cornerRadius = 40
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        return view
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLibrarySheet()
    }
    
    func setupLibrarySheet() {
        view.addSubview(trapezoidView)
        
        libraryViewController = LibraryViewController(audioService: audioService)
        guard let libraryVC = libraryViewController else { return }
        
        addChild(libraryVC)
        view.addSubview(libraryVC.view)
        libraryVC.didMove(toParent: self)
        
        trapezoidView.addSubview(audioButton)
        
        libraryVC.view.translatesAutoresizingMaskIntoConstraints = false
        audioButton.translatesAutoresizingMaskIntoConstraints = false
        
        libraryBottomConstraint = trapezoidView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        NSLayoutConstraint.activate([
            trapezoidView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trapezoidView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            libraryBottomConstraint!,
            trapezoidView.heightAnchor.constraint(equalToConstant: 160),
            
            audioButton.centerXAnchor.constraint(equalTo: trapezoidView.centerXAnchor),
            audioButton.centerYAnchor.constraint(equalTo: trapezoidView.centerYAnchor),
            audioButton.widthAnchor.constraint(equalToConstant: 78),
            audioButton.heightAnchor.constraint(equalToConstant: 78),
            
            libraryVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            libraryVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            libraryVC.view.topAnchor.constraint(equalTo: trapezoidView.bottomAnchor),
            libraryVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        trapezoidView.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let percentage = -translation.y / view.bounds.height
        
        switch gesture.state {
        case .changed:
            let maxMovement = view.bounds.height - 240
            let constrainedTranslation = min(max(translation.y, -maxMovement), 0)
            libraryBottomConstraint?.constant = constrainedTranslation
            audioButton.alpha = max(0, 1 - (-constrainedTranslation / maxMovement) * 1.5)
            view.layoutIfNeeded()
            
        case .ended:
            let velocity = gesture.velocity(in: view).y
            let maxMovement = view.bounds.height - 240
            let currentOffset = -(libraryBottomConstraint?.constant ?? 0)
            
            if -velocity > 300 || currentOffset > maxMovement * 0.25 {
                libraryBottomConstraint?.constant = -(maxMovement)
                audioButton.alpha = 0
                isLibraryExpanded = true
            } else {
                libraryBottomConstraint?.constant = 0
                audioButton.alpha = 1
                isLibraryExpanded = false
            }
            
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            })
            
        default:
            break
        }
    }
    
    func setupController() {
        audioButton.layer.zPosition = 20
        let tapGesture = UITapGestureRecognizer(target: customARView,
                                                action: #selector(customARView.handleTap))
        customARView.defineAudioService(audioService: audioService)
        customARView.addGestureRecognizer(tapGesture)
        
        view.addSubview(customARView)
        view.addSubview(recordingSavedView)

        audioButton.addTarget(self, action: #selector(recordTouchDown(_:)), for: .touchDown)
        audioButton.addTarget(self, action: #selector(recordTouchUpInside(_:)), for: .touchUpInside)
        audioButton.addTarget(self, action: #selector(recordTouchUpOutside(_:)), for: .touchUpOutside)
        audioButton.addTarget(self, action: #selector(recordTouchCancel(_:)), for: .touchCancel)
    
        NSLayoutConstraint.activate([
            customARView.topAnchor.constraint(equalTo: view.topAnchor),
            customARView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customARView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            customARView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            recordingSavedView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordingSavedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            recordingSavedView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -8),
            recordingSavedView.heightAnchor.constraint(equalToConstant: 24)
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
        let configImage = UIImage.SymbolConfiguration(pointSize: 30)
        let tintColor: UIColor = isRecording ? (UIColor(named: "AccentColor") ?? .systemBlue) : .white
        let image = UIImage(systemName: "microphone.fill", withConfiguration: configImage)?
            .withTintColor(tintColor, renderingMode: .alwaysOriginal)

        guard var config = audioButton.configuration else { return }
        config.image = image
        audioButton.configuration = config
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
                compartilhado: false,
                date: Date.now
            )
            showRecordingSavedFeedback()
        }
    }

    private func showRecordingSavedFeedback() {
        recordingSavedView.layer.removeAllAnimations()
        recordingSavedView.alpha = 1

        let bounce = CAKeyframeAnimation(keyPath: "transform.translation.y")
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
}
