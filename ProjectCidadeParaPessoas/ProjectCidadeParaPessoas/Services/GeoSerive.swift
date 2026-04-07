//
//  GeoSerive.swift
//  ProjectCidadeParaPessoas
//
//  Created by Jonas Fernando Nascimento Melo on 31/03/26.
//
import CoreMotion
import Foundation

class GeoSerive: NSObject {
    var locationManager = CLLocationManager()

    override init(){
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func getActualLocation() -> CLLocation {
        locationManager.requestLocation()
        return locationManager.location!
    }
    
    
    
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Permitido")
        case .denied:
            print("Negado")
        case .notDetermined, .restricted:
            print("Indeterminado ou restrito")
        @unknown default:
            print("Desconhecido")
        }
    }
}

extension GeoSerive: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
