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
        AspectVGrid(items: game.cards, aspectRatio: 2/3, content: {
            card in
            if card.isMatched && !card.isFaceUp {
                Rectangle().opacity(0)
            } else {
                MyCardView(card)
                    .padding(4)
                    .onTapGesture {
                        // View向ViewModel发送改变Model的通知
                        game.choose(card)
                    }
            }
        })
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
        // GeometryReader可以通过获取父组件的大小来调整子组件的样式
        // 如 geometry.size.height : 父组件的高度
        GeometryReader{ geometry in
            ZStack{
                Pie(startAngle: Angle(degrees: 0-90), endAngle: Angle(degrees: 110-90)).padding(5).opacity(0.5) // 自定义Shape
                Text(card.content).font(font(size: geometry.size)) // emoji的大小会根据容器宽度的大小变化
            }
            .cardify(isFaceUp: card.isFaceUp)
        }
    }
    /// emoji作为Font的大小
    private func font(size: CGSize) -> Font {
        Font.system(size: min(size.height,size.width) * 0.5)
    }
    /// 单个卡片的View参数
    private struct DrawingConstants {
        static let fontScale: CGFloat = 0.7
    }
    
}

// Xcode预览UI
struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        let game = EmojiMemoryGame()
        game.choose(game.cards.first!)
        return EmojiMomoryGameView(game: game).preferredColorScheme(.light)
    }
}

