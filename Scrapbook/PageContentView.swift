//
//  PageContentView.swift
//  Scrapbook
//
//  Created by Diya Patel on 4/27/26.
//

import SwiftUI

struct PageContentView: View {
    let page: ScrapbookPage
    @Binding var activePageIndex: Int
        
    var body:some View {
        ZStack {
            Color.scrapbookCardBackground.ignoresSafeArea() // background color
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil,for:nil)
                }
                
            if page.photos.isEmpty && page.texts.isEmpty{
                // empty state of page
                ContentUnavailableView("No Added Photos", systemImage: "plus.viewfinder")
            } else {
                // layers photo
                ForEach(page.photos) { photo in
                    IndividualPhotoView(photo: photo, page: page, allPhotos: page.photos)
                        .zIndex(0)
                }
                // render texts
                ForEach(page.texts) { textItem in
                    TextView(text: textItem,
                             activePageIndex: $activePageIndex,
                             page: page,
                             pageIndex: page.index,
                             allTexts: page.texts

                    )
                        .zIndex(1)
                }
            }
        }
    }
}
