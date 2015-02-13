//
//  Nian.swift
//  Nian iOS
//
//  Created by vizee on 14/11/7.
//  Copyright (c) 2014年 Sa. All rights reserved.
//i

import UIKit

struct Api {
    
    private static var s_load = false
    private static var s_uid: String!
    private static var s_shell: String!
    
    private static func loadCookies() {
        if (!s_load) {
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            s_uid = Sa.objectForKey("uid") as String
            s_shell = Sa.objectForKey("shell") as String
            s_load = true
        }
    }
    
    static func requestLoad() {
        s_load = false
    }
    
    static func getCookie() -> (String, String) {
        loadCookies()
        return (s_uid, s_shell)
    }
    
    static func getUserMe(callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/user.php?uid=\(s_uid)&myuid=\(s_uid)", callback: callback)
    }
    
    static func getCoinDetial(page: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/coindes.php?uid=\(s_uid)&shell=\(s_shell)&page=\(page)", callback: callback)
    }
    
    static func getExploreFollow(page: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/explore_fo.php?page=\(page)&uid=\(s_uid)", callback: callback)
    }
    
    static func getExploreDynamic(page: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/explore_like.php?page=\(page)&uid=\(s_uid)", callback: callback)
    }
    
    static func getExploreHot(callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/explore_hot.php", callback: callback)
    }
    
    static func getExploreNew(lastid: String, page: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/explore_all2.php?lastid=\(lastid)&&page=\(page)", callback: callback)
    }
    
    static func postReport(type: String, id: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/a.php", content: "uid=\(s_uid)&&shell\(s_shell)", callback: callback)
    }
    
    static func postLikeStep(sid: String, like: Int, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/like_query.php", content: "uid=\(s_uid)&&shell=\(s_shell)&&step=\(sid)&&like=\(like)", callback)
    }
    
    static func postFollow(uid: String, follow: Int, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/fo.php", content: "uid=\(uid)&&myuid=\(s_uid)&&shell=\(s_shell)&&fo=\(follow)", callback: callback)
    }
    
    static func postCircle(page: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/circle_list.php", content: "uid=\(s_uid)&&shell=\(s_shell)&&page=\(page)", callback: callback)
    }
    
    static func getLevelCalendar(callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/calendar.php?uid=\(s_uid)", callback: callback)
    }
    
    static func getUserTop(uid:Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/user.php?uid=\(uid)&myuid=\(s_uid)", callback: callback)
    }
    
    static func getDreamNewest(callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/addstep_dream.php?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func getDreamTag(tag:Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/circle_join_dream.php?uid=\(s_uid)&shell=\(s_shell)&tag=\(tag)", callback: callback)
    }
    
    static func getDreamTop(id:String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/dream.php?uid=\(s_uid)&shell=\(s_shell)&id=\(id)", callback: callback)
    }
    
    static func getCircleDetail(circle:String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/circle_detail.php?uid=\(s_uid)&id=\(circle)", callback: callback)
    }
    
    static func getCircleTitle(id:String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/circle_title.php?id=\(id)", callback: callback)
    }
    
    static func postIapVerify(transactionId: String, data: NSData, callback: V.JsonCallback) {
        loadCookies()
        var receiptData = ["receipt-data" : data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)]
        var err: NSError?
        var jsonData = NSJSONSerialization.dataWithJSONObject(receiptData, options: NSJSONWritingOptions.allZeros, error: &err)
        V.httpPostForJson("http://nian.so/api/iap_verify.php", content: "uid=\(s_uid)&shell=\(s_shell)&transaction_id=\(transactionId)&data=\(jsonData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros))", callback: callback)
    }
    
    static func postLabTrip(id: String, subid: Int = 0, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/lab_trip.php", content: "id=\(id)&&uid=\(s_uid)&&shell=\(s_shell)&&subid=\(subid)", callback: callback)
    }
    
    static func postCircleNew(name: String, content: String, img: String, privateType: Int, tag: Int, dream: Int, callback: V.JsonCallback) {
        loadCookies()
        var sid = client.getSid()
        V.httpPostForJson("http://nian.so/api/circle_new.php", content: "uid=\(s_uid)&shell=\(s_shell)&title=\(name)&content=\(content)&img=\(img)&private=\(privateType)&tag=\(tag)&dream=\(dream)&circleshellid=\(sid)", callback: callback)
    }
    
    static func postCircleEdit(name: String, content: String, img: String, privateType: Int, ID: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/circle_edit.php", content: "id=\(ID)&uid=\(s_uid)&shell=\(s_shell)&title=\(name)&content=\(content)&img=\(img)&private=\(privateType)", callback: callback)
    }
    
    static func postCircleChat(id: Int, content: String, type: Int, callback: V.JsonCallback) {
        loadCookies()
        var sid = client.getSid()
        V.httpPostForJson("http://nian.so/api/circle_chat.php", content: "id=\(id)&uid=\(s_uid)&shell=\(s_shell)&content=\(content)&type=\(type)&circleshellid=\(sid)", callback: callback)
    }
    
    static func postCircleQuit(Id: String, callback: V.JsonCallback) {
        loadCookies()
        var sid = client.getSid()
        V.httpPostForJson("http://nian.so/api/circle_quit.php", content: "uid=\(s_uid)&shell=\(s_shell)&id=\(Id)&circleshellid=\(sid)", callback: callback)
    }
    
