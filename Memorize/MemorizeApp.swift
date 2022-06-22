//
//  MemorizeApp.swift
//  Memorize
//
//  Created by atom on 2022/5/14.
//

import SwiftUI

@main
struct MemorizeApp: App {
    // game常量指针,指向不变
    let game = EmojiMemoryGame()
    
    var body: some Scene {
        WindowGroup {
            EmojiMomoryGameView(game:game)
        }
    }
}
