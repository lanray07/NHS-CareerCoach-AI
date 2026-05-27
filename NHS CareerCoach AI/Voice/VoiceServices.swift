import AVFoundation
import Foundation
import Speech
import SwiftUI

final class SpeechRecognitionService: NSObject, ObservableObject {
    @Published var transcript = ""
    @Published var isListening = false
    @Published var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = SFSpeechRecognizer.authorizationStatus()
    @Published var errorMessage: String?

    private let audioEngine = AVAudioEngine()
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-GB"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.authorizationStatus = status
            }
        }

        AVAudioSession.sharedInstance().requestRecordPermission { _ in }
    }

    func start() {
        guard authorizationStatus == .authorized else {
            requestAuthorization()
            errorMessage = "Speech recognition permission is required for voice coaching."
            return
        }

        do {
            try startRecognition()
        } catch {
            errorMessage = error.localizedDescription
            stop()
        }
    }

    func pause() {
        stopAudioOnly()
        isListening = false
    }

    func resume() {
        start()
    }

    func stop() {
        stopAudioOnly()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        isListening = false
    }

    func resetTranscript() {
        transcript = ""
    }

    private func startRecognition() throws {
        recognitionTask?.cancel()
        recognitionTask = nil

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: [.duckOthers])
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        recognitionRequest = request

        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
        isListening = true
        errorMessage = nil

        recognitionTask = recognizer?.recognitionTask(with: request) { [weak self] result, error in
            DispatchQueue.main.async {
                if let result {
                    self?.transcript = result.bestTranscription.formattedString
                }

                if error != nil || result?.isFinal == true {
                    self?.stopAudioOnly()
                    self?.isListening = false
                }
            }
        }
    }

    private func stopAudioOnly() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}

final class VoiceRecordingService: ObservableObject {
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0

    private var timer: Timer?

    func startPlaceholderRecording() {
        isRecording = true
        recordingDuration = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.recordingDuration += 1
        }
    }

    func stopPlaceholderRecording() {
        isRecording = false
        timer?.invalidate()
        timer = nil
    }
}

struct VoicePlaybackPlaceholder {
    var title = "AI voice coach placeholder"
    var message = "Future releases can stream an AI interviewer voice response from a secure backend. No API keys should be stored in the app."
}

struct SoundEffectsPlaceholder {
    var interactionSounds = [
        "premium_start_chime",
        "recording_pulse",
        "coaching_complete",
        "export_success"
    ]

    var message = "Sound effect identifiers are placeholders for future bundled audio assets."
}

final class WaveformAnimationManager: ObservableObject {
    @Published var samples: [CGFloat] = Array(repeating: 0.25, count: 34)

    private var timer: Timer?

    func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.07, repeats: true) { [weak self] _ in
            self?.samples = (0..<34).map { index in
                let base = CGFloat.random(in: 0.12...0.94)
                let taper = 1 - abs(CGFloat(index) - 17) / 28
                return max(0.12, min(0.98, base * taper + 0.08))
            }
        }
    }

    func idle() {
        timer?.invalidate()
        timer = nil
        samples = (0..<34).map { index in
            let curve = sin(Double(index) / 34 * Double.pi)
            return 0.12 + CGFloat(curve) * 0.18
        }
    }
}
