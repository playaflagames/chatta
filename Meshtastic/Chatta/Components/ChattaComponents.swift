// Chatta Reusable Components

import SwiftUI

// MARK: - Decorative Dots Pattern
struct DecorativeDots: View {
    var pattern: DotPattern = .scattered

    enum DotPattern {
        case scattered
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Dot clusters based on pattern
                switch pattern {
                case .scattered:
                    scatteredDots(in: geo.size)
                case .topLeft:
                    dotCluster()
                        .position(x: 60, y: 100)
                case .topRight:
                    dotCluster()
                        .position(x: geo.size.width - 60, y: 100)
                case .bottomLeft:
                    largeDotCluster()
                        .position(x: 80, y: geo.size.height - 200)
                case .bottomRight:
                    // Decorative circle
                    Circle()
                        .fill(Color.chattaGreenLight.opacity(0.5))
                        .frame(width: 200, height: 200)
                        .position(x: geo.size.width - 50, y: geo.size.height - 50)
                }
            }
        }
        .allowsHitTesting(false)
    }

    @ViewBuilder
    func scatteredDots(in size: CGSize) -> some View {
        // Top left cluster
        dotCluster()
            .position(x: 50, y: 100)

        // Top right cluster
        dotCluster()
            .position(x: size.width - 50, y: 150)

        // Middle left
        smallDotCluster()
            .position(x: 40, y: size.height * 0.4)

        // Middle right
        smallDotCluster()
            .position(x: size.width - 40, y: size.height * 0.5)

        // Bottom left large cluster
        largeDotCluster()
            .position(x: 80, y: size.height - 250)

        // Bottom right decorative circle
        Circle()
            .fill(Color.chattaGreenLight.opacity(0.4))
            .frame(width: 180, height: 180)
            .position(x: size.width - 30, y: size.height - 80)

        // Additional scattered dots
        ForEach(0..<5, id: \.self) { i in
            Circle()
                .fill(Color.chattaGreenLight.opacity(0.3))
                .frame(width: 8, height: 8)
                .position(
                    x: CGFloat.random(in: 20...(size.width - 20)),
                    y: CGFloat.random(in: 200...(size.height - 100))
                )
        }
    }

    func dotCluster() -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                dot()
                dot()
            }
            HStack(spacing: 6) {
                dot()
                dot()
            }
        }
    }

    func smallDotCluster() -> some View {
        HStack(spacing: 6) {
            dot()
            dot()
            dot()
        }
    }

    func largeDotCluster() -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                dot()
                dot()
            }
            HStack(spacing: 6) {
                dot()
                dot()
                dot()
            }
            HStack(spacing: 6) {
                dot()
                dot()
            }
            HStack(spacing: 6) {
                dot()
                dot()
                dot()
                dot()
            }
            HStack(spacing: 6) {
                dot()
                dot()
                dot()
                dot()
            }
            HStack(spacing: 6) {
                dot()
                dot()
            }
        }
    }

    func dot() -> some View {
        Circle()
            .fill(Color.chattaGreenLight.opacity(0.4))
            .frame(width: 10, height: 10)
    }
}

// MARK: - Message Bubble
struct ChattaMessageBubble: View {
    let message: String
    let isSent: Bool
    let timestamp: String?

    init(message: String, isSent: Bool, timestamp: String? = nil) {
        self.message = message
        self.isSent = isSent
        self.timestamp = timestamp
    }

    var body: some View {
        HStack {
            if isSent { Spacer(minLength: 60) }

            VStack(alignment: isSent ? .trailing : .leading, spacing: 4) {
                Text(message)
                    .font(.chattaBody)
                    .foregroundColor(isSent ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(isSent ? Color.chattaSentBubble : Color.chattaReceivedBubble)
                    .cornerRadius(ChattaDimensions.bubbleCornerRadius)

                if let timestamp = timestamp {
                    Text(timestamp)
                        .font(.chattaTimestamp)
                        .foregroundColor(.chattaTextSecondary)
                }
            }

            if !isSent { Spacer(minLength: 60) }
        }
    }
}

// MARK: - Chat Row (for chat list)
struct ChattaChatRow: View {
    let name: String
    let lastMessage: String
    let timestamp: String
    let avatarImage: Image?
    let isOnline: Bool
    let hasUnread: Bool

