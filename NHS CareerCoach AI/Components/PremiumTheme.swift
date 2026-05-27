import Foundation
import SwiftUI

enum CareerCoachTheme {
    static let background = Color(hex: "07111F")
    static let panel = Color(hex: "0B1B2F")
    static let elevatedPanel = Color(hex: "10243D")
    static let nhsBlue = Color(hex: "005EB8")
    static let electricBlue = Color(hex: "1FA8FF")
    static let mint = Color(hex: "53D6B5")
    static let gold = Color(hex: "D7B56D")
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.70)
    static let textTertiary = Color.white.opacity(0.48)
    static let stroke = Color.white.opacity(0.12)
    static let warning = Color(hex: "F7B955")
    static let destructive = Color(hex: "FF6B7A")

    static let screenGradient = LinearGradient(
        colors: [
            Color(hex: "06101D"),
            Color(hex: "071B31"),
            Color(hex: "06101D")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [nhsBlue, electricBlue, mint],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let red: UInt64
        let green: UInt64
        let blue: UInt64
        let alpha: UInt64

        switch hex.count {
        case 3:
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (255, 0, 94, 184)
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}

struct PremiumScreen<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            CareerCoachTheme.screenGradient
                .ignoresSafeArea()

            content
        }
    }
}

struct PremiumCardStyle: ViewModifier {
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 18

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(CareerCoachTheme.panel.opacity(0.86))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(CareerCoachTheme.stroke, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.28), radius: 22, x: 0, y: 14)
            )
    }
}

extension View {
    func premiumCard(cornerRadius: CGFloat = 20, padding: CGFloat = 18) -> some View {
        modifier(PremiumCardStyle(cornerRadius: cornerRadius, padding: padding))
    }

    func premiumNavigationTitleStyle() -> some View {
        toolbarBackground(CareerCoachTheme.background.opacity(0.96), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

struct PremiumPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(CareerCoachTheme.accentGradient)
                    .shadow(color: CareerCoachTheme.electricBlue.opacity(configuration.isPressed ? 0.10 : 0.28), radius: configuration.isPressed ? 8 : 18, x: 0, y: 10)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.78), value: configuration.isPressed)
    }
}

struct PremiumSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(CareerCoachTheme.textPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(CareerCoachTheme.elevatedPanel.opacity(configuration.isPressed ? 0.62 : 0.92))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(CareerCoachTheme.stroke, lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.24, dampingFraction: 0.82), value: configuration.isPressed)
    }
}
