import SwiftData
import SwiftUI

struct VoiceInputView: View {
    @Environment(\.aiService) private var aiService
    @Environment(\.modelContext) private var modelContext
    @StateObject private var speechService = SpeechRecognitionService()
    @StateObject private var waveform = WaveformAnimationManager()
    @StateObject private var viewModel = VoiceInputViewModel()

    var body: some View {
        PremiumScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    voiceConsole
                    transcriptEditor

                    if viewModel.isProcessing {
                        LoadingStateView(message: "Converting your voice notes into polished NHS coaching output...")
                    }

                    if let errorMessage = speechService.errorMessage ?? viewModel.errorMessage {
                        ErrorStateView(message: errorMessage)
                    }

                    if let result = viewModel.processedResult {
                        resultCard(result)
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Voice Coach")
        .premiumNavigationTitleStyle()
        .onAppear {
            speechService.requestAuthorization()
            waveform.idle()
        }
        .onChange(of: speechService.isListening) { _, isListening in
            isListening ? waveform.start() : waveform.idle()
        }
    }

    private var header: some View {
        PremiumDashboardCard(title: "Speech-to-text voice input", subtitle: "Dictate experiences, STAR examples, mock answers, or statement ideas.", systemImage: "waveform", accent: CareerCoachTheme.electricBlue) {
            Text("Live transcription stays editable. Local coaching can then polish your transcript into NHS-style application content.")
                .font(.subheadline)
                .foregroundStyle(CareerCoachTheme.textSecondary)
        }
    }

    private var voiceConsole: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Output type", selection: $viewModel.selectedModule) {
                ForEach(VoiceProcessingModule.allCases) { module in
                    Text(module.rawValue).tag(module)
                }
            }
            .pickerStyle(.menu)
            .tint(CareerCoachTheme.electricBlue)

            VoiceWaveformView(samples: waveform.samples, isActive: speechService.isListening)

            HStack(spacing: 10) {
                Button {
                    if speechService.isListening {
                        speechService.pause()
                    } else {
                        speechService.start()
                    }
                } label: {
                    Label(speechService.isListening ? "Pause" : "Record", systemImage: speechService.isListening ? "pause.fill" : "mic.fill")
                }
                .buttonStyle(PremiumPrimaryButtonStyle())

                Button {
                    speechService.stop()
                } label: {
                    Image(systemName: "stop.fill")
                }
                .buttonStyle(PremiumSecondaryButtonStyle())
                .accessibilityLabel("Stop recording")
            }

            HStack(spacing: 10) {
                Button {
                    speechService.resume()
                } label: {
                    Label("Resume", systemImage: "play.fill")
                }
                .buttonStyle(PremiumSecondaryButtonStyle())

                Button {
                    speechService.resetTranscript()
                    viewModel.processedResult = nil
                } label: {
                    Label("Clear", systemImage: "trash")
                }
                .buttonStyle(PremiumSecondaryButtonStyle())
            }
        }
        .premiumCard()
    }

    private var transcriptEditor: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Live transcript")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(CareerCoachTheme.textPrimary)
                Spacer()
                Text(speechService.isListening ? "Listening" : "Editable")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(speechService.isListening ? CareerCoachTheme.mint : CareerCoachTheme.textTertiary)
            }

            TextEditor(text: $speechService.transcript)
                .scrollContentBackground(.hidden)
                .foregroundStyle(CareerCoachTheme.textPrimary)
                .frame(minHeight: 210)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(CareerCoachTheme.elevatedPanel))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(CareerCoachTheme.stroke))

            HStack(spacing: 10) {
                Button {
                    Task { await viewModel.process(transcript: speechService.transcript, using: aiService) }
                } label: {
                    Label("Polish transcript", systemImage: "wand.and.stars")
                }
                .buttonStyle(PremiumPrimaryButtonStyle())

                Button {
                    saveTranscript()
                } label: {
                    Label("Save", systemImage: "tray.and.arrow.down.fill")
                }
                .buttonStyle(PremiumSecondaryButtonStyle())
            }
        }
        .premiumCard()
    }

    private func resultCard(_ result: VoiceProcessingResult) -> some View {
        PremiumDashboardCard(title: "AI-polished output", subtitle: "Confidence score \(Int(result.confidenceScore * 100))%", systemImage: "sparkles", accent: CareerCoachTheme.mint) {
            VStack(alignment: .leading, spacing: 12) {
                Text(result.polishedOutput)
                    .font(.body)
                    .foregroundStyle(CareerCoachTheme.textSecondary)
                    .textSelection(.enabled)

                ForEach(result.suggestedNextSteps, id: \.self) { step in
                    Label(step, systemImage: "checkmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(CareerCoachTheme.textSecondary)
                }
            }
        }
    }

    private func saveTranscript() {
        let transcript = VoiceTranscript(
            transcript: speechService.transcript,
            processedOutput: viewModel.processedResult?.polishedOutput ?? "",
            confidenceScore: viewModel.processedResult?.confidenceScore ?? 0.78
        )
        modelContext.insert(transcript)
        try? modelContext.save()
    }
}
