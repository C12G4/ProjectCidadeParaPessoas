import UIKit
import AVFoundation

class AudioService: NSObject, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    let audioSession = AVAudioSession.sharedInstance()
    var onRecordingStateChanged: ((Bool) -> Void)?

    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }

    func audioInit() {
        try? audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
    }

    func startRecording() {
        audioSession.requestRecordPermission { [weak self] granted in
            guard let self = self else { return }

            DispatchQueue.main.async {
                guard granted else { return }
                self.setupNewRecorder()

                try? self.audioSession.setActive(true)
                self.audioRecorder?.record()
                self.onRecordingStateChanged?(true)
            }
        }
    }

    func stopRecordingIfNeeded() {
        guard audioRecorder?.isRecording == true else { return }
        audioRecorder?.stop()
        do { try audioSession.setActive(false) } catch { }
        onRecordingStateChanged?(false)
    }

    func playAudioFromURL(_ url: URL) {
        guard let player = try? AVAudioPlayer(contentsOf: url) else { return }
        audioPlayer = player
        audioPlayer?.volume = 1.0
        audioPlayer?.delegate = self
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
    }

    func playAudio(_ sender: Any) {
        guard let url = audioRecorder?.url else { return }
        playAudioFromURL(url)
    }

    func getAudioFilePath() -> String? {
        guard let url = audioRecorder?.url else { return nil }
        return url.lastPathComponent
    }

    func resolveAudioURL(from storedValue: String) -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = URL(fileURLWithPath: storedValue).lastPathComponent
        let localURL = documentsURL.appendingPathComponent(fileName)

        if FileManager.default.fileExists(atPath: localURL.path) {
            return localURL
        }

        if storedValue.hasPrefix("/") {
            return URL(fileURLWithPath: storedValue)
        }

        return localURL
    }

    private func setupNewRecorder() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let soundFileURL = documentsURL.appendingPathComponent("audio_\(UUID().uuidString).m4a")

        let recordSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        guard let recorder = try? AVAudioRecorder(url: soundFileURL, settings: recordSettings) else { return }
        audioRecorder = recorder
        audioRecorder?.delegate = self
        audioRecorder?.prepareToRecord()
    }
}
