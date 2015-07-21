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
        var star = StarEmitter.emitternode()
        star.particlePosition = CGPointMake(self.frame.width/2, 0)
        self.addChild(star)
    }
}

extension SKNode {
    class func unarchiveFromFile(file : String) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class StarEmitter: SKEmitterNode {
    class func emitternode() -> SKEmitterNode {
        let untypedEmitter : AnyObject = NSKeyedUnarchiver.unarchiveObjectWithFile(NSBundle.mainBundle().pathForResource("star", ofType: "sks")!)!;
        return untypedEmitter as! SKEmitterNode
    }
}