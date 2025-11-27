// ChattaConnectMateView
// Multi-step connection flow for device pairing and adding mates

import SwiftUI
import CoreImage.CIFilterBuiltins

struct ChattaConnectMateView: View {
    @EnvironmentObject var bleManager: BLEManager
    @EnvironmentObject var navigationState: ChattaNavigationState

    @State private var selectedFlow: ConnectionFlow?
    @State private var flowStep: FlowStep = .initial

    enum ConnectionFlow {
        case connectDevice
        case addMate
    }

    enum FlowStep {
        case initial
        case bluetoothPrompt
        case searching
        case deviceSelection
        case pinEntry
        case success
        case showQR
    }

    var body: some View {
        ZStack {
            // Green background
            Color.chattaGreen
                .ignoresSafeArea()

            // Decorative dots
            DecorativeDots(pattern: .scattered)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                connectionHeader

                // Separator line
                Rectangle()
                    .fill(Color.red)
                    .frame(height: 3)

                // Content based on flow step
                flowContent

                Spacer()
            }
        }
    }

    // MARK: - Header
    private var connectionHeader: some View {
        HStack {
            // Back button
            Button(action: {
                if flowStep == .initial {
                    navigationState.goHome()
                } else {
                    goBack()
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.chattaGreen)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(Circle())
            }

            Spacer()

            // Logo and title
            HStack(spacing: 12) {
                // Chat bubbles
                ZStack {
                    ChatBubbleShape(isFlipped: false)
                        .fill(Color.chattaLogoBubbleGrey)
                        .frame(width: 40, height: 35)
                        .offset(x: -10, y: 0)

                    ChatBubbleShape(isFlipped: true)
                        .fill(Color.white)
                        .frame(width: 40, height: 35)
                        .offset(x: 10, y: -6)
                }
                .frame(width: 70, height: 45)

                Text(headerTitle)
                    .font(.chattaTitle2)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.trailing)
            }

            Spacer()

            // Connection status
            Circle()
                .fill(bleManager.isConnected ? Color.chattaConnected : Color.chattaDisconnected)
                .frame(width: ChattaDimensions.connectionDotSize, height: ChattaDimensions.connectionDotSize)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
        }
        .padding(.horizontal, ChattaDimensions.paddingMedium)
        .padding(.vertical, ChattaDimensions.paddingSmall)
    }

    private var headerTitle: String {
        switch flowStep {
        case .initial:
            return selectedFlow == .addMate ? "Connect a Mate\nto your Network" : "Connect Your\nChatta!"
        case .bluetoothPrompt, .searching, .deviceSelection, .pinEntry, .success, .showQR:
            return selectedFlow == .addMate ? "Connect a Mate\nto your Network" : "Connect Your\nChatta!"
        }
    }

    // MARK: - Flow Content
    @ViewBuilder
    private var flowContent: some View {
        switch flowStep {
        case .initial:
            initialSelectionView
        case .bluetoothPrompt:
            bluetoothPromptView
        case .searching:
            searchingView
        case .deviceSelection:
            deviceSelectionView
        case .pinEntry:
            pinEntryView
        case .success:
            successView
        case .showQR:
            showQRView
        }
    }

    // MARK: - Initial Selection View
    private var initialSelectionView: some View {
        VStack(spacing: 24) {
            Text("What are you looking to do today?")
                .font(.chattaTitle3)
                .foregroundColor(.white)
                .padding(.top, 40)

            HStack(spacing: 16) {
                // Connect Your Chatta button
                Button(action: {
                    selectedFlow = .connectDevice
                    flowStep = .bluetoothPrompt
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "iphone.radiowaves.left.and.right")
                            .font(.title)
                            .foregroundColor(.chattaGreen)

                        Text("Connect Your")
                            .font(.chattaButtonSmall)
                        Text("Chatta")
                            .font(.chattaButtonSmall)
                    }
                    .foregroundColor(.chattaGreen)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.white)
                    .cornerRadius(ChattaDimensions.buttonCornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: ChattaDimensions.buttonCornerRadius)
                            .stroke(Color.chattaGreen, lineWidth: 2)
                    )
                }

                // Add a Mate button
                Button(action: {
                    selectedFlow = .addMate
                    flowStep = .showQR
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "person.3.fill")
                            .font(.title)
                            .foregroundColor(.chattaGreen)

                        Text("Add a Mate")
                            .font(.chattaButtonSmall)
                        Text("to your Network")
                            .font(.chattaButtonSmall)
                    }
                    .foregroundColor(.chattaGreen)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.white)
                    .cornerRadius(ChattaDimensions.buttonCornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: ChattaDimensions.buttonCornerRadius)
                            .stroke(Color.chattaGreen, lineWidth: 2)
                    )
                }
            }
            .padding(.horizontal, ChattaDimensions.paddingMedium)
        }
    }

    // MARK: - Bluetooth Prompt View
    private var bluetoothPromptView: some View {
        VStack(spacing: 32) {
            Text("Let's Do It!")
                .font(.chattaTitle)
                .foregroundColor(.white)
                .padding(.top, 40)

            Image(systemName: "iphone.radiowaves.left.and.right")
                .font(.system(size: 80))
                .foregroundColor(.white)

            Text("Make sure your bluetooth is turned on and click below when ready!")
                .font(.chattaBody)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: {
                flowStep = .searching
                bleManager.startScanning()
            }) {
                Text("Connect!")
            }
            .buttonStyle(.chattaPrimary)
            .padding(.horizontal, 60)
        }
    }

    // MARK: - Searching View
    private var searchingView: some View {
        VStack(spacing: 32) {
            Image(systemName: "iphone.radiowaves.left.and.right")
                .font(.system(size: 60))
                .foregroundColor(.white)
                .padding(.top, 40)

            Text("Searching for nearby Chattas. You'll be connected in no time!")
                .font(.chattaTitle3)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // Hourglass animation
            Image(systemName: "hourglass")
                .font(.system(size: 80))
                .foregroundColor(.white)
                .symbolEffect(.pulse)

            // Show found devices or auto-advance after finding
            if !bleManager.peripherals.isEmpty {
                Button(action: {
                    flowStep = .deviceSelection
                }) {
                    Text("Found \(bleManager.peripherals.count) device(s)")
                        .font(.chattaBodyBold)
                        .foregroundColor(.chattaGreen)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(ChattaDimensions.buttonCornerRadius)
                }
            }
        }
        .onChange(of: bleManager.peripherals.count) { _, newCount in
            if newCount > 0 {
                // Auto-advance after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    if flowStep == .searching {
                        flowStep = .deviceSelection
                    }
                }
            }
        }
    }

    // MARK: - Device Selection View
    private var deviceSelectionView: some View {
        VStack(spacing: 24) {
            Image(systemName: "iphone.radiowaves.left.and.right")
                .font(.system(size: 50))
                .foregroundColor(.white)
                .padding(.top, 40)

            Text("Which one is yours?")
                .font(.chattaTitle)
                .foregroundColor(.white)

            // Device list
            VStack(spacing: 12) {
                ForEach(bleManager.peripherals, id: \.peripheral.identifier) { peripheral in
                    Button(action: {
                        bleManager.connectTo(peripheral: peripheral.peripheral)
                        flowStep = .pinEntry
                    }) {
                        HStack {
                            Image(systemName: "iphone")
                                .font(.title2)
                                .foregroundColor(.chattaGreen)

                            Text(peripheral.shortName)
                                .font(.chattaBodyBold)
                                .foregroundColor(.chattaGreen)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(ChattaDimensions.buttonCornerRadius)
                    }
                }
            }
            .padding(.horizontal, 60)

            Text("Your Chatta ID is located on the back of your device")
                .font(.chattaCaption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    // MARK: - PIN Entry View
    @State private var pinCode = ""

    private var pinEntryView: some View {
        VStack(spacing: 24) {
            Image(systemName: "iphone.radiowaves.left.and.right")
                .font(.system(size: 50))
                .foregroundColor(.white)
                .padding(.top, 40)

            Text("What's Your Pin?")
                .font(.chattaTitle)
                .foregroundColor(.white)

            TextField("Enter PIN Number...", text: $pinCode)
                .keyboardType(.numberPad)
                .font(.chattaBody)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.white)
                .cornerRadius(ChattaDimensions.buttonCornerRadius)
                .padding(.horizontal, 60)

            Text("First Time Connecting?")
                .font(.chattaBodyBold)
                .foregroundColor(.white)

            Text("Your device PIN is set at 3891 - you can change it in settings at any time!")
                .font(.chattaCaption)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: {
                flowStep = .success
            }) {
                Text("Connect")
            }
            .buttonStyle(.chattaPrimary)
            .padding(.horizontal, 60)
        }
        .onChange(of: bleManager.isConnected) { _, isConnected in
            if isConnected {
                flowStep = .success
            }
        }
    }

    // MARK: - Success View
    private var successView: some View {
        VStack(spacing: 24) {
            Text("You're amazing! You've done it! You're connected and ready to start a Chatta!")
                .font(.chattaTitle3)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 40)

            Image(systemName: "checkmark")
                .font(.system(size: 100, weight: .bold))
                .foregroundColor(.white.opacity(0.7))

            Text("Now to connect you to your Mates. Get them to scan the below code, or you can scan the code on their phone to get started!")
                .font(.chattaBody)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // QR Code placeholder
            if let qrImage = generateQRCode() {
                Image(uiImage: qrImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .background(Color.white)
                    .padding(8)
                    .background(Color.white)
            }

            Button(action: {
                navigationState.goHome()
            }) {
                HStack {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            }
            .buttonStyle(.chattaPrimary)
            .padding(.horizontal, 100)
        }
    }

    // MARK: - Show QR View (Add Mate)
    private var showQRView: some View {
        VStack(spacing: 24) {
            Text("Yay! Friends! Let's Add a Mate to Your Network!")
                .font(.chattaTitle3)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 40)

            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(.white)

            Text("Get them to scan the below QR code to join your super secure network:")
                .font(.chattaBody)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // QR Code
            if let qrImage = generateQRCode() {
                Image(uiImage: qrImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .background(Color.white)
                    .padding(12)
                    .background(Color.white)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .frame(width: 200, height: 200)
                    .overlay(
                        Text("QR Code")
                            .foregroundColor(.gray)
                    )
            }

            Button(action: {
                navigationState.goHome()
            }) {
                HStack {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            }
            .buttonStyle(.chattaPrimary)
            .padding(.horizontal, 100)
        }
    }

    // MARK: - Helper Methods
    private func goBack() {
        switch flowStep {
        case .bluetoothPrompt:
            flowStep = .initial
            selectedFlow = nil
        case .searching:
            bleManager.stopScanning()
            flowStep = .bluetoothPrompt
        case .deviceSelection:
            flowStep = .searching
        case .pinEntry:
            flowStep = .deviceSelection
        case .success, .showQR:
            navigationState.goHome()
        case .initial:
            navigationState.goHome()
        }
    }

    private func generateQRCode() -> UIImage? {
        // Generate a channel sharing QR code
        // This would use the actual channel config in a real implementation
        let channelURL = "https://meshtastic.org/e/#ChattaNetwork"

        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()

        filter.message = Data(channelURL.utf8)

        guard let outputImage = filter.outputImage else { return nil }

        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }

        return UIImage(cgImage: cgImage)
    }
}

#Preview {
    ChattaConnectMateView()
        .environmentObject(ChattaNavigationState())
}
