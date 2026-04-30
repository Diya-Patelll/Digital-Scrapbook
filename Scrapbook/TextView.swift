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
    @State private var isDragging = false
    @FocusState private var isFocused: Bool
    @Environment(\.modelContext) private var modelContext
    @GestureState private var activeScale: CGFloat = 1.0
    
    var page: ScrapbookPage
    let pageIndex: Int
    var allTexts: [ScrapbookText] // handles layering
    
    private var displayedScale: CGFloat {
        CGFloat(text.scale) * softenedMagnification(activeScale)
    }
    
    private func softenedMagnification(_ magnification: CGFloat) -> CGFloat {
        1 + ((magnification - 1) * 0.35)
    }
    
    var body: some View {
        TextField("Type here..", text: $text.content, axis: .vertical)
            .font(.title2)
            .padding(8)
            .frame(minWidth: 100)
            .foregroundStyle(text.boxColor)
            .cornerRadius(4)
            .focused($isFocused)
            .contentShape(Rectangle())
            .scaleEffect(displayedScale)
            .offset(x: text.offSetX + dragOffset.width, y: text.offSetY + dragOffset.height)
            .zIndex(text.zIndex)
            .transaction { transaction in
                transaction.animation = nil
            }
            .highPriorityGesture(
                DragGesture(minimumDistance: 1)
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                            isFocused = false

                            let maxZ = allTexts.map { $0.zIndex }.max() ?? 0
                            if text.zIndex <= maxZ {
                                text.zIndex = maxZ + 1
                            }
                        }

                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        text.offSetX += value.translation.width
                        text.offSetY += value.translation.height
                        dragOffset = .zero
                        isDragging = false
                    }
            )
            .simultaneousGesture(
                MagnifyGesture()
                    .updating($activeScale) { value, state, _ in
                        state = value.magnification
                    }
                    .onChanged { _ in
                        isFocused = false
                    }
                    .onEnded { value in
                        let nextScale = text.scale * softenedMagnification(value.magnification)
                        text.scale = min(max(nextScale, 0.5), 3.0)
                    }
            )
            .onTapGesture {
                isFocused = true
            }
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
