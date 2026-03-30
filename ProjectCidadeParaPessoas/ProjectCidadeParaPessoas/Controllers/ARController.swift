//
//  ARController.swift
//  ProjectCidadeParaPessoas
//
//  Created by Jonas Fernando Nascimento Melo on 30/03/26.
//
import UIKit

class ARController: UIViewController {
    let custonARView: CustomARView = {
        let view = CustomARView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
    }

    func setupController() {
        //configure view

        //add subviews
        view.addSubview(custonARView)
        
        // add constrains
        NSLayoutConstraint.activate([
            custonARView.topAnchor.constraint(equalTo: view.topAnchor),
            custonARView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            custonARView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            custonARView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}
