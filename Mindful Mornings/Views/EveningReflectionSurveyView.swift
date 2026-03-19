//
//  EveningReflectionSurveyView.swift
//  Mindful Mornings
//

import SwiftUI

struct EveningReflectionSurveyView: View {
    @EnvironmentObject var userData: UserData
    @Environment(\.dismiss) private var dismiss

    @State private var obligationsRating: Int? = nil
    @State private var contentmentRating: Int? = nil
    @State private var showingConfirmation = false

    var canSubmit: Bool {
        obligationsRating != nil && contentmentRating != nil
    }

    var body: some View {
        ZStack {
            Color.mmBackground.ignoresSafeArea()

            if showingConfirmation {
                confirmationView
            } else {
                surveyContent
            }
        }
    }

    // MARK: - Survey Content

    private var surveyContent: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer().frame(height: 16)

                // Header
                VStack(spacing: 10) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.mmAccent, .mmPrimary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Evening Reflection")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(.mmText)

                    Text("Rate your day on a scale of 1 to 10")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.mmTextSecondary)
                }
                .padding(.top, 8)

                Divider()
                    .background(Color.mmDivider)
                    .padding(.horizontal, 28)

                // Question 1
                questionBlock(
                    number: 1,
                    prompt: "I upheld my obligations to myself and others",
                    selection: $obligationsRating
                )

                // Question 2
                questionBlock(
                    number: 2,
                    prompt: "I felt contentment and fully appreciated my day",
                    selection: $contentmentRating
                )

                // Submit
                Button(action: submitSurvey) {
                    Text("Save Reflection")
                }
                .buttonStyle(MMPrimaryButtonStyle())
                .padding(.horizontal, 28)
                .disabled(!canSubmit)
                .opacity(canSubmit ? 1.0 : 0.5)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            // Pre-fill if already submitted today
            if let existing = userData.reflectionEntryForToday() {
                obligationsRating = existing.obligationsRating
                contentmentRating = existing.contentmentRating
            }
        }
    }

    // MARK: - Question Block

    private func questionBlock(number: Int, prompt: String, selection: Binding<Int?>) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 10) {
                Text("\(number)")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 22, height: 22)
                    .background(Circle().fill(Color.mmPrimary))

                Text(prompt)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.mmText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 28)

            // Rating picker: 1–10 tappable tiles
            HStack(spacing: 6) {
                ForEach(1...10, id: \.self) { value in
                    Button(action: { selection.wrappedValue = value }) {
                        Text("\(value)")
                            .font(.system(
                                size: 15,
                                weight: selection.wrappedValue == value ? .semibold : .regular,
                                design: .rounded
                            ))
                            .foregroundColor(selection.wrappedValue == value ? .white : .mmText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selection.wrappedValue == value ? Color.mmPrimary : Color.mmCard)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(
                                                selection.wrappedValue == value ? Color.clear : Color.mmDivider,
                                                lineWidth: 1
                                            )
                                    )
                            )
                    }
                }
            }
            .padding(.horizontal, 28)
        }
    }

    // MARK: - Confirmation View

    private var confirmationView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.mmSuccess)

            Text("Reflection Saved")
                .font(.system(size: 26, weight: .semibold, design: .rounded))
                .foregroundColor(.mmText)

            Text("See you tomorrow morning.")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.mmTextSecondary)

            Button(action: { dismiss() }) {
                Text("Done")
            }
            .buttonStyle(MMPrimaryButtonStyle())
            .padding(.horizontal, 48)
            .padding(.top, 16)

            Spacer()
            Spacer()
        }
    }

    // MARK: - Actions

    private func submitSurvey() {
        guard let obligations = obligationsRating, let contentment = contentmentRating else { return }
        userData.addOrUpdateReflectionEntry(
            obligationsRating: obligations,
            contentmentRating: contentment
        )
        withAnimation(.easeInOut(duration: 0.3)) {
            showingConfirmation = true
        }
    }
}

struct EveningReflectionSurveyView_Previews: PreviewProvider {
    static var previews: some View {
        EveningReflectionSurveyView()
            .environmentObject(UserData())
    }
}
