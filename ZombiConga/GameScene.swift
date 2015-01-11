//
//  GameScene.swift
//  ZombiConga
//
//  Created by Johannes Boehm on 24.11.14.
//  Copyright (c) 2014 Johannes Boehm. All rights reserved.
//

import SpriteKit
class GameScene: SKScene {
    
    let zombie: SKSpriteNode = SKSpriteNode(imageNamed: "zombie1")
    
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    let zombieMovePointsPerSec: CGFloat = 480.0
    let zombieRotateRadiansPerSec:CGFloat = 4.0 * π
    var velocity = CGPointZero
    
    let playableRect: CGRect
    
    var lastTouchLocation: CGPoint?
    
    
    
    override func didMoveToView(view: SKView) {
    
        backgroundColor = SKColor.whiteColor()
    
        let background = SKSpriteNode(imageNamed: "background1")
        background.anchorPoint = CGPointZero
        background.position = CGPointZero
        background.zPosition = -1
        addChild(background)
        
        zombie.position = CGPoint(x: 400, y: 400)
        //player.setScale(2)
        addChild(zombie)
        
        debugDrawPlayableArea()
    
    }
    
    
    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0 // 1
        let playableHeight = size.width / maxAspectRatio // 2
        let playableMargin = (size.height-playableHeight)/2.0 // 3 
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight) // 4 
        super.init(size: size) // 5
    }
    
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // 6
    }
    
    
// UPDATE LOOP
    override func update(currentTime: NSTimeInterval) {
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else { dt = 0 }
        
        lastUpdateTime = currentTime
        
        if let lastTouch = lastTouchLocation {
            var diff = lastTouch - zombie.position
            if (diff.length() <= zombieMovePointsPerSec * CGFloat(dt)) {
                zombie.position = lastTouchLocation!
                velocity = CGPointZero
            } else {
                moveSprite(zombie, velocity: velocity)
                rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
                
            }
        }
        
        boundsCheckZombie()
    }
    
    
// MOVEMENTS
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
            let amountToMove = velocity * CGFloat(dt)
            //println("Amount to move: \(amountToMove)")
            sprite.position += amountToMove
    }
    
    
    
    func moveZombieToward(location: CGPoint) {
            let offset = location - zombie.position
            let length = sqrt(Double(offset.x * offset.x + offset.y * offset.y))
            let direction = offset / CGFloat(length)
            velocity = direction * zombieMovePointsPerSec
    }
    
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        let shortest = shortestAngleBetween(sprite.zRotation, velocity.angle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    
    
// TOUCH EVENTS
    func sceneTouched(touchLocation:CGPoint) {
        lastTouchLocation = touchLocation
        moveZombieToward(touchLocation)
    }
    
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    
    
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    
    
// CHECK BOUNDS
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
        let topRight = CGPoint(x: size.width, y: CGRectGetMaxY(playableRect))
        
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        
        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
                                            
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
                                            
        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }

// DEBUG
    func debugDrawPlayableArea() {
            let shape = SKShapeNode()
            let path = CGPathCreateMutable()
            CGPathAddRect(path, nil, playableRect)
            shape.path = path
            shape.strokeColor = SKColor.redColor()
            shape.lineWidth = 4.0
            addChild(shape)
    }
    
    
    
}


