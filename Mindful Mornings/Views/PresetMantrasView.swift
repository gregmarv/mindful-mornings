//
//  PresetMantrasView.swift
//  Mindful Mornings
//
//  Created by Gregory Marvin on 6/12/24.
//

import SwiftUI

struct PresetMantrasView: View {
    @EnvironmentObject var userData: UserData
    @State private var selectedMantras: Set<String> = []
    @State private var navigateToHome = false

    let mantras = [
        "I choose presence over perfection",
        "Today I will show up fully for myself and others",
        "I choose how I respond to whatever comes my way",
        "My actions today reflect my values",
        "I am grateful for this ordinary day",
        "I hold my plans loosely and my values firmly",
        "I give my best to what matters most",
        "I can do difficult things",
        "The people in my life are worth my full attention",
        "Today I will be someone worth being around",
        "I don't need everything to be perfect to have a good day",
        "I take care of what's mine to take care of",
    ]

    var body: some View {
        ZStack {
            Color.mmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("Choose Your Mantras")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(.mmText)
                    Text("Tap the ones that resonate with you.")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.mmTextSecondary)
                }
                .padding(.top, 16)
                .padding(.bottom, 12)

                // Mantra list
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(mantras, id: \.self) { mantra in
                            let isSelected = selectedMantras.contains(mantra)
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    if isSelected {
                                        selectedMantras.remove(mantra)
                                    } else {
                                        selectedMantras.insert(mantra)
                                    }
                                }
                            }) {
                                HStack {
                                    Text(mantra)
                                        .font(.system(size: 15, design: .rounded))
                                        .foregroundColor(.mmText)
                                        .multilineTextAlignment(.leading)
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
                    .padding(.bottom, 16)
                }

                // Save button
                Button(action: {
                    if !selectedMantras.isEmpty {
                        userData.setPresetMantras(selectedMantras)
                        userData.completeOnboarding()
                        navigateToHome = true
                    }
                }) {
                    Text("Save & Continue")
                }
                .buttonStyle(MMPrimaryButtonStyle())
                .opacity(selectedMantras.isEmpty ? 0.5 : 1.0)
                .disabled(selectedMantras.isEmpty)
                .padding(.horizontal, 28)
                .padding(.vertical, 16)
            }
        }
        .onAppear {
            selectedMantras = Set(userData.mantras)
        }
        .navigationDestination(isPresented: $navigateToHome) {
            HomeView()
                .navigationBarBackButtonHidden(true)
        }
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.mmText)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.mmPrimary)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.mmDivider)
                }
            }
        }
    }
}
