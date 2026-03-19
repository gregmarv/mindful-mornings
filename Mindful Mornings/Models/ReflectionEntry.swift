//
//  ReflectionEntry.swift
//  Mindful Mornings
//

import Foundation

struct ReflectionEntry: Codable, Identifiable {
    var id: UUID
    var date: Date
    var obligationsRating: Int   // 1–10: "I upheld my obligations to myself and others"
    var contentmentRating: Int   // 1–10: "I felt contentment and fully appreciated my day"

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        obligationsRating: Int,
        contentmentRating: Int
    ) {
        self.id = id
        self.date = date
        self.obligationsRating = obligationsRating
        self.contentmentRating = contentmentRating
    }
}
