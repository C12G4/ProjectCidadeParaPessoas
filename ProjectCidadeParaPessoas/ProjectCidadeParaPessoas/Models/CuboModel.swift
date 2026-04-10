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
import CoreTransferable

nonisolated
struct Person: Decodable, Encodable, Sendable {
    let name: String
    let id: UUID
    let lat: Double
    let longe: Double
    let audio: String
    let compartilhado: Bool
    let audioData: Data?
}

extension UTType {
    public static let personType: UTType = .init(exportedAs: "com.testApp.person")
}

class PersonObject: NSObject, Encodable, Decodable{
    
    let name: String
    let id: UUID
    let lat: Double
    let longe: Double
    let audio: String
    let compartilhado: Bool
    let audioData: Data?
    
    init(person: Person) {
        self.name = person.name
        self.id = person.id
        self.lat = person.lat
        self.longe = person.longe
        self.audio = person.audio
        self.compartilhado = person.compartilhado
        self.audioData = person.audioData
    }
}

extension PersonObject: UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return name
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        guard let jsonData = try? JSONEncoder().encode(self) else { return nil }
        let fileURL = URL.temporaryDirectory.appendingPathComponent("\(id.uuidString).person")
        try? jsonData.write(to: fileURL, options: .atomic)
        return fileURL
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "Sharing Card: \(name)"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
        return UTType.personType.identifier
    }
}

extension Person:@preconcurrency Transferable {
    @available(iOS 16.0, *)
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .personType)
        DataRepresentation(importedContentType: .personType) { data in
            let person = try JSONDecoder().decode(Person.self, from: data)
            return person
        }
        DataRepresentation(exportedContentType: .personType) { person in
            let data = try JSONEncoder().encode(person)
            return data
        }
        FileRepresentation(contentType: .personType) { person in
            let docsURL = URL.temporaryDirectory.appendingPathComponent("\(person.name)\(UUID().uuidString)", conformingTo: await .personType)
            let data = try JSONEncoder().encode(person)
            try data.write(to: docsURL)
            return SentTransferredFile(docsURL)
        } importing: { received in
            let data = try Data(contentsOf: received.file)
            let person = try JSONDecoder().decode(Person.self, from: data)
            return person
        }
    }
}
