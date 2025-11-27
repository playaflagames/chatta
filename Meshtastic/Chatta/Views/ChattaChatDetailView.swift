// ChattaChatDetailView
// Individual chat conversation view with messages and input

import SwiftUI
import CoreData
import OSLog

struct ChattaChatDetailView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var bleManager: BLEManager
    @EnvironmentObject var navigationState: ChattaNavigationState

    @ObservedObject var user: UserEntity

    @State private var messageText = ""
    @State private var replyMessageId: Int64 = 0
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            chatHeader

            // Separator line
            Rectangle()
                .fill(Color.red)
                .frame(height: 3)

            // Messages
            messagesScrollView

            // Input field
            messageInput
        }
        .background(Color.white)
        .onAppear {
            markMessagesAsRead()
        }
    }

    // MARK: - Header
    private var chatHeader: some View {
        HStack {
            // Back button
            Button(action: {
                navigationState.pop()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.chattaGreen)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            }

            Spacer()

            // Logo, avatar and name
            HStack(spacing: 12) {
                // Chat bubbles
                ZStack {
                    ChatBubbleShape(isFlipped: false)
                        .fill(Color.chattaLogoBubbleGrey)
                        .frame(width: 35, height: 30)
                        .offset(x: -8, y: 0)

                    ChatBubbleShape(isFlipped: true)
                        .fill(Color.chattaGreen)
                        .frame(width: 35, height: 30)
                        .offset(x: 8, y: -6)
                }
                .frame(width: 60, height: 40)

                // User avatar
                ZStack {
                    Circle()
                        .fill(Color(UIColor(hex: UInt32(user.num))))

                    Text(user.shortName ?? "?")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(width: 36, height: 36)

                // User name
                Text(user.longName ?? "Unknown")
                    .font(.chattaTitle2)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }

            Spacer()

            // Connection status
            Circle()
                .fill(bleManager.isConnected ? Color.chattaConnected : Color.chattaDisconnected)
                .frame(width: ChattaDimensions.connectionDotSize, height: ChattaDimensions.connectionDotSize)
        }
        .padding(.horizontal, ChattaDimensions.paddingMedium)
        .padding(.vertical, ChattaDimensions.paddingSmall)
        .background(Color.white)
    }

    // MARK: - Messages
    private var messagesScrollView: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(user.messageList) { message in
                        let isCurrentUser = (Int64(UserDefaults.preferredPeripheralNum) == message.fromUser?.num ?? -1)

                        messageRow(message: message, isCurrentUser: isCurrentUser)
                            .id(message.messageId)
                    }
                }
                .padding(.vertical, ChattaDimensions.paddingMedium)
            }
            .scrollDismissesKeyboard(.interactively)
            .onAppear {
                // Scroll to last message
                if let lastMessage = user.messageList.last {
                    scrollView.scrollTo(lastMessage.messageId, anchor: .bottom)
                }
            }
            .onChange(of: user.messageList.count) {
                // Scroll to new message
                if let lastMessage = user.messageList.last {
                    withAnimation {
                        scrollView.scrollTo(lastMessage.messageId, anchor: .bottom)
                    }
                }
            }
        }
    }

    private func messageRow(message: MessageEntity, isCurrentUser: Bool) -> some View {
        let messageTime = Date(timeIntervalSince1970: TimeInterval(message.messageTimestamp))

        return VStack(spacing: 4) {
            // Timestamp for date changes (simplified - could be enhanced)
            if shouldShowDateHeader(for: message) {
                Text(formatDateHeader(messageTime))
                    .font(.chattaCaption)
                    .foregroundColor(.chattaTextSecondary)
                    .padding(.vertical, 8)
            }

            HStack(alignment: .bottom) {
                if isCurrentUser { Spacer(minLength: 60) }

                VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 2) {
                    // Message bubble
                    Text(message.messagePayload ?? "")
                        .font(.chattaBody)
                        .foregroundColor(isCurrentUser ? .white : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(isCurrentUser ? Color.chattaSentBubble : Color.chattaReceivedBubble)
                        .cornerRadius(ChattaDimensions.bubbleCornerRadius)

                    // Delivery status for sent messages
                    if isCurrentUser {
                        deliveryStatus(for: message)
                    }
                }

                if !isCurrentUser { Spacer(minLength: 60) }
            }
            .padding(.horizontal, ChattaDimensions.paddingMedium)
        }
    }

    private func deliveryStatus(for message: MessageEntity) -> some View {
        Group {
            if message.receivedACK && message.realACK {
                Text("Delivered")
                    .font(.chattaTimestamp)
                    .foregroundColor(.chattaTextSecondary)
            } else if message.receivedACK && !message.realACK {
                Text("Relayed")
                    .font(.chattaTimestamp)
                    .foregroundColor(.orange)
            } else if message.ackError > 0 {
                Text("Failed")
                    .font(.chattaTimestamp)
                    .foregroundColor(.red)
            } else {
                Text("Sending...")
                    .font(.chattaTimestamp)
                    .foregroundColor(.chattaTextSecondary)
            }
        }
    }

    // MARK: - Input Field
    private var messageInput: some View {
        HStack(spacing: 12) {
            TextField("Start typing...", text: $messageText, axis: .vertical)
                .font(.chattaBody)
                .focused($isInputFocused)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(ChattaDimensions.inputCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: ChattaDimensions.inputCornerRadius)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .onChange(of: messageText) { _, newValue in
                    // Limit to 200 bytes
                    while newValue.utf8.count > 200 {
                        messageText = String(messageText.dropLast())
                    }
                }

            Button(action: sendMessage) {
                Image(systemName: "paperplane.fill")
                    .font(.title2)
                    .foregroundColor(.chattaGreen)
                    .rotationEffect(.degrees(45))
            }
            .disabled(messageText.isEmpty || !bleManager.isConnected)
            .opacity(messageText.isEmpty ? 0.5 : 1.0)
        }
        .padding(.horizontal, ChattaDimensions.paddingMedium)
        .padding(.vertical, ChattaDimensions.paddingSmall)
        .background(Color.white)
    }

    // MARK: - Helper Methods
    private func sendMessage() {
        guard !messageText.isEmpty else { return }

        let messageSent = bleManager.sendMessage(
            message: messageText,
            toUserNum: user.num,
            channel: 0,
            isEmoji: false,
            replyID: replyMessageId
        )

        if messageSent {
            messageText = ""
            isInputFocused = false
            replyMessageId = 0
            context.refresh(user, mergeChanges: true)
            Logger.data.info("📤 [Chatta] Message sent to \(user.longName ?? "unknown", privacy: .public)")
        }
    }

    private func markMessagesAsRead() {
        for message in user.messageList where !message.read {
            message.read = true
        }
        do {
            try context.save()
        } catch {
            Logger.data.error("Failed to mark messages as read: \(error.localizedDescription)")
        }
    }

    private func shouldShowDateHeader(for message: MessageEntity) -> Bool {
        guard let index = user.messageList.firstIndex(of: message) else { return false }
        if index == 0 { return true }

        let previousMessage = user.messageList[index - 1]
        let currentDate = Date(timeIntervalSince1970: TimeInterval(message.messageTimestamp))
        let previousDate = Date(timeIntervalSince1970: TimeInterval(previousMessage.messageTimestamp))

        return !Calendar.current.isDate(currentDate, inSameDayAs: previousDate)
    }

    private func formatDateHeader(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: date)
        }
    }
}

#Preview {
    Text("ChatDetailView requires UserEntity")
}
