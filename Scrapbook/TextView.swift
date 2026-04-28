//
//  TextView.swift
//  Scrapbook
//
//  Created by Diya Patel on 3/30/26.
//

import SwiftUI
import SwiftData

struct TextView: View {
    @Bindable var text: ScrapbookText
    @Binding var activePageIndex: Int
    @State private var dragOffset: CGSize = .zero
    @State private var finalOffset: CGSize = .zero
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext
    @GestureState private var fingerOffset: CGSize = .zero
    
    var page: ScrapbookPage
    let pageIndex: Int
    var allTexts: [ScrapbookText] // handles layering
    
    var body: some View {
        TextField("Type here..", text: $text.content, axis: .vertical)
            .font(.title2)
            .padding(8)
            .frame(minWidth: 100)
            .foregroundStyle(text.boxColor)
            .cornerRadius(4)
            .focused($isFocused)
            .offset(x: text.offSetX + fingerOffset.width,y: text.offSetY + fingerOffset.height)
            .zIndex(text.zIndex)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($fingerOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onChanged { _ in
                        let maxZ = allTexts.map { $0.zIndex }.max() ?? 0
                        if text.zIndex <= maxZ {
                            text.zIndex = maxZ + 1
                        }
                    }
                    .onEnded { value in
                        text.offSetX += value.translation.width
                        text.offSetY += value.translation.height
                    }
                )
            .onAppear {
                if text.isNew && pageIndex == activePageIndex {
                    isFocused = true
                    text.isNew = false
                }
            }
            .contextMenu{
                Button(role: .destructive) {
                    withAnimation{
                        // remove from page array
                        page.texts.removeAll(where: { $0.id == text.id})
                        modelContext.delete(text)
                    }
                } label: {
                    Label("Delete Text", systemImage: "trash")
                }
            }
    }
}
