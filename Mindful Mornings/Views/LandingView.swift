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

                // Icon
                Image(systemName: "sun.horizon.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.mmAccent, .mmPrimary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(.bottom, 24)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 10)

                Text("Mindful Mornings")
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundColor(.mmText)
                    .padding(.bottom, 8)
                    .opacity(appear ? 1 : 0)

                Text("Brief and simple daily mental health habits")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.mmTextSecondary)
                    .padding(.bottom, 60)
                    .opacity(appear ? 1 : 0)

                NavigationLink(destination: OnboardingCarouselView()) {
                    Text("Get Started")
                }
                .buttonStyle(MMPrimaryButtonStyle())
                .padding(.horizontal, 48)
                .opacity(appear ? 1 : 0)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appear = true
            }
        }
    }
}
