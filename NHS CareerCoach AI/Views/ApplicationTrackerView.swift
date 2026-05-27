import SwiftData
import SwiftUI

struct ApplicationTrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JobApplication.createdAt, order: .reverse) private var applications: [JobApplication]
    @State private var isPresentingEditor = false
    @State private var summaryPDFURL: URL?

    var body: some View {
        PremiumScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    summary

                    if applications.isEmpty {
                        EmptyStateView(title: "No applications yet", message: "Track role title, trust, band, status, interview dates, rejection reasons, and reminders.", systemImage: "tray.full")
                    } else {
                        ForEach(applications) { application in
                            editableApplicationCard(application)
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Applications")
        .premiumNavigationTitleStyle()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingEditor = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add application")
            }
        }
        .sheet(isPresented: $isPresentingEditor) {
            ApplicationEditorSheet()
                .presentationDetents([.large])
        }
    }

    private var summary: some View {
        PremiumDashboardCard(title: "Application tracker", subtitle: "A premium pipeline for NHS applications and interviews.", systemImage: "tray.full.fill", accent: CareerCoachTheme.mint) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                MetricPill(title: "Drafting", value: "\(count(.drafting))", systemImage: "square.and.pencil", tint: CareerCoachTheme.warning)
                MetricPill(title: "Submitted", value: "\(count(.submitted))", systemImage: "paperplane.fill", tint: CareerCoachTheme.electricBlue)
                MetricPill(title: "Interview", value: "\(count(.interview))", systemImage: "person.wave.2.fill", tint: CareerCoachTheme.mint)
                MetricPill(title: "Offers", value: "\(count(.offer) + count(.accepted))", systemImage: "sparkles", tint: CareerCoachTheme.gold)
            }

            HStack(spacing: 10) {
                Button {
                    exportSummaryPDF()
                } label: {
                    Label("Export summary", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(PremiumSecondaryButtonStyle())

                if let summaryPDFURL {
                    ShareLink(item: summaryPDFURL) {
                        Label("Share", systemImage: "paperplane.fill")
                    }
                    .buttonStyle(PremiumSecondaryButtonStyle())
                }
            }
        }
    }

    private func editableApplicationCard(_ application: JobApplication) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ApplicationCard(application: application)

            HStack {
                Menu {
                    ForEach(ApplicationStatus.allCases) { status in
                        Button(status.rawValue) {
                            application.status = status
                            try? modelContext.save()
                        }
                    }
                } label: {
                    Label("Update status", systemImage: "slider.horizontal.3")
                }
                .buttonStyle(PremiumSecondaryButtonStyle())

                Spacer()

                Button(role: .destructive) {
                    modelContext.delete(application)
                    try? modelContext.save()
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(PremiumSecondaryButtonStyle())
                .accessibilityLabel("Delete application")
            }
            .padding(.horizontal, 2)
        }
    }

    private func count(_ status: ApplicationStatus) -> Int {
        applications.filter { $0.status == status }.count
    }

    private func exportSummaryPDF() {
        let summary = applications.map { application in
            "\(application.roleTitle) · \(application.trustName) · Band \(application.band) · \(application.applicationStatus)"
        }.joined(separator: "\n")

        summaryPDFURL = try? PDFExportService.export(
            title: "Application Summary",
            subtitle: "\(applications.count) tracked NHS application\(applications.count == 1 ? "" : "s")",
            body: summary.isEmpty ? "No applications tracked yet." : summary,
            sections: [
                ("Drafting", "\(count(.drafting))"),
                ("Submitted", "\(count(.submitted))"),
                ("Interview", "\(count(.interview))"),
                ("Offer or accepted", "\(count(.offer) + count(.accepted))")
            ]
        )
    }
}

private struct ApplicationEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var roleTitle = ""
    @State private var trustName = ""
    @State private var band = "5"
    @State private var status: ApplicationStatus = .drafting
    @State private var hasInterviewDate = false
    @State private var interviewDate = Date()
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            PremiumScreen {
                Form {
                    Section("Role") {
                        TextField("Role title", text: $roleTitle)
                        TextField("Trust name", text: $trustName)
                        Picker("Band", selection: $band) {
                            ForEach(["2", "3", "4", "5", "6", "7"], id: \.self) { band in
                                Text("Band \(band)").tag(band)
                            }
                        }
                    }

                    Section("Progress") {
                        Picker("Status", selection: $status) {
                            ForEach(ApplicationStatus.allCases) { status in
                                Text(status.rawValue).tag(status)
                            }
                        }

                        Toggle("Interview date", isOn: $hasInterviewDate)
                        if hasInterviewDate {
                            DatePicker("Date", selection: $interviewDate, displayedComponents: [.date, .hourAndMinute])
                        }
                    }

                    Section("Notes") {
                        TextEditor(text: $notes)
                            .frame(minHeight: 110)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Application")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
        }
    }

    private func save() {
        let application = JobApplication(
            roleTitle: roleTitle.trimmed.isEmpty ? "NHS role" : roleTitle.trimmed,
            trustName: trustName.trimmed.isEmpty ? "NHS Trust" : trustName.trimmed,
            band: band,
            applicationStatus: status,
            interviewDate: hasInterviewDate ? interviewDate : nil,
            notes: notes
        )

        modelContext.insert(application)
        try? modelContext.save()

        if application.interviewDate != nil {
            Task { await NotificationService.scheduleInterviewReminder(application: application) }
        }

        dismiss()
    }
}
