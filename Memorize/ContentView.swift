//
//  ContentView.swift
//  Memorize
//
//  Created by atom on 2022/5/14.
//



import SwiftUI

struct ContentView: View {
    // @ObservedObject使View跟踪viewModel的变换并刷新UI
    @ObservedObject var viewModel: EmojiMemoryGame

    var body: some View {
        ScrollView {
            LazyVGrid(columns:[GridItem(.adaptive(minimum: 65))]){
                ForEach(viewModel.cards){ card in
                    MyCardView(card: card)
                        .aspectRatio(2/3,contentMode: .fit)
                        .onTapGesture {
                            // View向ViewModel发送改变Model的通知
                            viewModel.choose(card)
                        }
                }
            }
        }
        .foregroundColor(.blue)
        .padding()
        
    }
    
}
struct MyCardView: View{
    let card: MemoryGame<String>.Card
    
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
        ContentView(viewModel: game).preferredColorScheme(.light)
        ContentView(viewModel: game).preferredColorScheme(.dark)
    }
}

