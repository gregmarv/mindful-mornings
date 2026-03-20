//
//  LandingView.swift
//  Mindful Mornings
//
//  Created by Gregory Marvin on 6/12/24.
//

import SwiftUI

struct LandingView: View {
    @State private var appear = false

    var body: some View {
        ZStack {
            Color.mmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                Spacer()

                // Icon
                Image(systemName: "sun.horizon.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.mmAccent, .mmPrimary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(.bottom, 28)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 10)

                // Title
                Text("Mindful Mornings")
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .foregroundColor(.mmText)
                    .padding(.bottom, 12)
                    .opacity(appear ? 1 : 0)

                // Tagline
                Text("A quiet space to begin your day.")
                    .font(.system(size: 17, design: .rounded))
                    .foregroundColor(.mmTextSecondary)
                    .padding(.bottom, 6)
                    .opacity(appear ? 1 : 0)

                // Subtagline
                Text("The most impactful habits are the simplest.")
                    .font(.system(size: 14, design: .rounded))
                    .italic()
                    .foregroundColor(.mmTextSecondary.opacity(0.7))
                    .padding(.bottom, 48)
                    .opacity(appear ? 1 : 0)

                // Features — minimal, just three short lines
                VStack(spacing: 14) {
                    featureRow(icon: "leaf.fill", text: "A personal mantra to ground you")
                    featureRow(icon: "pencil.line", text: "Two short prompts to set your intention")
                    featureRow(icon: "clock", text: "Under two minutes, every morning")
                }
                .padding(.horizontal, 48)
                .padding(.bottom, 48)
                .opacity(appear ? 1 : 0)

                // CTA
                NavigationLink(destination: OnboardingCarouselView()) {
                    Text("Get Started")
                }
                .buttonStyle(MMPrimaryButtonStyle())
                .padding(.horizontal, 48)
                .opacity(appear ? 1 : 0)

                Spacer()
                Spacer()
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                appear = true
            }
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.mmPrimary)
                .frame(width: 20)
            Text(text)
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(.mmTextSecondary)
            Spacer()
        }
    }
}
