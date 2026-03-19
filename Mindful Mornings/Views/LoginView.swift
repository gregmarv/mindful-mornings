//
//  LoginView.swift
//  Mindful Mornings
//
//  Created by Gregory Marvin on 6/12/24.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userData: UserData
    @State private var email = ""
    @State private var password = ""
    @State private var useFaceID = false
    @State private var navigateToMantras = false

    var body: some View {
        ZStack {
            Color.mmBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Spacer().frame(height: 40)

                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 44))
                        .foregroundColor(.mmPrimary)
                        .padding(.bottom, 4)

                    Text("Create Your Account")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(.mmText)

                    Text("Just a few details to get you started.")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.mmTextSecondary)
                        .padding(.bottom, 12)

                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .mmTextField()

                    SecureField("Password", text: $password)
                        .mmTextField()

                    Toggle(isOn: $useFaceID) {
                        HStack(spacing: 10) {
                            Image(systemName: "faceid")
                                .foregroundColor(.mmPrimary)
                            Text("Enable Face ID")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(.mmText)
                        }
                    }
                    .tint(.mmPrimary)
                    .padding(.vertical, 4)

                    Button(action: {
                        userData.email = email
                        userData.password = password
                        userData.useFaceID = useFaceID
                        navigateToMantras = true
                    }) {
                        Text("Continue")
                    }
                    .buttonStyle(MMPrimaryButtonStyle())
                    .padding(.top, 8)
                }
                .padding(.horizontal, 28)
            }
        }
        .navigationDestination(isPresented: $navigateToMantras) {
            MantraSelectionView()
        }
    }
}
