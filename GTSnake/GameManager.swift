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
        self.clear()
        // initialize a default snake here.
        self.snake = [
            (row: 0, col: cols / 2),
            (row: 1, col: cols / 2),
            (row: 2, col: cols / 2),
            (row: 3, col: cols / 2),
        ].reversed()
        
        self.currentDirection = .down
        self.gameState = .playing
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
        // check the game state. If game is lost, don't do anything
        
        // The first thing to do is to clear the grid.
        self.clear()
        // Move the snakes head. Hint: most of the snakes body actually stays
        // the same. The only squares that change are the head and the tail.
        // I also suggest keeping the coordinate of the snake somewhere.
        
        var snakeHead = snake[0]
        print(currentDirection)
        if (self.currentDirection == .down) {
            for i in 0...snake.count-1 {
                snake[i].row += 1
            }
        } else if (self.currentDirection == .up) {
            for i in 0...snake.count-1 {
                snake[i].row += -1
            }
        } else if (self.currentDirection == .left) {
            for i in 0...snake.count-1 {
                snake[i].col += -1
            }
        } else {
            for i in 0...snake.count-1 {
                snake[i].col += 1
            }
        }
        
        // Check for bounds. Make sure the snake stays inside the grid
        
        /*Add code here*/
        
        // Check if the game has been lost. When is the game lost? When the
        // snake tried to eat itself!

        /*Add code here*/
        
        // Check if the head of the snake if on top of food. In that case,
        // consume the food. Otherwise, maybe create food if food doesn't exist?
        
        /*Add code here*/
        
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

        /*Add code here*/
        
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
