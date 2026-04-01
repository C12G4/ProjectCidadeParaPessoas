//
//  ViewController.swift
//  ProjectCidadeParaPessoas
//
//  Created by Vinicius Marques on 27/03/26.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
          let card =  Card2(title: "asdadsdas",texto: "turn aroud everybody that......")
          let encoder = JSONEncoder()
          let json = try? encoder.encode("nadanada")
          let url = URL(string: "card.share://profile?name=\(json ?? Data())")
          print(url)
          
         // let cardObject = CardObject(json: json!)
                  let items = [url, card] as [Any]
                  let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                  present(ac, animated: true)
              }
}

