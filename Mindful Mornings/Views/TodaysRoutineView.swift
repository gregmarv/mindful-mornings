//
//  TodaysRoutineView.swift
//  Mindful Mornings
//
//  Created by Gregory Marvin on 6/12/24.
//

import SwiftUI

struct TodaysRoutineView: View {
    @EnvironmentObject var userData: UserData
    @Environment(\.dismiss) private var dismiss
    @State private var currentMantra: String = ""
    @State private var showMantraPhase = true
    @State private var mantraProgress: Double = 0.0
    @State private var helpText = ""
    @State private var gratitudeText = ""
    @State private var showCompletion = false
    @State private var mantraOpacity: Double = 0.0

    // Breathing animation state
    @State private var breatheScale: CGFloat = 0.88
    @State private var breatheOpacity: Double = 0.06

    private let mantraDuration: Double = 7.0

    // Today's rotating prompts (stable within the day)
    private let helpPrompt = UserData.dailyPrompt(from: UserData.helpPrompts)
    private let gratitudePrompt = UserData.dailyPrompt(from: UserData.gratitudePrompts)

    var body: some View {
        ZStack {
            Color.mmBackground.ignoresSafeArea()

            if showCompletion {
                completionView
            } else if showMantraPhase {
                mantraView
            } else {
                journalView
            }
        }
        .navigationBarBackButtonHidden(showCompletion)
    }

    // MARK: - Mantra Phase

    private var mantraView: some View {
        ZStack {
            // Breathing background circle
            Circle()
                .fill(Color.mmPrimary.opacity(breatheOpacity))
                .frame(width: 300, height: 300)
                .scaleEffect(breatheScale)
                .animation(
                    .easeInOut(duration: 3.5).repeatForever(autoreverses: true),
                    value: breatheScale
                )

            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "leaf.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.mmPrimary.opacity(0.6))
                    .opacity(mantraOpacity)
                    .scaleEffect(breatheScale * 0.98 + 0.02) // subtle pulse on icon too

                Text("Today's Mantra")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.mmTextSecondary)
                    .textCase(.uppercase)
                    .tracking(1.5)
                    .opacity(mantraOpacity)

                Text(currentMantra)
                    .font(.system(size: 24, weight: .medium, design: .serif))
                    .foregroundColor(.mmText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
                    .opacity(mantraOpacity)

                Spacer()

                // Progress bar
                VStack(spacing: 8) {
                    ProgressView(value: mantraProgress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .mmPrimary))
                        .frame(height: 4)
                        .padding(.horizontal, 60)

                    Text("Take a moment to reflect...")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.mmTextSecondary)
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            currentMantra = userData.randomMantra()
            withAnimation(.easeIn(duration: 1.0)) {
                mantraOpacity = 1.0
            }
            // Start breathing animation
            breatheScale = 1.0
            breatheOpacity = 0.10
            startMantraTimer()
        }
    }

    // MARK: - Journal Phase

    private var journalView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 24)

                Image(systemName: "book.closed.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.mmAccent)

                Text("Morning Reflection")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(.mmText)
                    .padding(.bottom, 4)

                // Help prompt
                VStack(alignment: .leading, spacing: 8) {
                    Text(helpPrompt)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.mmTextSecondary)
                    TextEditor(text: $helpText)
                        .font(.system(size: 16, design: .rounded))
                        .frame(minHeight: 80)
                        .padding(12)
                        .scrollContentBackground(.hidden)
                        .background(Color.mmCard)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.mmDivider, lineWidth: 1)
                        )
                }

                // Gratitude prompt
                VStack(alignment: .leading, spacing: 8) {
                    Text(gratitudePrompt)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.mmTextSecondary)
                    TextEditor(text: $gratitudeText)
                        .font(.system(size: 16, design: .rounded))
                        .frame(minHeight: 80)
                        .padding(12)
                        .scrollContentBackground(.hidden)
                        .background(Color.mmCard)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.mmDivider, lineWidth: 1)
                        )
                }

                Button(action: {
                    userData.markTodayComplete()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showCompletion = true
                    }
                }) {
                    Text("Finish")
                }
                .buttonStyle(MMPrimaryButtonStyle())
                .padding(.top, 8)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Completion Phase

    private var completionView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.mmSuccess)

            Text("Well Done")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundColor(.mmText)

            Text("You've completed your morning routine.\nHave a wonderful day.")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.mmTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // Show updated streak if > 1
            if userData.currentStreak > 1 {
                HStack(spacing: 6) {
                    Text("🔥")
                        .font(.system(size: 15))
                    Text("\(userData.currentStreak) day streak!")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.mmPrimary)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 9)
                .background(Capsule().fill(Color.mmCard))
                .padding(.top, 4)
            }

            Button(action: {
                dismiss()
            }) {
                Text("Done")
            }
            .buttonStyle(MMPrimaryButtonStyle())
            .padding(.horizontal, 48)
            .padding(.top, 24)

            Spacer()
            Spacer()
        }
    }

    // MARK: - Timer

    private func startMantraTimer() {
        let interval = 0.05
        let steps = mantraDuration / interval
        var currentStep = 0.0

        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            currentStep += 1
            mantraProgress = currentStep / steps

            if currentStep >= steps {
                timer.invalidate()
                withAnimation(.easeInOut(duration: 0.5)) {
                    showMantraPhase = false
                }
            }
        }
    }
}

struct TodaysRoutineView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TodaysRoutineView()
                .environmentObject(UserData())
        }
    }
}
