//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by atom on 2022/5/21.
//

import SwiftUI

//ViewModel
//ObservableObject 使得 @Published 修饰的变量改变时，会发送UI刷新公告
class EmojiMemoryGame: ObservableObject{
    //static类型变量的初始化顺序在普通var之前
    //因此static的类成员可以作为其他类成员的默认值使用
    //如 var a = EmojiMemoryGame.emojis[1]
    static var emojis = ["😀","🦴","🍎","🍇","🏀","🎽","🤣","🐶","🐱","🐭",
                         "🐹","🐰","🦊","🐵","🐢","🍎","🍋","🍉","🥩","🍳"]
    
    //创建一个Model
    static func createMemoryGame() -> MemoryGame<String> {
        return MemoryGame<String>(numberOfPairsOfCards: 3, createCardContent: {
            // 定义中：createCardContent: (Int) -> CardContend //CardContend是一个泛型
            // 因此，此处会自动识别类型，将
            // index in 识别为 (index: Int) -> String in
            index in
            return EmojiMemoryGame.emojis[index]
        } )
    }
    
    // @Published使得model每次改变时，都会发送UI刷新公告 objectWillChange.send()
    @Published private var model: MemoryGame<String> = createMemoryGame()
    
    
    var cards: Array<MemoryGame<String>.Card>{
        return model.cards
    }
    
    // MARK: - Intent(s)
    // 向Model发送从View接收到的指令
    func choose(_ card: MemoryGame<String>.Card){
        //objectWillChange.send()
        model.choose(card)
    }
}
