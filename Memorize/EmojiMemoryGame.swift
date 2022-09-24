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
    
    //为MemoryGame<String>.Card创建一个别名：Card，减少代码量
    typealias Card = MemoryGame<String>.Card
    
    //static类型变量的初始化顺序在普通var之前
    //因此static的类成员可以作为其他类成员的默认值使用
    //如 var a = EmojiMemoryGame.emojis[1]
    static var emojis = ["😀","🦴","🍎","🍇","🏀","🎽","🤣","🐶","🐱","🐭",
                         "🐹","🐰","🦊","🐵","🐢","🍎","🍋","🍉","🥩","🍳"]
    
    //创建一个Model
    static func createMemoryGame() -> MemoryGame<String> {
        return MemoryGame<String>(numberOfPairsOfCards: 10, createCardContent: {
            // 定义中：createCardContent: (Int) -> CardContend //CardContend是一个泛型
            // 因此，此处会自动识别类型，将
            // index in 识别为 (index: Int) -> String in
            index in
            return EmojiMemoryGame.emojis[index]
        } )
    }
    
    // @Published使得model每次改变时，都会发送UI刷新公告 objectWillChange.send()
    // Swift能够检测到struct中的变化，在class中无法这样做
    @Published private var model = createMemoryGame()
    
    var cards: Array<Card>{
        return model.cards
    }
    
    // MARK: - Intent(s)
    // 向Model发送从View接收到的指令
    func choose(_ card: Card){
        //objectWillChange.send()
        model.choose(card)
    }
    
    func shuffle(){
        self.model.shuffle();
    }
    
    func restart() {
        model = EmojiMemoryGame.createMemoryGame()
    }
}
