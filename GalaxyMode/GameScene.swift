//
//  GameScene.swift
//  GalaxyMode
//
//  Created by V.Sergeev on 13/04/2019.
//  Copyright © 2019 v.sergeev.m@icloud.com. All rights reserved.
//

import SpriteKit
import GameplayKit
// Добавляем библиотеку управления игроком через героскоп
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Новое меню для игры от 6/07/19
    var gameLogoMenu: SKLabelNode!
    // Луший результат(игрока)
    var bestScore: SKLabelNode!
    
    var playButton: SKShapeNode!
    
    // Отвечает за заднее поле экрана background animation
    var starfield:SKEmitterNode!
    // Создаем игрока, он не анимация а значет SKSpriteNode!
    var player:SKSpriteNode!
    // Создаем переменую под вывод текста на экране
    var scoreLabel:SKLabelNode!
    // Добавляем жизней для игрка
    var healthLabel:SKLabelNode!
    
    var score:Int = 0 {
        // добавляем текст на экран
        didSet {
            scoreLabel.text = "Счет: \(score)"
        }
    }
    
    // Добавляем 5 жизней игроку
    var health:Int = 5 {
        didSet {
            healthLabel.text = "Жизней: \(health)"
        }
    }
    
    // Добавляем переменную Time(таймер)
    // Нужна для создания врагов
    var gameTimer:Timer!
    
    // Добавляем врагов, выбираем кратинки из Assets.xcassets
    var enemis = ["alien", "alien2", "alien3"]
    
    // создаем уникальные идентификаторы для врагов
    let enemiCategory:UInt32 = 0x1 << 1
    // Создаем уникальные идентификаторы для пуль игрока
    let bulletCategory:UInt32 = 0x1 << 0
    // Обазаначем переменную для управления кораблем игрока в игре
    let motionManager = CMMotionManager()
    // Обазначаем для акселерометра 0
    var xAccelerate:CGFloat = 0
    
    let playerCategory:UInt32 = 0x1 << 1
    
    var game: GameManager!
    
    // Инициализация и загрузка всего проекта
    
    override func didMove(to view: SKView) {
        gameMenu()
        
        //game = GameManager()
    }
    
    private func gameMenu(){
        // создаем переменную анимации заднего поля(звезд)
        starfield = SKEmitterNode(fileNamed: "Starfield")
        // создаем позицию поля, расположение: 1472 покрывает площадь всех айфонов 6/7/8/10?
        starfield.position = CGPoint(x: 0, y: 1472)
        // создаем задержку для экрана, для отображения на экране всех звезд, а не первую анимацию появления
        starfield.advanceSimulationTime(10)
        // добавляем на экран звезды
        self.addChild(starfield)
        
        // устанваливаем наш фон так, чтобы он был всегда последним с низу слоев
        starfield.zPosition = -1
        
        // добавляем игрока
        player = SKSpriteNode(imageNamed: "shuttle")
        // Делаем адаптивное расположение нашего игрока по центру + 40 px от низа Y
        player.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: 40)
        
        self.addChild(player)
        
        // Не актуально из за CGPoint(x: UIScreen.main.bounds.width / 2, y: 40) - адаптивный дизайн
        // Увеличим размеры игрока, в два (2) раза
        //player.setScale(2)
        
        // добавление физики
        // отключаем гравитацию
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        // отслеживаем соприкосновения в игре, добавляем в class GameScene SKPhysicsContactDelegate
        self.physicsWorld.contactDelegate = self
        
        // Добавляем характеристики для scoreLabel
        scoreLabel = SKLabelNode(text: "Счет: 0")
        // Устанавливаем характеристики для шрифта можно найти по iOS fonts
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        // устанавливаем размер шрифта
        scoreLabel.fontSize = 36
        // устанавливаем цвет шрифта  - белый
        scoreLabel.fontColor = UIColor.white
        // устанавливаем позицию текста, берем выстоту и ширину экрана self.frame.size.height и отнимаем 60
        //scoreLabel.position = CGPoint(x: -200, y: self.frame.size.height - 100)
        //scoreLabel.position = CGPoint(x: -300, y: 625)
        // Aдаптивный дизайн
        scoreLabel.position = CGPoint(x: 100, y: UIScreen.main.bounds.height - 50)
        
        // обознаваем score как 0 при старте игры
        score = 0
        
        // Добавляем scoreLaberl на экран
        self.addChild(scoreLabel)
        
        
        // Добавляем жизни игроку
        healthLabel = SKLabelNode(text: "Жизней: 5")
        healthLabel.fontName = "AmericanTypewriter-Bold"
        //healthLabel.fontName = "ArialRoundedMTBold"
        healthLabel.fontSize = 36
        healthLabel.fontColor = UIColor.white
        healthLabel.position = CGPoint(x: 100, y: UIScreen.main.bounds.width  - 50)
        
        // обознаваем health для игрока как 5 при старте игры
        health = 5
        
        // Добавляем healthLabel на экран
        self.addChild(healthLabel)
        
        // Добавляем уровень сложности в игру
        var timeInterval = 0.75
        
        if UserDefaults.standard.bool(forKey: "hard") {
            timeInterval = 0.3
        }
        
        // Вызываем функцию и добавляем врага
        //          время появления                цель - себя   селектор отдельный объект      ниформация - нет  повторяющееся действие ? - да (true)
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addEnemi), userInfo: nil, repeats: true)
        
        // Время обновления
        motionManager.accelerometerUpdateInterval = 0.2
        // Добавляем параметры для обновления
        // Шаблонный метод для управления акселерометором на iPhone, для iPad нужно переработать
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, error: Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                // Плавное передвижение игрока на экране
                self.xAccelerate = CGFloat(acceleration.x) * 0.75 + self.xAccelerate * 0.25
            }
        }
    }
    
    private func initializeMenu(){
        
        gameLogoMenu = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        gameLogoMenu.zPosition = 1
        gameLogoMenu.position = CGPoint(x: 0, y: (frame.size.height / 2 ) - 200)
        gameLogoMenu.fontSize = 60
        gameLogoMenu.text = "Galaxy Mode"
        gameLogoMenu.fontColor = SKColor.red
        self.addChild(gameLogoMenu)
        
        bestScore = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        bestScore.zPosition = 1
        bestScore.position = CGPoint(x: 0, y: gameLogoMenu.position.y - 50)
        bestScore.fontSize = 40
        bestScore.text = "Best Score: 0"
        bestScore.fontColor = SKColor.white
        self.addChild(bestScore)
        
        playButton = SKShapeNode()
        playButton.name = "play_button"
        playButton.zPosition = 1
        playButton.position = CGPoint(x: 0, y: (frame.size.height / -2 ) + 200)
        playButton.fillColor = SKColor.cyan
        
        let topCorner = CGPoint(x: -50, y:50)
        let bottomCorner = CGPoint(x: -50, y: -50)
        let middle = CGPoint(x: 50, y: 0)
        let path = CGMutablePath()
        path.addLines(between: [topCorner])
        path.addLines(between: [topCorner, bottomCorner, middle])
        
        playButton.path = path
        self.addChild(playButton)
    }
    
    // Создаем функцию для вращения нашего играка, использовали для этого расчеты из motionManager.startAccelerometerUpdates
    override func didSimulatePhysics() {
        // добавляем скорость перемещения  игрока по экрану
        player.position.x += xAccelerate * 50
        // Создаем условия для перемещения игрока за рамками игры
        if player.position.x < 0 {
            // Создаем эффект появления игрока с другой стороны экрана, красивый эффект :)
            player.position = CGPoint(x: UIScreen.main.bounds.height - player.size.width, y: player.position.y)
        } else if player.position.x > UIScreen.main.bounds.width {
            // ТОжем самое, если игроко полетит в другую сторону
            player.position = CGPoint(x: 20, y: player.position.y)
        }
    }
    // Создаем функцию соприкосновения и отслеживания событий
    func didBegin(_ contact: SKPhysicsContact) {
        var enemiBody:SKPhysicsBody
        var bulletBody:SKPhysicsBody
        
        var playerBody:SKPhysicsBody
        
        // Создаем проверу столкновения пули и врага, делаем проверку
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            bulletBody  = contact.bodyA
            enemiBody   = contact.bodyB
        } else {
            bulletBody  = contact.bodyB
            enemiBody   = contact.bodyA
        }
        
        // Проверка на соприкосновение
        if (enemiBody.categoryBitMask & enemiCategory) != 0 && (bulletBody.categoryBitMask & bulletCategory) != 0 {
            collisionElements(bulletNode: bulletBody.node as! SKSpriteNode, enemiNode: enemiBody.node as! SKSpriteNode)
        }
        
        //----------------------------------------------------------------------------------------------------------------
        
        // Создаем проверу столкновения игрока и врага, делаем проверку
        if contact.bodyA.categoryBitMask < contact.bodyA.categoryBitMask {
            playerBody = contact.bodyA
            enemiBody = contact.bodyB
        } else {
            playerBody = contact.bodyB
            enemiBody = contact.bodyA
        }
        
        if (playerBody.categoryBitMask & playerCategory) != 0 && (playerBody.categoryBitMask & playerCategory) != 0{
            damageToPlayer(playerNode: playerBody.node as! SKSpriteNode, enemiNode: enemiBody.node as! SKSpriteNode)
        }
    }
    
    // Элименты столкнулись, проигрываем ситуацию
    func collisionElements(bulletNode:SKSpriteNode, enemiNode:SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "Vzriv")
        // Создаем где должен произойти взрыв, в нашем случае это на месте врага
        explosion?.position = enemiNode.position
        self.addChild(explosion!)
        
        // Добавляем звук
        //self.run(SKAction.playSoundFileNamed("vzriv.mp3", waitForCompletion: false))
        
        // После взрыва удаляем все объекты - пулю и врага
        bulletNode.removeFromParent()
        enemiNode.removeFromParent()
        
        // Делаем задержку для анимации
        self.run(SKAction.wait(forDuration: 2)) {
            explosion?.removeFromParent()
        }
        
        // добавляем баллы за уничтожение врагов
        score += 5
    }
    
    // Столкновение игрока и врага
    func damageToPlayer(playerNode:SKSpriteNode, enemiNode:SKSpriteNode) {
        let damage = SKEmitterNode(fileNamed: "Vzriv")
        damage?.position = playerNode.position
        self.addChild(damage!)
        
        self.run(SKAction.playSoundFileNamed("vzriv.mp3", waitForCompletion: false))
        
        enemiNode.removeFromParent()
        
        health = -1
    }
    
    @objc func addEnemi() {
        // Добавляем случайного врага из трех вариантов
        enemis = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: enemis) as! [String]
        
        // Создаем картинку врага на экране
        let enemi = SKSpriteNode(imageNamed: enemis[0])
        // Создаем коордианты появления врагов
        let randomPos = GKRandomDistribution(lowestValue: 20, highestValue: Int(UIScreen.main.bounds.size.width - 20))
        // Конвертируем все в CGFloat
        let pos = CGFloat(randomPos.nextInt())
        
        // создаем противника за экраном - реализовываем адаптив
        enemi.position = CGPoint(x: pos, y: UIScreen.main.bounds.size.height + enemi.size.height)
        
        /// Не актуально из за CGPoint(x: UIScreen.main.bounds.width / 2, y: 40) - адаптивный дизайн
        // Увеличим размеры наших врагов, в два (2) раза
        //enemi.setScale(2)
        
        // Добавляем физику для врагов, попаданя в них и т.д
        //                                             указываем физический размер врага
        enemi.physicsBody = SKPhysicsBody(rectangleOf: enemi.size)
        // Остлеживаем соприкосновения
        enemi.physicsBody?.isDynamic = true
        
        enemi.physicsBody?.categoryBitMask = enemiCategory
        enemi.physicsBody?.contactTestBitMask = bulletCategory
        enemi.physicsBody?.collisionBitMask = 0
        
        self.addChild(enemi)
        
        // Добавляем скорость появления врагов
        let animationDuration:TimeInterval = 6
        
        // Удаляем врагов ушедших за игравой экран
        var actions = [SKAction]()
        // Отнимаем высоту от экрана врага 0 - enemi.size.height
        actions.append(SKAction.move(to: CGPoint(x: pos, y: 0 - enemi.size.height), duration: animationDuration))
        // Удаляем объект
        actions.append(SKAction.removeFromParent())
        
        // какой массив будем проигрыать - actions
        enemi.run(SKAction.sequence(actions))
    }
    
    // Создаем функцию нажатия на экран и вызываем выстрел функцию fireBulle()
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireBulle()
    }
    
    // Создаем функцию игровой пули от игрока
    func fireBulle() {
        // Создаем звук, просто звук далее ничего не выполняем - waitForCompletion: false
        self.run(SKAction.playSoundFileNamed("vzriv.mp3", waitForCompletion: false))
        
        // Вызываем изображение нашей пули
        let bullet = SKSpriteNode(imageNamed: "torpedo")
        // Создаем выстрел из позиции игрока, привязываем к модели игрока
        bullet.position = player.position
        // Выстрел появляется чуть выше игрока
        bullet.position.y += 5
        
        // Добавляем физику для пули, попаданя в них и т.д
        //                                             указываем физический размер пули, в нашем случае это круг - circleOfRadius
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2)
        // Остлеживаем соприкосновения
        bullet.physicsBody?.isDynamic = true
        
        // Указываем что пуля попадает по врагам bulletCategory => enemiCategory
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = enemiCategory
        bullet.physicsBody?.collisionBitMask = 0
        // Отслеживаем выстрел, соприкосновения с другим объектом, указываем как true(да)
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(bullet)
        
        // Добавляем скорость полета пули
        let animationDuration:TimeInterval = 0.3
        
        // Удаляем пулю ушедшую за игравой экран
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: player.position.x, y: UIScreen.main.bounds.height + bullet.size.height), duration: animationDuration))
        // Удаляем пулю
        actions.append(SKAction.removeFromParent())
        
        // какой массив будем проигрыать - actions
        bullet.run(SKAction.sequence(actions))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = self.nodes(at: location)
            for node in touchedNode {
                if node.name == "player_button" {
                    startGame()
                }
            }
        }
    }
    
    private func startGame() {
        print("Start game")
        
        gameLogoMenu.run(SKAction.move(by: CGVector(dx: -50, dy: 600), duration: 0.5)){
            self.gameLogoMenu.isHidden = true
        }
        
        playButton.run(SKAction.scale(to: 0, duration: 0.3)) {
            self.playButton.isHidden = true
        }
        
        let bottomCorner = CGPoint(x: 0, y: (frame.size.height / -2) + 20)
        bestScore.run(SKAction.move(to: bottomCorner, duration: 0.4))
    }
}
