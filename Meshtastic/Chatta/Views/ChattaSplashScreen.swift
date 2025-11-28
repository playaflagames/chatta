// ChattaSplashScreen
// Loading screen displayed on app launch

import SwiftUI

struct ChattaSplashScreen: View {
    @State private var isAnimating = false
    @State private var showLogo = false
    @State private var pulsing = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.chattaGreen,
                    Color.chattaGreen.opacity(0.85)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                // Logo animation - using image asset
                Image("chatta-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 180)
                    .opacity(showLogo ? 1 : 0)
                    .scaleEffect(showLogo ? 1 : 0.5)
                    .scaleEffect(pulsing ? 1.02 : 1.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showLogo)

                // Note: Logo text is included in the chatta-logo image asset

                Spacer()

                // Loading indicator
                LoadingDotsView()
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeIn(duration: 0.3).delay(0.6), value: isAnimating)

                Spacer()
                    .frame(height: 60)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                showLogo = true
            }
            withAnimation {
                isAnimating = true
            }
            // Subtle pulse animation
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.8)) {
                pulsing = true
            }
        }
    }
}

// Loading dots animation
struct LoadingDotsView: View {
    @State private var animatingDot = 0

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(animatingDot == index ? 1.0 : 0.4))
                    .frame(width: 10, height: 10)
                    .scaleEffect(animatingDot == index ? 1.2 : 1.0)
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { timer in
            withAnimation(.easeInOut(duration: 0.3)) {
                animatingDot = (animatingDot + 1) % 3
            }
        }
    }
}

// Alternative loading spinner
struct ChattaLoadingSpinner: View {
    @State private var isRotating = false

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(Color.white, style: StrokeStyle(lineWidth: 3, lineCap: .round))
            .frame(width: 30, height: 30)
            .rotationEffect(.degrees(isRotating ? 360 : 0))
            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isRotating)
            .onAppear {
                isRotating = true
            }
    }
}

#Preview {
    ChattaSplashScreen()
}
