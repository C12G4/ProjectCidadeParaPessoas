//
//  ARController.swift
//  ProjectCidadeParaPessoas
//
//  Created by Jonas Fernando Nascimento Melo on 30/03/26.
//
import UIKit
import AVFoundation

class AudioService: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    static let shared = AudioService()
        ....
    
    //MARK: - Adição de teste para botão de gravar áudio
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    let audioSession = AVAudioSession.sharedInstance()
    
    //MARK: - Teste do botão de áudio abaixo
   // talvez ser privado
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

    @objc func startRecording(_ sender: Any) {
        audioSession.requestRecordPermission { [weak self] granted in
            guard let self = self else { return }

            DispatchQueue.main.async {
                guard granted else { return }
                guard self.audioRecorder?.isRecording == false else { return }

                do {
                    try self.audioSession.setActive(true)
                    self.audioRecorder?.record()
                } catch {
                    print("Erro ao ativar sessão: \(error)")
                }
            }
        }
    }

    @objc func stopRecordingIfNeeded(_ sender: Any) {
        if audioRecorder?.isRecording == true {
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
