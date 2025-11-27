// ChattaSettingsView
// Simple settings view matching wireframes

import SwiftUI

struct ChattaSettingsView: View {
    @EnvironmentObject var bleManager: BLEManager
    @EnvironmentObject var navigationState: ChattaNavigationState

    @State private var showingAbout = false
    @State private var showingAppSettings = false
    @State private var showingPinSecurity = false
    @State private var showingNameChatta = false
    @State private var showingNotifications = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            settingsHeader

            // Separator line
            Rectangle()
                .fill(Color.chattaGreen)
                .frame(height: 3)

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Tagline
                    Text("Sometimes the boring bits can be exciting...")
                        .font(.chattaTitle3)
                        .foregroundColor(.primary)
                        .padding(.horizontal, ChattaDimensions.paddingMedium)
                        .padding(.top, ChattaDimensions.paddingLarge)
                        .padding(.bottom, ChattaDimensions.paddingMedium)

                    Divider()

                    // Settings rows
                    settingsRow(
                        icon: "questionmark.square",
                        iconColor: .blue,
                        title: "About Chatta"
                    ) {
                        showingAbout = true
                    }

                    Divider()
                        .padding(.leading, 60)

                    settingsRow(
                        icon: "gearshape",
                        iconColor: .blue,
                        title: "App Settings"
                    ) {
                        showingAppSettings = true
                    }

                    Divider()
                        .padding(.leading, 60)

                    settingsRow(
                        icon: "lock.fill",
                        iconColor: .blue,
                        title: "PIN & Security"
                    ) {
                        showingPinSecurity = true
                    }

                    Divider()
                        .padding(.leading, 60)

                    settingsRow(
                        icon: "square.on.square",
                        iconColor: .blue,
                        title: "Name your Chatta"
                    ) {
                        showingNameChatta = true
                    }

                    Divider()
                        .padding(.leading, 60)

                    settingsRow(
                        icon: "megaphone",
                        iconColor: .blue,
                        title: "Notifications"
                    ) {
                        showingNotifications = true
                    }

                    Divider()
                }
            }
            .background(Color.white)
        }
        .background(Color.white)
        .sheet(isPresented: $showingAbout) {
            ChattaAboutView()
        }
        .sheet(isPresented: $showingAppSettings) {
            ChattaAppSettingsView()
        }
        .sheet(isPresented: $showingPinSecurity) {
            ChattaPinSecurityView()
        }
        .sheet(isPresented: $showingNameChatta) {
            ChattaNameDeviceView()
        }
        .sheet(isPresented: $showingNotifications) {
            ChattaNotificationsView()
        }
    }

    // MARK: - Header
    private var settingsHeader: some View {
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

            // Logo with text
            HStack(spacing: 8) {
                // Chat bubbles with black variant for settings
                ZStack {
                    ChatBubbleShape(isFlipped: false)
                        .fill(Color.chattaLogoBubbleGrey)
                        .frame(width: 40, height: 35)
                        .offset(x: -10, y: 0)

                    ChatBubbleShape(isFlipped: true)
                        .fill(Color.black)
                        .frame(width: 40, height: 35)
                        .offset(x: 10, y: -6)
                }
                .frame(width: 70, height: 45)

                Text("chatta")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
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

    // MARK: - Settings Row
    private func settingsRow(
        icon: String,
        iconColor: Color,
        title: String,
        action: @escaping () -> Void
    ) -> some View {
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
            .padding(.vertical, 16)
            .padding(.horizontal, ChattaDimensions.paddingMedium)
        }
    }
}

// MARK: - About View
struct ChattaAboutView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // Logo
                ChattaLogo(size: .large, showText: true)
                    .padding()
                    .background(Color.chattaGreen)
                    .cornerRadius(20)

                Text("Version 1.0.0")
                    .font(.chattaCaption)
                    .foregroundColor(.chattaTextSecondary)

                Text("Chatta is a simple, friendly way to text your friends and family when you're off the grid.")
                    .font(.chattaBody)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Text("Powered by Meshtastic")
                    .font(.chattaCaption)
                    .foregroundColor(.chattaTextSecondary)

                Spacer()
            }
            .navigationTitle("About Chatta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - App Settings View (Stub)
struct ChattaAppSettingsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Display") {
                    Toggle("Dark Mode", isOn: .constant(false))
                }

                Section("Sound") {
                    Toggle("Message Sounds", isOn: .constant(true))
                    Toggle("Vibration", isOn: .constant(true))
                }
            }
            .navigationTitle("App Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - PIN & Security View (Stub)
struct ChattaPinSecurityView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentPin = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Your device PIN is used to pair with your Chatta device.")
                    .font(.chattaBody)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 40)

                Text("Default PIN: 3891")
                    .font(.chattaBodyBold)
                    .foregroundColor(.chattaGreen)

                Text("You can change this PIN on your Meshtastic device settings.")
                    .font(.chattaCaption)
                    .foregroundColor(.chattaTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()
            }
            .navigationTitle("PIN & Security")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Name Device View (Stub)
struct ChattaNameDeviceView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var bleManager: BLEManager

    @State private var deviceName = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Give your Chatta a friendly name")
                    .font(.chattaTitle3)
                    .padding(.top, 40)

                TextField("Device Name", text: $deviceName)
                    .font(.chattaBody)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 40)

                Text("This name will appear to other Chatta users on your network.")
                    .font(.chattaCaption)
                    .foregroundColor(.chattaTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()

                Button("Save") {
                    // Save device name
                    dismiss()
                }
                .buttonStyle(.chattaPrimary)
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .navigationTitle("Name your Chatta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                deviceName = bleManager.connectedPeripheral?.longName ?? ""
            }
        }
    }
}

// MARK: - Notifications View (Stub)
struct ChattaNotificationsView: View {
    @Environment(\.dismiss) var dismiss

    @State private var enableNotifications = true
    @State private var soundEnabled = true
    @State private var badgeEnabled = true

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Push Notifications", isOn: $enableNotifications)
                    Toggle("Sound", isOn: $soundEnabled)
                    Toggle("Badge Count", isOn: $badgeEnabled)
                }

                Section(footer: Text("These settings control how Chatta notifies you about new messages.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ChattaSettingsView()
        .environmentObject(ChattaNavigationState())
}
