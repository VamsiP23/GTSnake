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
                    .frame(height: manager.cellHeight)
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
        .frame(width: manager.cellWidth * CGFloat(manager.cols))
        .onReceive(timer, perform: manager.update)
    }
}

final class GameManager: ObservableObject {
    enum Direction: UInt16 {
        case up = 126, down = 125, left = 123, right = 124
        
        var displacement: (row: Int, col: Int) {
            switch self {
            case .down: return (row: 1, col: 0)
            case .up: return (row: -1, col: 0)
            case .left: return (row: 0, col: -1)
            case .right: return (row: 0, col: 1)
            }
        }
        
        func isOpposite(to other: Direction) -> Bool {
            return self == .up && other == .down ||
                self == .down && other == .up ||
                self == .left && other == .right ||
                self == .right && other == .left
        }
    }
    
    enum GameState {
        case playing, lost
    }
    
    
    @Published var cellWidth: CGFloat = 20
    @Published var cellHeight: CGFloat = 20
    
    @Published var rows = 30
    @Published var cols = 20
    
    @Published var grid: [Color] = []
    @Published var gameState: GameState = .playing
    
    var snake: [(row: Int, col: Int)] = []
    var currentDirection: Direction = .down
    var food: (row: Int, col: Int)? = nil
    
    init() {
        self.clear()
        self.snake = [
            (row: 0, col: cols / 2),
            (row: 1, col: cols / 2),
            (row: 2, col: cols / 2),
            (row: 3, col: cols / 2),
        ].reversed()
    }
    
    func restartGame() {
        self.clear()
        self.snake = [
            (row: 0, col: cols / 2),
            (row: 1, col: cols / 2),
            (row: 2, col: cols / 2),
            (row: 3, col: cols / 2),
        ].reversed()
        self.currentDirection = .down
        self.gameState = .playing
    }
    
    func update(_ date: Date) {
        guard gameState == .playing else { return }
        
        self.clear()
        
        var newHead = snake[0]
        newHead.row += currentDirection.displacement.row
        newHead.col += currentDirection.displacement.col
        
        if newHead.row >= rows {
            newHead.row = 0
        } else if newHead.row < 0 {
            newHead.row = rows - 1
        }
        
        if newHead.col >= cols {
            newHead.col = 0
        } else if newHead.col <= 0 {
            newHead.col = cols - 1
        }
        
        for bodyPart in snake {
            if bodyPart.row == newHead.row && bodyPart.col == newHead.col {
                self.gameState = .lost
                return
            }
        }
        
        snake = snake.dropLast()
        snake.insert(newHead, at: 0)
        
        if let food {
            if let tail = snake.last, food.row == snake[0].row && food.col == snake[0].col {
                // add tail
                snake.append(tail)
                self.food = nil
            }
        } else {
            self.food = (
                row: Int.random(in: 0 ..< rows),
                col: Int.random(in: 0 ..< cols)
            )
        }
        
        for (row, col) in snake {
            self[row, col] = .yellow
        }
        
        if let food {
            self[food.row, food.col] = .red
        }
    }
    
    func keyDown(_ code: UInt16) {
        guard let newDirection = Direction(rawValue: code) else { return }
        
        if newDirection.isOpposite(to: currentDirection) {
            return
        }
        
        self.currentDirection = newDirection
        
    }
    
    func clear() {
        self.grid = (0 ..< rows * cols).map { _ in .clear}
    }
    
    subscript (_ row: Int, col: Int) -> Color {
        get { self.grid[row * cols + col] }
        set { self.grid[row * cols + col] = newValue}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
