//
//  Item.swift
//  Scrapbook
//
//  Created by Diya Patel on 1/29/26.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Item {
    var title: String
    var timestamp: Date
    @Relationship(deleteRule: .cascade) var pages: [ScrapbookPage] = []
    
    init(title: String = "Title", timestamp: Date) {
        self.title = title
        self.timestamp = timestamp
        self.pages = [ScrapbookPage(index: 0)]
    }
}

@Model
class ScrapbookPage {
    var index: Int
    @Relationship(deleteRule: .cascade) var photos: [ScrapbookPhoto] = []
    @Relationship(deleteRule: .cascade) var texts: [ScrapbookText] = []
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

@Model
class ScrapbookText {
    var content: String
    var offSetX: Double = 0.0
    var offSetY: Double = 0.0
    var zIndex: Double = 0.0
    var scale: Double = 1.0
    var colorName: String
    var isNew: Bool = false
    
    var boxColor: Color {
        Self.color(for: colorName)
    }
    
    static func color(for name: String) -> Color {
        switch name {
            case "red": return .red
            case "orange": return .orange
            case "green": return .green
            case "blue": return .blue
            case "purple": return .purple
            case "white": return .white
            default: return .black
        }
    }
    
    init(content: String, offSetX: Double, offSetY: Double, zIndex: Double, scale: Double = 1.0, colorName: String, isNew: Bool = false) {
        self.content = content
        self.offSetX = offSetX
        self.offSetY = offSetY
        self.zIndex = zIndex
        self.scale = scale
        self.colorName = colorName
        self.isNew = isNew
    }
}
