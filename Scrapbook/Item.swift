//
//  Item.swift
//  Scrapbook
//
//  Created by Diya Patel on 1/29/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    var photos: [ScrapbookPhoto] = []
    @Relationship(deleteRule: .cascade) var pages: [ScrapbookPage] = []
    
    init(timestamp: Date) {
        self.timestamp = timestamp
        self.pages = [ScrapbookPage(index: 0)]
    }
}

@Model
class ScrapbookPage {
    var index: Int
    @Relationship(deleteRule: .cascade) var photos: [ScrapbookPhoto] = []
    init(index: Int) {
        self.index = index
        
    }
    
}

@Model
final class ScrapbookPhoto {
    
    // store the photo
    @Attribute(.externalStorage) var imageData: Data?
    
    // track postion of image
    var offSetX: Double = 0.0
    var offSetY: Double = 0.0
    
    // size of image
    var scale: Double = 1.0
    
    // roation of image
    var rotation: Double = 0.0
    
    // stacking order of images
    var zIndex: Double = 0.0
    
    // toggle between crop and original 
    var isCropped: Bool = false
    
    init(imageData: Data?=nil, offSetX: Double=0.0, offSetY: Double=0.0, zIndex: Double = 0.0, scale: Double = 1.0, rotation: Double = 0.0, isCropped: Bool = false) {
        self.imageData = imageData
        self.offSetX = offSetX
        self.offSetY = offSetY
        self.zIndex = zIndex
        self.scale = scale
        self.rotation = rotation
        self.isCropped = isCropped
    }
}
