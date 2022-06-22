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
            LazyVGrid(columns:[GridItem(.adaptive(minimum: 60))]){
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
        // GeometryReader可以通过获取父组件的大小来调整子组件的样式
        // 如 geometry.size.height : 父组件的高度
        GeometryReader{ geometry in
            ZStack{
                let shape = RoundedRectangle(cornerRadius: Params.cornerRadius)
                if card.isFaceUp{
                    // 正面朝上
                    shape.fill().foregroundColor(.white)
                    shape.strokeBorder(lineWidth: Params.lineWidth)
                    Text(card.content).font(font(size: geometry.size)) // emoji的大小会根据容器宽度的大小变化
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
    /// emoji作为Font的大小
    private func font(size: CGSize) -> Font {
        Font.system(size: min(size.height,size.width) * 0.5)
    }
    /// 单个卡片的View参数
    private struct Params {
        static let cornerRadius: CGFloat = 20.0
        static let lineWidth: CGFloat = 3
        static let fontScale: CGFloat = 0.5
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

