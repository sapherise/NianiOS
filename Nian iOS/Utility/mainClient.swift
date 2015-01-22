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

func output<T>(o: T) {
    //stdout.writeData(("\(o)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!))
    print("\(o)")
}

func outputln<T>(o: T) {
    // stdout.writeData(("\(o)\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!))
    println("\(o)")
}

func readline(tip: String) -> String {
    output(tip)
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
    var r: AnyObject? = client.sendGroupMessage(vs[0].toInt()!, msgtype: 0, msg: vs[1])
    if r == nil {
        return
    }
    var s = r!["status"]
    outputln("on_gay \(r)")
}

//func main() {
//    var cmds = [String: Handler]()
//    cmds["enter"] = Handler(p: ["uid", "shell"], f: on_enter)
//    cmds["say"] = Handler(p: ["id", "what"], f: on_say)
//    cmds["gay"] = Handler(p: ["gid", "what"], f: on_gay)
//    while true {
//        var cmd = readline("cmd>")
//        if cmd == "quit" {
//            outputln("!!quit")
//            break
//        }
//        var v = cmds[cmd]
//        if v == nil {
//            outputln("!!bad cmd")
//            continue
//        }
//        v!.clear()
//        var interrupt = false
//        for var i = 0; i < v!.params.count; i++ {
//            var s = readline(v!.params[i] + ":")
//            if s == "int3" {
//                interrupt = true
//                break
//            }
//            v!.values[i] = s
//        }
//        if interrupt {
//            outputln("!!interrupted")
//            continue
//        }
//        v!.handle(v!.values)
//    }
//}
