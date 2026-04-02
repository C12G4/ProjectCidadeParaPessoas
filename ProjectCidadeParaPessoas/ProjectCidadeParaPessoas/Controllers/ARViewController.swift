//
//  ARController.swift
//  ProjectCidadeParaPessoas
//
//  Created by Jonas Fernando Nascimento Melo on 30/03/26.
//
import UIKit
import AVFoundation

class ARViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    //MARK: - Adição de teste para botão de gravar áudio
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    let audioSession = AVAudioSession.sharedInstance()
    
    let audioService = AudioService()
    
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
        audioInit()
    }

    func setupController() {
        //configure view
        audioButton.layer.zPosition = 10
        
        //add subviews
        view.addSubview(custonARView)
        view.addSubview(searchButton)
        view.addSubview(audioButton)
        
        view.addSubview(libraryButton)
        
        // addTarget
        searchButton.addTarget(self, action: #selector(playAudio(_:)), for: .touchUpInside)
        
        audioButton.addTarget(self, action: #selector(recordTouchDown(_:)), for: .touchUpInside)
        audioButton.addTarget(self, action: #selector(recordTouchUpInside(_:)), for: .touchUpInside)
        audioButton.addTarget(self, action: #selector(recordTouchDragExit(_:)), for: .touchUpInside)
    
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
        ])
    }
    
    //MARK: - Teste do botão de áudio abaixo
    
    func audioInit() {
        /// !!! Initially, this place was used for turning the functions playButton and stopButton as false, since no audio was recorded at the beginning
     
        /// these following 'let' - fileMgr, dirPaths, soundFileURL - looks out for the documents directory from the app and constructs a URL to a file in that location
        /// named sound.caf
        let fileMgr = FileManager.default
        let dirPaths = fileMgr.urls(for: .documentDirectory,
                                    in: .userDomainMask)
        let soundFileURL = dirPaths[0].appendingPathComponent("sound.caf")
        
        /// here we are able to configure the audio quality by creating a Dictionary with all the configuration
        let recordSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        /// error treatments for the audioRecorder, garanting that the audio will be recorded when requested to do so by the user
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        
        do {
            try audioRecorder = AVAudioRecorder(url: soundFileURL,
                                                settings: recordSettings)
            audioRecorder?.delegate = self
            audioRecorder?.prepareToRecord()
        } catch let error as NSError {
            print("audioRecorder error: \(error.localizedDescription)")
        }
    }
    
    
    
    @objc func recordTouchDown(_ sender: Any) {
        startRecording()
    }

    @objc func recordTouchUpInside(_ sender: Any) {
        stopRecordingIfNeeded()
    }

    @objc func recordTouchDragExit(_ sender: Any) {
        stopRecordingIfNeeded()
    }
    
    /// record audio method
    @objc func startRecording() {
        audioSession.requestRecordPermission { [weak self] granted in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if granted {
                    if self.audioRecorder?.isRecording == false {
                        do {
                            print("gravando")
                            try self.audioSession.setActive(true)
                        } catch {
                            print("Erro ao ativar sessão: \(error)")
                        }
//                        self.playButton.isEnabled = false
//                        self.stopButton.isEnabled = true
                        self.audioRecorder?.record()
                    }
                } else {
                    let alert = UIAlertController(title: "Permissão negada", message: "Habilite o microfone nos Ajustes.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
//                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    private func stopRecordingIfNeeded() {
        if audioRecorder?.isRecording == true {
            print("touchUpInside")
            audioRecorder?.stop()
            do { try audioSession.setActive(false) } catch { }
        }
    }
    
    @objc func playAudio(_ sender: Any) {
        if audioRecorder?.isRecording == false {
            /// here it turned the stopButton and recordButton as false, and only that
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: (audioRecorder?.url)!)
                audioPlayer?.volume = 1.0
                audioPlayer!.delegate = self
                audioPlayer!.prepareToPlay()
                audioPlayer!.play()
                print("TOCANDO ÁUDIO")
            } catch let error as NSError {
                print("audioPlayer error: \(error.localizedDescription)")
            }
        }
    }
}
