import SpriteKit


class MapScene: SKScene, ObservableObject {
    @Published var currentLevel = -1
    @Published var completedLevels = 0
    @Published var completedPhases = 0

    
    private var initialTouchPosition: CGPoint?
    
    
    var imagePositions: [CGPoint] = []
    var levels: [LevelNode] = []
    var completedLevelsList: [CompletedLevel] = []
    var imageNodes: [SKSpriteNode] = []
    var textNodes: [SKLabelNode] = []
    var phaseGates: [SKShapeNode] = []
    var phaseGatesText: [SKLabelNode] = []
    var cameraNode: SKCameraNode!
    var levelInfoBG: SKSpriteNode!
    var levelInfoText: SKLabelNode!
    var selectedPhase: Int = -1
    var currentYPosition: Float = 0
    var maxY: Float = 0
    
    func getTargetY() -> CGFloat {
        return (CGFloat(currentYPosition + 0.5) * UIScreen.main.bounds.height)
    }
    
    func reloadCompletedLevels() {
        for item in imageNodes {
            item.removeFromParent()
        }
        
        for item in textNodes {
            item.removeFromParent()
        }
        
        for level in levels {
            let position = getPositionForLevel(level: level)
            let imageNode = SKSpriteNode(imageNamed: "pkmd_level")
            imageNode.position = position
            imageNode.size = CGSize(width: 100, height: 100)
            imageNode.name = "imageNode"  // Add a name to each node for identification.
            imageNodes.append(imageNode)
            addChild(imageNode)
            if (getLevelCompleted(level: level)) {
                let imageNode2 = SKSpriteNode(imageNamed: "LevelComplete")
                imageNode2.position = CGPointMake(position.x + 14, position.y + 50)
                imageNode2.size = CGSize(width: 75, height: 100)
                addChild(imageNode2)
            } else {
                let text = SKLabelNode(text: String(level.uid + 1))
                text.position = CGPoint(x: position.x, y: position.y - 10)
                text.fontColor = UIColor.black
                text.fontName = "AvenirNext-Bold"
                text.fontSize = 40
                textNodes.append(text)
                addChild(text)
            }
        }
    }
    
    func getLevelCompleted(level: LevelNode) -> Bool {
        for singleLevel in completedLevelsList {
            if (singleLevel.phase == level.phase && singleLevel.uid == level.uid) {
                return true
            }
        }
        return false
    }
    
    func swipeUp() {
        if currentYPosition > 0 {
            currentYPosition -= 0.5
            let moveAction = SKAction.move(to: CGPoint(x: size.width / 2, y: cameraNode.position.y - (UIScreen.main.bounds.height/2)), duration: 0.3)
            moveAction.timingMode = .easeInEaseOut // Smooth transition
            cameraNode.run(moveAction)
        }
    }
    
    func swipeDown() {
        if currentYPosition < maxY {
            currentYPosition += 0.5
            let moveAction = SKAction.move(to: CGPoint(x: size.width / 2, y: cameraNode.position.y + (UIScreen.main.bounds.height/2)), duration: 0.3)
            moveAction.timingMode = .easeInEaseOut // Smooth transition
            cameraNode.run(moveAction)
        }
    }

    override func didMove(to view: SKView) {
        setupBackground()
        setupProps()
        setupNewImages()
        setupCamera()
        setupLevelBox()
        setupPhaseGates()
        self.backgroundColor = UIColor(red: 142/255, green: 214/255, blue: 137/255, alpha: 1)
    }

    private func setupBackground() {
        let imageNames = ["pkmd_path", "InnerPath"]
        let sizes = [CGSize(width: 250, height: UIScreen.main.bounds.height), CGSize(width: 100, height: UIScreen.main.bounds.height)]
        let yPositions: [CGFloat] = [-1, 0, 1, 2, 3, 4, 5].map { CGFloat($0) * UIScreen.main.bounds.height }

        for (index, imageName) in imageNames.enumerated() {
            for yPosition in yPositions {
                let node = SKSpriteNode(imageNamed: imageName)
                node.position = CGPoint(x: size.width / 2, y: yPosition + (size.height / 2))
                node.zPosition = -1
                node.size = sizes[index]
                addChild(node)
            }
        }
    }
    
    private func setupCamera() {
        cameraNode = SKCameraNode()
        self.camera = cameraNode
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(cameraNode)
    }
    
    func reloadGates() {
        setupPhaseGates()
    }
    
