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
    let indata = stdin.availableData
    let s = NSString(data: indata, encoding: NSUTF8StringEncoding)
    if s == nil {
        return ""
    }
    return s!.stringByTrimmingCharactersInSet(lineCharset)
}

var client = ImClient()

func on_say(vs: [String]) {
}

func on_gay(vs: [String]) {
    client.sendGroupMessage(Int(vs[0])!, msgtype: Int(vs[2])!, msg: vs[1], cid: Int(vs[3])!)
}
