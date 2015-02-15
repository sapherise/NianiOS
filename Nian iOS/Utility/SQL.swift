//
//  SQL.swift
//  Nian iOS
//
//  Created by Sa on 15/2/6.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation

// 创建梦境表
func SQLCreateCircleList() {
    SD.executeChange("CREATE TABLE if not exists `circlelist` ( `id` INTEGER PRIMARY KEY AUTOINCREMENT, `circleid` INT NOT NULL , `title` VARCHAR(255) NULL , `image` VARCHAR(255) NULL, `postdate` MEDIUMINT NOT NULL)")
}

// 创建梦境内容表
func SQLCreateCircleContent() {
    SD.executeChange("CREATE TABLE if not exists `circle` ( `id` INTEGER PRIMARY KEY AUTOINCREMENT, `msgid` INT NOT NULL , `uid` INT NOT NULL , `name` VARCHAR(255) NULL , `cid` INT NOT NULL , `cname` VARCHAR(255) NULL , `circle` INT NOT NULL , `content` TEXT NULL , `title` VARCHAR(255) NULL , `type` INT NOT NULL , `lastdate` MEDIUMINT NOT NULL, `isread` INT NOT NULL)")
}

// 创建私信内容表
func SQLCreateLetterContent() {
    SD.executeChange("CREATE TABLE if not exists `letter` ( `id` INTEGER PRIMARY KEY AUTOINCREMENT, `msgid` INT NOT NULL , `uid` INT NOT NULL , `name` VARCHAR(255) NULL , `circle` INT NOT NULL , `content` TEXT NULL , `type` INT NOT NULL , `lastdate` MEDIUMINT NOT NULL, `isread` INT NOT NULL)")
}

// 创建所有表
func SQLInit() {
    SQLCreateCircleList()
    SQLCreateCircleContent()
    SQLCreateLetterContent()
}

// 插入一条梦境
func SQLCircleListInsert(id: String, title: String, image: String, postdate: String) {
    let (resultSet2, err2) = SD.executeQuery("select id from circlelist where circleid = '\(id)' limit 1")
    if err2 == nil {
        if resultSet2.count == 0 {
            if let err3 = SD.executeChange("INSERT INTO circlelist (id, circleid, title, image, postdate) VALUES (null, ?, ?, ?, ?)", withArgs: [id, title, image, postdate]) {
            }
        }
    }
}

// 插入梦境聊天内容
func SQLCircleContent(id: String, uid: String, name: String, cid: String, cname: String, circle: String, content: String, title: String, type: String, time: String, isread: Int, callback: Void -> Void) {
    let (result, err) = SD.executeQuery("select id from circle where msgid = '\(id)' limit 1")
    if result.count == 0 {
        if let err = SD.executeChange("INSERT INTO circle (id, msgid, uid, name, cid, cname, circle, content, title, type, lastdate, isread) VALUES (null, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", withArgs: [id, uid, name, cid, cname, circle, content, title, type, time, isread]) {
        } else {
            callback()
        }
    }
}

// 删除梦境
func SQLCircleListDelete(id: String) {
    if let err2 = SD.executeChange("delete from circlelist where circleid=?", withArgs: [id]) {
    }
    if let err2 = SD.executeChange("delete from circle where circle=?", withArgs: [id]) {
    }
}

// 插入私信内容
func SQLLetterContent(id: String, uid: String, name: String, circle: String, content: String, type: String, time: String, isread: Int, callback: Void -> Void) {
    let (result, err) = SD.executeQuery("select id from letter where msgid = '\(id)' limit 1")
    if result.count == 0 {
        if let err = SD.executeChange("INSERT INTO letter (id, msgid, uid, name, circle, content, type, lastdate, isread) VALUES (null, ?, ?, ?, ?, ?, ?, ?, ?)", withArgs: [id, uid, name, circle, content, type, time, isread]) {
        } else {
            callback()
        }
    }
}
