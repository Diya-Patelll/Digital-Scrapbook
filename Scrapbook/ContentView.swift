//
//  ContentView.swift
//  Scrapbook
//
//  Created by Diya Patel on 1/29/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]
    @State private var selectedItemID: PersistentIdentifier? // stores ID of currently selected scrapbook for tabview
    
    var body: some View {
        NavigationSplitView {
            ZStack {
                Color.scrapbookBackground
                            .ignoresSafeArea()
                VStack(alignment: .leading, spacing: 0) {
                    // header text
                    Text("My Scrapbooks")
                        .font(.custom("Georgia-Bold", size: 32))
                        .foregroundStyle(Color.scrapbookText)
                        .padding(.horizontal, 20)
                        .padding(.top, -100)
                    // list of scrapbook entries
                    List {
                        ForEach(items) { item in
                            ZStack{
                                ScrapbookCardView(item: item)
                                
                                NavigationLink(destination: ItemDetailView(item: item)) {
                                    EmptyView()
                                }
                                .opacity(0)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: addItem) {
                            Image(systemName: "plus")
                                .fontWeight(.bold)
                                .padding(8)
                                .background(Color.scrapbookControlBackground)
                                .clipShape(Circle())
                        }
                        .foregroundStyle(Color.scrapbookText)
                        
                        // Edit Button
                        EditButton()
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.scrapbookControlBackground)
                            .clipShape(Capsule())
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.scrapbookText)
                        
                    }
                }
            }
        } detail: {
            detailCanvas
        }
        .onAppear{
            // auto selects first item if nothing is selected
            if selectedItemID == nil {
                selectedItemID = items.first?.persistentModelID
            }
        }
    }
        
        
    @ViewBuilder
    private var detailCanvas: some View {
        VStack(spacing: 0) {
            // page view between scrapbook items
            TabView(selection: $selectedItemID) {
                ForEach(items) { item in
                    ItemDetailView(item: item)
                        .tag(item.persistentModelID) // identifies which item is currently active
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never)) // disables swipe gesture
            navigationFooter // bottom nav controls
        }
        .ignoresSafeArea(edges: .bottom) // foot background is against bottom
    }
        
    // bottom navigation footer
    private var navigationFooter: some View {
        HStack {
            // left arrow
            Button(action: {movePage(by: -1) }) {
                Image(systemName: "arrow.left.circle.fill")
                    .font(.system(size: 40))
            }
            .disabled(isFirstPage) // when on first page you cant go back
            .foregroundStyle(isFirstPage ? .gray: .blue)
            
            Spacer()
            
            // current status
            Text("Page \(currentPageIndex + 1) of \(items.count)")
                .font(.headline)
                .foregroundStyle(Color.scrapbookText)
            
            Spacer()
            
            // right arrow
            Button(action: {movePage(by: 1) }) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 40))
            }
            .disabled(isLastPage) // when on last page you cant go any forward
            .foregroundStyle(isLastPage ? .gray: .blue)
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 20)
        .background(.thinMaterial)
    }
    
    // navigation logic
    // In item array calculates integer index of current selected item
    private var currentPageIndex: Int {
        items.firstIndex(where: { $0.persistentModelID == selectedItemID }) ?? 0
    }
    
    // helper booleans to keep footer code readable
    private var isFirstPage: Bool {selectedItemID == items.first?.persistentModelID}
    private var isLastPage: Bool {selectedItemID == items.last?.persistentModelID}
    
    // updates selectedItemID based on arrow clicks
    private func movePage(by delta: Int) {
        let newIndex = currentPageIndex + delta
        if newIndex >= 0 && newIndex < items.count {
            withAnimation(.easeInOut) {
                selectedItemID = items[newIndex].persistentModelID
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
            selectedItemID = newItem.persistentModelID
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Item.self, ScrapbookPhoto.self, ScrapbookText.self], inMemory: true)
}
