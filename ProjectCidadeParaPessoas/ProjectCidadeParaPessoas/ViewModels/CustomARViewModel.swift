//
//  customARViewModel.swift
//  ProjectCidadeParaPessoas
//
//  Created by Jonas Fernando Nascimento Melo on 31/03/26.
//
import CoreMotion
import UIKit
import RealityKit
import ARKit
import Foundation
import SwiftUI

class CustomARViewModel {
    private var initialLocation = CLLocation()
    private var actualLocation = CLLocation()
    private var acualLocation = CLLocationDistance()
    
    var fistTime: Bool = true
    
    var geoService = GeoSerive()
    var count = 0.0
    
    let anchor = AnchorEntity(world: .zero)

    init() {
        initialLocation = geoService.getActualLocation()!
    }
    
    func creatObj(color: UIColor,arView: ARView) -> AnchorEntity{
        let object = MeshResource.generateBox(size: 0.1)
        let material = SimpleMaterial(color: color, isMetallic: false)
        let entity = ModelEntity(mesh: object, materials: [material])

        entity.position.x = arView.cameraTransform.translation.x
        entity.position.y = 0
        entity.position.z = arView.cameraTransform.translation.x
        entity.generateCollisionShapes(recursive: true)
        
        anchor.addChild(entity)
        
        return anchor
    }
    
    private func gpsToSIMD3() -> SIMD3<Float> {
//        let radius = 6378.137
        
        let longitudeA = initialLocation.coordinate.longitude * Double.pi / 180.0
        let latitudeA = initialLocation.coordinate.latitude * Double.pi / 180.0
        
        let longitudeB = actualLocation.coordinate.longitude * Double.pi / 180.0
        let latitudeB = actualLocation.coordinate.latitude * Double.pi / 180.0
        
        let xA = cos(latitudeA) * cos(longitudeA)
//        let zA = sin(latitudeA)
        let zA = cos(latitudeA) * sin(longitudeA)
        
        let xB = cos(latitudeB) * cos(longitudeB)
//        let zB = sin(latitudeB)
        let zB = cos(latitudeB) * sin(longitudeB)

        let x = xB - xA
        let z = zB - zA
        
        return SIMD3<Float>(Float(x), Float(count), Float(z))
    }
    
    private func updateActualLocation(){
        actualLocation = geoService.getActualLocation()!
    }
    
    func rosaDosVentos(){
        let object1 = MeshResource.generateBox(size: 0.1)
        let material1 = SimpleMaterial(color: UIColor.blue, isMetallic: false)
        let material2 = SimpleMaterial(color: UIColor.green, isMetallic: false)
        let entity1 = ModelEntity(mesh: object1, materials: [material1])
        entity1.position.x = 1
        entity1.position.y = -0.5
        let entity2 = ModelEntity(mesh: object1, materials: [material2])
        entity2.position.x = -1
        entity2.position.y = -0.5

        let object3 = MeshResource.generateBox(size: 0.1)
        let material3 = SimpleMaterial(color: UIColor.red, isMetallic: false)
        let material4 = SimpleMaterial(color: UIColor.orange, isMetallic: false)
        let entity3 = ModelEntity(mesh: object3, materials: [material3])
        entity3.position.z = 1
        entity3.position.y = -0.5
        let entity4 = ModelEntity(mesh: object3, materials: [material4])
        entity4.position.z = -1
        entity4.position.y = -0.5
        
        let object5 = MeshResource.generateBox(size: 0.1)
        let material5 = SimpleMaterial(color: UIColor.gray, isMetallic: false)
        let entity5 = ModelEntity(mesh: object5, materials: [material5])

        anchor.addChild(entity1)
        anchor.addChild(entity2)
        anchor.addChild(entity3)
        anchor.addChild(entity4)
        anchor.addChild(entity5)
    }
}
