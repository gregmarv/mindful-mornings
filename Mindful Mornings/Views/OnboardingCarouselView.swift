//
//  OnboardingCarouselView.swift
//  Mindful Mornings
//

import SwiftUI

struct OnboardingCarouselView: View {
    @State private var currentPage = 0
    @State private var navigateToFocus = false

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "leaf.fill",
            iconColors: [Color(red: 0.47, green: 0.68, blue: 0.58), Color(red: 0.91, green: 0.74, blue: 0.41)],
            title: "A few quiet minutes\neach morning",
            body: "Each day begins with a personal mantra to set your intention, followed by two short reflection prompts. The whole routine takes under five minutes."
        ),
        OnboardingPage(
            icon: "flame.fill",
            iconColors: [Color(red: 0.91, green: 0.74, blue: 0.41), Color(red: 0.85, green: 0.50, blue: 0.30)],
            title: "Small habits,\nbig results",
            body: "Consistency is what makes a routine meaningful. Mindful Mornings tracks your streak so you can watch a daily practice take root over time."
        ),
        OnboardingPage(
            icon: "moon.stars.fill",
            iconColors: [Color(red: 0.55, green: 0.45, blue: 0.75), Color(red: 0.47, green: 0.68, blue: 0.58)],
            title: "Close the day\nwith intention",
            body: "An optional evening check-in lets you reflect on your day — two quick ratings that build into a picture of your wellbeing over time."
        ),
    ]

    var body: some View {
        ZStack {
            Color.mmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Page carousel
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        pageView(pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // Bottom controls
                VStack(spacing: 24) {
                    // Page dots
                    HStack(spacing: 8) {
                        ForEach(pages.indices, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ? Color.mmPrimary : Color.mmDivider)
                                .frame(width: index == currentPage ? 20 : 8, height: 8)
                                .animation(.easeInOut(duration: 0.25), value: currentPage)
                        }
                    }

                    // Button
                    Button(action: advance) {
                        Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                    }
                    .buttonStyle(MMPrimaryButtonStyle())
                    .padding(.horizontal, 48)

                    // Skip
                    if currentPage < pages.count - 1 {
                        Button(action: { navigateToFocus = true }) {
                            Text("Skip")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.mmTextSecondary)
                        }
                    } else {
                        Spacer().frame(height: 20)
                    }
                }
                .padding(.bottom, 48)
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToFocus) {
            FocusSelectionView()
        }
    }

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 28) {
            Spacer()

            // Icon bubble
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: page.iconColors.map { $0.opacity(0.15) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)

                Image(systemName: page.icon)
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: page.iconColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            // Text
            VStack(spacing: 14) {
                Text(page.title)
                    .font(.system(size: 26, weight: .semibold, design: .rounded))
                    .foregroundColor(.mmText)
                    .multilineTextAlignment(.center)

                Text(page.body)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.mmTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 36)
            }

            Spacer()
            Spacer()
        }
    }

    private func advance() {
        if currentPage < pages.count - 1 {
            withAnimation { currentPage += 1 }
        } else {
            navigateToFocus = true
        }
    }
}

private struct OnboardingPage {
    let icon: String
    let iconColors: [Color]
    let title: String
    let body: String
}

struct OnboardingCarouselView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            OnboardingCarouselView()
                .environmentObject(UserData())
        }
    }
}
