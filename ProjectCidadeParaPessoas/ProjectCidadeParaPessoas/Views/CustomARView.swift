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
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer, arViewController: ARViewController) {
        let arView = self
        let tapLocation = recognizer.location(in: arView)
        
        if let entity = arView.entity(at: tapLocation) as? ModelEntity {
            let cards = CoreDataService.shared.fetchAllCards()
            var actualCard = Card()
            for card in cards {
                if card.id?.uuidString == entity.name {
                    actualCard = card

                }
            }
            arViewController.openCube(name: actualCard.name!, audio: actualCard.audio!, date: actualCard.id!.uuidString)
            
            let url = audioService!.resolveAudioURL(from: actualCard.audio ?? "")
            print(url)
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    print("dentro do")
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.prepareToPlay()
                    audioPlayer?.play()
                } catch {
                    print("Error playing audio: \(error)")
                }
            }
        }
    }
    func defineAudioService(audioService: AudioService){
        self.audioService = audioService
    }
}
