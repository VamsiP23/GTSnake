//
//  GameManager.swift
//  GTSnake
//
//  Created by Maksim Tochilkin on 2/18/23.
//

import SwiftUI

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
    
    /// Number of rows in the snake grid
    @Published var rows = 30
    /// Number of columns in the snake grid
    @Published var cols = 20
    
    /// The grid is just an array of colors. You can decide the color
    /// of your snake and your food.
    @Published var grid: [Color] = []
    @Published var gameState: GameState = .playing
    
    
    var snake: [(row: Int, col: Int)] = []
    var currentDirection: Direction = .down
    var food: (row: Int, col: Int)? = nil
    
    init() {
        // first we need to clear the grid
        self.restartGame()
        // then initialize a default snake.

    }
    
    
    /// This function is called by the game renderer to reset the game after winning or
    /// losing.
    func restartGame() {
        // First, clear the grid
        self.clear()
        // reinitalize the default snake
        self.snake = [
            (row: 0, col: cols / 2),
            (row: 1, col: cols / 2),
            (row: 2, col: cols / 2),
            (row: 3, col: cols / 2),
        ].reversed()
        
        // Do any other state reseting that you need
        self.currentDirection = .down
        self.gameState = .playing
    }
    
    
    /// The update function. Called every 0.25 seconds by the renderer. Perform incremental
    /// updates to your game state here. That means moving the snake by one square,
    /// checking for the bounds of the grid, making sure snake stays in bounds, checkig if
    /// the game is lost, etc...
    /// You can also use `self[row, col] = Color.red` to draw color in the grid at position
    /// `(row, col)` in the grid, instead of manually computing the index in the grid
    /// array
    /// - Parameter date: The current date, you won't need to use this param here.
    func update(_ date: Date) {
        guard gameState == .playing else { return }
        
        // The first thing to do is to clear the grid.
        self.clear()
        
        // Move the snakes head. Hint: most of the snakes body actually stays
        // the same. The only squares that change are the head and the tail.
        // I also suggest keeping the coordinate of the snake somewhere.
        var newHead = snake[0]
        newHead.row += currentDirection.displacement.row
        newHead.col += currentDirection.displacement.col
        
        // Check for bounds. Make sure the snake stays inside the grid
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
        
        // Check if the game has been lost. When is the game lost? When the
        // snake tried to eat itself!
        for bodyPart in snake {
            if bodyPart.row == newHead.row && bodyPart.col == newHead.col {
                self.gameState = .lost
                return
            }
        }
        
        snake = snake.dropLast()
        snake.insert(newHead, at: 0)
        
        // Check if the head of the snake if on top of food. In that case,
        // consume the food. Otherwise, maybe create food if food doesn't exist?
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
        
        // Actually draw the snakes body into the grid.
        for (row, col) in snake {
            self[row, col] = .yellow
        }
        
        // Finally, draw food.
        if let food {
            self[food.row, food.col] = .red
        }
    }
    
    
    /// This method gets called when a user pressed any keys on the keyboard. In this game,
    /// you can change the position of the snake with the keys for example.
    /// - Parameter code: The code of the key that was pressed
    func keyDown(_ code: UInt16) {
        // Convert the key code into a direction first.
        guard let newDirection = Direction(rawValue: code) else { return }
        
        // change the velocity of the snake, according to the new direction.
        // Hint: if the new direction is opposite to the current direction,
        // just ignore this key event. Otherwise, you will end up with snake
        // eating itself
        if newDirection.isOpposite(to: currentDirection) {
            return
        }
        
        self.currentDirection = newDirection
        
    }
    
    
    /// Clears the grid by setting the color to clear on the entire grid
    func clear() {
        self.grid = (0 ..< rows * cols).map { _ in .clear}
    }
    
    /// A convenience subscript to map get the color or set the color at `(row, col)`
    subscript (_ row: Int, col: Int) -> Color {
        get { self.grid[row * cols + col] }
        set { self.grid[row * cols + col] = newValue}
    }
}
