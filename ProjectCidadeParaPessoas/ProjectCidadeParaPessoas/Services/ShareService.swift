////
////  ViewController.swift
////  ProjectCidadeParaPessoas
////
////  Created by Vinicius Marques on 27/03/26.
////
//
//import UIKit
////transformar em service e singleton-enviroment
//
//
//final class ShareService {
//    
//    static let shared = ShareService()
//        
//    private init() {}
//    
//    func share(card: Card2) -> Any{
//        let encoder = JSONEncoder()
//        let json = try? encoder.encode(card)
//        let convertedString = String(data: json ?? Data(), encoding: .utf8)
//        let url = URL(string: "card.share://profile?name=\(convertedString ?? "CardFalhaTextoURL")")
//        print(url)
//        
//        // let cardObject = CardObject(json: json!)
//        let items = [url] as [Any]
//        return items
//    }
//    
//}
//
//
