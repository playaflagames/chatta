// Chatta Navigation State
// Simplified navigation for the Chatta app

import SwiftUI

// MARK: - Navigation State
class ChattaNavigationState: ObservableObject {
    @Published var currentScreen: ChattaScreen = .home
    @Published var navigationPath: [ChattaDestination] = []

    // Chat detail state
    @Published var selectedChatUserNum: Int64?
    @Published var selectedChatChannelId: Int32?

    // Connection flow state
    @Published var connectionFlowStep: ConnectionFlowStep = .initial

    enum ChattaScreen {
        case home
        case chats
        case settings
        case connectMate
    }

    enum ChattaDestination: Hashable {
        case chatDetail(userNum: Int64)
        case channelDetail(channelId: Int32)
        case connectYourChatta
        case addMateToNetwork
        case settingsDetail(SettingsOption)
    }

    enum SettingsOption: String, Hashable {
        case about
        case appSettings
        case pinSecurity
        case nameYourChatta
        case notifications
    }

    enum ConnectionFlowStep {
        case initial
        case bluetoothPrompt
        case searching
        case deviceSelection
        case pinEntry
        case success
        case shareQR
    }

    // MARK: - Navigation Methods

    func navigateTo(_ screen: ChattaScreen) {
        withAnimation(.easeInOut(duration: 0.25)) {
            currentScreen = screen
            navigationPath.removeAll()
        }
    }

    func push(_ destination: ChattaDestination) {
        withAnimation(.easeInOut(duration: 0.25)) {
            navigationPath.append(destination)
        }
    }

    func pop() {
        withAnimation(.easeInOut(duration: 0.25)) {
            if !navigationPath.isEmpty {
                navigationPath.removeLast()
            }
        }
    }

    func popToRoot() {
        withAnimation(.easeInOut(duration: 0.25)) {
            navigationPath.removeAll()
        }
    }

    func goHome() {
        withAnimation(.easeInOut(duration: 0.25)) {
            currentScreen = .home
            navigationPath.removeAll()
            connectionFlowStep = .initial
        }
    }

    // Connection flow helpers
    func startConnectionFlow() {
        connectionFlowStep = .initial
        navigateTo(.connectMate)
    }

    func advanceConnectionFlow() {
        switch connectionFlowStep {
        case .initial:
            connectionFlowStep = .bluetoothPrompt
        case .bluetoothPrompt:
            connectionFlowStep = .searching
        case .searching:
            connectionFlowStep = .deviceSelection
        case .deviceSelection:
            connectionFlowStep = .pinEntry
        case .pinEntry:
            connectionFlowStep = .success
        case .success:
            connectionFlowStep = .shareQR
        case .shareQR:
            goHome()
        }
    }
}
