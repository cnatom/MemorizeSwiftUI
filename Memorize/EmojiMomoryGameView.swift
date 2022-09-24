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
        VStack {
            gameBody
            shuffle
        }
        .padding()
    }

    var gameBody: some View {
        AspectVGrid(items: game.cards, aspectRatio: 2 / 3, content: {
            card in
            if card.isMatched && !card.isFaceUp {
                Color.clear
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
    }

    var shuffle: some View {
        Button("Shuffle") {
            withAnimation {
                game.shuffle()
            }
        }
    }
}

struct MyCardView: View {
    // 在EmojiMemoryGame中，Card是MemoryGame<String>.Card的别名
    // 因此此处相当于 let card: EmojiMemoryGame.MemoryGame<String>.Card
    private let card: EmojiMemoryGame.Card

    init(_ card: EmojiMemoryGame.Card) {
        self.card = card
    }

    var body: some View {
        // GeometryReader可以通过获取父组件的大小来调整子组件的样式
        // 如 geometry.size.height : 父组件的高度
        GeometryReader { geometry in
            ZStack {
                Pie(startAngle: Angle(degrees: 0 - 90), endAngle: Angle(degrees: 110 - 90)).padding(5).opacity(0.5) // 自定义Shape
                // emoji的大小会根据容器宽度的大小变化
                Text(card.content)
                    .rotationEffect(Angle.degrees(card.isMatched ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: card.isMatched)
                    .font(Font.system(size: DrawingConstants.fontSize))
                    .scaleEffect(scale(thatFits: geometry.size))
            }
            .cardify(isFaceUp: card.isFaceUp)
        }
    }

    private func scale(thatFits size: CGSize) -> CGFloat {
        min(size.width, size.height) / (DrawingConstants.fontSize / DrawingConstants.fontScale)
    }

    /// 单个卡片的View参数
    private struct DrawingConstants {
        static let fontScale: CGFloat = 0.7
        static let fontSize: CGFloat = 32
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
