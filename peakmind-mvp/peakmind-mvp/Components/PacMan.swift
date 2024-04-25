import SwiftUI
import Foundation


// Represents a position on the grid
struct GridPosition: Hashable {
    let row: Int
    let column: Int
}

// Defines possible movement directions
enum Direction {
    case up, down, left, right, none
}

struct Maze {
    static let easy: [[Int]] = [
        [1, 1, 1, 1, 1],
        [1, 0, 0, 0, 1],
        [1, 0, 1, 0, 1],
        [1, 0, 0, 0, 1],
        [1, 1, 1, 1, 1]
    ]
    
    static let medium: [[Int]] = [
        [1, 1, 1, 1, 1, 1],
        [1, 0, 0, 1, 0, 1],
        [1, 0, 1, 0, 0, 1],
        [1, 0, 0, 0, 1, 1],
        [1, 1, 1, 1, 1, 1]
    ]
    
    static let hard: [[Int]] = [
        [1, 1, 1, 1, 1, 1, 1],
        [1, 0, 0, 1, 0, 0, 1],
        [1, 0, 1, 1, 1, 0, 1],
        [1, 0, 1, 0, 1, 0, 1],
        [1, 0, 0, 0, 0, 0, 1],
        [1, 1, 1, 1, 1, 1, 1]
    ]
}

enum Difficulty {
    case easy, medium, hard
}

// The main game model managing the state
class GameModel: ObservableObject {
    @Published var pacManPosition = GridPosition(row: 1, column: 1)
    @Published var dots: Set<GridPosition> = []
    @Published var ghosts: [GridPosition] = []
    @Published var isGameOver = false
    var pacManDirection: Direction = .none
    var rowCount: Int { maze.count }
    var columnCount: Int { maze.first?.count ?? 0 }
    var maze: [[Int]] = []
    
    
    init(difficulty: Difficulty = .hard) {
        let (rows, cols) = getDimensions(for: difficulty)
        maze = MazeGenerator(rows: rows, cols: cols).maze
        populateGridWithDots()
        restartGame()
        startMovement()
    }
    
//    init(difficulty: Difficulty = .hard) {
//        switch difficulty {
//        case .easy:
//            maze = Maze.easy
//        case .medium:
//            maze = Maze.medium
//        case .hard:
//            maze = Maze.hard
//        }
//        populateGridWithDots()
//        restartGame()
//        startMovement()
//    }
    
    private func getDimensions(for difficulty: Difficulty) -> (Int, Int) {
        switch difficulty {
        case .easy:
            return (9, 9)
        case .medium:
            return (15, 15)
        case .hard:
            return (21, 21)
        }
    }

    private var movementTimer: Timer?
    
    func populateGridWithDots() {
        dots.removeAll()
        for row in 0..<rowCount {
            for column in 0..<columnCount {
                if maze[row][column] == 0 {
                    dots.insert(GridPosition(row: row, column: column))
                }
            }
        }
    }

    func movePacMan() {
        let newPosition = getNextPosition(for: pacManPosition, direction: pacManDirection)
        if canMove(to: newPosition) {
            DispatchQueue.main.async {
                self.pacManPosition = newPosition
                self.dots.remove(newPosition)
            }
        }
    }

    func moveGhosts() {
        for index in ghosts.indices {
            let directionOptions: [Direction] = [.up, .down, .left, .right]
            let randomDirection = directionOptions.randomElement() ?? .none
            let newPosition = getNextPosition(for: ghosts[index], direction: randomDirection)
            if canMove(to: newPosition) {
                DispatchQueue.main.async {
                    self.ghosts[index] = newPosition
                }
            }
        }
    }

    func getNextPosition(for position: GridPosition, direction: Direction) -> GridPosition {
        switch direction {
        case .up: return GridPosition(row: max(position.row - 1, 0), column: position.column)
        case .down: return GridPosition(row: min(position.row + 1, rowCount - 1), column: position.column)
        case .left: return GridPosition(row: position.row, column: max(position.column - 1, 0))
        case .right: return GridPosition(row: position.row, column: min(position.column + 1, columnCount - 1))
        case .none: return position
        }
    }

