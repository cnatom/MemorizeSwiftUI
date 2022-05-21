//
//  ContentView.swift
//  Memorize
//
//  Created by atom on 2022/5/14.
//

import SwiftUI

struct ContentView: View {
    
    var emojis = ["1","2","3","4","5","6","7","8","9","10",
                  "11","12","13","14","15","16","17","18","19","20","21"]
    @State var count = 21
    var body: some View {
        VStack{
            //卡片布局
            ScrollView {
                LazyVGrid(columns:[GridItem(.adaptive(minimum: 100, maximum: 100))]){
                    ForEach(emojis[0..<count],id: \.self){ emoji in
                        MyCardView(emoji: emoji).aspectRatio(2/3,contentMode: .fit)
                    }
                }.foregroundColor(.blue)
            }
            Spacer()
            //底栏
            HStack{
                Button{
                    if count<emojis.count{
                        self.count+=1
                    }
                } label: {
                    Image(systemName: "plus.circle")
                    
                }
                Spacer()
                Button(action: {
                    if count>1{
                        self.count-=1
                    }
                }, label: {Image(systemName: "minus.circle")}
                )
            }
        }.padding()
        
    }
func myFunction(){
    
}
}
struct MyCardView: View{
    var emoji: String
    @State var hide: Bool = false
    //    var hide: Bool { return true }
    var body: some View{
        let shape = RoundedRectangle(cornerRadius: 25)
        ZStack{
            shape.stroke()
            Text(emoji)
            if hide {
                shape.fill().foregroundColor(.blue)
            }
        }.onTapGesture {
            hide = !hide
        }
    }
}






struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().preferredColorScheme(.light)
        ContentView().preferredColorScheme(.dark)
    }
}

