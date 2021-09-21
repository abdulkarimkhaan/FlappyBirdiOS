//
//  GameScene.swift
//  BasicGame
//
//  Created by Fawad Hasan on 9/6/21.
//  Copyright © 2021 Fawad Hasan. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    var bird = SKSpriteNode()
    var background = SKSpriteNode()
    var labelScore = SKLabelNode()
    var button = SKSpriteNode()
    var gameOver = false
    var score = 0
    
    enum ColliderType: UInt32 {
        case Bird = 2
        case Object = 4
        case Gap = 0
    }
    
    override func didMove(to view: SKView) {
        SKTAudio.sharedInstance().playBackgroundMusic("background-game.mp3") // Start the music
        self.physicsWorld.contactDelegate = self
        self.setupGround()
        self.setupBackground()
        self.setupBird()
        self.spawnAndThenDelayPipes()
        self.setupScore()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
            self.score += 1
            self.labelScore.text = "\(self.score)"
        }else{
            print("Game Over")
            self.viewGameOver()
            SKTAudio.sharedInstance().pauseBackgroundMusic() // Pause the music
            self.viewRestartGame()
            self.gameOver = true
            self.speed = 0
            
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameOver {
            let birdWingsUp = SKTexture(imageNamed: "flappy1.png")
            bird.physicsBody = SKPhysicsBody(circleOfRadius: birdWingsUp.size().height/2)
            bird.physicsBody!.isDynamic = true
            bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 30))
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Loop over all the touches in this event
        for touch in touches {
            // Get the location of the touch in this scene
            let location = touch.location(in: self)
            // Check if the location of the touch is within the button's bounds
            if button.contains(location) {
                let newScene = GameScene(size: self.size)
                newScene.scaleMode = self.scaleMode
                let animation = SKTransition.fade(withDuration: 1.0)
                self.view?.presentScene(newScene, transition: animation)                }
        }
    }
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
    }
}

//MARK:- Helper Method
extension GameScene {
    func viewGameOver(){
        let gifGameOver = SKTexture(imageNamed: "gameOver.gif")
        let gifNode = SKSpriteNode(texture: gifGameOver)
        self.gameOver = true
        gifNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 50)
        gifNode.zPosition = 10
        self.addChild(gifNode)
    }
    func viewRestartGame(){
        self.button = SKSpriteNode(imageNamed: "icon-restart")
        self.button.name = "btn-restart"
        self.button.size.height = 100
        self.button.size.width = 100
        self.button.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 50)
        self.button.zPosition = 10
        self.addChild(button)
    }
    func spawnAndThenDelayPipes(){
        let spawn = SKAction.run(self.setupPipeTexture)
        let delay = SKAction.wait(forDuration: TimeInterval(2.0))
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnThenDelayForever = SKAction.repeatForever(spawnThenDelay)
        self.run(spawnThenDelayForever)
    }
    func setupGround(){
        let ground = SKNode()
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height/2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        self.addChild(ground)
    }
    
    func setupBackground(){
        let bgTexture = SKTexture(imageNamed: "bg.png")
        
        let moveBgAnimation = SKAction.move(by: CGVector(dx: -bgTexture.size().width, dy: 0), duration: 7)
        let shiftBgAnimation = SKAction.move(by: CGVector(dx: bgTexture.size().width, dy: 0), duration: 0)
        let backgroundAnimationRunForever = SKAction.repeatForever(SKAction.sequence([moveBgAnimation, shiftBgAnimation]))
        
        //more than one background
        var i = 0
        while i < 3 {
            background = SKSpriteNode(texture: bgTexture)
            background.position = CGPoint(x: (bgTexture.size().width * CGFloat(i)), y: self.frame.midY)
            background.size.height = self.frame.height
            background.size.width = self.frame.width
            background.zPosition = -1
            background.run(backgroundAnimationRunForever)
            self.addChild(background)
            i+=1
        }
    }
    func setupBird(){
        let birdWingsUp = SKTexture(imageNamed: "flappy1.png")
        let birdWingsDown = SKTexture(imageNamed: "flappy2.png")
        
        let animation = SKAction.animate(with: [birdWingsUp, birdWingsDown], timePerFrame: 0.3)
        let makeBirdFlap = SKAction.repeatForever(animation)
        
        bird = SKSpriteNode(texture: birdWingsUp)
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        bird.run(makeBirdFlap)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdWingsUp.size().height/2)
        bird.physicsBody?.isDynamic = false
        bird.physicsBody?.allowsRotation = false
        
        bird.physicsBody?.categoryBitMask = ColliderType.Bird.rawValue
        bird.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue | ColliderType.Gap.rawValue
        bird.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        self.addChild(bird)
    }
    
    func setupPipeTexture(){
        let gapHeight = self.bird.size.height * 4
        
        let pipe1Texture = SKTexture(imageNamed: "pipe1.png")
        let pipe2Texture = SKTexture(imageNamed: "pipe2.png")
        
        let pipe1Node = SKSpriteNode(texture: pipe1Texture)
        let pipe2Node = SKSpriteNode(texture: pipe2Texture)
        
        let movementAmount = arc4random() % UInt32((self.frame.height/2)-gapHeight) // 0 and half the frame height
        let pipeOffset = CGFloat(movementAmount) - self.frame.height/4
        
        let movePipe = SKAction.move(by: CGVector(dx: -2 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width/100))
        let removePipes = SKAction.removeFromParent()
        
        let moveAndRemovePipe = SKAction.sequence([movePipe, removePipes])
        
        pipe1Node.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipe1Texture.size().height/2 + gapHeight/2 + pipeOffset)
        pipe1Node.run(moveAndRemovePipe)
        pipe2Node.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - pipe2Texture.size().height/2 - gapHeight/2 + pipeOffset)
        pipe2Node.run(moveAndRemovePipe)
        
        pipe1Node.physicsBody = SKPhysicsBody(rectangleOf: pipe1Texture.size())
        pipe1Node.physicsBody?.isDynamic = false
        pipe2Node.physicsBody = SKPhysicsBody(rectangleOf: pipe2Texture.size())
        pipe2Node.physicsBody?.isDynamic = false
        
        pipe1Node.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        pipe1Node.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        pipe1Node.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        
        pipe2Node.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue
        pipe2Node.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        pipe2Node.physicsBody?.collisionBitMask = ColliderType.Object.rawValue
        
        self.addChild(pipe1Node)
        self.addChild(pipe2Node)
        
        //GAP Node
        
        let gap = SKNode()
        gap.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeOffset)
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 0.001, height: gapHeight))
        gap.physicsBody!.isDynamic = false
        gap.run(moveAndRemovePipe)
        
        gap.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue
        gap.physicsBody!.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody!.collisionBitMask = 0//ColliderType.Gap.rawValue
        
        self.addChild(gap)
    }
    func setupScore(){
        self.labelScore.text = "0"
        self.labelScore.fontSize = 60
        self.labelScore.fontName = "Helvetica"
        self.labelScore.fontColor = .white
        self.labelScore.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - 150)
        self.labelScore.zPosition = 4
        self.addChild(self.labelScore)
    }
}
