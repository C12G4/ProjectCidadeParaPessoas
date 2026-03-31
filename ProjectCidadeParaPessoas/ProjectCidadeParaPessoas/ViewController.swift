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
        var encoder = JSONEncoder()
        var json = try? encoder.encode("nadanada")
        let url = URL(string: "card.share://profile?name=\(json)")
        
       // let cardObject = CardObject(json: json!)
                let items = [url]
                let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                present(ac, animated: true)
            }
    }


