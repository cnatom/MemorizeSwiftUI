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
// 获取card的第一个索引，该函数与内置函数cards.firstIndex(where:{})效果等同
//    func index(of card:Card)->Int?{
//        for index in 0..<cards.count{
//            if(cards[index].id==card.id){
//                return index
//            }
//        }
//        return nil  // 因为Int?，所以这里可以返回一个nil
//    }

    
    //MemoryGame<CardContent>.Card
    //Identifiable:使每一个Card独一无二，可以被Foreach唯一识别
    struct Card: Identifiable{
        var isFaceUp = false
        var isMatched = false
        let content : CardContend
        let id: Int
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
