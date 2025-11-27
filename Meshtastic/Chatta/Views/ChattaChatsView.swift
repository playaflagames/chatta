// ChattaChatsView
// Displays the list of conversations in Chatta style

import SwiftUI
import CoreData

struct ChattaChatsView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var bleManager: BLEManager
    @EnvironmentObject var navigationState: ChattaNavigationState

    @State private var searchText = ""
    @State private var showingNewChat = false
    @State private var selectedUser: UserEntity?

    // Fetch users with messages, sorted by most recent message
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(key: "lastMessage", ascending: false),
            NSSortDescriptor(key: "longName", ascending: true)
        ],
        predicate: NSPredicate(
            format: "userNode.ignored == false && longName != '' && longName != nil"
        ),
        animation: .default
    )
    var users: FetchedResults<UserEntity>

    var body: some View {
        ZStack {
            // White background for chat list
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                chattaHeader

                // Separator line
                Rectangle()
                    .fill(Color.red)
                    .frame(height: 3)

                // New Chat buttons
                newChatButtons

                // Search bar
                searchBar

                // Chat list
                chatList

                Spacer()
            }
        }
        .sheet(isPresented: $showingNewChat) {
            ChattaNewChatView(selectedUser: $selectedUser)
        }
        .onChange(of: selectedUser) { _, newUser in
            if let user = newUser {
                navigationState.selectedChatUserNum = user.num
                navigationState.push(.chatDetail(userNum: user.num))
                // Reset selection after navigation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    selectedUser = nil
                }
            }
        }
    }

    // MARK: - Header
    private var chattaHeader: some View {
        HStack {
            // Back button
            Button(action: {
                navigationState.goHome()
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

            // Logo and title
            HStack(spacing: 12) {
                // Chat bubbles (green version for this screen)
                ZStack {
                    ChatBubbleShape(isFlipped: false)
                        .fill(Color.chattaLogoBubbleGrey)
                        .frame(width: 45, height: 40)
                        .offset(x: -12, y: 0)

                    ChatBubbleShape(isFlipped: true)
                        .fill(Color.chattaGreen)
                        .frame(width: 45, height: 40)
                        .offset(x: 12, y: -8)
                }
                .frame(width: 80, height: 50)

                Text("Chats")
                    .font(.chattaTitle)
                    .foregroundColor(.primary)
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

    // MARK: - New Chat Buttons
    private var newChatButtons: some View {
        HStack(spacing: 16) {
            // New Chat button
            Button(action: {
                showingNewChat = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.title3)
                    Text("New Chat")
                        .font(.chattaButtonSmall)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.chattaGreen)
                .cornerRadius(ChattaDimensions.buttonCornerRadius)
            }

            // New Group Chat button
            Button(action: {
                // Group chat - future feature
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "person.3.fill")
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("New Group")
                            .font(.chattaButtonSmall)
                        Text("Chat")
                            .font(.chattaButtonSmall)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.chattaGreen)
                .cornerRadius(ChattaDimensions.buttonCornerRadius)
            }
        }
        .padding(.horizontal, ChattaDimensions.paddingMedium)
        .padding(.vertical, ChattaDimensions.paddingMedium)
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white)

            TextField("Search", text: $searchText)
                .foregroundColor(.white)
                .accentColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.chattaGreen)
        .cornerRadius(8)
        .padding(.horizontal, ChattaDimensions.paddingMedium)
        .padding(.bottom, 8)
    }

    // MARK: - Chat List
    private var chatList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(filteredUsers, id: \.self) { user in
                    Button(action: {
                        selectedUser = user
                    }) {
                        chatRow(for: user)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Divider()
                        .padding(.leading, 80)
                }
            }
        }
    }

    // MARK: - Chat Row
    private func chatRow(for user: UserEntity) -> some View {
        let mostRecent = user.messageList.last
        let lastMessageTime = mostRecent != nil ?
            Date(timeIntervalSince1970: TimeInterval(Int64(mostRecent!.messageTimestamp))) : nil
        let isOnline = isUserOnline(user)

        return HStack(spacing: 12) {
            // Online indicator
            Circle()
                .fill(isOnline ? Color.chattaOnline : Color.clear)
                .frame(width: ChattaDimensions.statusDotSize, height: ChattaDimensions.statusDotSize)

            // Avatar
            ZStack {
                Circle()
                    .fill(Color(UIColor(hex: UInt32(user.num))))

                Text(user.shortName ?? "?")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: ChattaDimensions.avatarMedium, height: ChattaDimensions.avatarMedium)

            // Name and message
            VStack(alignment: .leading, spacing: 4) {
                Text(user.longName ?? "Unknown")
                    .font(.chattaBodyBold)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                if let message = mostRecent?.messagePayload {
                    Text(message)
                        .font(.chattaCaption)
                        .foregroundColor(.chattaTextSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Timestamp and chevron
            VStack(alignment: .trailing, spacing: 4) {
                if let time = lastMessageTime {
                    Text(formatTimestamp(time))
                        .font(.chattaTimestamp)
                        .foregroundColor(.chattaTextSecondary)
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.chattaTextSecondary)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, ChattaDimensions.paddingMedium)
        .background(Color.white)
    }

    // MARK: - Helper Methods
    private var filteredUsers: [UserEntity] {
        guard !searchText.isEmpty else {
            return Array(users)
        }
        return users.filter { user in
            let name = user.longName ?? ""
            return name.localizedCaseInsensitiveContains(searchText)
        }
    }

    private func isUserOnline(_ user: UserEntity) -> Bool {
        guard let lastHeard = user.userNode?.lastHeard else { return false }
        let twoHoursAgo = Calendar.current.date(byAdding: .minute, value: -120, to: Date()) ?? Date()
        return Date(timeIntervalSince1970: TimeInterval(lastHeard)) >= twoHoursAgo
    }

    private func formatTimestamp(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "M/d/yy"
            return formatter.string(from: date)
        }
    }
}

// MARK: - New Chat View (Simple user picker)
struct ChattaNewChatView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var context

    @Binding var selectedUser: UserEntity?

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key: "longName", ascending: true)],
        predicate: NSPredicate(format: "userNode.ignored == false && longName != '' && longName != nil"),
        animation: .default
    )
    var users: FetchedResults<UserEntity>

    var body: some View {
        NavigationStack {
            List(users, id: \.self) { user in
                Button(action: {
                    selectedUser = user
                    dismiss()
                }) {
                    HStack(spacing: 12) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(Color(UIColor(hex: UInt32(user.num))))

                            Text(user.shortName ?? "?")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(width: 40, height: 40)

                        Text(user.longName ?? "Unknown")
                            .font(.chattaBody)
                    }
                }
            }
            .navigationTitle("New Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ChattaChatsView()
        .environmentObject(ChattaNavigationState())
}
