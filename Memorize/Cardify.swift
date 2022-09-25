//
//  Cardify.swift
//  Memorize
//
//  Created by atom on 2022/7/11.
//

import SwiftUI

struct Cardify: Animatable,ViewModifier {
    
    init(isFaceUp: Bool) {
        rotation = isFaceUp ? 0 : 180
    }
    
    // 告诉Animatable协议，哪些变量需要插值
    var animatableData: Double{
        get { rotation }
        set { rotation = newValue }
    }
    
    var rotation: Double // 旋转角度

    func body(content: Content) -> some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
            if rotation < 90 {
                // 正面朝上
                shape.fill().foregroundColor(.white)
                shape.strokeBorder(lineWidth: DrawingConstants.lineWidth)
            } else {
                // 反面朝上
                shape.fill()
            }
            content
                .opacity(rotation < 90 ? 1 : 0)
        }
        .rotation3DEffect(Angle.degrees(rotation), axis: (0, 1, 0)) // 绕y轴旋转
    }

    private struct DrawingConstants {
        static let cornerRadius: CGFloat = 10.0
        static let lineWidth: CGFloat = 3
    }
}

extension View {
    func cardify(isFaceUp: Bool) -> some View {
        return modifier(Cardify(isFaceUp: isFaceUp))
    }
}
