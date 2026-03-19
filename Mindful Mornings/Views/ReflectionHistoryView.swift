//
//  ReflectionHistoryView.swift
//  Mindful Mornings
//

import SwiftUI
import Charts

struct ReflectionHistoryView: View {
    @EnvironmentObject var userData: UserData
    @Environment(\.dismiss) private var dismiss

    @State private var selectedRange: TimeRange = .week
    @State private var showingSurvey = false
    @State private var showingPermissionAlert = false
    @State private var localToggleValue: Bool = false

    enum TimeRange: String, CaseIterable {
        case week = "7D"
        case month = "30D"
        case all = "All"
    }

    var filteredEntries: [ReflectionEntry] {
        let sorted = userData.reflectionEntries.sorted { $0.date < $1.date }
        switch selectedRange {
        case .week:
            let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            return sorted.filter { $0.date >= cutoff }
        case .month:
            let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            return sorted.filter { $0.date >= cutoff }
        case .all:
            return sorted
        }
    }

    var body: some View {
        ZStack {
            Color.mmBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    Spacer().frame(height: 8)

                    // Header
                    VStack(spacing: 6) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.mmAccent, .mmPrimary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text("Evening Reflection")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundColor(.mmText)
                    }

                    // Toggle card
                    toggleCard

                    if userData.eveningReflectionEnabled {
                        // Log today button (if not yet done)
                        if userData.reflectionEntryForToday() == nil {
                            logTodayBanner
                        }

                        // Chart section
                        if userData.reflectionEntries.isEmpty {
                            emptyState
                        } else {
                            chartSection
                        }
                    }

                    Spacer().frame(height: 20)
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            localToggleValue = userData.eveningReflectionEnabled
        }
        .sheet(isPresented: $showingSurvey) {
            EveningReflectionSurveyView()
                .environmentObject(userData)
        }
        .alert("Notifications Disabled", isPresented: $showingPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {
                localToggleValue = false
            }
        } message: {
            Text("Please enable notifications for Mindful Mornings in Settings to use Evening Reflection.")
        }
    }

    // MARK: - Toggle Card

    private var toggleCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily reminder at 8 PM")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.mmText)
                    Text("A gentle nudge to rate your day")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.mmTextSecondary)
                }
                Spacer()
                Toggle("", isOn: $localToggleValue)
                    .tint(.mmPrimary)
                    .onChange(of: localToggleValue) { newValue in
                        handleToggleChange(newValue)
                    }
            }
        }
        .padding(18)
        .background(Color.mmCard)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.mmDivider, lineWidth: 1))
        .padding(.horizontal, 20)
    }

    // MARK: - Log Today Banner

    private var logTodayBanner: some View {
        Button(action: { showingSurvey = true }) {
            HStack(spacing: 12) {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.mmAccent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Log today's reflection")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.mmText)
                    Text("You haven't logged today yet")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.mmTextSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.mmTextSecondary)
            }
            .padding(16)
            .background(Color.mmCard)
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.mmDivider, lineWidth: 1))
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40))
                .foregroundColor(.mmPrimary.opacity(0.4))
            Text("Your reflection history will appear here")
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(.mmTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
        .background(Color.mmCard)
        .cornerRadius(14)
        .padding(.horizontal, 20)
    }

    // MARK: - Chart Section

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Time range picker
            Picker("Range", selection: $selectedRange) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)

            // Legend
            HStack(spacing: 20) {
                legendItem(color: .mmPrimary, label: "Obligations")
                legendItem(color: .mmAccent, label: "Contentment")
            }
            .padding(.horizontal, 20)

            // Chart
            if filteredEntries.isEmpty {
                Text("No data for this period")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.mmTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                Chart {
                    ForEach(filteredEntries) { entry in
                        LineMark(
                            x: .value("Date", entry.date, unit: .day),
                            y: .value("Obligations", entry.obligationsRating)
                        )
                        .foregroundStyle(Color.mmPrimary)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                        .symbol(Circle().strokeBorder(lineWidth: 1.5))
                        .symbolSize(40)
                    }

                    ForEach(filteredEntries) { entry in
                        LineMark(
                            x: .value("Date", entry.date, unit: .day),
                            y: .value("Contentment", entry.contentmentRating)
                        )
                        .foregroundStyle(Color.mmAccent)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                        .symbol(Circle().strokeBorder(lineWidth: 1.5))
                        .symbolSize(40)
                    }
                }
                .chartYScale(domain: 1...10)
                .chartYAxis {
                    AxisMarks(values: [1, 3, 5, 7, 10]) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.mmDivider)
                        AxisValueLabel {
                            if let v = value.as(Int.self) {
                                Text("\(v)")
                                    .font(.system(size: 11, design: .rounded))
                                    .foregroundColor(.mmTextSecondary)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: strideCount)) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.mmDivider)
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                            .font(.system(size: 11, design: .rounded))
                            .foregroundStyle(Color.mmTextSecondary)
                    }
                }
                .frame(height: 220)
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 20)
        .background(Color.mmCard)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.mmDivider, lineWidth: 1))
        .padding(.horizontal, 20)
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(.mmTextSecondary)
        }
    }

    private var strideCount: Int {
        switch selectedRange {
        case .week: return 2
        case .month: return 7
        case .all: return max(1, filteredEntries.count / 5)
        }
    }

    // MARK: - Toggle Logic

    private func handleToggleChange(_ newValue: Bool) {
        if newValue {
            NotificationManager.shared.checkPermissionStatus { status in
                switch status {
                case .authorized, .provisional:
                    userData.eveningReflectionEnabled = true
                    NotificationManager.shared.scheduleEveningReflection()
                case .notDetermined:
                    NotificationManager.shared.requestPermission { granted in
                        if granted {
                            userData.eveningReflectionEnabled = true
                            NotificationManager.shared.scheduleEveningReflection()
                        } else {
                            localToggleValue = false
                        }
                    }
                case .denied, .ephemeral:
                    localToggleValue = false
                    showingPermissionAlert = true
                @unknown default:
                    localToggleValue = false
                }
            }
        } else {
            userData.eveningReflectionEnabled = false
            NotificationManager.shared.cancelEveningReflection()
        }
    }
}

struct ReflectionHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ReflectionHistoryView()
                .environmentObject(UserData())
        }
    }
}
