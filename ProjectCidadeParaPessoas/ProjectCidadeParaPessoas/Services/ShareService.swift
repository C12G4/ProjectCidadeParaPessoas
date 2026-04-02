//
//  ViewController.swift
//  ProjectCidadeParaPessoas
//
//  Created by Vinicius Marques on 27/03/26.
//

import UIKit

//transformar em service e singleton-enviroment

final class ShareService: UIViewController {
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
     func share(_ sender: Any) {
          let card =  Card2(title: "asdadsdas",texto: "turn aroud everybody that......", audio: "leroleroleor")
          let encoder = JSONEncoder()
          let json = try? encoder.encode(card)
          let convertedString = String(data: json ?? Data(), encoding: .utf8)
        let url = URL(string: "card.share://profile?name=\(convertedString ?? "bleble")")
          print(url)

         // let cardObject = CardObject(json: json!)
                  let items = [url] as [Any]
                  let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                  present(ac, animated: true)
              }
    
}
    

