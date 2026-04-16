//
//  GeoSerive.swift
//  ProjectCidadeParaPessoas
//
//  Created by Jonas Fernando Nascimento Melo on 31/03/26.
//
import CoreMotion
import Foundation
import CoreLocation
import MapKit

class GeoSerive: NSObject {
    var locationManager = CLLocationManager()
    var geocoder = CLGeocoder()

    override init(){
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func getActualLocation() -> CLLocation? {
        locationManager.requestLocation()
        return locationManager.location
    }

    func resolvePlaceName(location: CLLocation?, fallbackName: String, completion: @escaping (String) -> Void) {
        guard let location = location else {
            completion(fallbackName)
            return
        }

        if let request = MKReverseGeocodingRequest(location: location) {
            request.preferredLocale = Locale(identifier: "pt_BR")
            request.getMapItems { [weak self] mapItems, _ in
                let mapItem = mapItems?.first
                let mapKitName = self?.bestNameFromMapItem(mapItem)

                if let mapKitName, !mapKitName.isEmpty {
                    DispatchQueue.main.async {
                        completion(mapKitName)
                    }
                    return
                }

                self?.resolvePlaceNameWithCLGeocoder(location: location, fallbackName: fallbackName, completion: completion)
            }
            return
        }

        resolvePlaceNameWithCLGeocoder(location: location, fallbackName: fallbackName, completion: completion)
    }

    func resolvePlaceNameWithCLGeocoder(location: CLLocation, fallbackName: String, completion: @escaping (String) -> Void) {
        geocoder.reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "pt_BR")) { [weak self] placemarks, _ in
            let place = placemarks?.first
            let resolvedName = self?.bestNameFromPlacemark(place) ?? fallbackName

            DispatchQueue.main.async {
                completion(resolvedName)
            }
        }
    }

    func bestNameFromMapItem(_ item: MKMapItem?) -> String? {
        guard let item else { return nil }

        let mapItemName = normalizedLocationName(item.name)
        let placemarkName = bestNameFromPlacemark(item.placemark)

        if let mapItemName,
           mapItemName != normalizedLocationName(item.placemark.locality),
           mapItemName != normalizedLocationName(item.placemark.administrativeArea) {
            return mapItemName
        }

        return placemarkName
    }

    func bestNameFromPlacemark(_ place: CLPlacemark?) -> String? {
        guard let place else { return nil }

        let specificCandidates = [
            place.areasOfInterest?.first,
            place.name,
            composedStreetName(place),
            place.thoroughfare,
            place.subLocality
        ]

        let genericCandidates = [
            place.locality,
            place.subAdministrativeArea,
            place.administrativeArea,
            place.country
        ]

        for candidate in specificCandidates {
            let normalized = normalizedLocationName(candidate)
            if let normalized,
               normalized != normalizedLocationName(place.locality),
               normalized != normalizedLocationName(place.administrativeArea) {
                return normalized
            }
        }

        for candidate in genericCandidates {
            let normalized = normalizedLocationName(candidate)
            if let normalized {
                return normalized
            }
        }

        return nil
    }

    func composedStreetName(_ place: CLPlacemark) -> String? {
        guard let thoroughfare = normalizedLocationName(place.thoroughfare) else { return nil }

        if let subThoroughfare = normalizedLocationName(place.subThoroughfare) {
            return "\(subThoroughfare), \(thoroughfare)"
        }

        return thoroughfare
    }

    func normalizedLocationName(_ value: String?) -> String? {
        guard let value else { return nil }
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return normalized.isEmpty ? nil : normalized
    }
    
    func checkLocationAuthorization() {
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
