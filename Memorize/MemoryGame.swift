//
//  MemoryGame.swift
//  Memorize
//
//  Created by atom on 2022/5/21.
//

import Foundation

//Model
//where CardContend: Equatable 使得CardContent之间可以使用==
struct MemoryGame<CardContend> where CardContend: Equatable{
    
    //private(set) 代表只读
    private(set) var cards: Array<Card>
    private var indexOfFaceUp: Int?  // 正面朝上的卡片索引
    
    init(numberOfPairsOfCards: Int,createCardContent: (Int) -> CardContend){
        cards = Array<Card>()
        for pairIndex in 0..<numberOfPairsOfCards{
            let content = createCardContent(pairIndex)
            cards.append(Card(content: content, id: pairIndex*2))
            cards.append(Card(content: content, id: pairIndex*2+1))
        }
    }
    
    // mutating使该函数能够改变struct的变量
    mutating func choose(_ card: Card){
        //获取选中卡片的Index，确保该卡片反面朝上(为了防止重复点击，导致该卡片不断翻转），确保该卡片没有被匹配
        if let chosenIndex = cards.firstIndex(where: {$0.id == card.id}),
            cards[chosenIndex].isFaceUp==false,
            cards[chosenIndex].isMatched==false
        {
            if let potentialMatchIndex = indexOfFaceUp {
                // 如果第二张翻开的卡片
                if cards[chosenIndex].content == cards[potentialMatchIndex].content{
                    // 和第一张翻开的卡片内容相同,则两者成功匹配
                    cards[chosenIndex].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                }
                // 匹配成功后，当前没有卡片朝上
                indexOfFaceUp = nil
            }else{
                // 如果是第一张被翻开的卡片，则之前翻到正面的卡片都要翻到反面
                for index in cards.indices {
                    cards[index].isFaceUp = false
                }
                indexOfFaceUp = chosenIndex
                
            }
            cards[chosenIndex].isFaceUp.toggle() // 将卡片翻转，toggle相当于取反 a = !a
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
        var isFaceUp: Bool = false
        var isMatched: Bool = false
        let content : CardContend // 卡片的内容不需要改变 let
        let id: Int
    }
}