    private func setupPhaseGates() {
        for item in phaseGates {
            item.removeFromParent()
        }
        
        for item in phaseGatesText {
            item.removeFromParent()
        }
        
        maxY = (Float(completedPhases)*2) + 1.5
        
        let n1bg = SKShapeNode(rectOf: CGSize(width: 2000, height: 1000))
        n1bg.position = CGPointMake(UIScreen.main.bounds.width/2, UIScreen.main.bounds.height * CGFloat(maxY) + 900)
        n1bg.fillColor = .black
        n1bg.alpha = 0.5
        addChild(n1bg)
        phaseGates.append(n1bg)
        let n1 = SKShapeNode(rectOf: CGSize(width: 2000, height: 100))
        n1.position = CGPointMake(UIScreen.main.bounds.width/2, UIScreen.main.bounds.height * CGFloat(maxY) + 400)
        n1.fillColor = .white
        addChild(n1)
        phaseGates.append(n1bg)
        let n1textup = SKLabelNode(text: "Phase "+String(completedPhases+2))
        n1textup.position = CGPointMake(UIScreen.main.bounds.width/2, (UIScreen.main.bounds.height * CGFloat(maxY))+415)
        n1textup.fontName = "AvenirNext-Bold"
        n1textup.fontColor = .black
        n1textup.horizontalAlignmentMode = .center
        n1textup.verticalAlignmentMode = .center
        addChild(n1textup)
        phaseGatesText.append(n1textup)
        let n2textup = SKLabelNode(text: "Complete 5 more levels to unlock")
        n2textup.position = CGPointMake(UIScreen.main.bounds.width/2, (UIScreen.main.bounds.height * CGFloat(maxY))+400-25)
        n2textup.fontName = "AvenirNext"
        n2textup.fontColor = .black
        n2textup.horizontalAlignmentMode = .center
        n2textup.verticalAlignmentMode = .center
        n2textup.fontSize = CGFloat(15.0)
        addChild(n2textup)
        phaseGatesText.append(n1textup)
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
    
    private func setupProps() {
        var imageNode = SKSpriteNode(imageNamed: "Rocks")
        imageNode.position = CGPointMake(320, 565)
        imageNode.size = CGSize(width: 110, height: 110)
        addChild(imageNode)
        var imageNode2 = SKSpriteNode(imageNamed: "Rocks")
        imageNode2.position = CGPointMake(80, 250)
        imageNode2.xScale = -1.0
        imageNode2.size = CGSize(width: 80, height: 80)
        addChild(imageNode2)
    }
    
    private func setupNewImages() {
        for level in levels {
            let position = getPositionForLevel(level: level)
            let imageNode = SKSpriteNode(imageNamed: "pkmd_level")
            imageNode.position = position
            imageNode.size = CGSize(width: 100, height: 100)
            imageNode.name = "imageNode"  // Add a name to each node for identification.
            imageNodes.append(imageNode)
            addChild(imageNode)
            if (getLevelCompleted(level: level)) {
                let imageNode2 = SKSpriteNode(imageNamed: "LevelComplete")
                imageNode2.position = CGPointMake(position.x + 14, position.y + 50)
                imageNode2.size = CGSize(width: 75, height: 100)
                addChild(imageNode2)
            } else {
                let text = SKLabelNode(text: String(level.uid + 1))
                text.position = CGPoint(x: position.x, y: position.y - 10)
                text.fontColor = UIColor.black
                text.fontName = "AvenirNext-Bold"
                text.fontSize = 40
                textNodes.append(text)
                addChild(text)
            }
        }
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
        initialTouchPosition = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }

        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        if initialTouchPosition != nil {
            let movement = initialTouchPosition!.y - location.y
            
            if movement > 20 {
                swipeDown()
                zoomAlphaOut()
                return
            } else if movement < -20 {
                swipeUp()
                zoomAlphaOut()
                return
            }
        }
        
        for node in touchedNodes {
            if node.name == "imageNode", let sprite = node as? SKSpriteNode {
                shrinkNode(sprite)
                centerOnNode(node: sprite)
                selectedPhase = imageNodes.firstIndex(of: sprite) ?? -1
            
                return
            }
            if node.name == "LevelInfoBox" && self.levelInfoText.text != "Locked Level" {
                currentLevel = selectedPhase
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
    
    private func zoomAlphaOut() {
        let zoomAction = SKAction.scale(to: 1, duration: 0.25) // Zoom in effect
        cameraNode.run(zoomAction)
        
        let alphaAction1 = SKAction.fadeAlpha(to: 0, duration: 0.25)
        levelInfoBG.run(alphaAction1)
        
        let alphaAction2 = SKAction.fadeAlpha(to: 0, duration: 0.25)
        levelInfoText.run(alphaAction1)
        
        resetAllNodes()
    }
    
    private func zoomOut() {

        let moveAction = SKAction.move(to: CGPoint(x: size.width / 2, y: getTargetY()), duration: 0.5)
        moveAction.timingMode = .easeInEaseOut // Smooth transition
        cameraNode.run(moveAction)
        
        zoomAlphaOut()
    }
    
    private func centerOnNode(node: SKSpriteNode) {
        //if (levels[selectedPhase].phase - 1) <= completedPhases {
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
                self.levelInfoText.text = self.levels[self.selectedPhase].title
                self.levelInfoBG.texture = SKTexture(imageNamed: "RoundedShadow")
                
                if(self.levels[self.selectedPhase].phase - 1) > self.completedPhases {
                    self.levelInfoText.text = "Locked Level"
                    self.levelInfoBG.texture = SKTexture(imageNamed: "BGSquareLocked")
                } else {
                    if(self.getLevelCompleted(level: self.levels[self.selectedPhase])) {
                        self.levelInfoBG.texture = SKTexture(imageNamed: "ReviewBG")
                    }
                }
                
                self.levelInfoBG.position = CGPoint(x: node.position.x - 140, y: node.position.y)
                self.levelInfoText.position = CGPoint(x: node.position.x - 210, y: node.position.y + 47)
                
                let alphaAction = SKAction.fadeAlpha(to: 1, duration: 0.25)
                self.levelInfoBG.run(alphaAction)
                
                let alphaActionSecondary = SKAction.fadeAlpha(to: 1, duration: 0.25)
                self.levelInfoText.run(alphaActionSecondary)
            }
        //}
    }
    
    private func getPositionForLevel(level: LevelNode) -> CGPoint {
        let basePos = imagePositions[level.uid]
        let height = 2 * UIScreen.main.bounds.height
        let yPos = CGFloat((level.phase - 1) * Int(height)) + basePos.y
        let xPos = basePos.x
        
        return CGPoint(x: xPos, y: yPos)
    }
}
