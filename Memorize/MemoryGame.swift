//
//  MemoryGame.swift
//  Memorize
//
//  Created by atom on 2022/5/21.
//

import Foundation
import SwiftUI

//Model
//where CardContend: Equatable 使得CardContent之间可以使用==
struct MemoryGame<CardContend> where CardContend: Equatable{
    

    //private(set) 代表只读
    private(set) var cards: Array<Card>
    
    // 正面朝上的卡片索引,这是一个“计算变量”
    private var indexOfTheOneAndOnlyFaceUpCard: Int?{
        // get方法
        get { cards.indices.filter({cards[$0].isFaceUp}).oneAndOnly }
        // set方法  indexOfTheOneAndOnlyFaceUpCard = 2 ,则第3张卡片正面朝上，其他全部反面朝上
        set { cards.indices.forEach({cards[$0].isFaceUp = $0 == newValue}) }
    }
    
    mutating func shuffle(){
        self.cards.shuffle()
    }
    
    init(numberOfPairsOfCards: Int,createCardContent: (Int) -> CardContend){
        cards = []  // 此处相当于 cards = Array<Card>() swift自动判断类型
        for pairIndex in 0..<numberOfPairsOfCards{
            let content = createCardContent(pairIndex)
            cards.append(Card(content: content, id: pairIndex*2))
            cards.append(Card(content: content, id: pairIndex*2+1))
        }
        cards.shuffle()
    }
    
    // mutating使该函数能够改变struct的变量
    mutating func choose(_ card: Card){
        //获取选中卡片的Index，确保该卡片反面朝上(为了防止重复点击，导致该卡片不断翻转），确保该卡片没有被匹配
        if let chosenIndex = cards.firstIndex(where: {$0.id == card.id}),
            cards[chosenIndex].isFaceUp==false,
            cards[chosenIndex].isMatched==false
        {
            if let potentialMatchIndex = indexOfTheOneAndOnlyFaceUpCard {
                // 如果第二张翻开的卡片
                if cards[chosenIndex].content == cards[potentialMatchIndex].content{
                    // 和第一张翻开的卡片内容相同,则两者成功匹配
                    cards[chosenIndex].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                }
                // 匹配成功后，当前没有卡片朝上
                cards[chosenIndex].isFaceUp = true
            }else{
                // 如果是第一张被翻开的卡片，则之前翻到正面的卡片都要翻到反面
                indexOfTheOneAndOnlyFaceUpCard = chosenIndex
            }
        }
        
    }

    
    //MemoryGame<CardContent>.Card
    //Identifiable:使每一个Card独一无二，可以被Foreach唯一识别
    struct Card: Identifiable{
        var isFaceUp = false {
            didSet{
                if isFaceUp{
                    startUsingBonusTime()
                } else {
                    stopUsingBonusTime()
                }
            }
        }
        var isMatched = false {
            didSet {
                stopUsingBonusTime()
            }
        }
        let content : CardContend
        let id: Int
        
        // MARK: - Bonus Time
        
        // this could give matching bonus points
        // if the user matches the card
        // before a certain amount of time passes during which the card is face up
        
        // can be zero which means "no bonus available" for this card
        var bonusTimeLimit: TimeInterval = 6
        
        // how long this card has ever been face up
        private var faceUpTime: TimeInterval {
            if let lastFaceUpDate = self.lastFaceUpDate {
                return pastFaceUpTime + Date().timeIntervalSince(lastFaceUpDate)
            } else {
                return pastFaceUpTime
            }
        }
        // the last time this card was turned face up (and is still face up)
        var lastFaceUpDate: Date?
        // the accumulated time this card has been face up in the past
        // (i.e. not including the current time it's been face up if it is currently so)
        var pastFaceUpTime: TimeInterval = 0
        
        // how much time left before the bonus opportunity runs out
        var bonusTimeRemaining: TimeInterval {
            max(0, bonusTimeLimit - faceUpTime)
        }
        // percentage of the bonus time remaining
        var bonusRemaining: Double {
            (bonusTimeLimit > 0 && bonusTimeRemaining > 0) ? bonusTimeRemaining/bonusTimeLimit : 0
        }
        // whether the card was matched during the bonus time period
        var hasEarnedBonus: Bool {
            isMatched && bonusTimeRemaining > 0
        }
        // whether we are currently face up, unmatched and have not yet used up the bonus window
        var isConsumingBonusTime: Bool {
            isFaceUp && !isMatched && bonusTimeRemaining > 0
        }
        
        // called when the card transitions to face up state
        private mutating func startUsingBonusTime() {
            if isConsumingBonusTime, lastFaceUpDate == nil {
                lastFaceUpDate = Date()
            }
        }
        // called when the card goes back face down (or gets matched)
        private mutating func stopUsingBonusTime() {
            pastFaceUpTime = faceUpTime
            self.lastFaceUpDate = nil
        }
    }
}

extension Array {
    /// 返回Array中独一无二的变量
    /// - 例子
    ///```swift
    ///var a: Array<Int> = [1]
    ///print(a.oneAndArray) // output:1
    ///```
    var oneAndOnly: Element? { // 该计算变量的类型为泛型
        if self.count == 1 {
            return self.first
        } else {
            return nil
        }
    }
}
