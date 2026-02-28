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
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

@Model
final class ScrapbookPhoto {
    
    // store the photo
    @Attribute(.externalStorage) var imageData: Data?
    
    // track postion of image
    var offSetX: Double = 0.0
    var offSetY: Double = 0.0
    
    // stacking order of images
    var zIndex: Double = 0.0
    
    init(imageData: Data?=nil, offSetX: Double=0.0, offSetY: Double=0.0, zIndex: Double = 0.0) {
        self.imageData = imageData
        self.offSetX = offSetX
        self.offSetY = offSetY
        self.zIndex = zIndex
    }
}
