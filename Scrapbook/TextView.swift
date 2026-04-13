//
//  TextView.swift
//  Scrapbook
//
//  Created by Diya Patel on 3/30/26.
//

import SwiftUI

struct TextView: View {
    @Bindable var text: ScrapbookText
    @State private var dragOffset: CGSize = .zero
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) var colorScheme
    var allTexts: [ScrapbookText] // handles layering

    
    var body: some View {
        TextField("Type here..", text: $text.content, axis: .vertical)
            .font(.title2)
            .padding(8)
            .frame(minWidth: 100)
            .foregroundStyle(text.boxColor)
            .cornerRadius(4)
            .focused($isFocused) 
            .offset(x: text.offSetX + dragOffset.width, y: text.offSetY + dragOffset.height)
            .zIndex(text.zIndex)
            .gesture(
                DragGesture(minimumDistance: 5)
                    .onChanged { value in
                        let maxZ = allTexts.map { $0.zIndex }.max() ?? 0
                        text.zIndex = maxZ + 1
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        text.offSetX += value.translation.width
                        text.offSetY += value.translation.height
                        dragOffset = .zero
                    }
                )
            .onAppear {
                isFocused = true
            }
    }
}
