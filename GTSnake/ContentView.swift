//
//  ContentView.swift
//  GTSnake
//
//  Created by Maksim Tochilkin on 2/16/23.
//

import SwiftUI

extension Color {
    static var random: Color {
        [Color.blue, .green, .red, .brown, .cyan, .indigo, .mint, .orange].randomElement()!
    }
}

struct ContentView: View {
    let rows = 30
    let cols = 20
    
    let cellWidth: CGFloat = 20
    let cellHeight: CGFloat = 20
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    @State private var snake: [(Int, Int)] = [
        (10, 0), (10, 1), (10, 2), (10, 3), (10, 4)
    ]
    
    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            ForEach(0 ..< rows, id: \.self) { row in
                GridRow {
                    ForEach(0 ..< cols, id: \.self) { col in
                        Rectangle()
                            .fill()
                    }
                }
                .frame(height: cellHeight)
            }
        }
        .frame(width: cellWidth * CGFloat(cols))
        .onReceive(timer) { _ in
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
