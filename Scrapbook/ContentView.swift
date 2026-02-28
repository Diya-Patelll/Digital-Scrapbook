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
    @State private var photoSelection: [PhotosPickerItem] = [] // allows multiple selections
    
    var body: some View{
        ZStack { // switched to Zstack so photos is on top of each other
            if item.photos.isEmpty {
                
                // shows when theres no photo
                ContentUnavailableView("No added image", systemImage: "photo.badge.minus")
            } else {
                ForEach(item.photos) { photo in IndividualPhotoView(photo:photo, allPhotos: item.photos)
                }
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
        .onChange(of: photoSelection) {_, newValue in
            Task {
                for selection in newValue {
                    if let data = try? await selection.loadTransferable(type: Data.self) {
                        // sets initial zIndex from how many photos are already there
                        let newZIndex = Double(item.photos.count)
                        let newPhoto = ScrapbookPhoto(imageData: data, zIndex: newZIndex)
                        item.photos.append(newPhoto)
                    }
                }
                
                // clear selections
                photoSelection = []
            }
        }
    }
}


// handles each photos for its own drag gesture
struct IndividualPhotoView: View {
    @Bindable var photo: ScrapbookPhoto
    @State private var dragOffset: CGSize = .zero // tracks movement of finger
    var allPhotos: [ScrapbookPhoto] // access to other photos 
    
    var body: some View {
        if let data = photo.imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .zIndex(photo.zIndex) // stacking order
                .offset(x: photo.offSetX + dragOffset.width, y: photo.offSetY + dragOffset.height)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // bring to front once movement starts
                            let maxZ = allPhotos.map{$0.zIndex}.max() ?? 0
                            photo.zIndex = maxZ + 1
                            // updates postions as your finger moves
                            dragOffset = value.translation
                        }
                        .onEnded{ value in
                            // save position once finger is lifted
                            photo.offSetX += value.translation.width
                            photo.offSetY += value.translation.height
                            
                            dragOffset = .zero
                        }
                )
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Item.self, ScrapbookPhoto.self], inMemory: true)
}
