//
//  ViewController.swift
//  Nian iOS
//
//  Created by Sa on 14-7-7.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit

class FileUtility: NSObject {
   
    
    class func cachePath(_ fileName:String)->String
    {
      var arr =  NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
       let path = arr[0] 
        return "\(path)/\(fileName)"
    }
    
    
    class func imageCacheToPath(_ path:String,image:Data)->Bool
    {
        return ((try? image.write(to: URL(fileURLWithPath: path), options: [.atomic])) != nil)
    }
    
    class func imageDataFromPath(_ path:String)->AnyObject
    {
       let exist = FileManager.default.fileExists(atPath: path)
        if exist {
          let image = UIImage(contentsOfFile: path)
            if image != nil {
                return image!
            }
        }
        
        return NSNull()
    }
    
    
    
    
}
