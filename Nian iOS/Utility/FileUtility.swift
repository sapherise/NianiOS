//
//  ViewController.swift
//  Nian iOS
//
//  Created by Sa on 14-7-7.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit

class FileUtility: NSObject {
   
    
    class func cachePath(fileName:String)->String
    {
      var arr =  NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
       let path = arr[0] 
        return "\(path)/\(fileName)"
    }
    
    
    class func imageCacheToPath(path:String,image:NSData)->Bool
    {
        return image.writeToFile(path, atomically: true)
    }
    
    class func imageDataFromPath(path:String)->AnyObject
    {
       let exist = NSFileManager.defaultManager().fileExistsAtPath(path)
        if exist {
          let image = UIImage(contentsOfFile: path)
            if image != nil {
                return image!
            }
        }
        
        return NSNull()
    }
    
    
    
    
}
