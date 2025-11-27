// ChattaConnectMateView
// Multi-step connection flow for device pairing and adding mates

import SwiftUI
import CoreImage.CIFilterBuiltins
import CoreData
import MeshtasticProtobufs

struct ChattaConnectMateView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var bleManager: BLEManager
    @EnvironmentObject var navigationState: ChattaNavigationState

    @State private var selectedFlow: ConnectionFlow?
    @State private var flowStep: FlowStep = .initial

    // QR Scanner state
    @State private var showingQRScanner = false
    @State private var scannedCode: String?

    // Channel URL state
    @State private var channelURL: String = ""

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
        case scanQR
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
        .onChange(of: bleManager.isConnected) { _, isConnected in
            if isConnected && flowStep == .pinEntry {
                // Generate channel URL when connected
                generateChannelURL()
                flowStep = .success
            }
        }
        .sheet(isPresented: $showingQRScanner) {
            ChattaQRScanner(scannedCode: $scannedCode) { code in
                handleScannedQRCode(code)
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
        case .scanQR:
            return "Join a\nNetwork"
        default:
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
        case .scanQR:
            scanQRPromptView
        }
    }

    // MARK: - Initial Selection View
    private var initialSelectionView: some View {
        VStack(spacing: 24) {
            Text("What are you looking to do today?")
                .font(.chattaTitle3)
                .foregroundColor(.white)
                .padding(.top, 40)

            VStack(spacing: 16) {
                // Connect Your Chatta button
                Button(action: {
                    selectedFlow = .connectDevice
                    flowStep = .bluetoothPrompt
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "iphone.radiowaves.left.and.right")
                            .font(.title)
                            .foregroundColor(.chattaGreen)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Connect Your Chatta")
                                .font(.chattaButtonMedium)
                                .foregroundColor(.chattaGreen)
                            Text("Pair with your Meshtastic device")
                                .font(.chattaCaption)
                                .foregroundColor(.chattaTextSecondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.chattaGreen)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(ChattaDimensions.buttonCornerRadius)
                }

                // Add a Mate button (show QR)
                Button(action: {
                    selectedFlow = .addMate
                    generateChannelURL()
                    flowStep = .showQR
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "person.badge.plus")
                            .font(.title)
                            .foregroundColor(bleManager.isConnected ? .chattaGreen : .gray)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Add a Mate to Your Network")
                                .font(.chattaButtonMedium)
                                .foregroundColor(bleManager.isConnected ? .chattaGreen : .gray)
                            Text("Share your network via QR code")
                                .font(.chattaCaption)
                                .foregroundColor(.chattaTextSecondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(bleManager.isConnected ? .chattaGreen : .gray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(ChattaDimensions.buttonCornerRadius)
                }
                .disabled(!bleManager.isConnected)
                .opacity(bleManager.isConnected ? 1.0 : 0.6)

                // Join a Network button (scan QR)
                Button(action: {
                    flowStep = .scanQR
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.title)
                            .foregroundColor(bleManager.isConnected ? .chattaGreen : .gray)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Join a Network")
                                .font(.chattaButtonMedium)
                                .foregroundColor(bleManager.isConnected ? .chattaGreen : .gray)
                            Text("Scan a mate's QR code to join")
                                .font(.chattaCaption)
                                .foregroundColor(.chattaTextSecondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(bleManager.isConnected ? .chattaGreen : .gray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(ChattaDimensions.buttonCornerRadius)
                }
                .disabled(!bleManager.isConnected)
                .opacity(bleManager.isConnected ? 1.0 : 0.6)
            }
            .padding(.horizontal, ChattaDimensions.paddingMedium)

            if !bleManager.isConnected {
                Text("Connect your Chatta device first to add mates or join networks")
                    .font(.chattaCaption)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
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

            Text("Make sure your Bluetooth is turned on and your Chatta device is powered up!")
                .font(.chattaBody)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: {
                flowStep = .searching
                bleManager.startScanning()
            }) {
                Text("Search for Devices")
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

            Text("Searching for nearby Chattas...")
                .font(.chattaTitle3)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // Loading animation
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(2)
                .padding(.vertical, 40)

            // Show found devices or auto-advance after finding
            if !bleManager.peripherals.isEmpty {
                Button(action: {
                    flowStep = .deviceSelection
                }) {
                    Text("Found \(bleManager.peripherals.count) device(s) - Tap to select")
                        .font(.chattaBodyBold)
                        .foregroundColor(.chattaGreen)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(ChattaDimensions.buttonCornerRadius)
                }
            }

            Text("Make sure your device is on and in range")
                .font(.chattaCaption)
                .foregroundColor(.white.opacity(0.8))
        }
        .onChange(of: bleManager.peripherals.count) { _, newCount in
            if newCount > 0 {
                // Auto-advance after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    if flowStep == .searching && !bleManager.peripherals.isEmpty {
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

            Text("Which device is yours?")
                .font(.chattaTitle)
                .foregroundColor(.white)

            // Device list
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(bleManager.peripherals, id: \.peripheral.identifier) { peripheral in
                        Button(action: {
                            bleManager.connectTo(peripheral: peripheral.peripheral)
                            flowStep = .pinEntry
                        }) {
                            HStack {
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                    .font(.title2)
                                    .foregroundColor(.chattaGreen)

                                VStack(alignment: .leading) {
                                    Text(peripheral.longName)
                                        .font(.chattaBodyBold)
                                        .foregroundColor(.chattaGreen)
                                    Text(peripheral.shortName)
                                        .font(.chattaCaption)
                                        .foregroundColor(.chattaTextSecondary)
                                }

                                Spacer()

                                // Signal strength indicator
                                ChattaSignalStrengthIndicator(rssi: peripheral.rssi)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(ChattaDimensions.buttonCornerRadius)
                        }
                    }
                }
            }
            .frame(maxHeight: 300)
            .padding(.horizontal, 40)

            Text("Tap on your device to connect. Your device name is shown on its screen.")
                .font(.chattaCaption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: {
                bleManager.startScanning()
            }) {
                Text("Scan Again")
            }
            .buttonStyle(.chattaOutline)
        }
    }

    // MARK: - PIN Entry View (iOS handles this natively)
    @State private var pinCode = ""

    private var pinEntryView: some View {
        VStack(spacing: 24) {
            Image(systemName: "lock.shield")
                .font(.system(size: 60))
                .foregroundColor(.white)
                .padding(.top, 40)

            Text("Connecting...")
                .font(.chattaTitle)
                .foregroundColor(.white)

            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
                .padding()

            Text("If prompted, enter the PIN shown on your Chatta device. The default PIN is 3891.")
                .font(.chattaBody)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Text("iOS will show a pairing dialog if this is your first time connecting.")
                .font(.chattaCaption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    // MARK: - Success View
    private var successView: some View {
        VStack(spacing: 24) {
            Text("You're Connected!")
                .font(.chattaTitle)
                .foregroundColor(.white)
                .padding(.top, 40)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.white)

            Text("Your Chatta is ready to use. Share the QR code below to let your mates join your secure network.")
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
                    .frame(width: 150, height: 150)
                    .background(Color.white)
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(12)
            }

            HStack(spacing: 16) {
                Button(action: {
                    navigationState.goHome()
                }) {
                    HStack {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                }
                .buttonStyle(.chattaPrimary)

                if bleManager.isConnected && !channelURL.isEmpty {
                    ShareLink(
                        item: channelURL,
                        subject: Text("Join my Chatta Network"),
                        message: Text("Scan this link or QR code to join my secure Chatta network")
                    ) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }
                        .font(.chattaButtonMedium)
                        .foregroundColor(.chattaGreen)
                        .padding(.horizontal, 24)
                        .frame(height: ChattaDimensions.primaryButtonHeight)
                        .background(Color.white)
                        .cornerRadius(ChattaDimensions.buttonCornerRadius)
                    }
                }
            }
            .padding(.horizontal, 40)
        }
    }

    // MARK: - Show QR View (Add Mate)
    private var showQRView: some View {
        VStack(spacing: 24) {
            Text("Share Your Network")
                .font(.chattaTitle)
                .foregroundColor(.white)
                .padding(.top, 40)

            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(.white)

            Text("Your mate can scan this QR code to join your secure Chatta network")
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
                    .cornerRadius(16)
            } else {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    Text("No channel configured")
                        .font(.chattaCaption)
                        .foregroundColor(.white)
                }
                .frame(width: 200, height: 200)
                .background(Color.white.opacity(0.2))
                .cornerRadius(16)
            }

            // Security info
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(.white)
                Text("Encrypted with 256-bit AES")
                    .font(.chattaCaption)
                    .foregroundColor(.white.opacity(0.9))
            }

            HStack(spacing: 16) {
                Button(action: {
                    navigationState.goHome()
                }) {
                    HStack {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                }
                .buttonStyle(.chattaPrimary)

                if !channelURL.isEmpty {
                    ShareLink(
                        item: channelURL,
                        subject: Text("Join my Chatta Network"),
                        message: Text("Scan this link or QR code to join my secure Chatta network")
                    ) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }
                        .font(.chattaButtonMedium)
                        .foregroundColor(.chattaGreen)
                        .padding(.horizontal, 24)
                        .frame(height: ChattaDimensions.primaryButtonHeight)
                        .background(Color.white)
                        .cornerRadius(ChattaDimensions.buttonCornerRadius)
                    }
                }
            }
            .padding(.horizontal, 40)
        }
    }

    // MARK: - Scan QR Prompt View
    private var scanQRPromptView: some View {
        VStack(spacing: 32) {
            Text("Join a Network")
                .font(.chattaTitle)
                .foregroundColor(.white)
                .padding(.top, 40)

            Image(systemName: "qrcode.viewfinder")
                .font(.system(size: 80))
                .foregroundColor(.white)

            Text("Scan your mate's QR code to join their secure Chatta network")
                .font(.chattaBody)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: {
                showingQRScanner = true
            }) {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("Open Scanner")
                }
            }
            .buttonStyle(.chattaPrimary)
            .padding(.horizontal, 60)

            Text("Your mate's channel settings will be securely added to your device")
                .font(.chattaCaption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
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
        case .scanQR:
            flowStep = .initial
        case .initial:
            navigationState.goHome()
        }
    }

    private func generateChannelURL() {
        // Get the connected node's channel configuration
        guard let connectedNode = bleManager.connectedPeripheral,
              connectedNode.num > 0 else {
            channelURL = ""
            return
        }

        let nodeNum = Int64(connectedNode.num)

        // Fetch the node info from Core Data
        let fetchRequest: NSFetchRequest<NodeInfoEntity> = NodeInfoEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "num == %lld", nodeNum)
        fetchRequest.fetchLimit = 1

        do {
            if let node = try context.fetch(fetchRequest).first,
               let myInfo = node.myInfo,
               let channels = myInfo.channels?.array as? [ChannelEntity] {

                var channelSet = ChannelSet()

                // Add LoRa config
                if let loraConfig = node.loRaConfig {
                    var loRaConfig = Config.LoRaConfig()
                    loRaConfig.region = RegionCodes(rawValue: Int(loraConfig.regionCode))?.protoEnumValue() ?? .unset
                    loRaConfig.modemPreset = ModemPresets(rawValue: Int(loraConfig.modemPreset))?.protoEnumValue() ?? .longFast
                    loRaConfig.bandwidth = UInt32(loraConfig.bandwidth)
                    loRaConfig.spreadFactor = UInt32(loraConfig.spreadFactor)
                    loRaConfig.codingRate = UInt32(loraConfig.codingRate)
                    loRaConfig.frequencyOffset = loraConfig.frequencyOffset
                    loRaConfig.hopLimit = UInt32(loraConfig.hopLimit)
                    loRaConfig.txEnabled = loraConfig.txEnabled
                    loRaConfig.txPower = loraConfig.txPower
                    loRaConfig.usePreset = loraConfig.usePreset
                    loRaConfig.channelNum = UInt32(loraConfig.channelNum)
                    channelSet.loraConfig = loRaConfig
                }

                // Add channels
                for channel in channels where channel.role > 0 {
                    var channelSettings = ChannelSettings()
                    channelSettings.name = channel.name ?? ""
                    channelSettings.psk = channel.psk ?? Data()
                    channelSettings.id = UInt32(channel.id)
                    channelSet.settings.append(channelSettings)
                }

                // Generate URL
                if let settingsData = try? channelSet.serializedData() {
                    let base64String = settingsData.base64EncodedString().base64ToBase64url()
                    channelURL = "https://meshtastic.org/e/#\(base64String)"
                }
            }
        } catch {
            print("Error fetching node info: \(error)")
            channelURL = ""
        }
    }

    private func generateQRCode() -> UIImage? {
        guard !channelURL.isEmpty else { return nil }

        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()

        filter.message = Data(channelURL.utf8)

        guard let outputImage = filter.outputImage else { return nil }

        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }

        return UIImage(cgImage: cgImage)
    }

    private func handleScannedQRCode(_ code: String) {
        // Extract channel settings from the URL
        guard code.lowercased().contains("meshtastic.org/e/") else { return }

        if let components = code.components(separatedBy: "#").last {
            let addChannels = code.lowercased().contains("add=true")
            let channelSettings = components.components(separatedBy: "?").first ?? components

            // Save the channel settings
            let success = bleManager.saveChannelSet(base64UrlString: channelSettings, addChannels: addChannels)

            if success {
                // Show success and go back
                flowStep = .success
            }
        }
    }
}

// MARK: - Signal Strength Indicator
struct ChattaSignalStrengthIndicator: View {
    let rssi: Int

    var signalBars: Int {
        if rssi >= -50 { return 4 }
        if rssi >= -60 { return 3 }
        if rssi >= -70 { return 2 }
        return 1
    }

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<4, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(index < signalBars ? Color.chattaGreen : Color.gray.opacity(0.3))
                    .frame(width: 4, height: CGFloat(6 + index * 4))
            }
        }
    }
}

#Preview {
    ChattaConnectMateView()
        .environmentObject(ChattaNavigationState())
}
