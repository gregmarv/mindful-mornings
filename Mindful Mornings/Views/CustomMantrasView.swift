//
//  CustomMantrasView.swift
//  Mindful Mornings
//
//  Created by Gregory Marvin on 6/12/24.
//

import SwiftUI

struct CustomMantrasView: View {
    @EnvironmentObject var userData: UserData
    @State private var mantras: [String] = Array(repeating: "", count: 3)
    @State private var navigateToHome = false

    private var hasValidMantras: Bool {
        mantras.contains { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    var body: some View {
        ZStack {
            Color.mmBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Spacer().frame(height: 20)

                    Image(systemName: "pencil.line")
                        .font(.system(size: 36))
                        .foregroundColor(.mmPrimary)

                    Text("Write Your Mantras")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(.mmText)

                    Text("Add up to 15 personal mantras\nfor your morning routine.")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.mmTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 8)

                    ForEach(0..<mantras.count, id: \.self) { index in
                        TextField("Mantra \(index + 1)", text: $mantras[index])
                            .font(.system(size: 16, design: .rounded))
                            .mmTextField()
                    }

                    if mantras.count < 15 {
                        Button(action: {
                            mantras.append("")
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle")
                                Text("Add Another")
                            }
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.mmPrimary)
                        }
                        .padding(.top, 4)
                    }

                    Button(action: {
                        let nonEmpty = mantras.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                        if !nonEmpty.isEmpty {
                            userData.mantras = nonEmpty
                            userData.completeOnboarding()
                            navigateToHome = true
                        }
                    }) {
                        Text("Save & Continue")
                    }
                    .buttonStyle(MMPrimaryButtonStyle())
                    .opacity(hasValidMantras ? 1.0 : 0.5)
                    .disabled(!hasValidMantras)
                    .padding(.top, 8)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            if !userData.mantras.isEmpty {
                mantras = userData.mantras
            }
        }
        .navigationDestination(isPresented: $navigateToHome) {
            HomeView()
                .navigationBarBackButtonHidden(true)
        }
    }
}
