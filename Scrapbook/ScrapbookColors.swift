//
//  Theme.swift
//  Scrapbook
//
//  Created by Diya Patel on 4/27/26.
//

import SwiftUI

extension Color {
    static let scrapbookBackground = Color(
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.16, green: 0.14, blue: 0.13, alpha: 1.0)
                : UIColor(red: 0.97, green: 0.95, blue: 0.93, alpha: 1.0)
        }
    )
    static let scrapbookAccent = Color(
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.35, green: 0.30, blue: 0.24, alpha: 1.0)
                : UIColor(red: 0.92, green: 0.88, blue: 0.82, alpha: 1.0)
        }
    )
    static let scrapbookCardBackground = Color(
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor.secondarySystemBackground
                : UIColor.white
        }
    )
    static let scrapbookControlBackground = Color(
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor.tertiarySystemBackground
                : UIColor.systemGray5
        }
    )
    static let scrapbookText = Color(
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.96, green: 0.93, blue: 0.89, alpha: 1.0)
                : UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        }
    )
    static let scrapbookSecondaryText = Color(
        UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor.systemGray2 : UIColor.systemGray
        }
    )
    static let scrapbookIcon = Color(
        UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.84, green: 0.74, blue: 0.54, alpha: 1.0)
                : UIColor(red: 0.6, green: 0.5, blue: 0.3, alpha: 1.0)
        }
    )
}
