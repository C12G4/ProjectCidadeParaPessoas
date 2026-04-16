//
//  customARView.swift
//  ProjectCidadeParaPessoas
//
//  Created by Jonas Fernando Nascimento Melo on 30/03/26.
//
import UIKit
import ARKit
import RealityKit
import Foundation
import CoreData

class CustomARView: ARView {
    var anchor = AnchorEntity(world: .zero)
    var audioService: AudioService?
    var audioPlayer: AVAudioPlayer?
    var onCubeTapped: ((String) -> Void)?
    
    required init(frame: CGRect){
        super.init(frame: frame)
    }
    
    @MainActor @preconcurrency required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(){
        self.init(frame: UIScreen.main.bounds)
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        session.run(configuration)
        self.scene.addAnchor(anchor)
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        let arView = self
        let tapLocation = recognizer.location(in: arView)
        
        guard let entity = arView.entity(at: tapLocation) as? ModelEntity else { return }
        onCubeTapped?(entity.name)
    }
    func defineAudioService(audioService: AudioService){
        self.audioService = audioService
    }
}