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

class CustomARViewModel {
    private var initialLocation = CLLocation()
    private var actualLocation = CLLocation()
    private var acualLocation = CLLocationDistance()
    
    var fistTime: Bool = true
    
    var geoService = GeoSerive()
    var count = -0.1
    var numOfSons = 0
    
    init() {
        initialLocation = geoService.getActualLocation()
    }
    
    func creatObj(color: UIColor, cameraTransform: Transform) -> ModelEntity{
        let object = MeshResource.generateBox(size: 0.1)
        let material = SimpleMaterial(color: color, isMetallic: false)
        let entity = ModelEntity(mesh: object, materials: [material])
        
        let position = gpsToSIMD3()
        entity.position.x = position.x * -10000
        entity.position.y = position.y
        entity.position.z = position.z * 100
        print(entity.position.z)
        entity.name = "filho numero: \(numOfSons)"
        numOfSons += 1
    
        
        print(entity.position.x)
        return entity
    }
    
    private func gpsToSIMD3() -> SIMD3<Float> {
        updateActualLocation()
        let radius = 6371.0
        
        let lon1 = initialLocation.coordinate.longitude * Double.pi / 180.0
        let lat1 = initialLocation.coordinate.latitude * Double.pi / 180.0
        
        let lon2 = actualLocation.coordinate.longitude * Double.pi / 180.0
        let lat2 = actualLocation.coordinate.latitude * Double.pi / 180.0
        
        let dLat = (actualLocation.coordinate.latitude - initialLocation.coordinate.latitude) * Double.pi / 180.0
        let dLon = (actualLocation.coordinate.longitude - initialLocation.coordinate.longitude) * Double.pi / 180.0
        
        let a = sin(dLat/2) * sin(dLat/2) + cos(lat1) * cos(lat2) * sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        let z = sqrt(a) * radius
        let x = sqrt(1-a) * radius
        let d = radius * c
        
        count += 0.1
        print(z)
        return SIMD3<Float>(Float(0), Float(0), Float(x))
    }
    
    private func updateActualLocation(){
        actualLocation = geoService.getActualLocation()
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
    }
}