    static func postCircleDelete(Id: String, callback: V.JsonCallback) {
        loadCookies()
        var sid = client.getSid()
        V.httpPostForJson("http://nian.so/api/circle_delete.php", content: "uid=\(s_uid)&shell=\(s_shell)&id=\(Id)&circleshellid=\(sid)", callback: callback)
    }
    
    static func postCircleFire(Id: String, fireuid:Int, callback: V.JsonCallback) {
        loadCookies()
        var sid = client.getSid()
        V.httpPostForJson("http://nian.so/api/circle_fire.php", content: "uid=\(s_uid)&shell=\(s_shell)&id=\(Id)&fireuid=\(fireuid)&circleshellid=\(sid)", callback: callback)
    }
    
    static func postCirclePromo(Id: String, promouid: Int, promoname: String, callback: V.JsonCallback) {
        loadCookies()
        var sid = client.getSid()
        V.httpPostForJson("http://nian.so/api/circle_promote.php", content: "uid=\(s_uid)&shell=\(s_shell)&id=\(Id)&promouid=\(promouid)&circleshellid=\(sid)&promoname=\(promoname)", callback: callback)
    }
    
    static func postCircleDemo(Id: String, promouid: Int, promoname: String, callback: V.JsonCallback) {
        loadCookies()
        var sid = client.getSid()
        V.httpPostForJson("http://nian.so/api/circle_demote.php", content: "uid=\(s_uid)&shell=\(s_shell)&id=\(Id)&promouid=\(promouid)&circleshellid=\(sid)&promoname=\(promoname)", callback: callback)
    }
    
    static func postCircleJoinDirectly(Id: String, dream:String, word:String, callback: V.JsonCallback) {
        loadCookies()
        var sid = client.getSid()
        V.httpPostForJson("http://nian.so/api/circle_join.php", content: "uid=\(s_uid)&shell=\(s_shell)&circle=\(Id)&dream=\(dream)&word=\(word)&circleshellid=\(sid)", callback: callback)
    }
    
    static func getCircleExplore(lastid:String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/circle_explore.php?lastid=\(lastid)", callback: callback)
    }
    
    static func getCircleChatList(page: Int, id: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/circle_chat_list.php?page=\(page)&id=\(id)&uid=\(s_uid)", callback: callback)
    }
    
    static func getCircleJoinConfirmOK(id:String, callback: V.JsonCallback) {
        loadCookies()
        var sid = client.getSid()
        V.httpGetForJson("http://nian.so/api/circle_confirm_ok.php?uid=\(s_uid)&shell=\(s_shell)&id=\(id)&circleshellid=\(sid)", callback: callback)
    }
    
    static func getCircleStatus(id:String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/circle_status.php?uid=\(s_uid)&id=\(id)", callback: callback)
    }
    
    static func postCircleInvite(Id: String, uid: String, callback: V.JsonCallback) {
        loadCookies()
        var sid = client.getSid()
        V.httpPostForJson("http://nian.so/api/circle_invite.php", content: "uid=\(uid)&myuid=\(s_uid)&shell=\(s_shell)&circle=\(Id)&circleshellid=\(sid)", callback: callback)
    }
    
    static func postLetter(page: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/letter_list.php", content: "uid=\(s_uid)&&shell=\(s_shell)&&page=\(page)", callback: callback)
    }
    
    static func getLetterChatList(page: Int, id: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/letter_chat_list.php?page=\(page)&id=\(id)&uid=\(s_uid)", callback: callback)
    }
    
    static func postLetterAddReply(id: Int, content: String, type: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/letter_chat.php", content: "uid=\(s_uid)&&shell=\(s_shell)&&id=\(id)&&content=\(content)&&type=\(type)", callback: callback)
    }
    
    static func getWeibo(weibouid:String, Token:String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/weibo.php?uid=\(s_uid)&shell=\(s_shell)&weibouid=\(weibouid)&token=\(Token)", callback: callback)
    }
    
    static func postPhone(list: [String], callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/phone.php", content: "uid=\(s_uid)&&shell=\(s_shell)&&list=\(list)", callback: callback)
    }
    
    static func postUserPrivate(userPrivate: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/user_update.php", content: "uid=\(s_uid)&&shell=\(s_shell)&&type=4&&private=\(userPrivate)", callback: callback)
    }
    
    static func postUserPhone(phone: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/user_update.php", content: "uid=\(s_uid)&&shell=\(s_shell)&&type=5&&phone=\(phone)", callback: callback)
    }
    
    static func postUserSex(sex: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/user_update.php", content: "uid=\(s_uid)&&shell=\(s_shell)&&type=6&&sex=\(sex)", callback: callback)
    }
    
    static func postCircleInit(callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/circle_init.php", content: "uid=\(s_uid)&&shell=\(s_shell)", callback: callback)
    }
    
    static func test(callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/b.php", content: "uid=\(s_uid)&&shell=\(s_shell)", callback: callback)
    }
    
    static func getBBSComment(page: Int, flow: Int, id: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/bbs_comment.php?page=\(page)&flow=\(flow)&id=\(id)", callback: callback)
    }
    
    static func getBBSTop(id: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/bbstop.php?id=\(id)", callback: callback)
    }
    
    static func getNian(callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/nian.php?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
}