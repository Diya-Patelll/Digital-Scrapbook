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
                SplashScreenView()
                    .tint(.scrapbookIcon)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showSplash = false
                            }
                        }
                    }
            } else {
                ContentView()
                    .tint(.scrapbookIcon)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

private struct SplashScreenView: View {
    @State private var titleVisible = false
    @State private var cardVisible = false
    @State private var glowVisible = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.scrapbookBackground,
                    Color.scrapbookAccent.opacity(0.85),
                    Color.scrapbookBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Circle()
                .fill(Color.scrapbookAccent.opacity(0.4))
                .frame(width: 240, height: 240)
                .blur(radius: 24)
                .offset(x: 120, y: -220)
                .opacity(glowVisible ? 1 : 0.5)
            
            Circle()
                .fill(Color.scrapbookIcon.opacity(0.2))
                .frame(width: 180, height: 180)
                .blur(radius: 28)
                .offset(x: -130, y: 250)
            
            VStack(spacing: 28) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.scrapbookCardBackground)
                    .frame(width: 196, height: 228)
                    .overlay {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 10) {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.scrapbookAccent)
                                    .frame(width: 54, height: 54)
                                    .overlay {
                                        Image(systemName: "book.closed.fill")
                                            .font(.system(size: 24, weight: .semibold))
                                            .foregroundStyle(Color.scrapbookIcon)
                                    }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Capsule()
                                        .fill(Color.scrapbookAccent.opacity(0.9))
                                        .frame(width: 72, height: 12)
                                    Capsule()
                                        .fill(Color.scrapbookControlBackground)
                                        .frame(width: 54, height: 10)
                                }
                            }
                            
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.scrapbookBackground.opacity(0.8))
                                .frame(width: 148, height: 92)
                                .overlay(alignment: .topLeading) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Capsule()
                                            .fill(Color.scrapbookAccent)
                                            .frame(width: 92, height: 10)
                                        Capsule()
                                            .fill(Color.scrapbookControlBackground)
                                            .frame(width: 118, height: 10)
                                        Capsule()
                                            .fill(Color.scrapbookControlBackground)
                                            .frame(width: 80, height: 10)
                                    }
                                    .padding(16)
                                }
                            
                            HStack(spacing: 10) {
                                ForEach(0..<3) { _ in
                                    Circle()
                                        .fill(Color.scrapbookAccent)
                                        .frame(width: 12, height: 12)
                                }
                            }
                        }
                        .frame(width: 196, height: 228, alignment: .topLeading)
                        .padding(18)
                        .offset(x: 10,y: 8)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .shadow(color: .black.opacity(0.08), radius: 26, x: 0, y: 18)
                .rotationEffect(.degrees(cardVisible ? -5 : -10))
                .scaleEffect(cardVisible ? 1 : 0.92)
                .offset(y: cardVisible ? 0 : 24)
                .opacity(cardVisible ? 1 : 0)
                
                VStack(spacing: 8) {
                    Text("Collected Memories")
                        .font(.custom("Georgia-Bold", size: 34))
                        .foregroundStyle(Color.scrapbookText)
                }
                .multilineTextAlignment(.center)
                .opacity(titleVisible ? 1 : 0)
                .offset(y: titleVisible ? 0 : 12)
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            withAnimation(.spring(duration: 0.9, bounce: 0.22)) {
                cardVisible = true
            }
            withAnimation(.easeOut(duration: 0.7).delay(0.18)) {
                titleVisible = true
            }
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                glowVisible = true
            }
        }
    }
}
