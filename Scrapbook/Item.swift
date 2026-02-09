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
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
