//
//  ReflectionEntry.swift
//  Mindful Mornings
//

import Foundation

struct ReflectionEntry: Codable, Identifiable {
    var id: UUID
    var date: Date
    var obligationsRating: Int   // 1–10: "I showed up for myself and the people around me"
    var contentmentRating: Int   // 1–10: "I found moments of peace and appreciation today"

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
