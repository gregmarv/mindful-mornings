//
//  OnboardingCarouselView.swift
//  Mindful Mornings
//

import SwiftUI

struct OnboardingCarouselView: View {
    @State private var currentPage = 0
    @State private var navigateToFocus = false

    @State private var showValueProp = true
    @State private var headlineVisible = false
    @State private var sublineVisible = false
    @State private var valuePropButtonVisible = false

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

            if showValueProp {
                valuePropView
                    .transition(.opacity)
            } else {
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
                .transition(.opacity)
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToFocus) {
            FocusSelectionView()
        }
    }

    // MARK: - Value Prop Screen (animated, unique layout)

    private var valuePropView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                Text("Studies show that a short daily gratitude practice can meaningfully improve mood, reduce stress, and increase life satisfaction.")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.mmText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)
                    .opacity(headlineVisible ? 1 : 0)
                    .offset(y: headlineVisible ? 0 : 20)

                Text("Our goal is to make that as simple\nand personal as possible for you.")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.mmTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
                    .opacity(sublineVisible ? 1 : 0)
                    .offset(y: sublineVisible ? 0 : 12)
            }

            Spacer()

            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showValueProp = false
                }
            }) {
                Text("Continue")
            }
            .buttonStyle(MMPrimaryButtonStyle())
            .padding(.horizontal, 48)
            .opacity(valuePropButtonVisible ? 1 : 0)
            .padding(.bottom, 48)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                headlineVisible = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeOut(duration: 0.8)) {
                    sublineVisible = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                withAnimation(.easeOut(duration: 0.6)) {
                    valuePropButtonVisible = true
                }
            }
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
