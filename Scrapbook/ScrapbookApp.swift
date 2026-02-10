//
//  ScrapbookApp.swift
//  Scrapbook
//
//  Created by Diya Patel on 1/29/26.
//

import SwiftUI
import SwiftData

@main
struct ScrapbookApp: App {
    @State private var showSplash = true
    @State private var textOpacity = 0.0
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if showSplash {
                ZStack {
                    Color.blue
                        .edgesIgnoringSafeArea(.all)
                    Text("ScrapBook")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .padding()
                        .opacity(textOpacity)
                }
                .onAppear {
                    // Fade text in
                    withAnimation(.easeOut(duration: 0.8)) {
                        textOpacity = 1.0
                    }
                    // Then fade out to Contentview
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        showSplash = false
                    }
                }
            } else {
                ContentView()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

