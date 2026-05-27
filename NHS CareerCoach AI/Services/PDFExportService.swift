import Foundation
import UIKit

enum PDFExportService {
    enum ExportError: Error {
        case unableToCreatePDF
    }

    @MainActor
    static func export(title: String, subtitle: String, body: String, sections: [(String, String)] = []) throws -> URL {
        let fileName = "\(title.safeFileName)-\(Int(Date().timeIntervalSince1970)).pdf"
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        try renderer.writePDF(to: outputURL) { context in
            context.beginPage()

            let margin: CGFloat = 48
            var y: CGFloat = 52

            y = draw(title, in: pageRect, x: margin, y: y, font: .systemFont(ofSize: 26, weight: .bold), color: UIColor(red: 0.02, green: 0.10, blue: 0.20, alpha: 1))
            y = draw(subtitle, in: pageRect, x: margin, y: y + 6, font: .systemFont(ofSize: 12, weight: .semibold), color: UIColor(red: 0.00, green: 0.36, blue: 0.70, alpha: 1))
            y += 20
            y = drawWrapped(body, in: pageRect, x: margin, y: y, font: .systemFont(ofSize: 12), color: .darkText)

            for section in sections {
                if y > pageRect.height - 150 {
                    context.beginPage()
                    y = 52
                }
                y += 18
                y = draw(section.0, in: pageRect, x: margin, y: y, font: .systemFont(ofSize: 16, weight: .bold), color: UIColor(red: 0.02, green: 0.10, blue: 0.20, alpha: 1))
                y = drawWrapped(section.1, in: pageRect, x: margin, y: y + 6, font: .systemFont(ofSize: 12), color: .darkText)
            }

            let disclaimer = "Independent coaching platform. Not affiliated with the NHS. No guaranteed interviews, job offers, or employment outcomes. Review AI suggestions before submission."
            _ = drawWrapped(disclaimer, in: pageRect, x: margin, y: pageRect.height - 72, font: .systemFont(ofSize: 9), color: .secondaryLabel)
        }

        return outputURL
    }

    private static func draw(_ text: String, in pageRect: CGRect, x: CGFloat, y: CGFloat, font: UIFont, color: UIColor) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let size = text.boundingRect(with: CGSize(width: pageRect.width - x * 2, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil).size
        text.draw(in: CGRect(x: x, y: y, width: pageRect.width - x * 2, height: ceil(size.height)), withAttributes: attributes)
        return y + ceil(size.height)
    }

    private static func drawWrapped(_ text: String, in pageRect: CGRect, x: CGFloat, y: CGFloat, font: UIFont, color: UIColor) -> CGFloat {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color, .paragraphStyle: paragraph]
        let attributed = NSAttributedString(string: text, attributes: attributes)
        let maxWidth = pageRect.width - x * 2
        let size = attributed.boundingRect(with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).size
        attributed.draw(in: CGRect(x: x, y: y, width: maxWidth, height: ceil(size.height)))
        return y + ceil(size.height)
    }
}

private extension String {
    var safeFileName: String {
        components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: "-")
            .lowercased()
    }
}