    init(
        name: String,
        lastMessage: String,
        timestamp: String,
        avatarImage: Image? = nil,
        isOnline: Bool = false,
        hasUnread: Bool = false
    ) {
        self.name = name
        self.lastMessage = lastMessage
        self.timestamp = timestamp
        self.avatarImage = avatarImage
        self.isOnline = isOnline
        self.hasUnread = hasUnread
    }

    var body: some View {
        HStack(spacing: 12) {
            // Online indicator
            if isOnline {
                Circle()
                    .fill(Color.chattaOnline)
                    .frame(width: ChattaDimensions.statusDotSize, height: ChattaDimensions.statusDotSize)
            } else {
                Color.clear
                    .frame(width: ChattaDimensions.statusDotSize, height: ChattaDimensions.statusDotSize)
            }

            // Avatar
            ZStack {
                if let image = avatarImage {
                    image
                        .resizable()
                        .scaledToFill()
                } else {
                    // Default avatar with initials
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                    Text(String(name.prefix(1)).uppercased())
                        .font(.chattaTitle3)
                        .foregroundColor(.gray)
                }
            }
            .frame(width: ChattaDimensions.avatarMedium, height: ChattaDimensions.avatarMedium)
            .clipShape(Circle())

            // Name and message
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.chattaBodyBold)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(lastMessage)
                    .font(.chattaCaption)
                    .foregroundColor(.chattaTextSecondary)
                    .lineLimit(1)
            }

            Spacer()

            // Timestamp and chevron
            VStack(alignment: .trailing, spacing: 4) {
                Text(timestamp)
                    .font(.chattaTimestamp)
                    .foregroundColor(.chattaTextSecondary)

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.chattaTextSecondary)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, ChattaDimensions.paddingMedium)
        .background(Color.white)
    }
}

// MARK: - Connection Status Bar
struct ChattaConnectionStatusBar: View {
    @EnvironmentObject var bleManager: BLEManager

    var body: some View {
        HStack {
            Text(bleManager.isConnected ? "Your Chatta is Connected" : "Your Chatta is Disconnected")
                .font(.chattaBodyBold)
                .foregroundColor(bleManager.isConnected ? .chattaGreen : .chattaDisconnected)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(ChattaDimensions.buttonCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: ChattaDimensions.buttonCornerRadius)
                .stroke(bleManager.isConnected ? Color.chattaGreen : Color.chattaDisconnected, lineWidth: 2)
        )
    }
}

// MARK: - Action Button with Icon
struct ChattaActionButton: View {
    let title: String
    let subtitle: String?
    let icon: String
    let action: () -> Void

    init(title: String, subtitle: String? = nil, icon: String, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.chattaGreen)
                    .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.chattaButtonSmall)
                        .foregroundColor(.chattaGreen)
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.chattaCaption)
                            .foregroundColor(.chattaTextSecondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(ChattaDimensions.buttonCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: ChattaDimensions.buttonCornerRadius)
                    .stroke(Color.chattaGreen.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Settings Row
struct ChattaSettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(iconColor)
                    .frame(width: 28)

                Text(title)
                    .font(.chattaBody)
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.chattaTextSecondary)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, ChattaDimensions.paddingMedium)
        }
    }
}

// MARK: - Text Input Field
struct ChattaTextInput: View {
    @Binding var text: String
    let placeholder: String
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            TextField(placeholder, text: $text)
                .font(.chattaBody)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(ChattaDimensions.inputCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: ChattaDimensions.inputCornerRadius)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )

            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .font(.title2)
                    .foregroundColor(.chattaGreen)
                    .rotationEffect(.degrees(45))
            }
            .disabled(text.isEmpty)
            .opacity(text.isEmpty ? 0.5 : 1.0)
        }
        .padding(.horizontal, ChattaDimensions.paddingMedium)
        .padding(.vertical, ChattaDimensions.paddingSmall)
        .background(Color.white)
    }
}

#Preview("Message Bubbles") {
    VStack(spacing: 16) {
        ChattaMessageBubble(message: "Hey! How are you?", isSent: false, timestamp: "11:30 AM")
        ChattaMessageBubble(message: "I'm doing great, thanks for asking!", isSent: true, timestamp: "11:31 AM")
    }
    .padding()
}

#Preview("Chat Row") {
    ChattaChatRow(
        name: "Nick Arnott",
        lastMessage: "Leave that in the comments?",
        timestamp: "11:37 AM",
        isOnline: true
    )
}
