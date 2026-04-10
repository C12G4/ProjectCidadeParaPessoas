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

class CustomARView: ARView {
    var anchor = AnchorEntity(world: .zero)
    
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
}
