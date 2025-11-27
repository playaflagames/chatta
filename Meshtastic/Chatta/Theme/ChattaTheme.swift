// Chatta Theme - Design System
// Based on Chatta Wireframes

import SwiftUI

// MARK: - Colors
extension Color {
    // Primary brand color - bright green
    static let chattaGreen = Color(red: 0.13, green: 0.77, blue: 0.37)  // #22C55E
    static let chattaGreenLight = Color(red: 0.55, green: 0.85, blue: 0.55)  // Lighter green for dots

    // Message bubbles
    static let chattaSentBubble = Color.chattaGreen
    static let chattaReceivedBubble = Color(red: 0.90, green: 0.90, blue: 0.90)  // Light grey

    // Text colors
    static let chattaTextOnGreen = Color.white
    static let chattaTextOnWhite = Color.chattaGreen
    static let chattaTextSecondary = Color.gray

    // Status indicators
    static let chattaConnected = Color.green
    static let chattaDisconnected = Color.red
    static let chattaOnline = Color.green

    // Logo colors
    static let chattaLogoBubbleGrey = Color(red: 0.70, green: 0.70, blue: 0.78)  // Lavender-grey
    static let chattaLogoBubbleWhite = Color.white
}

// MARK: - Fonts
extension Font {
    // Logo font - rounded, friendly
    static let chattaLogo = Font.system(size: 48, weight: .bold, design: .rounded)
    static let chattaLogoSmall = Font.system(size: 32, weight: .bold, design: .rounded)

    // Titles
    static let chattaTitle = Font.system(size: 32, weight: .bold, design: .rounded)
    static let chattaTitle2 = Font.system(size: 24, weight: .semibold, design: .rounded)
    static let chattaTitle3 = Font.system(size: 20, weight: .semibold, design: .rounded)

    // Body text
    static let chattaBody = Font.system(size: 17, weight: .regular, design: .default)
    static let chattaBodyBold = Font.system(size: 17, weight: .semibold, design: .default)

    // Captions
    static let chattaCaption = Font.system(size: 14, weight: .regular, design: .default)
    static let chattaTimestamp = Font.system(size: 12, weight: .regular, design: .default)

    // Buttons
    static let chattaButtonLarge = Font.system(size: 28, weight: .bold, design: .rounded)
    static let chattaButtonMedium = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let chattaButtonSmall = Font.system(size: 14, weight: .semibold, design: .rounded)
}

// MARK: - Dimensions
struct ChattaDimensions {
    // Corner radii
    static let buttonCornerRadius: CGFloat = 30
    static let cardCornerRadius: CGFloat = 20
    static let bubbleCornerRadius: CGFloat = 18
    static let inputCornerRadius: CGFloat = 25

    // Spacing
    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 16
    static let paddingLarge: CGFloat = 24
    static let paddingXLarge: CGFloat = 32

    // Button sizes
    static let primaryButtonHeight: CGFloat = 70
    static let secondaryButtonHeight: CGFloat = 50
    static let iconButtonSize: CGFloat = 44

    // Avatar sizes
    static let avatarSmall: CGFloat = 40
    static let avatarMedium: CGFloat = 50
    static let avatarLarge: CGFloat = 70

    // Status dot
    static let statusDotSize: CGFloat = 12
    static let connectionDotSize: CGFloat = 16
}

// MARK: - View Modifiers

struct ChattaPrimaryButtonStyle: ButtonStyle {
    var isFullWidth: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.chattaButtonLarge)
            .foregroundColor(.chattaTextOnWhite)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: ChattaDimensions.primaryButtonHeight)
            .background(Color.white)
            .cornerRadius(ChattaDimensions.buttonCornerRadius)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct ChattaSecondaryButtonStyle: ButtonStyle {
    var isFullWidth: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.chattaButtonMedium)
            .foregroundColor(.white)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: ChattaDimensions.secondaryButtonHeight)
            .padding(.horizontal, ChattaDimensions.paddingLarge)
            .background(Color.chattaGreen)
            .cornerRadius(ChattaDimensions.buttonCornerRadius)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct ChattaOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.chattaButtonSmall)
            .foregroundColor(.chattaGreen)
            .padding(.horizontal, ChattaDimensions.paddingMedium)
            .padding(.vertical, ChattaDimensions.paddingSmall)
            .background(Color.white)
            .cornerRadius(ChattaDimensions.buttonCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: ChattaDimensions.buttonCornerRadius)
                    .stroke(Color.chattaGreen, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Button Style Extensions
extension ButtonStyle where Self == ChattaPrimaryButtonStyle {
    static var chattaPrimary: ChattaPrimaryButtonStyle { ChattaPrimaryButtonStyle() }
}

extension ButtonStyle where Self == ChattaSecondaryButtonStyle {
    static var chattaSecondary: ChattaSecondaryButtonStyle { ChattaSecondaryButtonStyle() }
}

extension ButtonStyle where Self == ChattaOutlineButtonStyle {
    static var chattaOutline: ChattaOutlineButtonStyle { ChattaOutlineButtonStyle() }
}

// MARK: - View Extensions
extension View {
    func chattaGreenBackground() -> some View {
        self
            .background(Color.chattaGreen)
    }

    func chattaCard() -> some View {
        self
            .background(Color.white)
            .cornerRadius(ChattaDimensions.cardCornerRadius)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
