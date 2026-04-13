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
    @State private var selectedItemID: PersistentIdentifier? // stores ID of currently selected scrapbook for tabview
    
    var body: some View {
        NavigationSplitView {
            // list of scrapbook entries
            List {
                ForEach(items) { item in
                    NavigationLink {
                        ItemDetailView(item: item)
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric))
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
                    PageContentView(page: page)
                        .tag(page.index) // links zStack to Tabview selection
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never)) // horizontal swipe behavior
            
            // footer with arrows and add button
            HStack (spacing: 30) {
                // back arrow
                Button(action: { withAnimation { currentPageIndex -= 1 }}) {
                    Image(systemName: "arrow.left.circle.fill")
                }
                .disabled(currentPageIndex == 0)
                
                Spacer()
                
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
        .toolbar {
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
                                ForEach(["red", "orange", "green", "blue", "black"], id: \.self) { colorName in
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
    
struct PageContentView: View {
    let page: ScrapbookPage
        
    var body:some View {
        ZStack {
            Color.white.ignoresSafeArea() // background color
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil,for:nil)
                }
                
            if page.photos.isEmpty && page.texts.isEmpty{
                // empty state of page
                ContentUnavailableView("No Added Photos", systemImage: "plus.viewfinder")
            } else {
                // layers photo
                ForEach(page.photos) { photo in
                    IndividualPhotoView(photo: photo, allPhotos: page.photos)
                        .zIndex(0)
                }
                // render texts
                ForEach(page.texts) { textItem in
                    TextView(text: textItem, allTexts: page.texts)
                        .zIndex(1)
                }
            }
        }
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
    
private func addText(color:String) {
    guard let currentPage = item.pages.first(where: {$0.index == currentPageIndex})
        else {
            return
        }
        
        let newZ = Double(currentPage.texts.count)
        
        let newText = ScrapbookText(content: "", offSetX: 50.0,offSetY: 50.0, zIndex: newZ, colorName: color)
        currentPage.texts.append(newText)
    }
}


// handles each photos for its own drag gesture
struct IndividualPhotoView: View {
    @Bindable var photo: ScrapbookPhoto
    @State private var dragOffset: CGSize = .zero // tracks movement of finger
    @State private var finalScale: CGFloat = 1.0 // end of scale
    @State private var showingCropper = false
    @State private var tempImage: UIImage? // holds image when cropping
    
    @GestureState private var activeScale: CGFloat = 1.0 // active gesture values
    @GestureState private var activeRotation: Angle = .zero
    
    
    var allPhotos: [ScrapbookPhoto] // access to other photos
    
    var body: some View {
        if let data = photo.imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
            
                .rotationEffect(Angle(degrees: photo.rotation) + activeRotation)
                .scaleEffect(photo.scale * activeScale)
                .zIndex(photo.zIndex) // stacking order
                .offset(x: photo.offSetX + dragOffset.width, y: photo.offSetY + dragOffset.height)
                        
                // hold for crop button to show
                .contextMenu {
                    Button{
                        if let data = photo.imageData {
                            tempImage = UIImage(data: data)
                            showingCropper = true
                        }
                    } label : {
                    
                    Label(photo.isCropped ? "Original Size" : "Crop", systemImage: "crop")
                    }
                }
                .fullScreenCover(isPresented: $showingCropper) {
                    CropPicker(image: $tempImage)
                        .onDisappear {
                            if let newImage = tempImage {
                                // saves newly cropped image
                                photo.imageData = newImage.jpegData(compressionQuality: 0.8)
                                
                                photo.scale = 1.0
                                photo.rotation = 0.0
                            }
                        }
                }
                
                
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
                .gesture(
                    SimultaneousGesture(
                        MagnifyGesture() // scale feature
                            .updating($activeScale) { value, state, _ in
                                state = value.magnification
                            }
                            .onEnded { value in
                                photo.scale *= value.magnification
                            },
                        RotateGesture() // rotate feature
                            .updating($activeRotation) { value, state, _ in
                                state = value.rotation
                            }
                            .onEnded{value in
                                photo.rotation += value.rotation.degrees
                            }
                    )
                )
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Item.self, ScrapbookPhoto.self, ScrapbookText.self], inMemory: true)
}
