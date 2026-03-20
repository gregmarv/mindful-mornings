//
//  FocusSelectionView.swift
//  Mindful Mornings
//

import SwiftUI

struct FocusSelectionView: View {
    @EnvironmentObject var userData: UserData
    @State private var selectedFocus: String? = nil
    @State private var navigateToHome = false

    private let focusOptions: [(label: String, icon: String, description: String)] = [
        ("Finding calm", "wind", "Stress, anxiety, or feeling overwhelmed"),
        ("Processing loss", "heart", "Grief, change, or difficult transitions"),
        ("Building gratitude", "sun.max", "Noticing and appreciating what's here"),
        ("Seeking growth", "arrow.up.right", "Purpose, confidence, or new direction"),
        ("Strengthening connections", "person.2", "Relationships, kindness, belonging"),
        ("Just exploring", "sparkles", "I'm curious — show me everything"),
    ]

    var body: some View {
        ZStack {
            Color.mmBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 24)

                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "hand.wave")
                            .font(.system(size: 36))
                            .foregroundColor(.mmPrimary)

                        Text("What brings you here?")
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundColor(.mmText)

                        Text("This helps us show you prompts\nthat feel relevant to you.")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(.mmTextSecondary)
                            .multilineTextAlignment(.center)

                        Text("You can change this anytime.")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.mmTextSecondary.opacity(0.7))
                    }
                    .padding(.bottom, 8)

                    // Focus options
                    VStack(spacing: 10) {
                        ForEach(focusOptions, id: \.label) { option in
                            let isSelected = selectedFocus == option.label
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    selectedFocus = option.label
                                }
                            }) {
                                HStack(spacing: 14) {
                                    Image(systemName: option.icon)
                                        .font(.system(size: 18))
                                        .foregroundColor(isSelected ? .mmPrimary : .mmTextSecondary)
                                        .frame(width: 28)

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(option.label)
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundColor(.mmText)
                                        Text(option.description)
                                            .font(.system(size: 13, design: .rounded))
                                            .foregroundColor(.mmTextSecondary)
                                    }

                                    Spacer()

                                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(isSelected ? .mmPrimary : .mmDivider)
                                        .font(.system(size: 22))
                                }
                                .padding(.vertical, 14)
                                .padding(.horizontal, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(isSelected ? Color.mmPrimary.opacity(0.08) : Color.mmCard)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isSelected ? Color.mmPrimary.opacity(0.3) : Color.clear, lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // Continue — seeds mantras and completes onboarding
                    Button(action: {
                        let focus = selectedFocus ?? "Just exploring"
                        userData.focusArea = focus
                        userData.seedMantras(forFocusArea: focus)
                        userData.completeOnboarding()
                        navigateToHome = true
                    }) {
                        Text("Continue")
                    }
                    .buttonStyle(MMPrimaryButtonStyle())
                    .opacity(selectedFocus != nil ? 1.0 : 0.5)
                    .disabled(selectedFocus == nil)
                    .padding(.horizontal, 28)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationDestination(isPresented: $navigateToHome) {
            HomeView()
                .navigationBarBackButtonHidden(true)
        }
    }
}

struct FocusSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FocusSelectionView()
                .environmentObject(UserData())
        }
    }
}
