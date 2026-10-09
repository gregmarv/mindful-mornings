//
//  HabitHeatmapView.swift
//  Mindful Mornings
//

import SwiftUI

struct HabitHeatmapView: View {
    @EnvironmentObject var userData: UserData

    // Show 15 weeks (105 days) of history, ending today
    private let weeksToShow = 15
    private let cellSize: CGFloat = 18
    private let cellSpacing: CGFloat = 4

    // Build a 2D grid: [week][weekday 0=Mon…6=Sun]
    private var grid: [[Date?]] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Find the Monday on or before today
        let weekday = calendar.component(.weekday, from: today) // 1=Sun, 2=Mon...
        let daysFromMonday = (weekday + 5) % 7
        guard let firstMonday = calendar.date(byAdding: .day, value: -(daysFromMonday + (weeksToShow - 1) * 7), to: today) else { return [] }

        var weeks: [[Date?]] = []
        for w in 0..<weeksToShow {
            var week: [Date?] = []
            for d in 0..<7 {
                let offset = w * 7 + d
                if let date = calendar.date(byAdding: .day, value: offset, to: firstMonday) {
                    // Don't show future dates
                    week.append(date <= today ? date : nil)
                } else {
                    week.append(nil)
                }
            }
            weeks.append(week)
        }
        return weeks
    }

    // Month labels: one per week column, shown when month changes
    private var monthLabels: [String?] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        var labels: [String?] = []
        var lastMonth = -1
        for week in grid {
            let firstDate = week.compactMap { $0 }.first
            if let date = firstDate {
                let month = calendar.component(.month, from: date)
                if month != lastMonth {
                    labels.append(formatter.string(from: date))
                    lastMonth = month
                } else {
                    labels.append(nil)
                }
            } else {
                labels.append(nil)
            }
        }
        return labels
    }

    private let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        ZStack {
            Color.mmBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    Spacer().frame(height: 8)

                    // Header
                    VStack(spacing: 6) {
                        Image(systemName: "chart.dots.scatter")
                            .font(.system(size: 30))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.mmAccent, .mmPrimary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text("Your Habit")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundColor(.mmText)
                    }

                    // Stats row
                    statsRow

                    // Heatmap card
                    heatmapCard

                    // Legend
                    HStack(spacing: 6) {
                        Text("Less")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.mmTextSecondary)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.mmCard)
                            .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.mmDivider, lineWidth: 0.5))
                            .frame(width: cellSize, height: cellSize)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.mmPrimary.opacity(0.35))
                            .frame(width: cellSize, height: cellSize)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.mmPrimary)
                            .frame(width: cellSize, height: cellSize)
                        Text("More")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.mmTextSecondary)
                    }

                    Spacer().frame(height: 20)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(
                value: "\(userData.currentStreak)",
                label: "Current streak",
                icon: "flame.fill",
                iconColor: .mmAccent
            )
            statCard(
                value: "\(longestStreak)",
                label: "Longest streak",
                icon: "trophy.fill",
                iconColor: .mmPrimary
            )
            statCard(
                value: "\(totalCompletions)",
                label: "Total days",
                icon: "checkmark.circle.fill",
                iconColor: .mmSuccess
            )
        }
    }

    private func statCard(value: String, label: String, icon: String, iconColor: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(iconColor)
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.mmText)
            Text(label)
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(.mmTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.mmCard)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.mmDivider, lineWidth: 1))
    }

    // MARK: - Heatmap Card

    private var heatmapCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Month labels row
            HStack(spacing: cellSpacing) {
                // Offset for day-of-week labels
                Text("  ")
                    .font(.system(size: 10, design: .rounded))
                    .frame(width: 14)

                ForEach(0..<weeksToShow, id: \.self) { w in
                    Text(monthLabels[w] ?? "")
                        .font(.system(size: 10, design: .rounded))
                        .foregroundColor(.mmTextSecondary)
                        .frame(width: cellSize)
                }
            }

            // Grid rows (Mon–Sun)
            HStack(alignment: .top, spacing: cellSpacing) {
                // Day of week labels
                VStack(spacing: cellSpacing) {
                    ForEach(0..<7, id: \.self) { d in
                        Text(d % 2 == 0 ? dayLabels[d] : "")
                            .font(.system(size: 9, design: .rounded))
                            .foregroundColor(.mmTextSecondary)
                            .frame(width: 14, height: cellSize)
                    }
                }

                // Week columns
                HStack(spacing: cellSpacing) {
                    ForEach(0..<weeksToShow, id: \.self) { w in
                        VStack(spacing: cellSpacing) {
                            ForEach(0..<7, id: \.self) { d in
                                cell(for: grid[w][d])
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.mmCard)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.mmDivider, lineWidth: 1))
    }

    @ViewBuilder
    private func cell(for date: Date?) -> some View {
        if let date = date {
            let isToday = Calendar.current.isDateInToday(date)
            let completed = userData.isCompleted(on: date)

            RoundedRectangle(cornerRadius: 3)
                .fill(completed ? Color.mmPrimary : Color.mmCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(
                            isToday ? Color.mmPrimary : Color.mmDivider,
                            lineWidth: isToday ? 1.5 : 0.5
                        )
                )
                .frame(width: cellSize, height: cellSize)
        } else {
            // Future date — invisible placeholder
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.clear)
                .frame(width: cellSize, height: cellSize)
        }
    }

    // MARK: - Computed Stats

    private var totalCompletions: Int {
        userData.completedDates.count
    }

    private var longestStreak: Int {
        let calendar = Calendar.current
        let sortedDates = userData.completedDates
            .compactMap(UserData.date(fromKey:))
            .sorted()

        var longest = 0
        var current = 0
        var previousDate: Date?

        for date in sortedDates {
            if let prev = previousDate,
               let diff = calendar.dateComponents([.day], from: prev, to: date).day,
               diff == 1 {
                current += 1
            } else {
                current = 1
            }
            longest = max(longest, current)
            previousDate = date
        }
        return longest
    }
}

struct HabitHeatmapView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HabitHeatmapView()
                .environmentObject(UserData())
        }
    }
}
