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
            let Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            
            /*
                  废弃原来写在 NSUserDefault 里的 uid 和 shell, 
                  uid 和 shell 放到 Keychain 里面
            */
            
            let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
            
            if let _s_uid = Sa.objectForKey("uid") as? String {
                s_uid = _s_uid
                
                uidKey.setObject(s_uid, forKey: kSecAttrAccount)
                
                Sa.removeObjectForKey("uid")
            }
            
            if let _s_shell = Sa.objectForKey("shell") as? String {
                s_shell = _s_shell
                
                uidKey.setObject(s_shell, forKey: kSecValueData)
                
                Sa.removeObjectForKey("shell")
            }
            
            s_uid = uidKey.objectForKey(kSecAttrAccount) as! String
            s_shell = uidKey.objectForKey(kSecValueData) as! String
            
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
    
    static func postResetPwd(email: String, callback: V.JsonCallback) {
        V.httpPostForJson_AFN("http://api.nian.so/password/reset/mail", content: ["email": email], callback: callback)
    }
    
    static func getCoinDetial(page: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/coindes.php?uid=\(s_uid)&shell=\(s_shell)&page=\(page)", callback: callback)
    }
    
    static func getExploreFollow(page: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/explore/follow?page=\(page)&uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func getExploreDynamic(page: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/explore/like?page=\(page)&uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func getExploreHot(callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/explore_hot.php", callback: callback)
    }
    
    static func getExploreNew(lastid: String, page: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/explore_all2.php?lastid=\(lastid)&&page=\(page)", callback: callback)
    }
    
    // MARK: - 获得排行
    static func getExploreNewHot(page page: String,callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/discover/ranking?uid=\(s_uid)&&shell=\(s_shell)&&page=\(page)", callback: callback)
    }
    
    // MARK: - 发现-“热门” 之“推荐”和“最新”
    static func getDiscoverTop(callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/discover/top?uid=\(s_uid)&&shell=\(s_shell)", callback: callback)
    }
    
    // MARK: - 获取所有最新的梦想
    static func getDiscoverLatest(page: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/discover/newest?page=\(page)&uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    // MARK: - 获取所有推荐的结果
    static func getDiscoverEditorRecom(page: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/discover/recommend?page=\(page)&uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    // MARK: - 搜索梦想
    static func getSearchDream(keyword: String, page: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/tags/search?uid=\(s_uid)&&shell=\(s_shell)&&keyword=\(keyword)&&page=\(page)", callback: callback)
        ///dream/search?keyword=php&page=2
    }
    
    // MARK: - 搜索用户
    static func getSearchUsers(keyword: String, page: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/searchuser.php?uid=\(s_uid)&&shell=\(s_shell)&&keyword=\(keyword)&&page=\(page)", callback: callback)
    }
    
    // MARK: - 搜索进展
    static func getSearchSteps(keyword: String, page: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/search/step?uid=\(s_uid)&&shell=\(s_shell)&&keyword=\(keyword)&&page=\(page)", callback: callback)
    }
    
    // MARK: - 搜索话题
    static func getSearchTopics(keyword: String, page: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/follow/tag?uid=\(s_uid)&&shell=\(s_shell)&&tag=\(keyword)&&page=\(page)", callback: callback)
    }
    
    // MARK: -
    static func getHasFollowTopic(keyword: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/tags/status?uid=\(s_uid)&&shell=\(s_shell)&&tag=\(keyword)", callback: callback)
    }
    
    // MARK: - 关注搜索内容
    static func postSearchFollow(keyword: String, type: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson_AFN("http://api.nian.so/topic/tag/follow?uid=\(s_uid)&&shell=\(s_shell)", content: ["tag": "\(keyword)", "type": "\(type)"], callback: callback)
    }
    
    static func getSearchUsers(callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/search_user.php", callback: callback)
    }

    // 自动提示
    static func getAutoComplete(keyword: String, callback: V.JsonCallback) {
        loadCookies()
        
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.operationQueue.cancelAllOperations()
        manager.GET("http://api.nian.so/tags/autocomplete?uid=\(s_uid)&&shell=\(s_shell)&&keyword=\(keyword)",
            parameters: nil,
            success: { (op: AFHTTPRequestOperation!, obj: AnyObject!) -> Void in
                callback(obj)
            },
            failure: {(operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
        })
    }
    
    // 搜索标签
    static func getSearchTags(keyword: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/searchtags.php?keyword=\(keyword)", callback: callback)
    }
    
    // 添加标签
    static func getTags(tag: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/tags.php?tag=\(tag)", callback: callback)
    }
    
    static func postTag(tag: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson_AFN("http://api.nian.so/tags?uid=\(s_uid)&&shell=\(s_shell)", content: ["tag": "\(tag)"], callback: callback)
    }
    
    static func postReport(type: String, id: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/a.php", content: "uid=\(s_uid)&&shell=\(s_shell)", callback: callback)
    }
    
    static func postLikeStep(sid: String, like: Int, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/like_query.php", content: "uid=\(s_uid)&&shell=\(s_shell)&&step=\(sid)&&like=\(like)", callback: callback)
    }
    
    static func postCircle(page: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson_AFN("http://nian.so/api/circle_list.php", content: ["uid": "\(s_uid)", "shell": "\(s_shell)", "page": "\(page)"], callback: callback)
    }
    
    static func getCircleStep(id: String, page: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/circle/\(id)/steps?uid=\(s_uid)&shell=\(s_shell)&page=\(page)", callback: callback)
    }
    
    static func getLevelCalendar(callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/calendar.php?uid=\(s_uid)", callback: callback)
    }
    
    static func getUserTop(uid:Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/user.php?uid=\(uid)&myuid=\(s_uid)", callback: callback)
    }
    
    static func getDreamStep(id: String, page: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/dream/\(id)/steps?uid=\(s_uid)&sort=desc&page=\(page)&shell=\(s_shell)", callback: callback)
    }
    
    //GET /dream/{dream_id}/steps?page=2&sort=desc
    
    static func getSingleStep(id: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/step/\(id)?uid=\(s_uid)&sid=\(id)&shell=\(s_shell)", callback: callback)
        // GET /step/{step_id}
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
        V.httpGetForJson("http://api.nian.so/dream/\(id)?&uid=\(s_uid)&shell=\(s_shell)", callback: callback)
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
        let receiptData = ["receipt-data" : data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())]
        var jsonData: NSData?
        do {
            jsonData = try NSJSONSerialization.dataWithJSONObject(receiptData, options: NSJSONWritingOptions())
        } catch _ as NSError {
            jsonData = nil
        }
        V.httpPostForJson("http://nian.so/api/iap_verify.php", content: "uid=\(s_uid)&shell=\(s_shell)&transaction_id=\(transactionId)&data=\(jsonData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions()))", callback: callback)
    }
    
    static func postLabTrip(id: String, subid: Int = 0, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/lab_trip.php", content: "id=\(id)&&uid=\(s_uid)&&shell=\(s_shell)&&subid=\(subid)", callback: callback)
    }
    
    static func postCircleNew(name: String, content: String, img: String, privateType: Int, dream: String, callback: V.JsonCallback) {
        loadCookies()
        let sid = client.getSid()
        V.httpPostForJson("http://nian.so/api/circle_new2.php", content: "uid=\(s_uid)&shell=\(s_shell)&title=\(name)&content=\(content)&img=\(img)&private=\(privateType)&dream=\(dream)&circleshellid=\(sid)", callback: callback)
//        V.httpPostForJson_AFN("http://nian.so/api/circle_new2.php",
//            content: ["uid": "\(s_uid)", "shell": "\(s_shell)", "title": "\(name)", "content": "\(content)", "img": "\(img)", "private": "\(privateType)", "dream": "\(dream)", "circleshellid": "\(sid)" ],
//            callback: callback)
    }
    
    static func postCircleEdit(name: String, content: String, img: String, privateType: Int, ID: String, callback: V.JsonCallback) {
        loadCookies()
        let sid = client.getSid()
        V.httpPostForJson("http://nian.so/api/circle_edit.php", content: "id=\(ID)&uid=\(s_uid)&shell=\(s_shell)&title=\(name)&content=\(content)&img=\(img)&private=\(privateType)&circleshellid=\(sid)", callback: callback)
//        V.httpPostForJson_AFN("http://nian.so/api/circle_edit.php",
//            content: ["id": "\(ID)", "uid": "\(s_uid)", "shell": "\(s_shell)", "title": "\(name)", "content": "\(content)", "img": "\(img)", "private": "\(privateType)", "circleshellid": "\(sid)"],
//            callback: callback)
    }
    
    static func postCircleChat(id: Int, content: String, type: Int, callback: V.JsonCallback) {
        loadCookies()
        let sid = client.getSid()
        V.httpPostForJsonSync("http://nian.so/api/circle_chat2.php", content: "id=\(id)&uid=\(s_uid)&shell=\(s_shell)&content=\(content)&type=\(type)&circleshellid=\(sid)", callback: callback)
    }
    
    static func postCircleQuit(Id: String, callback: V.JsonCallback) {
        loadCookies()
        let sid = client.getSid()
        V.httpPostForJson("http://nian.so/api/circle_quit.php", content: "uid=\(s_uid)&shell=\(s_shell)&id=\(Id)&circleshellid=\(sid)", callback: callback)
    }
    
    static func postCircleDelete(Id: String, callback: V.JsonCallback) {
        loadCookies()
        let sid = client.getSid()
        V.httpPostForJson("http://nian.so/api/circle_delete.php", content: "uid=\(s_uid)&shell=\(s_shell)&id=\(Id)&circleshellid=\(sid)", callback: callback)
    }
    
    static func postCircleFire(Id: String, fireuid:Int, callback: V.JsonCallback) {
        loadCookies()
        let sid = client.getSid()
        V.httpPostForJson("http://nian.so/api/circle_fire.php", content: "uid=\(s_uid)&shell=\(s_shell)&id=\(Id)&fireuid=\(fireuid)&circleshellid=\(sid)", callback: callback)
    }
    
    static func postCirclePromo(Id: String, promouid: Int, promoname: String, callback: V.JsonCallback) {
        loadCookies()
        let sid = client.getSid()
        V.httpPostForJson("http://nian.so/api/circle_promote.php", content: "uid=\(s_uid)&shell=\(s_shell)&id=\(Id)&promouid=\(promouid)&circleshellid=\(sid)&promoname=\(promoname)", callback: callback)
    }
    
    static func postCircleDemo(Id: String, promouid: Int, promoname: String, callback: V.JsonCallback) {
        loadCookies()
        let sid = client.getSid()
        V.httpPostForJson("http://nian.so/api/circle_demote.php", content: "uid=\(s_uid)&shell=\(s_shell)&id=\(Id)&promouid=\(promouid)&circleshellid=\(sid)&promoname=\(promoname)", callback: callback)
    }
    
    static func postCircleJoinDirectly(Id: String, dream:String, word:String, callback: V.JsonCallback) {
        loadCookies()
        let sid = client.getSid()
        V.httpPostForJson("http://nian.so/api/circle_join.php", content: "uid=\(s_uid)&shell=\(s_shell)&circle=\(Id)&dream=\(dream)&word=\(word)&circleshellid=\(sid)", callback: callback)
    }
    
    static func getCircleExplore(page: Int, callback: V.JsonCallback) {
        loadCookies()
//        V.httpGetForJson("http://nian.so/api/circle_explore.php?lastid=\(lastid)", callback: callback)
        V.httpGetForJson("http://api.nian.so/circle/explore?page=\(page)", callback: callback)
    }
    
    static func getCircleChatList(page: Int, id: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/circle_chat_list.php?page=\(page)&id=\(id)&uid=\(s_uid)", callback: callback)
    }
    
    static func getCircleJoinConfirmOK(id:String, callback: V.JsonCallback) {
        loadCookies()
        let sid = client.getSid()
        V.httpGetForJson("http://nian.so/api/circle_confirm_ok.php?uid=\(s_uid)&shell=\(s_shell)&id=\(id)&circleshellid=\(sid)", callback: callback)
    }
    
    static func getCircleStatus(id:String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJsonSync("http://nian.so/api/circle_status.php?uid=\(s_uid)&id=\(id)", callback: callback)
    }
    
    static func postCircleInvite(Id: String, uid: String, callback: V.JsonCallback) {
        loadCookies()
        let sid = client.getSid()
        V.httpPostForJson("http://nian.so/api/circle_invite.php", content: "uid=\(uid)&myuid=\(s_uid)&shell=\(s_shell)&circle=\(Id)&circleshellid=\(sid)", callback: callback)
    }
    
    static func postLetter(callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/letter_list3.php", content: "uid=\(s_uid)&shell=\(s_shell)", callback: callback)
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
    
    static func postUserCover(callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/user_update.php", content: "uid=\(s_uid)&&shell=\(s_shell)&&type=7", callback: callback)
    }
    
    static func postUserFrequency(isMonthly: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/user_update.php", content: "uid=\(s_uid)&shell=\(s_shell)&type=8&isMonthly=\(isMonthly)", callback: callback)
    }
    
    static func postCircleInit(callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJsonSync("http://nian.so/api/circle_init2.php", content: "uid=\(s_uid)&&shell=\(s_shell)", callback: callback)
    }
    
    static func postUserCircleLastid(lastid: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/user_update.php", content: "uid=\(s_uid)&&shell=\(s_shell)&&type=10&&lastid=\(lastid)", callback: callback)
    }
    
//    static func getBBSComment(page: Int, flow: Int, id: String, callback: V.JsonCallback) {
//        loadCookies()
////        V.httpGetForJson("http://nian.so/api/bbs_comment.php?page=\(page)&flow=\(flow)&id=\(id)", callback: callback)
//        
////        GET /bbs/{bbs_id}/comments?page=2&sort=desc
//        
//        V.httpGetForJson("http://api.nian.so/bbs/\(id)/comments?page=\(page)&sort=\(what)", callback: callback)
//    }
    
    static func getBBSComment(id: String, page: Int, isAsc: Bool, callback: V.JsonCallback) {
        loadCookies()
        let sort = isAsc ? "asc" : "desc"
        V.httpGetForJson("http://api.nian.so/bbs/\(id)/comments?page=\(page)&sort=\(sort)", callback: callback)
    }
    
    static func getBBSTop(id: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/bbstop.php?id=\(id)", callback: callback)
    }
    
    static func getNian(callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/nian.php?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func postLetterChat(id: Int, content: String, type: Int, callback: V.JsonCallback) {
        loadCookies()
//        let sid = client.getSid()
//        V.httpPostForJsonSync("http://nian.so/api/letter_chat.php", content: "id=\(id)&uid=\(s_uid)&shell=\(s_shell)&content=\(content)&type=\(type)&circleshellid=\(sid)", callback: callback)
        V.httpPostForJson_AFN("http://api.nian.so/letter/chat?uid=\(s_uid)&&shell=\(s_shell)", content: ["receiver": "\(id)", "content": "\(content)", "type": "\(type)"], callback: callback)
    }
    
    static func postLetterInit(callback: V.JsonCallback) {
        loadCookies()
//        V.httpPostForJsonSync("http://nian.so/api/letter_init2.php", content: "uid=\(s_uid)&shell=\(s_shell)", callback: callback)
        V.httpPostForJson_AFN("http://nian.so/api/letter_init2.php", content: ["uid": "\(s_uid)", "shell": "\(s_shell)" ], callback: callback)
    }
    
    static func postUserLetterLastid(lastid: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/user_update.php", content: "uid=\(s_uid)&&shell=\(s_shell)&&type=9&&lastid=\(lastid)", callback: callback)
    }
    
    static func postLike(step: String, like: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/like_query.php", content: "uid=\(s_uid)&shell=\(s_shell)&step=\(step)&like=\(like)", callback: callback)
    }
    
    static func postName(uid: Int, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/username.php", content: "uid=\(uid)", callback: callback)
    }
    
    static func postCircleDisturb(circle: String, isDisturb: Bool, callback: V.JsonCallback) {
        loadCookies()
        let disturb: Int = isDisturb ? 1 : 0
        V.httpPostForJson_AFN("http://nian.so/api/circle_disturb.php", content: ["circle": "\(circle)", "uid": "\(s_uid)", "shell": "\(s_shell)", "disturb": "\(disturb)" ], callback: callback)
    }
    
    static func postGameover(callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson_AFN("http://nian.so/api/gameover1.php", content: ["uid": "\(s_uid)", "shell": "\(s_shell)"], callback: callback)
    }
    
    static func postLogin(email: String, password: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/login.php", content: "em=\(email)&pw=\(password)", callback: callback)
    }
    
    static func postGameoverCoin(id: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/gameover_coin.php", content: "uid=\(s_uid)&shell=\(s_shell)&id=\(id)", callback: callback)
    }
    
    static func postAddStep(dream: String, content: String, img: String, img0: String, img1: String, callback: V.JsonCallback) {
        loadCookies()
        let sid = client.getSid()
        V.httpPostForJson("http://nian.so/api/addstep_query2.php", content: "uid=\(s_uid)&shell=\(s_shell)&dream=\(dream)&content=\(content)&img=\(img)&img0=\(img0)&img1=\(img1)&circleshellid=\(sid)", callback: callback)
        
//        ["uid": "\(s_uid)", "shell": "\(s_shell)", "dream": "\(dream)", "content": "\(content)", "img": "\(img)", "img0": "\(img0)", "img1": "\(img1)", "circleshellid": "\(sid)"]
    }
    
    // MARK: post add step API
    /**
    取代上面的 postAddStep API
    and 上面的 API 有问题
    
    */
    static func postAddStep_AFN(dream: String, content: String, img: String, img0: String, img1: String, callback: V.JsonCallback) {
        loadCookies()
        Cookies.set(dream, forKey: "DreamNewest")
        V.httpPostForJson_AFN("http://api.nian.so/step?uid=\(s_uid)&shell=\(s_shell)", content: ["dream": dream, "content": content, "image": img, "width": img0, "height": img1], callback: callback)
    }
    
    // ===
    
    static func postAddBBSComment(id: String, content: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/addbbscomment_query.php", content: "id=\(id)&&uid=\(s_uid)&&shell=\(s_shell)&&content=\(content)", callback: callback)
    }
    
    static func postAddBBS(title: String, content: String, circle: String, callback: V.JsonCallback) {
        loadCookies()
        let sid = client.getSid()
        V.httpPostForJson("http://api.nian.so/bbs?uid=\(s_uid)&shell=\(s_shell)", content: "content=\(content)&title=\(title)&circle_id=\(circle)&circleshellid=\(sid)", callback: callback)
    }
    
    static func getDeleteDream(id: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/dream/\(id)/delete?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func getNews(callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/news.php", callback: callback)
    }
    
    static func postAddDream(title: String, content: String, uploadUrl: String, isPrivate: Int, tags: NSArray, callback: V.JsonCallback) {
        loadCookies()
        if tags == "" {
            V.httpPostForJson_AFN("http://api.nian.so/dream?uid=\(s_uid)&shell=\(s_shell)",
                content: ["content": "\(content)", "title": "\(title)", "img": "\(uploadUrl)", "private": "\(isPrivate)" ],
                callback: callback)
        } else {
            V.httpPostForJson_AFN("http://api.nian.so/dream?uid=\(s_uid)&shell=\(s_shell)",
                content: ["content": "\(content)", "title": "\(title)", "img": "\(uploadUrl)", "private": "\(isPrivate)", "tags": tags],
                callback: callback)
        }
    }
    
    static func postEditDream(id: String, title: String, content: String, uploadUrl: String, editPrivate: Int, tags: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/dream/\(id)/edit?uid=\(s_uid)&shell=\(s_shell)", content: "content=\(content)&title=\(title)&image=\(uploadUrl)&private=\(editPrivate)&\(tags)", callback: callback)
    }
    
    static func postEditStep(sid: String, content: String, uploadUrl: String, uploadWidth: Int, uploadHeight: Int, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/editstep_query.php", content: "sid=\(sid)&&uid=\(s_uid)&&shell=\(s_shell)&&content=\(content)&&img=\(uploadUrl)&&img0=\(uploadWidth)&&img1=\(uploadHeight)", callback: callback)
    }
    
    static func postEditStep_AFN(sid: String, content: String, uploadUrl: String, uploadWidth: String, uploadHeight: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson_AFN("http://api.nian.so/step/\(sid)/edit?uid=\(s_uid)&shell=\(s_shell)",
            content: ["content": "\(content)", "image": "\(uploadUrl)", "width": "\(uploadWidth)", "height": "\(uploadHeight)"],
            callback: callback)
    }
    
    
    static func postDeleteBBSComment(cid: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/delete_bbscomment.php", content: "uid=\(s_uid)&shell=\(s_shell)&cid=\(cid)", callback: callback)
    }
    
    
    static func postCircleTag(callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/circle_tag2.php", content: "uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    
    static func getDreamForAddStep(callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/addstep_dream.php?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    
    static func postDeleteStep(sid: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/delete_step.php", content: "uid=\(s_uid)&shell=\(s_shell)&sid=\(sid)", callback: callback)
    }
    
    
    static func postDeleteDream(dream: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/delete_dream.php", content: "uid=\(s_uid)&shell=\(s_shell)&id=\(dream)", callback: callback)
    }
    
    
    static func postCompleteDream(dream: String, percent: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/dream_complete_query.php", content: "id=\(dream)&&uid=\(s_uid)&&shell=\(s_shell)&&percent=\(percent)", callback: callback)
    }
    
    
    static func postFollowDream(dream: String, follow: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/dream_fo_query.php", content: "id=\(dream)&&uid=\(s_uid)&&shell=\(s_shell)&&fo=\(follow)", callback: callback)
    }
    
    
    static func postLikeDream(dream: String, like: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/dream_cool_query.php", content: "id=\(dream)&&uid=\(s_uid)&&shell=\(s_shell)&&cool=\(like)", callback: callback)
    }
    
    static func postDreamStepComment(dream: String, step: String, content: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/step/\(step)/comment?uid=\(s_uid)&shell=\(s_shell)", content: "dream_id=\(dream)&content=\(content)", callback: callback)
    }
    
    static func postDeleteComment(id: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/comment/\(id)/delete?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func getDreamStepComment(sid: String, page: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/comment_step.php?page=\(page)&id=\(sid)", callback: callback)
    }
    
    static func postFollow(uid: String, follow: Int, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/fo.php", content: "uid=\(uid)&&myuid=\(s_uid)&&shell=\(s_shell)&&fo=\(follow)", callback: callback)
    }
    
    static func postUnfollow(uid: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/fo.php", content: "uid=\(uid)&&myuid=\(s_uid)&&shell=\(s_shell)&&unfo=1", callback: callback)
    }
    
    
    static func getBBS(id: String, page: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/circle/\(id)/bbs?page=\(page)", callback: callback)
    }
    
    
    static func postDot(callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/dot.php", content: "uid=\(s_uid)&&shell=\(s_shell)", callback: callback)
    }
    
    
    static func getLike(dream: String, page: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/like2.php?page=\(page)&id=\(dream)&myuid=\(s_uid)", callback: callback)
    }
    
    
    static func getFollowList(uid: String, page: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/user_fo_list2.php?page=\(page)&uid=\(uid)&myuid=\(s_uid)", callback: callback)
    }
    
    
    static func getFollowedList(uid: String, page: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/user_foed_list2.php?page=\(page)&uid=\(uid)&myuid=\(s_uid)", callback: callback)
    }
    
    
    static func getDreamLike(uid: String, page: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/like_dream.php?page=\(page)&id=\(uid)&myuid=\(s_uid)", callback: callback)
    }
    
    
    static func postUsername(uid: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/username.php", content: "uid=\(uid)", callback: callback)
    }
    
    // MARK: - 通过 user nick Name 获得 User id
    static func postUserNickName(name: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson_AFN("http://api.nian.so/user/username?uid=\(s_uid)&&shell=\(s_shell)", content: ["username": name], callback: callback)
    }
    
    static func postDeviceToken(callback: V.StringCallback) {
        loadCookies()
        let UserDefaults = NSUserDefaults.standardUserDefaults()
        let DeviceToken = UserDefaults.objectForKey("DeviceToken") as? String
        if DeviceToken != nil {
            V.httpPostForString("http://nian.so/api/user_update.php", content: "devicetoken=\(DeviceToken!)&&uid=\(s_uid)&&shell=\(s_shell)&&type=1", callback: callback)
        }
    }
    
    // MARK: - 极光推送
    static func postJpushBinding(callback: V.JsonCallback) {
        V.httpPostForJson_AFN("http://api.nian.so/jpush/add?uid=\(s_uid)&&shell=\(s_shell)", content: ["registration_id": "\(APService.registrationID())", "platform": "ios"], callback: callback)
    }
    
    static func postDeviceTokenClear(callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/user_update.php", content: "devicetoken=&uid=\(s_uid)&shell=\(s_shell)&type=1", callback: callback)
    }
    
    static func getMeNext(page: Int, tag: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/me_next2.php?page=\(page)&uid=\(s_uid)&shell=\(s_shell)&tag=\(tag)", callback: callback)
    }
    
    /**
    获得通知详情，替代上面的 getMeNext
    
    :param: type --  "reply" or "like" or "notify"
    */
    static func getNotify(type: String, page: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/notify?type=\(type)&&page=\(page)&&uid=\(s_uid)&&shell=\(s_shell)", callback: callback)
    }
    
    static func postBan(uid: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/ban.php", content: "uid=\(uid)&&myuid=\(s_uid)&&shell=\(s_shell)", callback: callback)
    }
    
    
    static func postNoban(uid: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/ban.php", content: "uid=\(uid)&&myuid=\(s_uid)&&shell=\(s_shell)&noban=1", callback: callback)
    }
    
    
    static func getUserDream(uid: String, page: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/user_dream.php?page=\(page)&uid=\(uid)", callback: callback)
    }
    
    
    static func getUserActive(uid: String, page: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/user/\(uid)/steps?page=\(page)&uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    
    static func postNewname(name: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/user_update.php", content: "newname=\(name)&&uid=\(s_uid)&&shell=\(s_shell)&&type=2", callback: callback)
    }
    
    
    static func postNewEmail(email: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/user_update.php", content: "newemail=\(email)&&uid=\(s_uid)&&shell=\(s_shell)&&type=3", callback: callback)
    }
    
    
    static func postUpyunCache(callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/upyun_cache.php", content: "uid=\(s_uid)", callback: callback)
    }
    
    
    static func postChangeCover(uploadUrl: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/change_cover.php", content: "uid=\(s_uid)&&shell=\(s_shell)&&cover=\(uploadUrl)", callback: callback)
    }
    
    
    static func postCheckName(name: String, callback: V.StringCallback) {
        V.httpPostForString("http://nian.so/api/sign_checkname.php", content: "name=\(name)", callback: callback)
    }
    
    
    static func postSignup(name: String, password: String, email: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/sign_check.php", content: "name=\(name)&&pw=\(password)&&em=\(email)", callback: callback)
    }
    
    static func getConsume(type: String, coins: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/consume?uid=\(s_uid)&shell=\(s_shell)", content: "type=\(type)&coins=\(coins)", callback: callback)
    }
}


// MARK: - 和宠物相关的 API
extension  Api {
    
    /**
    抽取宠物
    
    - parameter callback: <#callback description#>
    */
    static func postPetLottery(tag: Int, callback: V.JsonCallback) {
        let _sha256String = ((s_uid + s_shell) as NSString).SHA256()
        V.httpPostForJson_AFN("http://api.nian.so/pet/extract?uid=\(s_uid)&&shell=\(s_shell)&tag=\(tag)", content: ["luckcode": _sha256String], callback: callback)
    }
   
    /**
    获得用户的宠物
    
    - parameter page:     <#page description#>
    - parameter callback: <#callback description#>
    */
    static func getUserPet(page: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/user/\(s_uid)/pets?uid=\(s_uid)&&shell=\(s_shell)&&page=\(page)", callback: callback)
    }
    
    static func getPetUpgrade(pet: String, callback: V.JsonCallback) {
        V.httpGetForJson("http://api.nian.so/pet/\(pet)/upgrade?uid=\(s_uid)&&shell=\(s_shell)", callback: callback)
    }
    
    static func getAllPets(callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/pets?uid=\(s_uid)&&shell=\(s_shell)", callback: callback)
    }
    
}

// MARK: - 新的注册 API
extension Api {

    static func postSignUp(name: String, password: String, email: String, daily: Int, callback: V.JsonCallback) {
//        loadCookies()
        V.httpPostForJson_AFN("http://api.nian.so/user/signup", content: ["username": "\(name)", "email": "\(email)", "password": "\(password)", "daily": daily], callback: callback)
    }

}

// MARK: - 新广场 API
extension Api {
    static func postAddReddit(title: String, content: String, tags: NSArray, callback: V.JsonCallback) {
        loadCookies()
        if tags == "" {
            V.httpPostForJson_AFN("http://api.nian.so/topic?uid=\(s_uid)&shell=\(s_shell)", content: ["title": "\(title)", "content": "\(content)", "type": "question"], callback: callback)
        } else {
            V.httpPostForJson_AFN("http://api.nian.so/topic?uid=\(s_uid)&shell=\(s_shell)", content: ["title": "\(title)", "content": "\(content)", "tags": tags, "type": "question"], callback: callback)
        }
    }
    
    /**
    编辑话题之后要上传 id
    */
    static func postEditReddit(id: String, title: String, content: String, tags: NSArray, callback: V.JsonCallback) {
        loadCookies()
        if tags == "" {
            V.httpPostForJson_AFN("http://api.nian.so/topic/\(id)/edit?uid=\(s_uid)&shell=\(s_shell)", content: ["title": "\(title)", "content": "\(content)"], callback: callback)
        } else {
            V.httpPostForJson_AFN("http://api.nian.so/topic/\(id)/edit?uid=\(s_uid)&shell=\(s_shell)", content: ["title": "\(title)", "content": "\(content)", "tags": tags], callback: callback)
        }
    }
    
    static func postMention(topicId: String, commentId: String, mentions: NSArray, callback: V.JsonCallback) {
        loadCookies()
        if commentId == "" {
            V.httpPostForJson_AFN("http://api.nian.so/mention?uid=\(s_uid)&&shell=\(s_shell)", content: ["topic_id": "\(topicId)", "mentions": mentions], callback: callback)
        } else if topicId == "" {
             V.httpPostForJson_AFN("http://api.nian.so/mention?uid=\(s_uid)&&shell=\(s_shell)", content: ["comment_id": "\(commentId)", "mentions": mentions], callback: callback)
        }
    }
    
    static func postAddRedditComment(id: String, content: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson_AFN("http://api.nian.so/topic?uid=\(s_uid)&shell=\(s_shell)", content: ["content": "\(content)", "type": "answer", "question_id": "\(id)"], callback: callback)
    }
    
    static func getReddit(page: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/topics?page=\(page)&uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func getRedditFollow(page: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/user/\(s_uid)/follow/topics?page=\(page)&uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func getVoteUp(id: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/topic/\(id)/vote/up?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func getVoteDown(id: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/topic/\(id)/vote/down?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    
    static func getVoteUpDelete(id: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/topic/\(id)/vote/up/delete?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func getVoteDownDelete(id: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/topic/\(id)/vote/down/delete?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
//    GET /topic/{topic_id}/hot
    
    // 获得热门评论
    static func getTopicCommentHot(id: String, page: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/topic/\(id)/hot?uid=\(s_uid)&shell=\(s_shell)&page=\(page)", callback: callback)
    }
    
    // 获得最新评论
    static func getTopicCommentNew(id: String, page: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/topic/\(id)/newest?uid=\(s_uid)&shell=\(s_shell)&page=\(page)", callback: callback)
    }
    
    // 获得记本信息
    static func getDream(id: String, callback : V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/topic/dream/\(id)", callback: callback)
    }
    
    // 获得话题顶部
    static func getTopic(id: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/topic/\(id)?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    // 发布评论的评论
    static func postTopicCommentComment(id: String, content: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson_AFN("http://api.nian.so/topic/comment?uid=\(s_uid)&shell=\(s_shell)", content: ["topic_id": "\(id)", "content": content], callback: callback)
    }
    
    // 获得评论的评论
    static func getTopicCommentComment(id: String, page: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/topic/answer/\(id)/comments?uid=\(s_uid)&shell=\(s_shell)&page=\(page)", callback: callback)
    }

    // 删除某个回应
    static func getTopicDelete(id: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/topic/\(id)/delete?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    // 删除回应的回应
    static func getTopicCommentDelete(id: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/topic/comment/\(id)/delete?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    // 查询通行证
    static func getPassportStatus(callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/passport?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    // 购买通行证
    static func getPassport(callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/passport/exchange?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
}


// MARK: - 活动 API
extension Api {
    static func getRewardsActivity(activity: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/rewardsactivity.php?uid=\(s_uid)&shell=\(s_shell)&activity=\(activity)", callback: callback)
    }
    
    static func getRewards(activity: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/rewards.php?uid=\(s_uid)&shell=\(s_shell)&activity=\(activity)", callback: callback)
    }
}

