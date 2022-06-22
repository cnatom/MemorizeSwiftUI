//
//  EmojiMomoryGameView.swift
//  Memorize
//
//  Created by atom on 2022/5/14.
//



import SwiftUI

struct EmojiMomoryGameView: View {
    // @ObservedObject使View跟踪viewModel的变换并刷新UI
    @ObservedObject var game: EmojiMemoryGame

    var body: some View {
        ScrollView {
            LazyVGrid(columns:[GridItem(.adaptive(minimum: 65))]){
                ForEach(game.cards){ card in
                    MyCardView(card)
                        .aspectRatio(2/3,contentMode: .fit)
                        .onTapGesture {
                            // View向ViewModel发送改变Model的通知
                            game.choose(card)
                        }
                }
            }
        }
        .foregroundColor(.blue)
        .padding()
        
    }
    
}
struct MyCardView: View{
    // 在EmojiMemoryGame中，Card是MemoryGame<String>.Card的别名
    // 因此此处相当于 let card: EmojiMemoryGame.MemoryGame<String>.Card
    private let card: EmojiMemoryGame.Card
    
    init(_ card: EmojiMemoryGame.Card){
        self.card = card
    }
    
    var body: some View{
        ZStack{
            let shape = RoundedRectangle(cornerRadius: 20)
            if card.isFaceUp{
                // 正面朝上
                shape.fill().foregroundColor(.white)
                shape.strokeBorder(lineWidth: 3)
                Text(card.content).font(.largeTitle)
            }else if card.isMatched{
                // 成功匹配的卡片
                shape.opacity(0)
            }else{
                // 反面朝上
                shape.fill()
            }
        }
    }
}

// Xcode预览UI
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = EmojiMemoryGame()
        EmojiMomoryGameView(game: game).preferredColorScheme(.light)
        EmojiMomoryGameView(game: game).preferredColorScheme(.dark)
    }
}

