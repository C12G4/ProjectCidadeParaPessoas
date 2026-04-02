//
//  Card2.swift
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


nonisolated
class Card2: NSObject, Decodable, Encodable{
    let title: String
    let texto: String
    let audio: String
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.texto = try container.decode(String.self, forKey: .texto)
        self.audio = try container.decode(String.self, forKey: .audio)
        super.init()
    }
    
    init(title: String, texto: String, audio: String) throws {
        self.title = title
        self.texto = texto
        self.audio = audio
    }
}
