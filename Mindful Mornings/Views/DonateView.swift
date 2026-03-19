//
//  DonateView.swift
//  Mindful Mornings
//
//  Created by Gregory Marvin on 6/13/24.
//

import SwiftUI
import StoreKit

struct DonateView: View {
    @State private var products: [Product] = []
    @State private var isLoading = true
    @State private var showThankYou = false
    @State private var purchasedProductName: String = ""
    @State private var errorMessage: String?
    @State private var showError = false

    private let productIDs = [
        "com.mindfulmornings.donate.small",
        "com.mindfulmornings.donate.medium",
        "com.mindfulmornings.donate.large"
    ]

    // Emoji for each tier, keyed by product ID
    private let tierEmoji: [String: String] = [
        "com.mindfulmornings.donate.small":  "🍵",
        "com.mindfulmornings.donate.medium": "✨",
        "com.mindfulmornings.donate.large":  "🫶"
    ]

    var body: some View {
        ZStack {
            Color.mmBackground.ignoresSafeArea()

            if showThankYou {
                thankYouView
            } else {
                mainContent
            }
        }
        .navigationTitle("Support")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadProducts() }
        .alert("Something went wrong", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "Please try again.")
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 16)

                // Header
                VStack(spacing: 12) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.mmAccent, .mmPrimary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Made with care")
                        .font(.system(size: 26, weight: .semibold, design: .rounded))
                        .foregroundColor(.mmText)

                    Text("This app is a one-person project, built to make mornings a little more intentional. If it's been useful to you, a small tip means a lot.")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.mmTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 8)
                }

                Divider()
                    .background(Color.mmDivider)
                    .padding(.horizontal, 20)

                // Products
                if isLoading {
                    ProgressView()
                        .tint(.mmPrimary)
                        .padding(.top, 20)
                } else if products.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 28))
                            .foregroundColor(.mmDivider)
                        Text("Tip options aren't available right now.")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(.mmTextSecondary)
                        Text("Please check back later.")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.mmTextSecondary)
                    }
                    .padding(.top, 20)
                } else {
                    VStack(spacing: 12) {
                        ForEach(products.sorted(by: { $0.price < $1.price }), id: \.id) { product in
                            tipRow(for: product)
                        }
                    }
                }

                // Footer note
                if !isLoading && !products.isEmpty {
                    Text("All tips are one-time purchases. No subscriptions, ever.")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.mmTextSecondary.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                }

                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Tip Row

    private func tipRow(for product: Product) -> some View {
        Button(action: {
            Task { await purchase(product) }
        }) {
            HStack(spacing: 14) {
                Text(tierEmoji[product.id] ?? "💚")
                    .font(.system(size: 28))

                VStack(alignment: .leading, spacing: 3) {
                    Text(product.displayName)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.mmText)
                    Text(product.description)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.mmTextSecondary)
                }

                Spacer()

                Text(product.displayPrice)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.mmPrimary)
            }
            .padding(16)
            .background(Color.mmCard)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.mmDivider, lineWidth: 1)
            )
        }
    }

    // MARK: - Thank You View

    private var thankYouView: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("🌿")
                .font(.system(size: 64))

            Text("Thank you")
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .foregroundColor(.mmText)

            Text("Your support genuinely helps.\nEvery tip keeps this project alive.")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.mmTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 40)

            Button(action: { withAnimation { showThankYou = false } }) {
                Text("Back")
            }
            .buttonStyle(MMSecondaryButtonStyle())
            .padding(.horizontal, 48)
            .padding(.top, 16)

            Spacer()
            Spacer()
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    // MARK: - StoreKit

    private func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            print("Failed to load products: \(error)")
        }
        isLoading = false
    }

    private func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    purchasedProductName = product.displayName
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showThankYou = true
                    }
                case .unverified:
                    errorMessage = "Your purchase could not be verified. Please contact support."
                    showError = true
                }
            case .userCancelled:
                break
            case .pending:
                errorMessage = "Your purchase is pending approval — it may take a moment."
                showError = true
            @unknown default:
                break
            }
        } catch {
            errorMessage = "There was a problem completing your purchase. Please try again."
            showError = true
        }
    }
}
