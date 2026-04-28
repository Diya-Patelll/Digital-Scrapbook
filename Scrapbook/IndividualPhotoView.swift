//
//  IndividualPhotoView.swift
//  Scrapbook
//
//  Created by Diya Patel on 4/27/26.
//
import SwiftUI
import SwiftData
// handles each photos for its own drag gesture
struct IndividualPhotoView: View {
    @Bindable var photo: ScrapbookPhoto
    @State private var dragOffset: CGSize = .zero // tracks movement of finger
    @State private var showingCropper = false
    @State private var tempImage: UIImage? // holds image when cropping
    
    @GestureState private var activeScale: CGFloat = 1.0 // active gesture values
    @GestureState private var activeRotation: Angle = .zero
    
    @Environment(\.modelContext) private var modelContext
    let page: ScrapbookPage
    
    var allPhotos: [ScrapbookPhoto] // access to other photos
    
    // deletes photo logic
    private func deletePhoto() {
        withAnimation {
            page.photos.removeAll(where: { $0.id == photo.id})
            
            modelContext.delete(photo)
        }
    }
    
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
                    // delete button
                    Button(role: .destructive) {
                        deletePhoto()
                    } label: {
                        Label("Delete", systemImage: "trash")
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
