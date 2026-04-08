////
////  Card2.swift
////  ProjectCidadeParaPessoas
////
////  Created by Vinicius Marques on 01/04/26.
////
//
//
////
////  Card.swift
////  UIKitPocs
////
////
////  Created by Vinicius Alves Marques on 22/10/25.
////
//
import UIKit
import UniformTypeIdentifiers

struct Person: Decodable, Encodable {
    let name: String
    let id: UUID
    let lat: Double
    let longe: Double
    let audio: String
}

extension UTType {
    static var personType: UTType = .init(exportedAs: "com.testApp.person")
}

class PersonObject: NSObject, Encodable, Decodable{
    
    let name: String
    let id: UUID
    let lat: Double
    let longe: Double
    let audio: String
    
    init(person: Person) {
        self.name = person.name
        self.id = person.id
        self.lat = person.lat
        self.longe = person.longe
        self.audio = person.audio
    }
}

extension PersonObject: UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return name
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        let encoder = JSONEncoder()
        let jsonData = try? encoder.encode(self)
        return jsonData
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "Sharing Person: \(name)"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
        return UTType.personType.identifier
    }
}
