//
//  Card.swift
//  UIKitPocs
//
//
//  Created by Vinicius Alves Marques on 22/10/25.
//

import UIKit
import UniformTypeIdentifiers
import SwiftUI


extension UTType {
    static var card: UTType = .init(exportedAs: "com.ProjectCidadesParaPesoa.card")
}

nonisolated
struct Card: Decodable, Encodable {
    var title: String
    let texto: String
}

class CardObject: NSObject {
    let json: Data
    
    init(json: Data) {
        self.json = json
    }
}


extension CardObject: UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return json
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return self
}
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "Sharing Card: \(json)"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
        return UTType.card.identifier
    }
    
}
