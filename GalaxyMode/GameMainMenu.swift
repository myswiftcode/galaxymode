//
//  GameMainMenu.swift
//  GalaxyMode
//
//  Created by V.Sergeev on 14/04/2019.
//  Copyright © 2019 v.sergeev.m@icloud.com. All rights reserved.
//

import SpriteKit

class GameMainMenu: SKScene {
    //
    var starfield:SKEmitterNode!
    //
    var newGameBtnNode:SKSpriteNode!
    var levelBtnNode:SKSpriteNode!
    var labelLevelNode:SKLabelNode!
    
    // Добавляем +10 секунд для сцены меню
    override func didMove(to view: SKView) {
        
        // Обращаемся
        starfield = self.childNode(withName: "starfieldMenu") as? SKEmitterNode
        // Ставим анимацию в меню начиная с 10 секунд
        starfield.advanceSimulationTime(10)
        
        // Привязываем кнопки меню к коду
        newGameBtnNode = self.childNode(withName: "junior") as? SKSpriteNode
        //newGameBtnNode.texture = SKTexture("название картинки")
        levelBtnNode = self.childNode(withName: "proff") as? SKSpriteNode
        //levelBtnNode = self.childNode(withName: "proff") as? SKSpriteNode
        
        // При перезаходе сохраняем текст для игрока
        let userLevel = UserDefaults.standard
        if userLevel.bool(forKey: "hard") {
            labelLevelNode.text = "Профи"
        } //else {
            //labelLevelNode.text = "Новичок"
        //}
    }
    
    // Отслеживаем нажатие пользователя на экране
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //
        let touch = touches.first
        // Отслеживаем нажатие в этом же файле
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            // Создаем проверку
            if nodesArray.first?.name == "junior" {
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                // Создаем адаптивный дизайн игры
                let gameScene = GameScene(size: UIScreen.main.bounds.size)
                self.view?.presentScene(gameScene, transition: transition)
                // Проверяем уровень игры, если выбран не junior то создаем инсту для proff
            } else if nodesArray.first?.name == "junior" {
                // обращаемся к функции
                changeLevel()
            }
        }
    }
    
    func changeLevel() {
        // Создаем переменную которая сохраняется в ячейки памяти устройства
        let userLevel = UserDefaults.standard
        
        if labelLevelNode.text == "Новичок" {
            labelLevelNode.text = "Профи"
            userLevel.set(true, forKey: "hard")
        } else {
            labelLevelNode.text = "Новичок"
            userLevel.set(false, forKey: "hard")
        }
        // Создаем синхронизацию для всех уровней
        userLevel.synchronize()
    }
}
