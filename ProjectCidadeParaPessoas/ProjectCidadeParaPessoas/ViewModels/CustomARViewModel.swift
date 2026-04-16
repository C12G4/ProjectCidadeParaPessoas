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
    private var initialLocation = CLLocation(latitude: 0, longitude: 0)
    var geoService = GeoSerive()
    
    var fistTime: Bool = true
    var count = -0.1
    var numOfSons = 0
    
    init() {
    }
    
    func creatObj(color: UIColor, cameraTransform: Transform, id: String) -> ModelEntity{
        let object = MeshResource.generateBox(size: 0.1)
        let material = SimpleMaterial(color: color, isMetallic: false)
        let entity = ModelEntity(mesh: object, materials: [material])

        entity.position.x = cameraTransform.translation.x
        entity.position.y = 0
        entity.position.z = cameraTransform.translation.z
        entity.generateCollisionShapes(recursive: true)
        entity.name = id
        return entity
    }
    
    private func gpsToSIMD3(lat: Double, lon: Double) -> SIMD3<Float> {
        let radius = 6378.137
        
        let lon1 = initialLocation.coordinate.longitude * Double.pi / 180.0
        let lat1 = initialLocation.coordinate.latitude * Double.pi / 180.0
        
        let lon2 = lon * Double.pi / 180
        let lat2 = lat * Double.pi / 180
        
        let dLat = (lat - initialLocation.coordinate.latitude) * Double.pi / 180.0
        let dLon = (lon - initialLocation.coordinate.longitude) * Double.pi / 180.0
        
        let a = sin(dLat/2) * sin(dLat/2) + cos(lat1) * cos(lat2) * sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        let z = sqrt(a) * radius
        let x = sqrt(1-a) * radius
        
        return SIMD3<Float>(Float(dLat), Float(0), Float(dLon))
    }
    
    func renderAllMemories(arView: CustomARView) {
        let cards = CoreDataService.shared.fetchAllCards()
        for card in cards {
            let cardPosition = gpsToSIMD3(lat: card.lat, lon: card.longe)
            let object = MeshResource.generateBox(size: 0.1)
    
            let material = SimpleMaterial(color: card.compartilhado ? UIColor.green : UIColor.blue, isMetallic: false)
        
            let entity = ModelEntity(mesh: object, materials: [material])
            
            entity.position.x = cardPosition.x * 1000000
            entity.position.y = 0
            entity.position.z = cardPosition.z * 1000000
            entity.generateCollisionShapes(recursive: true)
            entity.name = card.id?.uuidString ?? "No ID"
            
            arView.anchor.addChild(entity)
        }
    }
    
    func deleteAllRenderd(arView: CustomARView){
        arView.anchor.children.removeAll()
    }
    
    func setInitialLocation(){
        initialLocation = geoService.getActualLocation() ?? CLLocation(latitude: 0, longitude: 0)
    }
}
