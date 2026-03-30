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
    required init(frame: CGRect){
        super.init(frame: frame)
    }
    
    @MainActor @preconcurrency required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(){
        self.init(frame: UIScreen.main.bounds)
        setup()
    }
        
    func setup() {
        configuration()
    }
    
    func creatObj(color: UIColor) {
        let objeto = MeshResource.generateBox(size: 0.1)
        let material = SimpleMaterial(color: color, isMetallic: true)
        let entidade = ModelEntity(mesh: objeto, materials: [material])
        
        let ancora = AnchorEntity(world: .zero)
        
        ancora.addChild(entidade)
        
        scene.addAnchor(ancora)
    }
    
    func configuration(){
        let configuration = ARWorldTrackingConfiguration()
        session.run(configuration)
    }
}
