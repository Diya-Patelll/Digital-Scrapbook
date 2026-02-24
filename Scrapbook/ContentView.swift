//
//  ContentView.swift
//  Scrapbook
//
//  Created by Diya Patel on 1/29/26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        ItemDetailView(item: item)
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, ))
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            if let selectedItem = items.first {
                ItemDetailView(item: selectedItem)
            } else {
                Text("Select an item")
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
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

struct ItemDetailView: View {
    @Bindable var item: Item
    @State private var photoSelection: PhotosPickerItem?
    @State private var dragOffset: CGSize = .zero // tracks movement of finger
    
    var body: some View{
        VStack {
            // check if the item has image data and to be converted to UIimage
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .offset(x: item.offSetX + dragOffset.width, y: item.offSetY + dragOffset.height)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                // updates postions as your finger moves
                                dragOffset = value.translation
                            }
                            .onEnded{ value in
                                // save position once finger is lifted
                                item.offSetX += value.translation.width
                                item.offSetY += value.translation.height
                                
                                dragOffset = .zero
                            }
                    )
            } else {
                // show when theres no photo
                ContentUnavailableView("No added image", systemImage: "photo.badge.minus")
                    
            }
        }
        .navigationTitle(item.timestamp.formatted(date: .numeric, time: .omitted))
        // button for top
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                PhotosPicker(selection: $photoSelection, matching: .images) {
                    Image(systemName: "photo.badge.plus")
                }
            }
        }
        .onChange(of: photoSelection) {oldValue,newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    item.imageData = data
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
