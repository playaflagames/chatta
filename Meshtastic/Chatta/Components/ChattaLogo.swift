// Chatta Logo Component
// Displays the chat bubble logo with optional text

import SwiftUI

struct ChattaLogo: View {
    enum Size {
        case small   // For headers
        case medium  // For navigation bars
        case large   // For home screen

        var bubbleSize: CGFloat {
            switch self {
            case .small: return 60
            case .medium: return 100
            case .large: return 160
            }
        }

        var fontSize: CGFloat {
            switch self {
            case .small: return 24
            case .medium: return 36
            case .large: return 48
            }
        }
    }

    var size: Size = .large
    var showText: Bool = true
    var useGreenBubble: Bool = false  // For Chats view header

    var body: some View {
        VStack(spacing: size == .large ? 0 : -8) {
            // Chat bubbles
            ZStack {
                // Back bubble (grey/lavender)
                ChatBubbleShape(isFlipped: false)
                    .fill(Color.chattaLogoBubbleGrey)
                    .frame(width: size.bubbleSize * 0.7, height: size.bubbleSize * 0.6)
                    .offset(x: -size.bubbleSize * 0.15, y: 0)

                // Front bubble (white or green)
                ChatBubbleShape(isFlipped: true)
                    .fill(useGreenBubble ? Color.chattaGreen : Color.white)
                    .frame(width: size.bubbleSize * 0.7, height: size.bubbleSize * 0.6)
                    .offset(x: size.bubbleSize * 0.15, y: -size.bubbleSize * 0.1)
            }
            .frame(width: size.bubbleSize, height: size.bubbleSize * 0.8)

            // Logo text
            if showText {
                Text("chatta")
                    .font(.system(size: size.fontSize, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
            }
        }
    }
}

// Custom chat bubble shape
struct ChatBubbleShape: Shape {
    var isFlipped: Bool = false

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height
        let cornerRadius = min(width, height) * 0.35
        let tailSize = width * 0.15

        if isFlipped {
            // Bubble pointing right
            path.move(to: CGPoint(x: cornerRadius, y: 0))
            path.addLine(to: CGPoint(x: width - cornerRadius, y: 0))
            path.addQuadCurve(to: CGPoint(x: width, y: cornerRadius),
                             control: CGPoint(x: width, y: 0))
            path.addLine(to: CGPoint(x: width, y: height - cornerRadius - tailSize))
            path.addQuadCurve(to: CGPoint(x: width - cornerRadius, y: height - tailSize),
                             control: CGPoint(x: width, y: height - tailSize))
            // Tail
            path.addLine(to: CGPoint(x: width - cornerRadius + tailSize, y: height))
            path.addLine(to: CGPoint(x: width - cornerRadius - tailSize, y: height - tailSize))
            path.addLine(to: CGPoint(x: cornerRadius, y: height - tailSize))
            path.addQuadCurve(to: CGPoint(x: 0, y: height - tailSize - cornerRadius),
                             control: CGPoint(x: 0, y: height - tailSize))
            path.addLine(to: CGPoint(x: 0, y: cornerRadius))
            path.addQuadCurve(to: CGPoint(x: cornerRadius, y: 0),
                             control: CGPoint(x: 0, y: 0))
        } else {
            // Bubble pointing left
            path.move(to: CGPoint(x: cornerRadius, y: 0))
            path.addLine(to: CGPoint(x: width - cornerRadius, y: 0))
            path.addQuadCurve(to: CGPoint(x: width, y: cornerRadius),
                             control: CGPoint(x: width, y: 0))
            path.addLine(to: CGPoint(x: width, y: height - tailSize - cornerRadius))
            path.addQuadCurve(to: CGPoint(x: width - cornerRadius, y: height - tailSize),
                             control: CGPoint(x: width, y: height - tailSize))
            path.addLine(to: CGPoint(x: cornerRadius + tailSize, y: height - tailSize))
            // Tail
            path.addLine(to: CGPoint(x: cornerRadius - tailSize, y: height))
            path.addLine(to: CGPoint(x: cornerRadius, y: height - tailSize))
            path.addQuadCurve(to: CGPoint(x: 0, y: height - tailSize - cornerRadius),
                             control: CGPoint(x: 0, y: height - tailSize))
            path.addLine(to: CGPoint(x: 0, y: cornerRadius))
            path.addQuadCurve(to: CGPoint(x: cornerRadius, y: 0),
                             control: CGPoint(x: 0, y: 0))
        }

        path.closeSubpath()
        return path
    }
}

// Header variant with title
struct ChattaHeader: View {
    var title: String
    var showBackButton: Bool = true
    var useGreenBubbles: Bool = false
    var onBack: (() -> Void)?

    @EnvironmentObject var bleManager: BLEManager

    var body: some View {
        HStack {
            if showBackButton {
                Button(action: { onBack?() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.chattaGreen)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                }
            }

            Spacer()

            HStack(spacing: 12) {
                ChattaLogo(size: .small, showText: false, useGreenBubble: useGreenBubbles)
                Text(title)
                    .font(.chattaTitle)
                    .foregroundColor(useGreenBubbles ? .primary : .white)
            }

            Spacer()

            // Connection status dot
            ConnectionStatusDot()
        }
        .padding(.horizontal, ChattaDimensions.paddingMedium)
        .padding(.vertical, ChattaDimensions.paddingSmall)
    }
}

// Connection status indicator
struct ConnectionStatusDot: View {
    @EnvironmentObject var bleManager: BLEManager

    var body: some View {
        Circle()
            .fill(bleManager.isConnected ? Color.chattaConnected : Color.chattaDisconnected)
            .frame(width: ChattaDimensions.connectionDotSize, height: ChattaDimensions.connectionDotSize)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            )
    }
}

#Preview {
    ZStack {
        Color.chattaGreen.ignoresSafeArea()
        VStack(spacing: 40) {
            ChattaLogo(size: .large)
            ChattaLogo(size: .medium)
            ChattaLogo(size: .small)
        }
    }
}
