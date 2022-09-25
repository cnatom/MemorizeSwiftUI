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

    @Namespace private var dealingNamespace

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                gameBody
                HStack {
                    restart
                    Spacer()
                    shuffle
                }
                .padding(.horizontal)
            }
            deckBody
        }
        .padding()
    }

    @State private var dealt = Set<Int>()

    private func deal(_ card: EmojiMemoryGame.Card) {
        dealt.insert(card.id)
    }

    private func isUndealt(_ card: EmojiMemoryGame.Card) -> Bool {
        return !dealt.contains(card.id)
    }

    private func dealAnimation(for card: EmojiMemoryGame.Card) -> Animation {
        var delay = 0.0
        if let index = game.cards.firstIndex(where: { $0.id == card.id }) {
            delay = Double(index) * (CardConstants.totalDealDuration / Double(game.cards.count))
        }
        return Animation.easeInOut(duration: CardConstants.dealDuration).delay(delay)
    }

    private func zIndex(of card: EmojiMemoryGame.Card) -> Double {
        -Double(game.cards.firstIndex(where: { item in
            item.id == card.id
        }) ?? 0)
    }

    var gameBody: some View {
        AspectVGrid(items: game.cards, aspectRatio: 2 / 3) {
            card in
            if isUndealt(card) || card.isMatched && !card.isFaceUp {
                Color.clear
            } else {
                MyCardView(card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace) // 同步发牌前与发牌后的几何形状
                    .padding(4)
                    .transition(AnyTransition.asymmetric(insertion: .identity, removal: .opacity)) // 卡片出现以及消失的动画
                    .zIndex(zIndex(of: card))
                    .onTapGesture {
                        withAnimation {
                            game.choose(card) // View向ViewModel发送改变Model的通知
                        }
                    }
            }
        }

        .foregroundColor(CardConstants.color)
    }

    var deckBody: some View {
        ZStack {
            ForEach(game.cards.filter { isUndealt($0) }) { card in
                MyCardView(card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .transition(AnyTransition.asymmetric(insertion: .opacity, removal: .identity))
                    .zIndex(zIndex(of: card))
            }
        }
        .frame(width: CardConstants.undealtWidth, height: CardConstants.undealtHeight)
        .foregroundColor(CardConstants.color)
        .onTapGesture {
            // 在View出现时执行
            for card in game.cards {
                withAnimation(dealAnimation(for: card)) {
                    deal(card)
                }
            }
        }
    }

    var shuffle: some View {
        Button("洗牌") {
            withAnimation {
                game.shuffle()
            }
        }
    }

    var restart: some View {
        Button("重新开始") {
            withAnimation {
                dealt = []
                game.restart()
            }
        }
    }

    private struct CardConstants {
        static let color = Color.blue
        static let aspectRatio: CGFloat = 2 / 3
        static let dealDuration: Double = 0.5
        static let totalDealDuration: Double = 2
        static let undealtHeight: CGFloat = 90
        static let undealtWidth = undealtHeight * aspectRatio
    }
}

struct MyCardView: View {
    // 在EmojiMemoryGame中，Card是MemoryGame<String>.Card的别名
    // 因此此处相当于 let card: EmojiMemoryGame.MemoryGame<String>.Card
    private let card: EmojiMemoryGame.Card
    
    init(_ card: EmojiMemoryGame.Card) {
        self.card = card
    }

    @State private var animatedBonusRemaining: Double = 0

    var body: some View {
        // GeometryReader可以通过获取父组件的大小来调整子组件的样式
        // 如 geometry.size.height : 父组件的高度
        GeometryReader { geometry in
            ZStack {
                // 倒计时动画圆盘
                Group {
                    if card.isConsumingBonusTime {
                        Pie(startAngle: Angle(degrees: 0 - 90), endAngle: Angle(degrees: (1 - animatedBonusRemaining) * 360 - 90))
                            .onAppear{
                                animatedBonusRemaining = card.bonusRemaining // 倒计时开始
                                withAnimation(.linear(duration: card.bonusTimeRemaining)) {
                                    animatedBonusRemaining = 0 // 倒计时通过动画慢慢结束
                                }
                            }
                    } else {
                        Pie(startAngle: Angle(degrees: 0 - 90), endAngle: Angle(degrees: (1 - card.bonusRemaining) * 360 - 90))
                    }
                }
                .padding(5)
                .opacity(0.5)
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
