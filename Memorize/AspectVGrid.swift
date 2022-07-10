//
//  AspectVGrid.swift
//  Memorize
//
//  Created by atom on 2022/7/10.
//

import SwiftUI

struct AspectVGrid<Item,ItemView>: View where ItemView: View, Item: Identifiable {
    var items: [Item]
    var aspectRatio: CGFloat
    var content: (Item) -> ItemView
    // @escaping :struct是复制型的，而content是一个指向外部函数的引用，因此要加escaping
    // @ViewBuilder :使content可以被传入一个 if(){ return Example1View() }else{ return Example2View() } 类似的复杂函数
    init(items: [Item], aspectRatio: CGFloat,@ViewBuilder content: @escaping (Item) -> ItemView) {
        self.items = items
        self.aspectRatio = aspectRatio
        self.content = content
    }
    var body: some View {
        VStack{
            GeometryReader { geometry in
                let width: CGFloat = widthThatFits(itemCount: items.count, in: geometry.size, itemAspectRatio: aspectRatio)
                LazyVGrid(columns: [adaptiveGridItem(width: width)],spacing: 0){
                    ForEach(items){ item in
                        content(item).aspectRatio(aspectRatio,contentMode:.fit)
                    }
                }
            }
            Spacer(minLength: 0)
        }

    }
    // 取消GridItem间距
    private func adaptiveGridItem(width: CGFloat) -> GridItem {
        var gridItem = GridItem(.adaptive(minimum: width))
        gridItem.spacing = 0
        return gridItem
    }
    
    // 自适应卡片宽度：计算一行放多少卡片，可以被容器容纳
    private func widthThatFits(itemCount: Int, in size: CGSize, itemAspectRatio: CGFloat) -> CGFloat {
        var columnCount = 1 // 一行有多少个
        var rowCount = itemCount  // 一列有多少个
        // 寻找合适的columnCount，使卡片刚好能被容器容纳
        repeat {
            let itemWidth = size.width / CGFloat(columnCount)
            let itemHeight = itemWidth / itemAspectRatio
            // 如果卡片叠起来的高度 < 容器的高度 则刚好可适应
            if CGFloat(rowCount) * itemHeight < size.height{
                break
            }
            // 当前columnCount会把容器撑爆，继续调整
            columnCount += 1
            rowCount = (itemCount + (columnCount - 1)) / columnCount
        } while columnCount < itemCount
        // 如果一行刚好全部放得下，则放在一行
        if columnCount > itemCount{
            columnCount = itemCount
        }
        return floor(size.width / CGFloat(columnCount))
    }
}

//struct AspectVGrid_Previews: PreviewProvider {
//    static var previews: some View {
//        AspectVGrid()
//    }
//}

