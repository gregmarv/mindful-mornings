//
//  MantraSelectionView.swift
//  Mindful Mornings
//
//  Created by Gregory Marvin on 6/12/24.
//

import SwiftUI

struct MantraSelectionView: View {
    @EnvironmentObject var userData: UserData

    var body: some View {
        ZStack {
            Color.mmBackground.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "quote.opening")
                    .font(.system(size: 40))
                    .foregroundColor(.mmAccent)
                    .padding(.bottom, 4)

                Text("One last thing")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.mmText)

                VStack(spacing: 10) {
                    Text("Each morning starts with a mantra — a short phrase you read slowly before journaling.")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.mmTextSecondary)
                        .multilineTextAlignment(.center)

                    Text("You can write your own or pick from our suggestions. You can always change them later.")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.mmTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)

                VStack(spacing: 14) {
                    NavigationLink(destination: PresetMantrasView()) {
                        Text("Select Preset Mantras")
                    }
                    .buttonStyle(MMPrimaryButtonStyle())

                    NavigationLink(destination: CustomMantrasView()) {
                        Text("Add Custom Mantras")
                    }
                    .buttonStyle(MMSecondaryButtonStyle())
                }
                .padding(.horizontal, 48)

                Spacer()
                Spacer()
            }
        }
    }
}

struct MantraSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MantraSelectionView()
                .environmentObject(UserData())
        }
    }
}
