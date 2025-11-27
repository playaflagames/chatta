// ChattaHomeView
// Main home screen with logo, Chats/Settings buttons, and connection status

import SwiftUI

struct ChattaHomeView: View {
    @EnvironmentObject var bleManager: BLEManager
    @EnvironmentObject var navigationState: ChattaNavigationState

    var body: some View {
        ZStack {
            // Green background
            Color.chattaGreen
                .ignoresSafeArea()

            // Decorative dots
            DecorativeDots(pattern: .scattered)
                .ignoresSafeArea()

            // Main content
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 60)

                // Logo
                ChattaLogo(size: .large, showText: true)
                    .padding(.bottom, 60)

                // Main buttons
                VStack(spacing: 20) {
                    // Chats button
                    Button(action: {
                        navigationState.navigateTo(.chats)
                    }) {
                        Text("Chats")
                    }
                    .buttonStyle(.chattaPrimary)
                    .padding(.horizontal, 40)

                    // Settings button
                    Button(action: {
                        navigationState.navigateTo(.settings)
                    }) {
                        Text("Settings")
                    }
                    .buttonStyle(.chattaPrimary)
                    .padding(.horizontal, 40)
                }

                Spacer()

                // Bottom section
                VStack(spacing: 16) {
                    // Connect a Mate button
                    Button(action: {
                        navigationState.startConnectionFlow()
                    }) {
                        HStack {
                            Text("Connect a Mate to your Network")
                                .font(.chattaBodyBold)
                                .foregroundColor(.chattaGreen)

                            Spacer()

                            Image(systemName: "qrcode")
                                .font(.title2)
                                .foregroundColor(.chattaGreen)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.95))
                        .cornerRadius(ChattaDimensions.buttonCornerRadius)
                    }
                    .padding(.horizontal, 40)

                    // Connection status bar
                    ChattaConnectionStatusBar()
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    ChattaHomeView()
        .environmentObject(ChattaNavigationState())
}
