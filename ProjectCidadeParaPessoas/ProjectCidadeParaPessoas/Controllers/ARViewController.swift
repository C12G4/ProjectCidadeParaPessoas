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
    let sheetSavedBounceAnimationKey = "sheetSavedBounce"
    let recordingSavedBounceAnimationKey = "recordingSavedBounce"

    let audioService = AudioService()
    let customARViewModel = CustomARViewModel()
    let geoService = GeoSerive()
    var libraryViewController: LibraryViewController?
    
    var libraryBottomConstraint: NSLayoutConstraint?
    var libraryHeightConstraint: NSLayoutConstraint?
    var panStartBottomConstant: CGFloat = 0
    var isLibraryExpanded = false
    let sheetHorizontalInset: CGFloat = 8
    let collapsedSheetHeaderHeight: CGFloat = 140
    let expandedSheetHeaderHeight: CGFloat = 64
    let expandedSheetTopInset: CGFloat = 80
    var panGesture: UIPanGestureRecognizer?

    let recordingSavedView: UIView = {
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
        let image = UIImage(systemName: "microphone.fill", withConfiguration: configImage)?.withTintColor(UIColor(named: "ButtonColor") ?? .systemGray4, renderingMode: .alwaysOriginal)
        
        var config = UIButton.Configuration.plain()
        config.image = image
        config.imagePlacement = .all
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        button.configuration = config
        return button
    }()
    
    let sheetGrabberView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "ButtonColor") ?? .systemGray4
        view.layer.cornerRadius = 2
        return view
    }()
    
    let sheetContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "OffWhiteColor") ?? .systemGray6
        view.layer.cornerCurve = .continuous
        view.layer.cornerRadius = 32
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
        guard libraryViewController == nil else { return }

        view.addSubview(sheetContainerView)

        libraryViewController = LibraryViewController(audioService: audioService)
        guard let libraryVC = libraryViewController else { return }

        libraryVC.onCloseTapped = { [weak self] in
            self?.updateSheetState(isExpanded: false, animated: true)
        }

        addChild(libraryVC)
        view.addSubview(libraryVC.view)
        libraryVC.didMove(toParent: self)

        libraryVC.view.translatesAutoresizingMaskIntoConstraints = false
        libraryVC.view.alpha = 0
        libraryVC.view.isUserInteractionEnabled = false
        
        libraryBottomConstraint = sheetContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        libraryHeightConstraint = sheetContainerView.heightAnchor.constraint(equalToConstant: collapsedSheetHeaderHeight)
        
        NSLayoutConstraint.activate([
            sheetContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sheetHorizontalInset),
            sheetContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sheetHorizontalInset),
            libraryBottomConstraint!,
            libraryHeightConstraint!,

            libraryVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sheetHorizontalInset),
            libraryVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sheetHorizontalInset),
            libraryVC.view.topAnchor.constraint(equalTo: sheetContainerView.bottomAnchor),
            libraryVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        sheetContainerView.addSubview(sheetGrabberView)
        sheetContainerView.addSubview(audioButton)

        audioButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sheetGrabberView.centerXAnchor.constraint(equalTo: sheetContainerView.centerXAnchor),
            sheetGrabberView.topAnchor.constraint(equalTo: sheetContainerView.topAnchor, constant: 10),
            sheetGrabberView.widthAnchor.constraint(equalToConstant: 36),
            sheetGrabberView.heightAnchor.constraint(equalToConstant: 4),

            audioButton.centerXAnchor.constraint(equalTo: sheetContainerView.centerXAnchor),
            audioButton.centerYAnchor.constraint(equalTo: sheetContainerView.centerYAnchor, constant: -6),
            audioButton.widthAnchor.constraint(equalToConstant: 78),
            audioButton.heightAnchor.constraint(equalToConstant: 78)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(grabberTapped))
        sheetGrabberView.addGestureRecognizer(tapGesture)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        sheetContainerView.addGestureRecognizer(panGesture)
        self.panGesture = panGesture
    }
    
    @objc func grabberTapped() {
        updateSheetState(isExpanded: !isLibraryExpanded, animated: true)
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard !audioService.isRecording else { return }

        let translation = gesture.translation(in: view)
        let maxMovement = view.bounds.height - expandedSheetTopInset - expandedSheetHeaderHeight

        switch gesture.state {
        case .began:
            panStartBottomConstant = libraryBottomConstraint?.constant ?? 0

        case .changed:
            let proposedConstant = panStartBottomConstant + translation.y
            let constrainedConstant = min(max(proposedConstant, -maxMovement), 0)
            libraryBottomConstraint?.constant = constrainedConstant
            let progress = min(max(-constrainedConstant / maxMovement, 0), 1)
            libraryHeightConstraint?.constant = collapsedSheetHeaderHeight - ((collapsedSheetHeaderHeight - expandedSheetHeaderHeight) * progress)
            audioButton.alpha = 1 - progress
            libraryViewController?.view.alpha = progress
            view.layoutIfNeeded()

        case .ended:
            let velocity = gesture.velocity(in: view).y
            let currentOffset = -(libraryBottomConstraint?.constant ?? 0)

            if velocity < -500 {
                updateSheetState(isExpanded: true, animated: true)
            }
            else if velocity > 500 {
                updateSheetState(isExpanded: false, animated: true)
            }
            else {
                updateSheetState(isExpanded: currentOffset > maxMovement * 0.5, animated: true)
            }

        default:
            break
        }
    }

    func updateSheetState(isExpanded: Bool, animated: Bool) {
        let wasExpanded = isLibraryExpanded
        isLibraryExpanded = isExpanded

        if isExpanded && !wasExpanded {
            libraryViewController?.refreshCardsForCurrentSegment()
        }

        libraryBottomConstraint?.constant = isExpanded
            ? -(view.bounds.height - expandedSheetTopInset - expandedSheetHeaderHeight)
            : 0
        libraryHeightConstraint?.constant = isExpanded ? expandedSheetHeaderHeight : collapsedSheetHeaderHeight
        let libraryAlpha: CGFloat = isExpanded ? 1 : 0
        let microphoneAlpha: CGFloat = isExpanded ? 0 : 1

        libraryViewController?.view.isUserInteractionEnabled = isExpanded

        let animations = {
            self.audioButton.alpha = microphoneAlpha
            self.libraryViewController?.view.alpha = libraryAlpha
            self.view.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.7, options: [.curveEaseInOut, .allowUserInteraction], animations: animations)
        }
        else {
            animations()
        }
    }

    func presentAudioSheet(for entityName: String) {
        let cards = CoreDataService.shared.fetchAllCards()
        guard let card = cards.first(where: { $0.id?.uuidString == entityName }),
              let audio = card.audio else { return }

        let audioSheet = AudioSheetController()
        let dateText: String

        if let date = card.date {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "pt_BR")
            formatter.dateFormat = "dd 'de' MMMM, yyyy"
            dateText = formatter.string(from: date).capitalized
        }
        else {
            dateText = ""
        }

        audioSheet.configure(
            name: card.name ?? "Meu relato",
            date: dateText,
            audioUrl: audio
        )
        audioSheet.modalPresentationStyle = .pageSheet

        if let cubeSheet = audioSheet.sheetPresentationController {
            cubeSheet.detents = [.medium(), .large()]
            cubeSheet.prefersGrabberVisible = true
        }

        present(audioSheet, animated: true)
    }

    func setupController() {
        audioButton.layer.zPosition = 20
        let tapGesture = UITapGestureRecognizer(target: customARView,
                                                action: #selector(CustomARView.handleTap(_:)))
        customARView.defineAudioService(audioService: audioService)
        customARView.onCubeTapped = { [weak self] entityName in
            self?.presentAudioSheet(for: entityName)
        }
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
        panGesture?.isEnabled = false
        audioService.startRecording()
    }

    @objc func recordTouchUpInside(_ sender: Any) {
        audioService.stopRecordingIfNeeded()
        panGesture?.isEnabled = true
        creatARObj()
    }

    @objc func recordTouchUpOutside(_ sender: Any) {
        audioService.stopRecordingIfNeeded()
        panGesture?.isEnabled = true
        creatARObj()

    }

    @objc func recordTouchCancel(_ sender: Any) {
        audioService.stopRecordingIfNeeded()
        panGesture?.isEnabled = true
        creatARObj()
    }

    func setAudioButtonRecordingState(isRecording: Bool) {
        let configImage = UIImage.SymbolConfiguration(pointSize: 30)
        let tintColor: UIColor = isRecording ? (UIColor(named: "AccentColor") ?? .systemOrange) : (UIColor(named: "ButtonColor") ?? .systemGray4)
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

    func showRecordingSavedFeedback() {
        animateSheetHeaderSavedFeedback()

        recordingSavedView.layer.removeAllAnimations()
        recordingSavedView.alpha = 1

        let bounce = CAKeyframeAnimation(keyPath: "transform.translation.y")
        bounce.values = [18, -3, 0, -1, 0, 18]
        bounce.keyTimes = [0, 0.35, 0.55, 0.7, 0.82, 1]
        bounce.duration = 0.55
        bounce.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        bounce.fillMode = .forwards
        bounce.isRemovedOnCompletion = false
        recordingSavedView.layer.add(bounce, forKey: recordingSavedBounceAnimationKey)

        UIView.animate(withDuration: 0.18, delay: 0.57, options: [.curveEaseOut]) {
            self.recordingSavedView.alpha = 0
        } completion: { _ in
            self.recordingSavedView.layer.removeAnimation(forKey: self.recordingSavedBounceAnimationKey)
        }
    }

    func animateSheetHeaderSavedFeedback() {
        if panGesture?.state == .changed || panGesture?.state == .began {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
                self?.animateSheetHeaderSavedFeedback()
            }
            return
        }

        sheetContainerView.layer.removeAnimation(forKey: sheetSavedBounceAnimationKey)

        let bounce = CAKeyframeAnimation(keyPath: "transform.translation.y")
        bounce.values = [0, -10, 2, -2, 0]
        bounce.keyTimes = [0, 0.3, 0.58, 0.78, 1]
        bounce.duration = 0.45
        bounce.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        bounce.isRemovedOnCompletion = true

        sheetContainerView.layer.add(bounce, forKey: sheetSavedBounceAnimationKey)
    }
}
