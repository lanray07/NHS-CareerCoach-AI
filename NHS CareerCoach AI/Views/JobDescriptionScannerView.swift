import SwiftData
import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct JobDescriptionScannerView: View {
    @Environment(\.aiService) private var aiService
    @Query(sort: \UserProfile.createdAt) private var profiles: [UserProfile]
    @StateObject private var viewModel = JobScannerViewModel()
    @State private var isShowingDocumentImporter = false
    @State private var selectedScreenshot: PhotosPickerItem?

    var body: some View {
        PremiumScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    inputCard
                    importCard

                    if viewModel.isLoading {
                        LoadingStateView(message: "Scanning NHS criteria, values, and interview signals...")
                    }

                    if let importMessage = viewModel.importMessage {
                        InfoStateView(message: importMessage)
                    }

                    if let errorMessage = viewModel.errorMessage {
                        ErrorStateView(message: errorMessage)
                    }

                    if let analysis = viewModel.analysis {
                        analysisResults(analysis)
                    } else if !viewModel.isLoading {
                        EmptyStateView(title: "Paste a role advert", message: "The scanner will extract person specification signals, essential criteria, likely interview topics, and values alignment.", systemImage: "doc.viewfinder")
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Job Scanner")
        .premiumNavigationTitleStyle()
        .fileImporter(isPresented: $isShowingDocumentImporter, allowedContentTypes: [.pdf, .plainText, .rtf], allowsMultipleSelection: false) { result in
            handleDocumentImport(result)
        }
        .onChange(of: selectedScreenshot) { _, item in
            guard item != nil else { return }
            viewModel.prepareScreenshotImport()
        }
    }

    private var header: some View {
        PremiumDashboardCard(title: "Job description scanner", subtitle: "Turn an NHS advert into a focused coaching brief.", systemImage: "doc.viewfinder", accent: CareerCoachTheme.mint) {
            Text("Extract person specification signals, essential criteria, interview topics, NHS values alignment, and high-value keywords from an NHS advert.")
                .font(.subheadline)
                .foregroundStyle(CareerCoachTheme.textSecondary)
        }
    }

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("NHS job advert")
                .font(.headline.weight(.semibold))
                .foregroundStyle(CareerCoachTheme.textPrimary)

            TextEditor(text: $viewModel.jobDescription)
                .scrollContentBackground(.hidden)
                .foregroundStyle(CareerCoachTheme.textPrimary)
                .frame(minHeight: 220)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(CareerCoachTheme.elevatedPanel))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(CareerCoachTheme.stroke))

            Button {
                Task { await viewModel.analyze(using: aiService, profile: profiles.first) }
            } label: {
                Label("Analyze job description", systemImage: "sparkles")
            }
            .buttonStyle(PremiumPrimaryButtonStyle())
            .disabled(viewModel.isLoading)
        }
        .premiumCard()
    }

    private var importCard: some View {
        HStack(spacing: 12) {
            Button {
                isShowingDocumentImporter = true
            } label: {
                Label("Upload PDF", systemImage: "doc.richtext")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PremiumSecondaryButtonStyle())

            PhotosPicker(selection: $selectedScreenshot, matching: .images) {
                Label("Upload screenshot", systemImage: "photo.on.rectangle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PremiumSecondaryButtonStyle())
        }
    }

    private func handleDocumentImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else {
                viewModel.errorMessage = "No document was selected."
                return
            }

            if url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }
                if let text = try? String(contentsOf: url, encoding: .utf8), !text.trimmed.isEmpty {
                    viewModel.jobDescription = text
                    viewModel.importMessage = "Imported text from \(url.lastPathComponent). Review it, then run the scan."
                } else {
                    viewModel.preparePDFImport(fileName: url.lastPathComponent)
                }
            } else {
                viewModel.preparePDFImport(fileName: url.lastPathComponent)
            }
        case .failure(let error):
            viewModel.errorMessage = error.localizedDescription
        }
    }

    private func analysisResults(_ analysis: JobAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            resultSection("Person specification", "person.text.rectangle", analysis.personSpecification)
            resultSection("Key competencies", "target", analysis.keyCompetencies)
            resultSection("Essential criteria", "checklist", analysis.essentialCriteria)
            resultSection("Likely interview topics", "questionmark.bubble.fill", analysis.likelyInterviewTopics)
            resultSection("NHS values alignment", "heart.text.square.fill", analysis.valuesAlignment)
            keywordCloud(analysis.importantKeywords)
        }
    }

    private func resultSection(_ title: String, _ systemImage: String, _ items: [String]) -> some View {
        PremiumDashboardCard(title: title, subtitle: "\(items.count) coaching signals", systemImage: systemImage) {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(CareerCoachTheme.mint)
                        Text(item)
                            .font(.subheadline)
                            .foregroundStyle(CareerCoachTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private func keywordCloud(_ keywords: [String]) -> some View {
        PremiumDashboardCard(title: "Important keywords", subtitle: "Use naturally, only where accurate.", systemImage: "number") {
            FlowLayout(items: keywords) { keyword in
                Text(keyword)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CareerCoachTheme.electricBlue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(CareerCoachTheme.electricBlue.opacity(0.12)))
            }
        }
    }
}

private struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    var items: Data
    private let content: (Data.Element) -> Content

    init(items: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.items = items
        self.content = content
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(Array(items), id: \.self) { item in
                content(item)
            }
        }
    }
}
