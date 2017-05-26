import SpriteKit

class GameScene: SKScene {
    let hero = SKSpriteNode(imageNamed: "Spaceship")
    let obstacle = SKSpriteNode(imageNamed: "obstacle")
    let astronaut = SKSpriteNode(imageNamed: "astronaut")
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    let heroMovePointsPerSec: CGFloat = 200.0
    var velocity = CGPoint.zero
    let playableRect: CGRect

    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0 // 1
        let playableHeight = size.width / maxAspectRatio // 2
        let playableMargin = (size.height-playableHeight)/2.0 // 3
        playableRect = CGRect(x: 0, y: playableMargin,
                              width: size.width,
                              height: playableHeight) // 4
        super.init(size: size) // 5
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // 6
    }


    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        hero.position = CGPoint (x: size.width/2, y: size.height/2)
        hero.setScale(0.33)
        hero.name = "hero"

        addChild(hero)
        //spawnObstacle()
        spawnAstronaut()

        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
                self?.spawnObstacle()
                },
                               SKAction.wait(forDuration: 2.0)])))

        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
                self?.spawnAstronaut()
                },
                               SKAction.wait(forDuration: 10.0)])))


    }


    override func update(_ currentTime: TimeInterval){
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime


        move(sprite: hero, velocity: velocity)
        boundsCheckHero()

        rotate(sprite: hero, direction: velocity)
        checkCollisions()
    }

    func move (sprite: SKSpriteNode, velocity: CGPoint) {
        //1
        let amountToMove = CGPoint(x: velocity.x * CGFloat(dt),
                                   y: velocity.y * CGFloat(dt))
        //print("Amount to move: \(amountToMove)")
        sprite.position += amountToMove
    }

    func MoveHeroToward(location: CGPoint) {
        let offset = location - hero.position
        let direction = offset.normalized()
        velocity = direction * heroMovePointsPerSec
        //use some type of friction here
    }

    //MARK: TOUCH EVENTS
    func sceneTouched (touchLocation:CGPoint){
        MoveHeroToward(location: touchLocation)
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation:
        touchLocation)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation:
            touchLocation)
    }

    func boundsCheckHero() {
        let bottomLeft = CGPoint(x: 0, y: playableRect.minY)
        let topRight = CGPoint(x: size.width, y: playableRect.maxY)

        //reverses the velocity of the hero when a bound is hit

        if hero.position.x <= bottomLeft.x {
            hero.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if hero.position.x >= topRight.x {
            hero.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if hero.position.y <= bottomLeft.y {
            hero.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if hero.position.y >= topRight.y {
            hero.position.y = topRight.y
            velocity.y = -velocity.y
        } 
    }

    func rotate(sprite: SKSpriteNode, direction: CGPoint) {
        sprite.zRotation = direction.angle
        print (sprite.zRotation)
    }

    func spawnObstacle() {
        let obstacle = SKSpriteNode(imageNamed: "obstacle")
        obstacle.name = "obstacle"
        obstacle.setScale(2.0)
        obstacle.position = CGPoint(
            x: size.width + obstacle.size.width/2,
            y: CGFloat.random(
                min: playableRect.minY + obstacle.size.height/2,
                max: playableRect.maxY - obstacle.size.height/2))
        addChild(obstacle)

        let actionMove =
            SKAction.moveTo(x: -obstacle.size.width/2, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        obstacle.run(SKAction.sequence([actionMove, actionRemove]))
//
    }

    func spawnAstronaut() {
        let astronaut = SKSpriteNode(imageNamed: "astronaut")
        astronaut.name = "astronaut"
        astronaut.position = CGPoint(
            x: CGFloat.random(
                min: playableRect.minY + obstacle.size.height/2,
                max: playableRect.maxY - obstacle.size.height/2),
            y: CGFloat.random(
                min: playableRect.minY + obstacle.size.height/2,
                max: playableRect.maxY - obstacle.size.height/2))
        astronaut.setScale(3.0)
        addChild(astronaut)

    }
    //MARK: COLLISION DETECTION

    func heroHit(obstacle: SKSpriteNode){
        obstacle.removeFromParent()
    }

    func heroHit(astronaut: SKSpriteNode){
        astronaut.removeFromParent()
    }

    func checkCollisions(){
        var hitObstacles: [SKSpriteNode] = []
        var hitAstronaut: [SKSpriteNode] = []

        enumerateChildNodes(withName: "obstacle"){node, _ in
            let obstacle = node as! SKSpriteNode
            if node.frame.insetBy(dx: 20, dy: 30).intersects(self.hero.frame){
                hitObstacles.append(obstacle)
            }
        }

        for obstacle in hitObstacles {
            heroHit(obstacle: obstacle)
        }

        enumerateChildNodes(withName: "astronaut"){node, _ in
            let astronaut = node as! SKSpriteNode
            if node.frame.insetBy(dx: 20, dy: 30).intersects(self.hero.frame){
                hitAstronaut.append(astronaut)
            }
        }

        for astronaut in hitAstronaut {
            heroHit(obstacle: astronaut)
        }
}
}