    func canMove(to position: GridPosition) -> Bool {
        guard position.row >= 0, position.row < rowCount, position.column >= 0, position.column < columnCount else {
            return false
        }
        return maze[position.row][position.column] == 0
    }

    func startMovement() {
        movementTimer?.invalidate()
        movementTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            self?.movePacMan()
            self?.moveGhosts()
            self?.checkForCollisions()
        }
    }

    func changePacManDirection(to newDirection: Direction) {
        pacManDirection = newDirection
    }

    func checkForCollisions() {
        if ghosts.contains(pacManPosition) {
            DispatchQueue.main.async {
                self.isGameOver = true
                self.movementTimer?.invalidate()
            }
        }
    }

    func restartGame() {
        isGameOver = false
        pacManPosition = GridPosition(row: 1, column: 1)
        pacManDirection = .none
        ghosts = [
            GridPosition(row: 2, column: 2),
            GridPosition(row: 12, column: 8)
        ]
        populateGridWithDots()
        startMovement()
    }
}


struct PacManGameView: View {
    @EnvironmentObject var gameModel: GameModel

    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 0) {
                        ForEach(0..<gameModel.rowCount, id: \.self) { row in
                            HStack(spacing: 0) {
                                ForEach(0..<gameModel.columnCount, id: \.self) { column in
                                    CellView(position: GridPosition(row: row, column: column))
                                        .environmentObject(gameModel)
                                }
                            }
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.width * (CGFloat(gameModel.rowCount) / CGFloat(gameModel.columnCount)))
                    .padding(.bottom, geometry.size.height - geometry.size.width * (CGFloat(gameModel.rowCount) / CGFloat(gameModel.columnCount)))
                    
                    if gameModel.isGameOver {
                        GameOverView()
                            .environmentObject(gameModel)
                    }

                    
                    if !gameModel.isGameOver {
                        ControlsView(gameModel: gameModel)
                            .padding()
                            .position(x: geometry.size.width / 2, y: geometry.size.height - 50) // Positioning controls at the bottom
                    }
                }
            }
        }
        .gesture(DragGesture().onEnded(handleSwipe))
        // Your existing swipe handling remains the same...
    }
    
        private func handleSwipe(_ drag: DragGesture.Value) {
            let horizontal = abs(drag.translation.width)
            let vertical = abs(drag.translation.height)
    
            if horizontal > vertical {
                gameModel.changePacManDirection(to: drag.translation.width < 0 ? .left : .right)
            } else {
                gameModel.changePacManDirection(to: drag.translation.height < 0 ? .up : .down)
            }
        }
}

struct CellView: View {
    @EnvironmentObject var gameModel: GameModel
    var position: GridPosition
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if gameModel.maze[position.row][position.column] == 1 {
                    Color.blue // Wall color
                } else {
                    Color.black // Background for paths
                    if gameModel.pacManPosition == position {
                        Circle().fill(Color.yellow)
                    } else if gameModel.ghosts.contains(position) {
                        Circle().fill(Color.red)
                    } else if gameModel.dots.contains(position) {
                        Circle().fill(Color.white)
                            .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.3) // Adjust size to center dot
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2) // Center the dot
                    } else if isPowerPellet(position: position) {
                        Circle().fill(Color.white)
                            .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.5) // Adjust size for power pellet
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2) // Center the power pellet
                    } else if isGhostHouse(position: position) {
                        // Add ghost house visual here
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func isPowerPellet(position: GridPosition) -> Bool {
        // Implement logic to determine if the position is a power pellet
        // For example, check if the position is near the four corners
        return false
    }
    
    private func isGhostHouse(position: GridPosition) -> Bool {
        // Implement logic to determine if the position is the ghost house
        // For example, check if the position is in the center
        return false
    }
}


struct ControlsView: View {
    @ObservedObject var gameModel: GameModel

    var body: some View {
        HStack {
            ForEach([Direction.left, .up, .down, .right], id: \.self) { direction in
                Button(action: {
                    self.gameModel.changePacManDirection(to: direction)
                }) {
                    Image(systemName: iconName(for: direction))
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .padding()
                        .background(Circle().fill(Color.blue))
                }
            }
        }
    }

