//
//  SharedViewController.swift
//  ProjectCidadeParaPessoas
//
//  Created by Vinicius Marques on 01/04/26.
//


//
//  SharedViewController.swift
//  POC_share
//
//  Created by Pedro Augusto on 30/03/26.
//

import UIKit

class SharedViewController: UIViewController {
    
    let card: Card2
    
    init(card: Card2) {
        self.card = card
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let label: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 23)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    let label2: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 23)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(label)
        view.addSubview(label2)
        label.text = card.texto
        label2.text = card.title
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            label2.topAnchor.constraint(equalTo: label.topAnchor, constant: 20),
            label2.centerXAnchor.constraint(equalTo: label.centerXAnchor),
            label2.bottomAnchor.constraint(equalTo: label.bottomAnchor)
        ])
    }
}
