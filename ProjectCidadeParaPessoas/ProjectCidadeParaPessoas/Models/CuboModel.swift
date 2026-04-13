////
////  CuboModel.swift
////  ProjectCidadeParaPessoas
////
////  Created by Vinicius Marques on 01/04/26.
////

import UIKit
import UniformTypeIdentifiers
import CoreTransferable
import RealityKit

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
    // tipo de arquivo customizado do app (.person)
    // precisa ser o mesmo que ta no info.plist
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
        // placeholder obrigatorio da API de compartilhamento
        return name
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        // converte o payload em JSON e salva em .person
        // esse arquivo que o sistema entende e usa para aparecer a funcao de "Abrir em..." (ai abre com o nosso app)
        guard let jsonData = try? JSONEncoder().encode(self) else { return nil }
        let fileURL = URL.temporaryDirectory.appendingPathComponent("\(id.uuidString).person")
        try? jsonData.write(to: fileURL, options: .atomic)
        return fileURL
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "Sharing Card: \(name)"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
        // informa o tipo do arquivo que foi compartilhado
        return UTType.personType.identifier
    }
}

extension Person:@preconcurrency Transferable {
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
