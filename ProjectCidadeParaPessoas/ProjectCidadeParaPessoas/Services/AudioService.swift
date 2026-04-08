//
//  AudioService.swift
//  UIKitPocs
//
//  Created by Tamires Mendes on 31/03/26.
//

/// Code Documentation
///
///# Initial Variables #
/// - var audioPlayer: this variable its used to controll the audio player, from recorded audios
/// - var audioRecorder: this variable its used to controll the processo of recording audios
///
/// # Notes: #
/// 1. The AVFoundation is an import used to get and manipulate the audio file
/// 2. AVAudioPlayerDelegate its a protocol that defines the methods to respond to audio playback events and decoding errors
/// 3. AVAudioRecorderDelegate its the same as the previous mention, except its focus is on the audio record

import UIKit
import AVFoundation
import Combine

class AudioService: NSObject, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    let audioSession = AVAudioSession.sharedInstance()
    var onRecordingStateChanged: ((Bool) -> Void)?
    var coreDataController = CoreDataController()
    
    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }
    
    //MARK: - This function has the purpose of managing the audio player, doing the treatment of the audio paths
    func audioInit() {
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
    
    //MARK: - The following action methods will implement it to the three buttons created previously
    /// record audio method
    @objc func startRecording() {
        audioSession.requestRecordPermission { [weak self] granted in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if granted {
                    if self.audioRecorder?.isRecording == false {
                        do {
                            try self.audioSession.setActive(true)
                        } catch {
                            print("Erro ao ativar sessão: \(error)")
                        }
                        self.audioRecorder?.record()
                        self.onRecordingStateChanged?(true)
                    }
                } else {
                    let alert = UIAlertController(title: "Permissão negada", message: "Habilite o microfone nos Ajustes.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                }
            }
        }
    }
    
    /// stop recording if needed method
    func stopRecordingIfNeeded() {
        if audioRecorder?.isRecording == true {
            audioRecorder?.stop()
            do { try audioSession.setActive(false) } catch { }
            onRecordingStateChanged?(false)
            coreDataController.createCard(name: "abacate", id: UUID(), lat: 0, longe: 0, audio: audioRecorder?.url.absoluteString ?? "não veio")
        }
    }
    
    /// play audio method
    @objc func playAudio(_ sender: Any) {
        if audioRecorder?.isRecording == false {
            /// here it turned the stopButton and recordButton as false, and only that
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: (audioRecorder?.url)!)
                audioPlayer?.volume = 1.0
                audioPlayer!.delegate = self
                audioPlayer!.prepareToPlay()
                audioPlayer!.play()
            } catch let error as NSError {
                print("audioPlayer error: \(error.localizedDescription)")
            }
        }
    }
    
    func getAudioFileURL() -> URL? {
        return audioRecorder?.url
    }
}
