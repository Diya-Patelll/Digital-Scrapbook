//
//  ItemDetailView.swift
//  Scrapbook
//
//  Created by Diya Patel on 4/27/26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ItemDetailView: View {
    @Bindable var item: Item
    @State private var photoSelection: [PhotosPickerItem] = [] // allows multiple selections
    @State private var currentPageIndex = 0 // tracks active pages
    @State private var showColorPicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPageIndex) {
                // sort pages by index so it appears in correct order
                ForEach(item.pages.sorted(by: { $0.index < $1.index })) { page in
                    PageContentView(page: page, activePageIndex: $currentPageIndex)
                        .tag(page.index) // links zStack to Tabview selection
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never)) // horizontal swipe behavior
            .onChange(of: currentPageIndex) {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            
            // footer with arrows and add button
            HStack (spacing: 30) {
                // back arrow
                Button(action: { withAnimation { currentPageIndex -= 1 }}) {
                    Image(systemName: "arrow.left.circle.fill")
                }
                .disabled(currentPageIndex == 0)
                
                Spacer()
                
                // delete page button
                Button(role: .destructive, action: deleteCurrentPage) {
                    VStack {
                        Image(systemName: "trash.circle.fill")
                            .font(.title)
                        Text("Delete").font(.caption2)
                    }
                }
                .disabled(item.pages.count <= 1)
                .foregroundStyle(item.pages.count <= 1 ? .gray : .red)
                
                // add page button
                Button(action: addPage) {
                    VStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                        Text("Add Page").font(.caption2)
                    }
                }
                Spacer()
                
                // next arrow
                Button(action: { withAnimation { currentPageIndex += 1 }}) {
                    Image(systemName: "arrow.right.circle.fill")
                }
                .disabled(currentPageIndex == item.pages.count - 1)
            }
            .padding(.vertical, 2)
            .background(.thinMaterial)
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
            TextField("Scrapbook Title", text: $item.title)
                    .textFieldStyle(.roundedBorder)
                    .font(.headline)
                    .frame(maxWidth: 220)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 20){
                    // text button
                    ZStack(alignment: .top){
                        Button {
                            withAnimation{
                                showColorPicker.toggle()
                            }
                        } label: {
                            Image(systemName: "text.cursor")
                        }
                        // options of colors show
                        .popover(isPresented: $showColorPicker) {
                            VStack(spacing: 20) {
                                ForEach(["red", "orange", "green", "blue", "black", "white"], id: \.self) { colorName in
                                    Button {
                                        addText(color: colorName)
                                        showColorPicker = false
                                    } label: {
                                        Circle()
                                            .fill(ScrapbookText.color(for: colorName))
                                            .frame(width: 25, height: 25)
                                            .shadow(radius: 2)
                                    }
                                }
                            }
                            .padding(15)
                            .presentationCompactAdaptation(.popover)
                        }
                    }
                    
                    PhotosPicker(selection: $photoSelection, matching: .images) {
                        Image(systemName: "photo.badge.plus")
                    }
                }
            }
        }
    
    // add photo to current page were on
    .onChange(of: photoSelection) { _, newValue in
        addPhotosToCurrentPage(newValue)
    }
}

    // creates new page and goes to it
    private func addPage() {
        let newIndex = item.pages.count
        let newPage = ScrapbookPage(index: newIndex)
        item.pages.append(newPage)
        withAnimation {
            currentPageIndex = newIndex
        }
    }
    
    private func addPhotosToCurrentPage(_ selections: [PhotosPickerItem]) {
        // find page we are looking at
        guard let currentPage = item.pages.first(where: { $0.index == currentPageIndex }) else { return }
        
        Task {
            for selection in selections {
                if let data = try? await selection.loadTransferable(type: Data.self) {
                    // stacks new photo on top
                    let newZIndex = Double(currentPage.photos.count)
                    let newPhoto = ScrapbookPhoto(imageData: data, zIndex: newZIndex)
                    currentPage.photos.append(newPhoto)
                }
            }
            photoSelection = [] // clear selections
        }
    }
    
    
private func deleteCurrentPage() {
    // find page were looking for
    if let indexToDelete = item.pages.firstIndex(where: { $0.index == currentPageIndex}) {
        withAnimation {
            // remove page
            item.pages.remove(at: indexToDelete)
            // re-index remain pages so numbers arent messed up
            for i in 0..<item.pages.count {
                item.pages[i].index = i
            }
                
            if currentPageIndex >= item.pages.count {
                currentPageIndex = max(0, item.pages.count - 1)
            }
        }
    }
}
    
private func addText(color:String) {
    guard let currentPage = item.pages.first(where: {$0.index == currentPageIndex})
        else {
            return
        }
        
        let newZ = Double(currentPage.texts.count)
        
    let newText = ScrapbookText(content: "", offSetX: 50.0,offSetY: 50.0, zIndex: newZ, colorName: color, isNew: true)
        currentPage.texts.append(newText)
    }
}
