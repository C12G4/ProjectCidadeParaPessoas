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
//import UIKit
//import UniformTypeIdentifiers
//import CoreTransferable
//
//
//nonisolated
//struct Person: Decodable, Encodable {
//    let name: String
//    let id: UUID
//}
//
//extension UTType {
//    static var personType: UTType = .init(exportedAs: "com.testApp.person")
//}
//
//extension Person: @preconcurrency Transferable {
//    static var transferRepresentation: some TransferRepresentation {
//        CodableRepresentation(contentType: .personType)
//        DataRepresentation(importedContentType: .personType) { data in
//            let person = try JSONDecoder().decode(Person.self, from: data)
//            return person
//        }
//        DataRepresentation(exportedContentType: .personType) { person in
//            let data = try JSONEncoder().encode(person)
//            return data
//        }
//        FileRepresentation(contentType: .personType) { person in
//            let docsURL = URL.temporaryDirectory.appendingPathComponent("\(person.name)\(UUID().uuidString)", conformingTo: await .personType)
//            let data = try JSONEncoder().encode(person)
//            try data.write(to: docsURL)
//            return SentTransferredFile(docsURL)
//        } importing: { received in
//            let data = try Data(contentsOf: received.file)
//            let person = try JSONDecoder().decode(Person.self, from: data)
//            return person
//        }
//    }
//}
