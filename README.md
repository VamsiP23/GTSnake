# GTSnake game
Your task is to finish the implementation of the snake game. The graphics part has already been done, all you need to fill out is the `GameManager` class.

## The anatomy of any game
Any game usually consists of three steps: 
1. An external event happens. This could be a user pressing a button or a timer firing or, in our case, both.
2. Update phase. When an external event occurs, we want to update the state of our game. Imagine that you are playing a first shooter game and the player 
presses the `w` key. Based on that, you probably want to move your character straight by updating its position. The position of the character is considered
a piece of game state. In our case, the game state will probably consist of a grid of colors, the position of the snake and its body, position of food, 
snake current velocity, if the game has been lost, how many food items the snake has consumed, etc. Update the state of your snake game in this phase.
3. Rendering. This phase takes the state of your game and actually renders it on screen. This step has been taken care for you. Later in the semester, 
we will learn more about how we can take the state and render it.

## Steps
1. Clone the repo. First thing to do is to switch into a folder where you want the game to be stored and then run `git clone `
2. Switch the branch to `hw`. Since this is not the actual homework, the solution is on the `main` branch. Please, switch to the assignment branch with
`git switch hw`.
You can check your solution with ours by switching to the main branch. 
