//
//  ScrapbookCardView.swift
//  Scrapbook
//
//  Created by Diya Patel on 4/27/26.
//

import SwiftUI
import SwiftData

struct ScrapbookCardView: View {
    let item: Item
    
    private var displayTitle: String {
        let trimmedTitle = item.title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedTitle.isEmpty ? "Untitled" : trimmedTitle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // header text "Title: 2026"
            Text("\(displayTitle): \(item.timestamp, format: .dateTime.year())")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.scrapbookText)
                .padding(.leading, 4)

            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.scrapbookAccent)
                    Image(systemName: "book.closed.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color.scrapbookIcon)
                        .overlay(alignment: .bottomLeading) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.white)
                                .padding(4)
                        }
                }
                .frame(width: 60, height: 60)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.timestamp, format: .dateTime.month().day().year())
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.scrapbookText)
                    
                    Text("\(item.pages.count) Pages")
                        .font(.system(size: 14))
                        .foregroundColor(Color.scrapbookSecondaryText)
                }

                Spacer()

                // arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.scrapbookSecondaryText)
            }
        }
        .padding(16)
        .background(Color.scrapbookCardBackground)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
