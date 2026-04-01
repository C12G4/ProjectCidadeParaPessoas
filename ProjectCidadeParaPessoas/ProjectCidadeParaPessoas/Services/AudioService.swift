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

class AudioService: NSObject, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    let audioSession = AVAudioSession.sharedInstance()
    
    //MARK: - This function has the purpose of managing the audio player, doing the treatment of the audio paths
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
    
    //MARK: - The following action methods will implement it to the three buttons created previously
    @objc private func recordTouchDown(_ sender: Any) {
        startRecording()
    }

    @objc private func recordTouchUpInside(_ sender: Any) {
        stopRecordingIfNeeded()
    }

    @objc private func recordTouchDragExit(_ sender: Any) {
        stopRecordingIfNeeded()
    }
    
    /// record audio method
    private func startRecording() {
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
            audioRecorder?.stop()
            do { try audioSession.setActive(false) } catch { }
        }
//        stopButton.isEnabled = false
//        playButton.isEnabled = true
//        recordButton.isEnabled = true
    }
    
    /// stop audio method
    @objc func stopAudio(_ sender: Any) {
        /// here it turned stopButton = false and all the others as true
        
        if audioRecorder?.isRecording == true {
            audioRecorder?.stop()
        } else {
            audioPlayer?.stop()
        }

        do { try audioSession.setActive(false) } catch { }
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
    
    //MARK: - Delegate Methods
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer,
                                     successfully flag: Bool, button: UIButton) {
        /// recordButton = true and stopButton = false
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio Play Decode Error")
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        /// playButton = true
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Audio Record Encode Error")
    }
    
}
