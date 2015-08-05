//
//  SQL.swift
//  Nian iOS
//
//  Created by Sa on 15/2/6.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation

// MARK: - 创建梦境表
func SQLCreateCircleList() {
    SD.executeChange("CREATE TABLE if not exists `circlelist` ( `id` INTEGER PRIMARY KEY AUTOINCREMENT, `circleid` INT NOT NULL , `title` VARCHAR(255) NULL , `image` VARCHAR(255) NULL, `postdate` MEDIUMINT NOT NULL, `owner` VARCHAR(255) NULL)")
    let (indexes, err) = SD.existingIndexesForTable("circlelist")
    if indexes.count == 0 {
        SD.createIndex(name: "circleid", onColumns: ["circleid"], inTable: "circlelist", isUnique: false)
    }
}

// MARK: - 创建梦境内容表
func SQLCreateCircleContent() {
    SD.executeChange("CREATE TABLE if not exists `circle` ( `id` INTEGER PRIMARY KEY AUTOINCREMENT, `msgid` INT NOT NULL , `uid` INT NOT NULL , `name` VARCHAR(255) NULL , `cid` INT NOT NULL , `cname` VARCHAR(255) NULL , `circle` INT NOT NULL , `content` TEXT NULL , `title` VARCHAR(255) NULL , `type` INT NOT NULL , `lastdate` MEDIUMINT NOT NULL, `isread` INT NOT NULL, `owner` VARCHAR(255) NULL)")
    let (indexes, err) = SD.existingIndexesForTable("circle")
    if indexes.count == 0 {
        SD.createIndex(name: "msgid", onColumns: ["msgid"], inTable: "circle", isUnique: false)
    }
}

// MARK: - 创建私信内容表
func SQLCreateLetterContent() {
    SD.executeChange("CREATE TABLE if not exists `letter` ( `id` INTEGER PRIMARY KEY AUTOINCREMENT, `msgid` INT NOT NULL , `uid` INT NOT NULL , `name` VARCHAR(255) NULL , `circle` INT NOT NULL , `content` TEXT NULL , `type` INT NOT NULL , `lastdate` MEDIUMINT NOT NULL, `isread` INT NOT NULL, `owner` VARCHAR(255) NULL)")
    let (indexes, err) = SD.existingIndexesForTable("letter")
    if indexes.count == 0 {
        SD.createIndex(name: "lettermsgid", onColumns: ["msgid"], inTable: "letter", isUnique: false)
    }
}

// MARK: - 创建进展表
func SQLCreateStepContent() {
    SD.executeChange("CREATE TABLE if not exists `step` ( `id` INTEGER PRIMARY KEY AUTOINCREMENT, `sid` INT NOT NULL , `uid` INT NOT NULL , `dream` INT NOT NULL , `content` VARCHAR(255) NULL , `img` VARCHAR(255) NULL , `img0` VARCHAR(255) NULL , `img1` VARCHAR(255) NULL)")
    let (indexes, err) = SD.existingIndexesForTable("step")
    if indexes.count == 0 {
        SD.createIndex(name: "sid", onColumns: ["sid"], inTable: "step", isUnique: false)
    }
}

// MARK: - 创建所有表
func SQLInit() {
    SQLCreateCircleList()
    SQLCreateCircleContent()
    SQLCreateLetterContent()
    SQLCreateStepContent()
}

// MARK: - 插入一条梦境
func SQLCircleListInsert(id: String, title: String, image: String, postdate: String) {
    var uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
    var safeuid = uidKey.objectForKey(kSecAttrAccount) as! String
//    var safeshell = uidKey.objectForKey(kSecValueData) as! String
    
    let (resultSet2, err2) = SD.executeQuery("select id from circlelist where circleid = '\(id)' and owner = '\(safeuid)' limit 1")
    if err2 == nil {
        if resultSet2.count == 0 {
            SD.executeChange("INSERT INTO circlelist (id, circleid, title, image, postdate, owner) VALUES (null, ?, ?, ?, ?, ?)", withArgs: [id, title, image, postdate, safeuid])
        }else{
            SD.executeChange("update circlelist set title = ?, image = ? where circleid='\(id)' and owner = '\(safeuid)'", withArgs: [title, image])
        }
    }
}

// MARK: - 插入梦境聊天内容
func SQLCircleContent(id: String, uid: String, name: String, cid: String, cname: String, circle: String, content: String, title: String, type: String, time: String, isread: Int, callback: Void -> Void) {
    var uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
    var safeuid = uidKey.objectForKey(kSecAttrAccount) as! String
//    var safeshell = uidKey.objectForKey(kSecValueData) as! String
    
    let (result, err) = SD.executeQuery("select id from circle where msgid = '\(id)' and owner = '\(safeuid)' limit 1")
    if result.count == 0 {
        if let err = SD.executeChange("INSERT INTO circle (id, msgid, uid, name, cid, cname, circle, content, title, type, lastdate, isread, owner) VALUES (null, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", withArgs: [id, uid, name, cid, cname, circle, content, title, type, time, isread, safeuid]) {
        } else {
            callback()
        }
    }
}


// MARK: - 插入进展
func SQLStepContent(sid: String, uid: String, dream: String, content: String, img: String, img0: String, img1: String, callback: Void -> Void) {
    var uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
    var safeuid = uidKey.objectForKey(kSecAttrAccount) as! String
//    var safeshell = uidKey.objectForKey(kSecValueData) as! String
    
    let (result, err) = SD.executeQuery("select sid from step where sid = '\(sid)' limit 1")
    if result.count == 0 {
        if let err = SD.executeChange("INSERT INTO step (id, sid, uid, dream, content, img, img0, img1) VALUES (null, ?, ?, ?, ?, ?, ?, ?)", withArgs: [sid, uid, dream, content, img, img0, img1]) {
        } else {
            callback()
        }
    }
}

// MARK: - 删除梦境
func SQLCircleListDelete(id: String) {
    var uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
    var safeuid = uidKey.objectForKey(kSecAttrAccount) as! String
//    var safeshell = uidKey.objectForKey(kSecValueData) as! String
    
    SD.executeChange("delete from circlelist where circleid=? and owner = ?", withArgs: [id, safeuid])
    SD.executeChange("delete from circle where circle=? and owner = ?", withArgs: [id, safeuid])
}

// MARK: - 插入私信内容
func SQLLetterContent(id: String, uid: String, name: String, circle: String, content: String, type: String, time: String, isread: Int, callback: Void -> Void) {
    var uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
    var safeuid = uidKey.objectForKey(kSecAttrAccount) as! String
//    var safeshell = uidKey.objectForKey(kSecValueData) as! String
    
    let (result, err) = SD.executeQuery("select id from letter where msgid = '\(id)' and owner = '\(safeuid)' limit 1")
    if result.count == 0 {
        if let err = SD.executeChange("INSERT INTO letter (id, msgid, uid, name, circle, content, type, lastdate, isread, owner) VALUES (null, ?, ?, ?, ?, ?, ?, ?, ?, ?)", withArgs: [id, uid, name, circle, content, type, time, isread, safeuid]) {
        } else {
            callback()
        }
    }
}

// MARK: - 删除私信内容
func SQLLetterDelete(uid: String) {
    var uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
    var safeuid = uidKey.objectForKey(kSecAttrAccount) as! String
//    var safeshell = uidKey.objectForKey(kSecValueData) as! String
    SD.executeChange("delete from letter where circle=? and owner = ?", withArgs: [uid, safeuid])
}
