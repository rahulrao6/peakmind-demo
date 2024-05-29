import SpriteKit


class MapScene: SKScene, ObservableObject {
    @Published var currentPhase = -1
    
    var imagePositions: [CGPoint] = []
    var phases: [Phase] = []
    var imageNodes: [SKSpriteNode] = []
    var cameraNode: SKCameraNode!
    var levelInfoBG: SKSpriteNode!
    var levelInfoText: SKLabelNode!
    var selectedPhase: Int = -1

    override func didMove(to view: SKView) {
        setupBackground()
        setupImages()
        setupCamera()
        setupLevelBox()
        self.backgroundColor = UIColor(red: 193/255, green: 243/255, blue: 255/255, alpha: 1)
    }

    private func setupBackground() {
        let background = SKSpriteNode(imageNamed: "pkmd_path")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        background.size = CGSize(width: 250, height: UIScreen.main.bounds.height)
        addChild(background)
        let background2 = SKSpriteNode(imageNamed: "pkmd_path")
        background2.position = CGPoint(x: size.width / 2, y: (-size.height) + (size.height / 2))
        background2.zPosition = -1
        background2.size = CGSize(width: 250, height: UIScreen.main.bounds.height)
        addChild(background2)
        let path = SKSpriteNode(imageNamed: "InnerPath")
        path.position = CGPoint(x: size.width / 2, y: size.height / 2)
        path.zPosition = -1
        path.size = CGSize(width: 100, height: UIScreen.main.bounds.height)
        addChild(path)
        let path2 = SKSpriteNode(imageNamed: "InnerPath")
        path2.position = CGPoint(x: size.width / 2, y: (-size.height) + (size.height / 2))
        path2.zPosition = -1
        path2.size = CGSize(width: 100, height: UIScreen.main.bounds.height)
        addChild(path2)
    }
    
    private func setupCamera() {
        cameraNode = SKCameraNode()
        self.camera = cameraNode
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(cameraNode)
    }

    private func setupLevelBox() {
        levelInfoBG = SKSpriteNode(imageNamed: "RoundedShadow")
        levelInfoBG.position = CGPoint(x: 100, y: size.height/2)
        levelInfoBG.size = CGSize(width: 185, height: 140)
        levelInfoBG.alpha = 0
        levelInfoBG.name = "LevelInfoBox"
        addChild(levelInfoBG)
        
        levelInfoText = SKLabelNode(text: "Intro")
        levelInfoText.position = CGPoint(x: 100, y: size.height/2)
        levelInfoText.fontSize = 16
        levelInfoText.alpha = 0
        levelInfoText.horizontalAlignmentMode = .left
        levelInfoText.verticalAlignmentMode = .top
        levelInfoText.fontColor = UIColor.black
        levelInfoText.fontName = "AvenirNext-Bold"
        levelInfoText.lineBreakMode = .byWordWrapping
        levelInfoText.numberOfLines = 2
        levelInfoText.preferredMaxLayoutWidth = 100
        addChild(levelInfoText)
    }
    
    private func setupImages() {
        for position in imagePositions {
            let imageNode = SKSpriteNode(imageNamed: "pkmd_level")
            imageNode.position = position
            imageNode.size = CGSize(width: 100, height: 100)
            imageNode.name = "imageNode"  // Add a name to each node for identification.
            imageNodes.append(imageNode)
            addChild(imageNode)
            let text = SKLabelNode(text: String(imagePositions.firstIndex(of: position)!+1))
            text.position = CGPoint(x: position.x, y: position.y - 10)
            text.fontColor = UIColor.black
            text.fontName = "AvenirNext-Bold"
            text.fontSize = 40
            addChild(text)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }

        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if node.name == "imageNode", let sprite = node as? SKSpriteNode {
                shrinkNode(sprite)
                centerOnNode(node: sprite)
                selectedPhase = imageNodes.firstIndex(of: sprite) ?? -1
                return
            }
            if node.name == "LevelInfoBox" {
                currentPhase = selectedPhase
            }
        }
        zoomOut()
    }
    
    private func resetAllNodes() {
        let growAction = SKAction.scale(to: 1, duration: 0.1)
        for loopnode in imageNodes {
            loopnode.run(growAction)
        }
    }

    private func shrinkNode(_ node: SKSpriteNode) {
        resetAllNodes()
        let shrinkAction = SKAction.scale(to: 0.8, duration: 0.1)  // Adjust node shrink
        node.run(shrinkAction)
    }
    
    private func zoomOut() {
        let moveAction = SKAction.move(to: CGPoint(x: size.width / 2, y: size.height / 2), duration: 0.5)
        moveAction.timingMode = .easeInEaseOut // Smooth transition
        cameraNode.run(moveAction)
        
        let zoomAction = SKAction.scale(to: 1, duration: 0.5) // Zoom in effect
        cameraNode.run(zoomAction)
        
        let alphaAction1 = SKAction.fadeAlpha(to: 0, duration: 0.25)
        levelInfoBG.run(alphaAction1)
        
        let alphaAction2 = SKAction.fadeAlpha(to: 0, duration: 0.25)
        levelInfoText.run(alphaAction1)
        
        resetAllNodes()
    }
    
    private func centerOnNode(node: SKSpriteNode) {
        let alphaAction1 = SKAction.fadeAlpha(to: 0, duration: 0.25)
        levelInfoBG.run(alphaAction1)
        
        let alphaAction2 = SKAction.fadeAlpha(to: 0, duration: 0.25)
        levelInfoText.run(alphaAction1)
        
        let moveAction = SKAction.move(to: CGPoint(x: node.position.x - 85, y: node.position.y), duration: 0.5)
        moveAction.timingMode = .easeInEaseOut // Smooth transition
        cameraNode.run(moveAction)
        
        let zoomAction = SKAction.scale(to: 0.8, duration: 0.5) // Zoom in effect
        cameraNode.run(zoomAction)
                
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.levelInfoText.text = self.phases[self.selectedPhase].title
            
            self.levelInfoBG.position = CGPoint(x: node.position.x - 140, y: node.position.y)
            self.levelInfoText.position = CGPoint(x: node.position.x - 210, y: node.position.y + 47)

            let alphaAction = SKAction.fadeAlpha(to: 1, duration: 0.25)
            self.levelInfoBG.run(alphaAction)
            
            let alphaActionSecondary = SKAction.fadeAlpha(to: 1, duration: 0.25)
            self.levelInfoText.run(alphaActionSecondary)
        }
    }
}
