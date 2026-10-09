//
//  ManageAccountView.swift
//  Mindful Mornings
//
//  Created by Gregory Marvin on 6/12/24.
//

import SwiftUI

struct ManageAccountView: View {
    @EnvironmentObject var userData: UserData
    @State private var newCustomMantra = ""

    var body: some View {
        ZStack {
            Color.mmBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 16)

                    // Focus area section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Focus Area")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.mmTextSecondary)
                            .textCase(.uppercase)
                            .tracking(1)

                        NavigationLink(destination: FocusSelectionView(isEditing: true)) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.mmPrimary)
                                    .frame(width: 24)
                                Text(userData.focusArea.isEmpty ? "Not set" : userData.focusArea)
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(.mmText)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13))
                                    .foregroundColor(.mmTextSecondary)
                            }
                            .padding(16)
                            .background(Color.mmCard)
                            .cornerRadius(12)
                        }
                    }

                    Divider()
                        .background(Color.mmDivider)

                    // Reminders section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Reminders")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.mmTextSecondary)
                            .textCase(.uppercase)
                            .tracking(1)

                        HStack {
                            Image(systemName: "bell")
                                .foregroundColor(.mmPrimary)
                                .frame(width: 24)
                            Text("Morning reminder")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(.mmText)
                            Spacer()
                            Text(userData.reminderTime.isEmpty ? "Not set" : userData.reminderTime)
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.mmTextSecondary)
                        }
                        .padding(16)
                        .background(Color.mmCard)
                        .cornerRadius(12)
                    }

                    Divider()
                        .background(Color.mmDivider)

                    // Mantra deck section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Mantras")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.mmTextSecondary)
                            .textCase(.uppercase)
                            .tracking(1)

                        Text("\(userData.mantras.count) in your deck")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.mmTextSecondary)

                        // Add custom mantra
                        HStack(spacing: 10) {
                            TextField("Add your own mantra...", text: $newCustomMantra)
                                .font(.system(size: 15, design: .rounded))
                                .mmTextField()

                            Button(action: {
                                userData.addCustomMantra(newCustomMantra)
                                newCustomMantra = ""
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.mmPrimary)
                            }
                            .disabled(newCustomMantra.trimmingCharacters(in: .whitespaces).isEmpty)
                            .opacity(newCustomMantra.trimmingCharacters(in: .whitespaces).isEmpty ? 0.4 : 1.0)
                        }

                        // Current mantras — swipe to delete
                        ForEach(userData.mantras, id: \.self) { mantra in
                            HStack(spacing: 12) {
                                // Weight indicator
                                let weight = userData.mantraWeights[mantra] ?? 1.0
                                Image(systemName: weight >= 1.5 ? "heart.fill" : "circle.fill")
                                    .font(.system(size: weight >= 1.5 ? 10 : 6))
                                    .foregroundColor(weight >= 1.5 ? .mmPrimary : .mmDivider)

                                Text(mantra)
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundColor(.mmText)

                                Spacer()

                                // Remove button
                                Button(action: {
                                    withAnimation {
                                        userData.removeMantra(mantra)
                                    }
                                }) {
                                    Image(systemName: "xmark.circle")
                                        .font(.system(size: 16))
                                        .foregroundColor(.mmTextSecondary.opacity(0.5))
                                }
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 14)
                            .background(Color.mmCard)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.mmDivider, lineWidth: 0.5)
                            )
                        }
                    }

                    Divider()
                        .background(Color.mmDivider)

                    // Support — always reachable (Home only shows the heart after a 7-day
                    // streak, and App Review must be able to find the in-app purchases).
                    NavigationLink(destination: DonateView()) {
                        HStack {
                            Image(systemName: "heart")
                                .foregroundColor(.mmPrimary)
                                .frame(width: 24)
                            Text("Support Mindful Mornings")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(.mmText)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13))
                                .foregroundColor(.mmTextSecondary)
                        }
                        .padding(16)
                        .background(Color.mmCard)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
