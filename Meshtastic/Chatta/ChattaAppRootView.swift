// ChattaAppRootView
// Main entry point for the Chatta UI experience
// This replaces the tab-based Meshtastic UI with a simplified flow

import SwiftUI
import CoreData

struct ChattaAppRootView: View {
    @EnvironmentObject var bleManager: BLEManager
    @EnvironmentObject var appState: AppState
    @StateObject private var navigationState = ChattaNavigationState()

    @Environment(\.managedObjectContext) private var context

    // Splash screen state
    @State private var showSplash = true
    private let splashDuration: Double = 2.5

    var body: some View {
        ZStack {
            // Main app content
            NavigationStack(path: $navigationState.navigationPath) {
                ZStack {
                    // Background
                    Color.chattaGreen
                        .ignoresSafeArea()

                    // Main content based on current screen
                    mainContent
                }
                .animation(.easeInOut(duration: 0.25), value: navigationState.currentScreen)
                .navigationDestination(for: ChattaNavigationState.ChattaDestination.self) { destination in
                    destinationView(for: destination)
                }
            }
            .environmentObject(navigationState)

            // Splash screen overlay
            if showSplash {
                ChattaSplashScreen()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            // Hide splash after duration
            DispatchQueue.main.asyncAfter(deadline: .now() + splashDuration) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        switch navigationState.currentScreen {
        case .home:
            ChattaHomeView()
                .transition(.opacity)

        case .chats:
            ChattaChatsView()
                .transition(.move(edge: .trailing))

        case .settings:
            ChattaSettingsView()
                .transition(.move(edge: .trailing))

        case .connectMate:
            ChattaConnectMateView()
                .transition(.move(edge: .trailing))
        }
    }

    @ViewBuilder
    private func destinationView(for destination: ChattaNavigationState.ChattaDestination) -> some View {
        switch destination {
        case .chatDetail(let userNum):
            if let user = fetchUser(userNum: userNum) {
                ChattaChatDetailView(user: user)
            } else {
                Text("User not found")
            }

        case .channelDetail(let channelId):
            // Channel detail view - could be added later
            Text("Channel: \(channelId)")

        case .connectYourChatta:
            ChattaConnectMateView()

        case .addMateToNetwork:
            ChattaConnectMateView()

        case .settingsDetail(let option):
            settingsDetailView(for: option)
        }
    }

    @ViewBuilder
    private func settingsDetailView(for option: ChattaNavigationState.SettingsOption) -> some View {
        switch option {
        case .about:
            ChattaAboutView()
        case .appSettings:
            ChattaAppSettingsView()
        case .pinSecurity:
            ChattaPinSecurityView()
        case .nameYourChatta:
            ChattaNameDeviceView()
        case .notifications:
            ChattaNotificationsView()
        }
    }

    private func fetchUser(userNum: Int64) -> UserEntity? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "num == %lld", userNum)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
}

// MARK: - Preview
#Preview {
    ChattaAppRootView()
        .environmentObject(AppState(router: Router()))
}
