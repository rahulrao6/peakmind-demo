import SwiftUI
import Foundation

struct GridPosition: Hashable {
    let row: Int
    let column: Int
}

enum Direction {
    case up, down, left, right, none
}

struct Maze {
    static let pacMan: [[Int]] = [
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1],
        [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1],
        [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1],
        [1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1],
        [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1],
        [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1],
        [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1],
        [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1],
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
    ]
}

class GameModel: ObservableObject {
    @Published var pacManPosition = GridPosition(row: 1, column: 1)
    @Published var dots: Set<GridPosition> = []
    @Published var ghosts: [GridPosition] = []
    @Published var isGameOver = false
    @Published var isGameWon = false
    var pacManDirection: Direction = .none
    var rowCount: Int { maze.count }
    var columnCount: Int { maze.first?.count ?? 0 }
    var maze: [[Int]] = Maze.pacMan
    
    init() {
        populateGridWithDots()
        restartGame()
        startMovement()
    }

    deinit {
        movementTimer?.invalidate()
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
            DispatchQueue.main.async { [weak self] in
                self?.pacManPosition = newPosition
                self?.dots.remove(newPosition)
                self?.checkForWin()
            }
        }
    }

    func moveGhosts() {
        for index in ghosts.indices {
            let newPosition = getNextGhostPosition(for: ghosts[index])
            if canMove(to: newPosition) {
                DispatchQueue.main.async { [weak self] in
                    self?.ghosts[index] = newPosition
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

    func getNextGhostPosition(for position: GridPosition) -> GridPosition {
        let directionOptions: [Direction] = [.up, .down, .left, .right]
        let randomDirection = directionOptions.randomElement() ?? .none
        return getNextPosition(for: position, direction: randomDirection)
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
            DispatchQueue.main.async { [weak self] in
                self?.isGameOver = true
                self?.movementTimer?.invalidate()
            }
        }
    }

    func checkForWin() {
        if dots.isEmpty {
            DispatchQueue.main.async { [weak self] in
                self?.isGameWon = true
                self?.movementTimer?.invalidate()
            }
        }
    }

    func restartGame() {
        isGameOver = false
        isGameWon = false
        pacManPosition = GridPosition(row: 1, column: 1)
        pacManDirection = .none
        ghosts = [
            GridPosition(row: 4, column: 4),
            GridPosition(row: 6, column: 6)
        ]
        populateGridWithDots()
        startMovement()
    }
}

struct PacManGameView: View {
    @EnvironmentObject var gameModel: GameModel
    var closeAction: (String) -> Void

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
                        GameOverView(closeAction: closeAction)
                            .environmentObject(gameModel)
                    }

                    if gameModel.isGameWon {
                        GameWonView(closeAction: closeAction)
                            .environmentObject(gameModel)
                    }

                    if !gameModel.isGameOver && !gameModel.isGameWon {
                        ControlsView(gameModel: gameModel, closeAction: closeAction)
                            .padding()
                            .position(x: geometry.size.width / 2, y: geometry.size.height - 50) // Positioning controls at the bottom
                    }
                }
            }
        }
        .gesture(DragGesture().onEnded(handleSwipe))
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
                    Color.gray
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
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct ControlsView: View {
    @ObservedObject var gameModel: GameModel
    var closeAction: (String) -> Void

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
            Button(action: {
                closeAction("")
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding()
                    .background(Circle().fill(Color.red))
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
    var closeAction: (String) -> Void

    var body: some View {
        VStack {
            Text("Game Over").font(.largeTitle).foregroundColor(.white)
            Button("Restart") {
                gameModel.restartGame()
            }
            .padding().background(Color.green).foregroundColor(.white).clipShape(RoundedRectangle(cornerRadius: 10))
            Button("Exit") {
                closeAction("")
            }
            .padding().background(Color.green).foregroundColor(.white).clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.8))
    }
}

struct GameWonView: View {
    @EnvironmentObject var gameModel: GameModel
    var closeAction: (String) -> Void

    var body: some View {
        VStack {
            Text("You Win!").font(.largeTitle).foregroundColor(.white)
            Button("Restart") {
                gameModel.restartGame()
            }
            .padding().background(Color.green).foregroundColor(.white).clipShape(RoundedRectangle(cornerRadius: 10))
            Button("Exit") {
                closeAction("")
            }
            .padding().background(Color.green).foregroundColor(.white).clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.8))
    }
}
