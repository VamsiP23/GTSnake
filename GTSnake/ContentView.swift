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

class KeyDownHandlingView: NSView {
    var handler: Any?
    let manager: GameManager
    
    init(manager: GameManager) {
        self.manager = manager
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        handler = NSEvent.addLocalMonitorForEvents(
            matching: .keyDown
        ) { [weak manager] event in
            manager?.keyDown(event.keyCode)
            return event
        }
    }
    
    deinit {
        guard let handler else { return }
        NSEvent.removeMonitor(handler)
    }
}

struct KeyDownViewRep: NSViewRepresentable {
    var manager: GameManager
    
    func makeNSView(context: Context) -> KeyDownHandlingView {
        return KeyDownHandlingView(manager: manager)
    }

    func updateNSView(_ nsView: KeyDownHandlingView, context: Context) {
        // Nothing to do here
    }
}

struct ContentView: View {
    @StateObject private var manager = GameManager()
    let timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
    let cellWidth: CGFloat = 20
    let cellHeight: CGFloat = 20
    
    var body: some View {
        ZStack {
            KeyDownViewRep(manager: manager)
            
            Text("Score: \(manager.snake.count)")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                ForEach(0 ..< manager.rows, id: \.self) { row in
                    GridRow {
                        ForEach(0 ..< manager.cols, id: \.self) { col in
                            Rectangle()
                                .strokeBorder(Color.gray, lineWidth: 1)
                                .background(manager[row, col])
                            
                        }
                    }
                    .frame(height: cellHeight)
                }
            }
            .opacity(manager.gameState == .lost ? 0.4 : 1)
            
            if manager.gameState == .lost {
                VStack {
                    Text("You Lost!")
                        .font(.custom("SF Pro Rounded", size: 64))
                        .bold()
                        .shadow(color: .white, radius: 12)
                    
                    Button("Restart") {
                        manager.restartGame()
                    }
                    .buttonStyle(.plain)
                }
                .transition(
                    .scale.combined(with: .opacity)
                    .animation(.spring(response: 0.4, dampingFraction: 0.4))
                )
            }
        }
        .frame(width: cellWidth * CGFloat(manager.cols))
        .onReceive(timer, perform: manager.update)
    }
}
