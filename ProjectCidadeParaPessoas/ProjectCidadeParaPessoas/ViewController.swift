//
//  ViewController.swift
//  ProjectCidadeParaPessoas
//
//  Created by Vinicius Marques on 27/03/26.
//

import UIKit


class ViewController: UIViewController {
    
    //card vira json
    override func viewDidLoad() {
        let card =  Card(title: "asdadsdas",texto: "turn aroud everybody that......")
        let encoder = JSONEncoder()
        let json = try? encoder.encode("nadanada")
        let url = URL(string: "card.share://profile?name=\(json ?? Data())")
        print(url)
        
       // let cardObject = CardObject(json: json!)
                let items = [url]
                let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                present(ac, animated: true)
            }
    }


