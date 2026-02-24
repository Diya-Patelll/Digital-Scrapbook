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
    
    // store the photo
    @Attribute(.externalStorage) var imageData: Data?
    
    // track postion of image
    var offSetX: Double = 0.0
    var offSetY: Double = 0.0
    
    init(timestamp: Date, imageData: Data?=nil, offSetX: Double=0.0, offSetY: Double=0.0) {
        self.timestamp = timestamp
        self.imageData = imageData
        self.offSetX = offSetX
        self.offSetY = offSetY
    }
}
