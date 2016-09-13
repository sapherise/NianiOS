//
//  GameScene.swift
//  Nian iOS
//
//  Created by Sa on 15/7/21.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation
import SpriteKit

class GameScene: SKScene {
    func setupViews() {
        let star = StarEmitter.emitternode()
        star.particlePosition = CGPoint(x: self.frame.width/2, y: 0)
        self.addChild(star)
    }
}

extension SKNode {
    class func unarchiveFromFile(_ file : String) -> SKNode? {
        if let path = Bundle.main.path(forResource: file, ofType: "sks") {
            let sceneData = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let archiver = NSKeyedUnarchiver(forReadingWith: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class StarEmitter: SKEmitterNode {
    class func emitternode() -> SKEmitterNode {
        let untypedEmitter : AnyObject = NSKeyedUnarchiver.unarchiveObject(withFile: Bundle.main.path(forResource: "star", ofType: "sks")!)! as AnyObject;
        return untypedEmitter as! SKEmitterNode
    }
}
