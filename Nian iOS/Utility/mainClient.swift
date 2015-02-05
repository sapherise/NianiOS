//
//  main.swift
//  imclient
//
//  Created by vizee on 15/1/5.
//  Copyright (c) 2015年 nian. All rights reserved.
//

import Foundation

class Handler {
    var values: [String]
    var params: [String]
    var handle: [String] -> Void
    
    init(p: [String], f: [String] -> Void) {
        params = p
        handle = f
        values = [String]()
        for var i = 0; i < params.count; i++ {
            values.append("")
        }
    }
    
    func clear() {
        for var i = 0; i < values.count; i++ {
            values[i] = ""
        }
    }
}

let stdin = NSFileHandle.fileHandleWithStandardInput()
let stdout = NSFileHandle.fileHandleWithStandardOutput()
let lineCharset = NSCharacterSet.newlineCharacterSet()

func readline(tip: String) -> String {
    print(tip)
    var indata = stdin.availableData
    var s = NSString(data: indata, encoding: NSUTF8StringEncoding)
    if s == nil {
        return ""
    }
    return s!.stringByTrimmingCharactersInSet(lineCharset)
}

var client = ImClient()

func on_say(vs: [String]) {
}

func on_gay(vs: [String]) {
    var r: AnyObject? = client.sendGroupMessage(vs[0].toInt()!, msgtype: vs[2].toInt()!, msg: vs[1], cid: vs[3].toInt()!)
    if r == nil {
        return
    }
}
