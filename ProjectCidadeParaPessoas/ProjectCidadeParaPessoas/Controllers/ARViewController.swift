//
//  ARController.swift
//  ProjectCidadeParaPessoas
//
//  Created by Jonas Fernando Nascimento Melo on 30/03/26.
//
import UIKit

class ARViewController: UIViewController {
    
    @objc func share(_ sender: Any) {
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
    
    let custonARView: CustomARView = {
        let view = CustomARView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let audioButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let configImage = UIImage.SymbolConfiguration(pointSize: 40)
        let image = UIImage(systemName: "microphone.fill", withConfiguration: configImage)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        
        var config = UIButton.Configuration.plain()
        
        config.image = image
        config.imagePlacement = .all
        config.background.backgroundColor = UIColor(named: "ButtonColor")
        config.background.cornerRadius = 1000
        config.imagePadding = 12.88
        
        button.configuration = config
        return button
    }()
    
    let searchButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        var configImage = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
        let image = UIImage(systemName: "magnifyingglass", withConfiguration: configImage)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        
        var config = UIButton.Configuration.plain()
        
        config.image = image
        config.imagePlacement = .all
        config.background.backgroundColor = UIColor(named: "ButtonColor")
        config.background.cornerRadius = 1000
        config.imagePadding = 12.88
        
        button.configuration = config
        return button
    }()
    
    let shareButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let configImage = UIImage.SymbolConfiguration(pointSize: 40)
        let image = UIImage(systemName: "square.and.arrow.up", withConfiguration: configImage)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        
        var config = UIButton.Configuration.plain()
        
        config.image = image
        config.imagePlacement = .all
        config.background.backgroundColor = UIColor(named: "ButtonColor")
        config.background.cornerRadius = 1000
        config.imagePadding = 12.88
        
        button.configuration = config
        return button
    }()
    
    let libraryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let configImage = UIImage.SymbolConfiguration(pointSize: 20)
        let image = UIImage(systemName: "book.fill", withConfiguration: configImage)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        
        var config = UIButton.Configuration.plain()
        
        config.image = image
        config.imagePlacement = .all
        config.background.backgroundColor = UIColor(named: "ButtonColor")
        config.background.cornerRadius = 1000
        config.imagePadding = 12.88
        
        button.configuration = config
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
    }

    func setupController() {
        //configure view
        audioButton.layer.zPosition = 10
        
        //add subviews
        view.addSubview(custonARView)
        view.addSubview(audioButton)
        view.addSubview(searchButton)
        view.addSubview(libraryButton)
        view.addSubview(shareButton)
        
        //target
        
        shareButton.addTarget(self, action: #selector(share(_:)), for: .touchUpInside)
        
        // add constrains
        NSLayoutConstraint.activate([
            custonARView.topAnchor.constraint(equalTo: view.topAnchor),
            custonARView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            custonARView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            custonARView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            audioButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 102.38),
            audioButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32.25),
            audioButton.widthAnchor.constraint(equalToConstant: 78),
            audioButton.heightAnchor.constraint(equalToConstant: 78),
            
            searchButton.leadingAnchor.constraint(equalTo: audioButton.trailingAnchor, constant: 32.65),
            searchButton.bottomAnchor.constraint(equalTo: audioButton.bottomAnchor),
            searchButton.widthAnchor.constraint(equalToConstant: 78),
            searchButton.heightAnchor.constraint(equalToConstant: 78),
            
            libraryButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 64),
            libraryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            libraryButton.widthAnchor.constraint(equalToConstant: 52),
            libraryButton.heightAnchor.constraint(equalToConstant: 52),
            
            shareButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 120.38),
            shareButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200),
            shareButton.widthAnchor.constraint(equalToConstant: 78),
            shareButton.heightAnchor.constraint(equalToConstant: 78),
        ])
    }
}