    private func iconName(for direction: Direction) -> String {
        switch direction {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .left: return "arrow.left"
        case .right: return "arrow.right"
        default: return ""
        }
    }
}


struct GameOverView: View {
    @EnvironmentObject var gameModel: GameModel

    var body: some View {
        VStack {
            Text("Game Over").font(.largeTitle).foregroundColor(.white)
            Button("Restart") {
                gameModel.restartGame()
            }
            .padding().background(Color.green).foregroundColor(.white).clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.8))
    }
}

struct Cell: Hashable {
    let row: Int
    let col: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(row)
        hasher.combine(col)
    }
    
    static func == (lhs: Cell, rhs: Cell) -> Bool {
        return lhs.row == rhs.row && lhs.col == rhs.col
    }
}

class MazeGenerator {
    let rows: Int
        let cols: Int
        var maze: [[Int]]
        
        init(rows: Int, cols: Int) {
            self.rows = rows
            self.cols = cols
            maze = Array(repeating: Array(repeating: 1, count: cols), count: rows)
            generateMaze()
            addTunnels()
            addGhostHouse()
        }
        
        private func generateMaze() {
            let startRow = 0
            let startCol = 0
            
            maze[startRow][startCol] = 0
            
            var stack = [Cell(row: startRow, col: startCol)]
            var visitedCells = Set<Cell>()
            
            while !stack.isEmpty {
                let currentCell = stack.removeLast()
                visitedCells.insert(currentCell)
                
                var neighbors = [Cell]()
                if currentCell.row > 1, !visitedCells.contains(Cell(row: currentCell.row - 2, col: currentCell.col)) { neighbors.append(Cell(row: currentCell.row - 2, col: currentCell.col)) }
                if currentCell.row < rows - 2, !visitedCells.contains(Cell(row: currentCell.row + 2, col: currentCell.col)) { neighbors.append(Cell(row: currentCell.row + 2, col: currentCell.col)) }
                if currentCell.col > 1, !visitedCells.contains(Cell(row: currentCell.row, col: currentCell.col - 2)) { neighbors.append(Cell(row: currentCell.row, col: currentCell.col - 2)) }
                if currentCell.col < cols - 2, !visitedCells.contains(Cell(row: currentCell.row, col: currentCell.col + 2)) { neighbors.append(Cell(row: currentCell.row, col: currentCell.col + 2)) }
                
                neighbors.shuffle()
                
                for neighbor in neighbors {
                    let betweenRow = (currentCell.row + neighbor.row) / 2
                    let betweenCol = (currentCell.col + neighbor.col) / 2
                    stack.append(neighbor)
                    maze[neighbor.row][neighbor.col] = 0
                    maze[betweenRow][betweenCol] = 0
                }
            }
        }
    
    private func addTunnels() {
        let halfRows = rows / 2
        let halfCols = cols / 2
        
        // Left tunnel
        for col in 0..<cols {
            if maze[halfRows][col] == 0 {
                maze[halfRows - 1][col] = 0
                maze[halfRows + 1][col] = 0
                break
            }
        }
        
        // Right tunnel
        for col in (0..<cols).reversed() {
            if maze[halfRows][col] == 0 {
                maze[halfRows - 1][col] = 0
                maze[halfRows + 1][col] = 0
                break
            }
        }
    }
    
    private func addGhostHouse() {
        let centerRow = rows / 2
        let centerCol = cols / 2
        
        maze[centerRow - 1][centerCol - 1] = 1
        maze[centerRow - 1][centerCol] = 1
        maze[centerRow - 1][centerCol + 1] = 1
        maze[centerRow][centerCol - 1] = 1
        maze[centerRow][centerCol] = 0
        maze[centerRow][centerCol + 1] = 1
        maze[centerRow + 1][centerCol - 1] = 1
        maze[centerRow + 1][centerCol] = 1
        maze[centerRow + 1][centerCol + 1] = 1
    }
}


struct PacManGameView_Previews: PreviewProvider {
    static var previews: some View {
        PacManGameView().environmentObject(GameModel())
    }
}
