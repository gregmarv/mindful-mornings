//
//  ManageAccountView.swift
//  Mindful Mornings
//
//  Created by Gregory Marvin on 6/12/24.
//

import SwiftUI

struct ManageAccountView: View {
    @EnvironmentObject var userData: UserData
    @State private var email = ""
    @State private var password = ""
    @State private var showSavedAlert = false

    var body: some View {
        ZStack {
            Color.mmBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 16)

                    // Mantra management section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Mantras")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.mmTextSecondary)
                            .textCase(.uppercase)
                            .tracking(1)

                        NavigationLink(destination: CustomMantrasView()) {
                            HStack {
                                Image(systemName: "pencil.line")
                                    .foregroundColor(.mmPrimary)
                                    .frame(width: 24)
                                Text("Edit Custom Mantras")
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

                        NavigationLink(destination: PresetMantrasView()) {
                            HStack {
                                Image(systemName: "list.bullet")
                                    .foregroundColor(.mmPrimary)
                                    .frame(width: 24)
                                Text("Edit Preset Mantras")
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

                    // Account details section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Account")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.mmTextSecondary)
                            .textCase(.uppercase)
                            .tracking(1)

                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .font(.system(size: 16, design: .rounded))
                            .mmTextField()

                        SecureField("New Password", text: $password)
                            .font(.system(size: 16, design: .rounded))
                            .mmTextField()
                    }

                    Button(action: {
                        if !email.isEmpty {
                            userData.updateEmail(email)
                        }
                        if !password.isEmpty {
                            userData.updatePassword(password)
                        }
                        showSavedAlert = true
                    }) {
                        Text("Save Changes")
                    }
                    .buttonStyle(MMPrimaryButtonStyle())
                    .padding(.top, 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            email = userData.email
        }
        .alert("Changes Saved", isPresented: $showSavedAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}
