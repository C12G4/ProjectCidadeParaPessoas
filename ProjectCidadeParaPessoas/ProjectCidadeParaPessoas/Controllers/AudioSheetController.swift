//
//  AudioSheetController.swift
//  ProjectCidadeParaPessoas
//
//  Created by Tamires Mendes da Silva on 13/04/26.
//

import UIKit

class AudioSheetController: UIViewController {
    var audioUrl: String = ""
    
    let squareBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 40
        view.layer.maskedCorners = [.layerMinXMinYCorner]
        view.backgroundColor = .white //mudar aqui p offWhite
        
        return view
    }()
    
    let squareMain: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .orangeDark
        view.cornerConfiguration = .corners(
            topLeftRadius: .fixed(40), topRightRadius: .fixed(0), bottomLeftRadius: .fixed(0), bottomRightRadius: .fixed(120)
        )
        return view
    }()
    
    let horizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 24
        
        return stack
    }()
    
    let textStack: UIStackView = {
        let label = UIStackView()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.axis = .vertical
        label.spacing = 8
        
        return label
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        label.text = "Meu relato"
        label.textColor = .black
        
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .thin)
        label.text = "21 de Abril, 2026"
        label.textColor = .black
        
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.text = "1:32"
        label.textColor = .black
        
        return label
    }()
    
    let exitButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let configImage = UIImage.SymbolConfiguration(pointSize: 24)
        let image = UIImage(systemName: "xmark", withConfiguration: configImage)?.withTintColor(.black, renderingMode: .alwaysOriginal)
        
        var config = UIButton.Configuration.glass()
        
        config.image = image
        config.imagePlacement = .all
        config.background.cornerRadius = 1000
        config.imagePadding = 12.88
        
        button.configuration = config
        return button
    }()
    
    let playAudioButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let configImage = UIImage.SymbolConfiguration(pointSize: 24)
        let image = UIImage(systemName: "play.fill", withConfiguration: configImage)?.withTintColor(.black, renderingMode: .alwaysOriginal)
        
        var config = UIButton.Configuration.glass()
        
        config.image = image
        config.imagePlacement = .all
        config.background.cornerRadius = 1000
        config.imagePadding = 12.88
        
        button.configuration = config
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        view.addSubview(squareBackground)
        view.addSubview(squareMain)
        view.addSubview(horizontalStack)
        view.addSubview(textStack)
        view.addSubview(exitButton)
        view.addSubview(playAudioButton)
        view.addSubview(timeLabel)
        
        textStack.addArrangedSubview(nameLabel)
        textStack.addArrangedSubview(dateLabel)
        
        horizontalStack.addArrangedSubview(timeLabel)
        horizontalStack.addArrangedSubview(playAudioButton)
        
        NSLayoutConstraint.activate([
            squareBackground.heightAnchor.constraint(equalToConstant: 484),
            squareBackground.widthAnchor.constraint(equalToConstant: 393),
            squareBackground.topAnchor.constraint(equalTo: view.topAnchor, constant: 243),
            
            squareMain.heightAnchor.constraint(equalToConstant: 400),
            squareMain.widthAnchor.constraint(equalToConstant: 393),
            squareMain.topAnchor.constraint(equalTo: squareBackground.topAnchor),
            
            textStack.topAnchor.constraint(equalTo: squareMain.topAnchor, constant: 30),
            textStack.leadingAnchor.constraint(equalTo: squareMain.leadingAnchor, constant: 32),
            
            exitButton.topAnchor.constraint(equalTo: squareMain.topAnchor, constant: 24),
            exitButton.trailingAnchor.constraint(equalTo: squareMain.trailingAnchor, constant: -24),
            
            horizontalStack.topAnchor.constraint(equalTo: squareMain.bottomAnchor, constant: 16),
            horizontalStack.trailingAnchor.constraint(equalTo: squareBackground.trailingAnchor, constant: -24)
        ])
    }
}

#Preview {
    AudioSheetController()
}

