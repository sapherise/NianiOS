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
            s_uid = Sa.objectForKey("uid") as! String
            s_shell = Sa.objectForKey("shell") as! String
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
    
    static func getExploreNewHot(page: String,callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/explore_test.php?page=\(page)", callback: callback)
    }
    
    static func getSearchDream(keyword: String, page: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/searchdream.php?uid=\(s_uid)&&shell=\(s_shell)&&keyword=\(keyword)&&page=\(page)", callback: callback)
    }
    
    static func getSearchUsers(keyword: String, page: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/searchuser.php?uid=\(s_uid)&&shell=\(s_shell)&&keyword=\(keyword)&&page=\(page)", callback: callback)
    }
    
    static func getSearchDream(callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/search_dream.php", callback: callback)
    }
        
    static func getSearchUsers(callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/search_user.php", callback: callback)
    }

    
    static func postReport(type: String, id: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/a.php", content: "uid=\(s_uid)&&shell\(s_shell)", callback: callback)
    }
    
    static func postLikeStep(sid: String, like: Int, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/like_query.php", content: "uid=\(s_uid)&&shell=\(s_shell)&&step=\(sid)&&like=\(like)", callback: callback)
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
    
    static func getDreamStep(id: String, page: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/step.php?uid=\(s_uid)&id=\(id)&page=\(page)&shell=\(s_shell)", callback: callback)
    }
    
    static func getSingleStep(id: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/step_single.php?uid=\(s_uid)&sid=\(id)&shell=\(s_shell)", callback: callback)
    }
    
    static func getSingleStepSync(id: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJsonSync("http://nian.so/api/step_single.php?uid=\(s_uid)&sid=\(id)&shell=\(s_shell)", callback: callback)
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
        var sid = client.getSid()
        V.httpPostForJson("http://nian.so/api/circle_edit.php", content: "id=\(ID)&uid=\(s_uid)&shell=\(s_shell)&title=\(name)&content=\(content)&img=\(img)&private=\(privateType)&circleshellid=\(sid)", callback: callback)
    }
    
    static func postCircleChat(id: Int, content: String, type: Int, callback: V.JsonCallback) {
        loadCookies()
        var sid = client.getSid()
        V.httpPostForJsonSync("http://nian.so/api/circle_chat.php", content: "id=\(id)&uid=\(s_uid)&shell=\(s_shell)&content=\(content)&type=\(type)&circleshellid=\(sid)", callback: callback)
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
        V.httpGetForJsonSync("http://nian.so/api/circle_status.php?uid=\(s_uid)&id=\(id)", callback: callback)
    }
    
    static func postCircleInvite(Id: String, uid: String, callback: V.JsonCallback) {
        loadCookies()
        var sid = client.getSid()
        V.httpPostForJson("http://nian.so/api/circle_invite.php", content: "uid=\(uid)&myuid=\(s_uid)&shell=\(s_shell)&circle=\(Id)&circleshellid=\(sid)", callback: callback)
    }
    
    static func postLetter(callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/letter_list.php", content: "uid=\(s_uid)&shell=\(s_shell)", callback: callback)
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
        V.httpPostForJsonSync("http://nian.so/api/circle_init.php", content: "uid=\(s_uid)&&shell=\(s_shell)", callback: callback)
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
    
    static func postLetterChat(id: Int, content: String, type: Int, callback: V.JsonCallback) {
        loadCookies()
        var sid = client.getSid()
        V.httpPostForJsonSync("http://nian.so/api/letter_chat.php", content: "id=\(id)&uid=\(s_uid)&shell=\(s_shell)&content=\(content)&type=\(type)&circleshellid=\(sid)", callback: callback)
    }
    
    static func postLetterInit(callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJsonSync("http://nian.so/api/letter_init.php", content: "uid=\(s_uid)&shell=\(s_shell)", callback: callback)
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
        var disturb: Int = isDisturb ? 1 : 0
        V.httpPostForJson("http://nian.so/api/circle_disturb.php", content: "circle=\(circle)&uid=\(s_uid)&shell=\(s_shell)&disturb=\(disturb)", callback: callback)
    }
    
    static func postGameover(callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/gameover1.php", content: "uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func postGameoverCoin(id: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/gameover_coin.php", content: "uid=\(s_uid)&shell=\(s_shell)&id=\(id)", callback: callback)
    }
    
    static func postAddStep(dream: String, content: String, img: String, img0: String, img1: String, callback: V.JsonCallback) {
        loadCookies()
        var sid = client.getSid()
        V.httpPostForJson("http://nian.so/api/addstep_query2.php", content: "uid=\(s_uid)&shell=\(s_shell)&dream=\(dream)&content=\(content)&img=\(img)&img0=\(img0)&img1=\(img1)&circleshellid=\(sid)", callback: callback)
    }
    
    // ===
    
    static func postAddBBSComment(id: String, content: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/addbbscomment_query.php", content: "id=\(id)&&uid=\(s_uid)&&shell=\(s_shell)&&content=\(content)", callback: callback)
    }
    
    
    static func postAddBBS(title: String, content: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/add_bbs.php", content: "uid=\(s_uid)&&shell=\(s_shell)&&content=\(content)&&title=\(title)", callback: callback)
    }
    
    
    static func postAddDream(title: String, content: String, uploadUrl: String, isPrivate: Int, tagType: Int, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/add_query.php", content: "uid=\(s_uid)&&shell=\(s_shell)&&content=\(content)&&title=\(title)&&img=\(uploadUrl)&&private=\(isPrivate)&&hashtag=\(tagType)", callback: callback)
    }
    
    
    static func postEditDream(id: String, title: String, content: String, uploadUrl: String, editPrivate: Int, tagType: Int, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/editdream.php", content: "uid=\(s_uid)&&shell=\(s_shell)&&content=\(content)&&title=\(title)&&img=\(uploadUrl)&&private=\(editPrivate)&&id=\(id)&&hashtag=\(tagType)", callback: callback)
    }
    
    
    static func postEditStep(sid: String, content: String, uploadUrl: String, uploadWidth: Int, uploadHeight: Int, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/editstep_query.php", content: "sid=\(sid)&&uid=\(s_uid)&&shell=\(s_shell)&&content=\(content)&&img=\(uploadUrl)&&img0=\(uploadWidth)&&img1=\(uploadHeight)", callback: callback)
    }
    
    
    static func postDeleteBBSComment(cid: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/delete_bbscomment.php", content: "uid=\(s_uid)&shell=\(s_shell)&cid=\(cid)", callback: callback)
    }
    
    
    static func getCircleTag(callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/circle_tag.php?uid=\(s_shell)", callback: callback)
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
    
    static func postDreamStepComment(dream: String, step: String, content: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/comment_query.php", content: "id=\(dream)&&step=\(step)&&uid=\(s_uid)&&shell=\(s_shell)&&content=\(content)", callback: callback)
    }
    
    
    static func getDreamStepComment(sid: String, page: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/comment_step.php?page=\(page)&id=\(sid)", callback: callback)
    }
    
    
    static func postDeleteComment(cid: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/delete_comment.php", content: "uid=\(s_uid)&shell=\(s_shell)&cid=\(cid)", callback: callback)
    }
    
    static func postFollow(uid: String, follow: Int, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/fo.php", content: "uid=\(uid)&&myuid=\(s_uid)&&shell=\(s_shell)&&fo=\(follow)", callback: callback)
    }
    
    static func postUnfollow(uid: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/fo.php", content: "uid=\(uid)&&myuid=\(s_uid)&&shell=\(s_shell)&&unfo=1", callback: callback)
    }
    
    
    static func getBBS(page: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/bbs.php?age=\(page)", callback: callback)
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
    
    
    static func postLogin(email: String, password: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/login.php", content: "em=\(email)&&pw=\(password)", callback: callback)
    }
    
    
    static func postUsername(uid: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/username.php", content: "uid=\(uid)", callback: callback)
    }
    
    
    static func postDeviceToken(devicetoken: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/user_update.php", content: "devicetoken=\(devicetoken)&&uid=\(s_uid)&&shell=\(s_shell)&&type=1", callback: callback)
    }
    
    
    static func getMeNext(page: Int, tag: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/me_next.php?page=\(page)&uid=\(s_uid)&shell=\(s_shell)&&tag=\(tag)", callback: callback)
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
        V.httpGetForJson("http://nian.so/api/user_active.php?page=\(page)&uid=\(uid)&myuid=\(s_uid)", callback: callback)
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
        loadCookies()
        V.httpPostForString("http://nian.so/api/sign_checkname.php", content: "name=\(name)", callback: callback)
    }
    
    
    static func postSignup(name: String, password: String, email: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/sign_check.php", content: "name=\(name)&&pw=\(password)&&em=\(email)", callback: callback)
    }
    
}