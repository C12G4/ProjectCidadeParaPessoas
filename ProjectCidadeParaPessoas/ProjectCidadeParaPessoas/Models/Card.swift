//
//  Card.swift
//  ProjectCidadeParaPessoas
//
//  Created by Vinicius Marques on 01/04/26.
//


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

// Source - https://stackoverflow.com/a/36206692
// Posted by ccjensen
// Retrieved 2026-03-31, License - CC BY-SA 3.0

class Card: NSObject, UIActivityItemSource {
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return myData
    }
    
    
    let myData: NSData
    
    init(myData: NSData, typeIdentifier: String, subject: String, previewImage: UIImage) {
        self.myData = myData
    }
    
    // called to determine data type. only the class of the return type is consulted. it should match what -itemForActivityType: returns later
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any  {
        return myData
    }
    
    // called to fetch data after an activity is selected. you can return nil.
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> Any? {
        return myData
    }
}
