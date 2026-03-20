//
//  HomeView.swift
//  Mindful Mornings
//
//  Created by Gregory Marvin on 6/12/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userData: UserData

    private var todayComplete: Bool {
        userData.isCompleted(on: Date())
    }

    // Time-aware greeting
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default:      return "Good Evening"
        }
    }

    private var greetingSubtitle: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Take a few minutes to center yourself."
        case 12..<17: return "Pause and reconnect with your intentions."
        default:      return "Reflect and wind down with intention."
        }
    }

    var body: some View {
        ZStack {
            Color.mmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    if userData.currentStreak >= 7 {
                        NavigationLink(destination: DonateView()) {
                            Image(systemName: "heart")
                                .font(.system(size: 18))
                                .foregroundColor(.mmPrimary)
                                .padding(10)
                                .background(Circle().fill(Color.mmCard))
                        }
                    }
                    Spacer()
                    NavigationLink(destination: ReflectionHistoryView()) {
                        Image(systemName: "moon.stars")
                            .font(.system(size: 18))
                            .foregroundColor(.mmPrimary)
                            .padding(10)
                            .background(Circle().fill(Color.mmCard))
                    }
                    NavigationLink(destination: ManageAccountView()) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 18))
                            .foregroundColor(.mmPrimary)
                            .padding(10)
                            .background(Circle().fill(Color.mmCard))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                Spacer()

                // Center content
                VStack(spacing: 16) {
                    if todayComplete {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 52))
                            .foregroundColor(.mmSuccess)
                            .padding(.bottom, 8)

                        Text("You're all set today")
                            .font(.system(size: 28, weight: .semibold, design: .rounded))
                            .foregroundColor(.mmText)

                        Text("Your morning routine is done.\nEnjoy the rest of your day.")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.mmTextSecondary)
                            .multilineTextAlignment(.center)
                    } else {
                        Image(systemName: "sun.horizon.fill")
                            .font(.system(size: 52))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.mmAccent, .mmPrimary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .padding(.bottom, 8)

                        Text(greeting)
                            .font(.system(size: 28, weight: .semibold, design: .rounded))
                            .foregroundColor(.mmText)

                        Text(greetingSubtitle)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.mmTextSecondary)
                    }

                    // Streak badge
                    if userData.currentStreak > 0 {
                        NavigationLink(destination: HabitHeatmapView()) {
                            HStack(spacing: 6) {
                                Text("🔥")
                                    .font(.system(size: 14))
                                Text("\(userData.currentStreak) day streak")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.mmPrimary)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                Capsule().fill(Color.mmCard)
                                    .overlay(Capsule().stroke(Color.mmDivider, lineWidth: 1))
                            )
                        }
                        .padding(.top, 4)
                    }
                }

                Spacer()

                // Start / repeat button
                if todayComplete {
                    NavigationLink(destination: TodaysRoutineView()) {
                        Text("Revisit Today's Routine")
                    }
                    .buttonStyle(MMSecondaryButtonStyle())
                    .padding(.horizontal, 40)
                    .padding(.bottom, 48)
                } else {
                    NavigationLink(destination: TodaysRoutineView()) {
                        Text("Start Today's Routine")
                    }
                    .buttonStyle(MMPrimaryButtonStyle())
                    .padding(.horizontal, 40)
                    .padding(.bottom, 48)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
