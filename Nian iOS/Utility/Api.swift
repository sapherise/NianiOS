//
//  Nian.swift
//  Nian iOS
//
//  Created by vizee on 14/11/7.
//  Copyright (c) 2014年 Sa. All rights reserved.
//i

import UIKit

struct Api {
    
    fileprivate static var s_load = false
    fileprivate static var s_uid: String = ""
    fileprivate static var s_shell: String = ""
    
    fileprivate static func loadCookies() {
        if (!s_load) {
            let Sa:UserDefaults = UserDefaults.standard
            
            /*
             废弃原来写在 NSUserDefault 里的 uid 和 shell,
             uid 和 shell 放到 Keychain 里面
             */
            
            let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
            
            if let _s_uid = Sa.object(forKey: "uid") as? String {
                s_uid = _s_uid
                
                uidKey?.setObject(s_uid, forKey: kSecAttrAccount)
                
                Sa.removeObject(forKey: "uid")
            }
            
            if let _s_shell = Sa.object(forKey: "shell") as? String {
                s_shell = _s_shell
                
                uidKey?.setObject(s_shell, forKey: kSecValueData)
                
                Sa.removeObject(forKey: "shell")
            }
            
            if let a = uidKey!.object(forKey: kSecAttrAccount) as? String {
                s_uid = a
            }
            if let b = uidKey!.object(forKey: kSecValueData) as? String {
                s_shell = b
            }
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
    
    static func postResetPwd(_ email: String, callback: @escaping V.JsonCallback) {
        V.httpPostForJson("http://api.nian.so/password/reset/mail", content: ["email": email], callback: callback)
    }
    
    static func getCoinDetial(_ page: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/coindes.php?uid=\(s_uid)&shell=\(s_shell)&page=\(page)", callback: callback)
    }
    
    static func getExploreFollow(_ page: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/v2/explore/follow?page=\(page)&uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func getExploreDynamic(_ page: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/v2/explore/like?page=\(page)&uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func getExploreHot(_ callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/explore_hot.php", callback: callback)
    }
    
    static func getExploreNew(_ lastid: String, page: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/explore_all2.php?lastid=\(lastid)&&page=\(page)", callback: callback)
    }
    
    // MARK: - 获得排行
    static func getExploreNewHot(_ page: String,callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/discover/ranking?uid=\(s_uid)&&shell=\(s_shell)&&page=\(page)", callback: callback)
    }
    
    // MARK: - 发现-“热门” 之“推荐”和“最新”
    static func getDiscoverTop(_ callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/discover/top?uid=\(s_uid)&&shell=\(s_shell)", callback: callback)
    }
    
    // MARK: - 获取所有最新的梦想
    static func getDiscoverLatest(_ page: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/discover/newest?page=\(page)&uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    // MARK: - 获取用户赞过的梦想
    static func getMyLikeDreams(_ page: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/v2/user/\(s_uid)/like/dreams?page=\(page)&uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    // MARK: - 获取用户关注的梦想
    static func getMyFollowDreams(_ page: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/user/\(s_uid)/following/dreams?page=\(page)&uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    // MARK: - 获取所有推荐的结果
    static func getDiscoverEditorRecom(_ page: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/discover/recommend?page=\(page)&uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    // MARK: - 搜索梦想
    static func getSearchDream(_ keyword: String, page: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/tags/search?uid=\(s_uid)&shell=\(s_shell)&keyword=\(keyword)&page=\(page)", callback: callback)
    }
    
    // MARK: - 搜索用户
    static func getSearchUsers(_ keyword: String, page: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/searchuser.php?uid=\(s_uid)&&shell=\(s_shell)&&keyword=\(keyword)&&page=\(page)", callback: callback)
    }
    
    // MARK: - 搜索进展
    static func getSearchSteps(_ keyword: String, page: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/v2/search/step?uid=\(s_uid)&&shell=\(s_shell)&&keyword=\(keyword)&&page=\(page)", callback: callback)
    }
    
    // MARK: - 搜索话题
    static func getSearchTopics(_ keyword: String, page: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/follow/tag?uid=\(s_uid)&&shell=\(s_shell)&&tag=\(keyword)&&page=\(page)", callback: callback)
    }
    
    // MARK: -
    static func getHasFollowTopic(_ keyword: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/tags/status?uid=\(s_uid)&&shell=\(s_shell)&&tag=\(keyword)", callback: callback)
    }
    
    // MARK: - 关注搜索内容
    static func postSearchFollow(_ keyword: String, type: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/topic/tag/follow?uid=\(s_uid)&&shell=\(s_shell)", content: ["tag": "\(keyword)", "type": "\(type)"], callback: callback)
    }
    
    static func getSearchUsers(_ callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/search_user.php", callback: callback)
    }
    
    // 自动提示
    static func getAutoComplete(_ keyword: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/tags/autocomplete?uid=\(s_uid)&shell=\(s_shell)&keyword=\(keyword)", callback: callback)
    }
    
    // 搜索标签
    static func getSearchTags(_ keyword: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/searchtags.php?keyword=\(keyword)", callback: callback)
    }
    
    // 添加标签
    static func getTags(_ tag: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/tags.php?tag=\(tag)", callback: callback)
    }
    
    static func postTag(_ tag: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/tags?uid=\(s_uid)&&shell=\(s_shell)", content: ["tag": "\(tag)"], callback: callback)
    }
    
    static func postCircle(_ page: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/circle_list.php", content: ["uid": "\(s_uid)", "shell": "\(s_shell)", "page": "\(page)"], callback: callback)
    }
    
    static func getCircleStep(_ id: String, page: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/circle/\(id)/steps?uid=\(s_uid)&shell=\(s_shell)&page=\(page)", callback: callback)
    }
    
    static func getLevelCalendar(_ callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/calendar.php?uid=\(s_uid)", callback: callback)
    }
    
    static func getUserTop(_ uid:Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/user/\(uid)?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func getDreamStep(_ id: String, page: Int, sort: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/v2/multidream/\(id)?uid=\(s_uid)&sort=\(sort)&page=\(page)&shell=\(s_shell)", callback: callback)
    }
    
    /* 获取我的所有进展 */
    static func getMyStep(_ page: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/user/\(s_uid)/active?uid=\(s_uid)&page=\(page)&shell=\(s_shell)", callback: callback)
    }
    
    static func getSingleStep(_ id: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/v2/step/\(id)/comments?uid=\(s_uid)&sid=\(id)&shell=\(s_shell)", callback: callback)
    }
    
    static func getDreamNewest(_ callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/addstep_dream.php?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func getDreamTag(_ tag:Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/circle_join_dream.php?uid=\(s_uid)&shell=\(s_shell)&tag=\(tag)", callback: callback)
    }
    
    static func getDreamTop(_ id:String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/dream/\(id)?&uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func getCircleDetail(_ circle:String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/circle_detail.php?uid=\(s_uid)&id=\(circle)", callback: callback)
    }
    
    static func getCircleTitle(_ id:String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/circle_title.php?id=\(id)", callback: callback)
    }
    
    /* 应用内购买念币 */
    static func postIapVerify(_ transactionId: String, data: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/payment/apple/iap/verify?uid=\(s_uid)&shell=\(s_shell)", content: ["transaction_id": transactionId, "data": data], callback: callback)
    }
    
    static func getCircleExplore(_ page: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/circle/explore?page=\(page)", callback: callback)
    }
    
    static func getCircleChatList(_ page: Int, id: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/circle_chat_list.php?page=\(page)&id=\(id)&uid=\(s_uid)", callback: callback)
    }
    
    static func postLetter(_ callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/letter/list?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func getWeibo(_ weibouid:String, Token:String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/weibo.php?uid=\(s_uid)&shell=\(s_shell)&weibouid=\(weibouid)&token=\(Token)", callback: callback)
    }
    
    static func postStep(dreamId: String, content: String, stepType: Int, imagesString: NSString, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/multidream/\(dreamId)/update?uid=\(s_uid)&shell=\(s_shell)", content: ["content": content, "type": "\(stepType)", "images": "\(imagesString)"], callback: callback)
    }
    
    static func postStepEdit(sid: String, content: String, stepType: Int, imagesString: NSString, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/v2/step/\(sid)/edit?uid=\(s_uid)&shell=\(s_shell)", content: ["content": content, "type": "\(stepType)", "images": "\(imagesString)"], callback: callback)
    }
    
    static func postUserPrivate(_ userPrivate: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/user_update.php", content: ["uid": "\(s_uid)", "shell": "\(s_shell)", "type": "4", "private": "\(userPrivate)"], callback: callback)
    }
    
    static func postUserPhone(_ phone: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/user_update.php", content: ["uid": "\(s_uid)", "shell": "\(s_shell)", "type": "5", "phone": "\(phone)"], callback: callback)
    }
    
    static func postUserSex(_ sex: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/user_update.php", content: ["uid": "\(s_uid)", "shell": "\(s_shell)", "type": "6", "sex": "\(sex)"], callback: callback)
    }
    
    static func postUserCover(_ callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/user_update.php", content: ["uid": "\(s_uid)", "shell": "\(s_shell)", "type": "7"], callback: callback)
    }
    
    static func postUserFrequency(_ isMonthly: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/user_update.php", content: ["uid": "\(s_uid)", "shell": "\(s_shell)", "type": "8", "isMonthly": "\(isMonthly)"], callback: callback)
    }
    
    static func getNian(_ callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/user/\(s_uid)/dreams?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func postLike(_ step: String, like: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/like_query.php", content: ["uid": "\(s_uid)", "shell": "\(s_shell)", "step": "\(step)", "like": "\(like)"], callback: callback)
    }
    
    static func getGameover(_ callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/game/over?uid=\(s_uid)&&shell=\(s_shell)", callback: callback)
    }
    
    static func postGameoverCoin(_ id: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/gameover_coin.php", content: ["uid": "\(s_uid)", "shell": "\(s_shell)", "id": "\(id)"], callback: callback)
        
    }
    
    static func getDeleteDream(_ id: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/dream/\(id)/delete?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func getNews(_ callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/news.php", callback: callback)
    }
    
    static func postAddDream(_ title: String, content: String, uploadUrl: String, isPrivate: Int, tags: NSArray, permission: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        if tags.count == 0 {
            V.httpPostForJson("http://api.nian.so/v2/dream?uid=\(s_uid)&shell=\(s_shell)",
                content: ["content": "\(content)", "title": "\(title)", "img": "\(uploadUrl)", "private": "\(isPrivate)", "permission": permission],
                callback: callback)
        } else {
            V.httpPostForJson("http://api.nian.so/v2/dream?uid=\(s_uid)&shell=\(s_shell)",
                content: ["content": "\(content)", "title": "\(title)", "img": "\(uploadUrl)", "private": "\(isPrivate)", "tags": tags, "permission": permission], callback: callback)
        }
    }
    
    static func postEditDream(_ id: String, title: String, content: String, uploadUrl: String, editPrivate: Int, tags: NSArray, permission: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        if tags.count == 0 {
            V.httpPostForJson("http://api.nian.so/dream/\(id)/edit?uid=\(s_uid)&shell=\(s_shell)",
                content: ["content": "\(content)", "title": "\(title)", "image": "\(uploadUrl)", "private": "\(editPrivate)", "permission": permission], callback: callback)
        } else {
            V.httpPostForJson("http://api.nian.so/dream/\(id)/edit?uid=\(s_uid)&shell=\(s_shell)",
                content: ["content": "\(content)", "title": "\(title)", "image": "\(uploadUrl)", "private": "\(editPrivate)", "tags": tags, "permission": permission], callback: callback)
        }
        
    }
    
    static func postEditStep_AFN(_ sid: String, content: String, uploadUrl: String, uploadWidth: String, uploadHeight: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/step/\(sid)/edit?uid=\(s_uid)&shell=\(s_shell)",
            content: ["content": "\(content)", "image": "\(uploadUrl)", "width": "\(uploadWidth)", "height": "\(uploadHeight)"],
            callback: callback)
    }
    
    
    static func postCircleTag(_ callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/circle_tag2.php", content: ["uid": "\(s_uid)", "shell": "\(s_shell)"], callback: callback)
    }
    
    
    static func getDreamForAddStep(_ callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/addstep_dream.php?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    
    static func postDeleteStep(_ sid: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/step/\(sid)/delete?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    
    static func getFollowDream(_ dream: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/dream/\(dream)/follow?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func getUnFollowDream(_ dream: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/dream/\(dream)/unfollow?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    /* 添加回应 */
    static func postDreamStepComment(_ dream: String, step: String, content: String, type: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/v2/step/\(step)/comment?uid=\(s_uid)&shell=\(s_shell)", content: ["dream_id": dream, "content": content, "type": type], callback: callback)
    }
    
    /* 删除回应 */
    static func postDeleteComment(_ id: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/comment/\(id)/delete?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    /* 获取回应 */
    static func getDreamStepComment(_ sid: String, page: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/step/\(sid)/comments?page=\(page)&uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    /* 关注用户 */
    static func getFollow(_ uid: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/user/\(uid)/follow?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    /* 取消关注用户 */
    static func getUnfollow(_ uid: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/user/\(uid)/unfollow?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    
    static func getBBS(_ id: String, page: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/circle/\(id)/bbs?page=\(page)", callback: callback)
    }
    
    static func getLike(_ dream: String, page: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/like2.php?page=\(page)&id=\(dream)&myuid=\(s_uid)", callback: callback)
    }
    
    
    static func getFollowList(_ uid: String, page: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/user_fo_list2.php?page=\(page)&uid=\(uid)&myuid=\(s_uid)", callback: callback)
    }
    
    
    static func getFollowedList(_ uid: String, page: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/user_foed_list2.php?page=\(page)&uid=\(uid)&myuid=\(s_uid)", callback: callback)
    }
    
    // MARK: - 通过 user nick Name 获得 User id
    static func postUserNickName(_ name: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/user/username?uid=\(s_uid)&&shell=\(s_shell)", content: ["username": name], callback: callback)
    }
    
    /**
     获得通知详情
     */
    static func getNotify(_ type: String, page: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/v2/notify?type=\(type)&page=\(page)&uid=\(s_uid)&shell=\(s_shell)", callback: callback)
        //        GET /v2/notify
    }
    
    
    static func getUserDream(_ uid: String, page: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/user/\(uid)/dreams?uid=\(s_uid)&shell=\(s_shell)&page=\(page)", callback: callback)
    }
    
    static func getUserActive(_ uid: String, page: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/v2/user/\(uid)/steps?page=\(page)&uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    /* 获取我赞过的进展 */
    static func getLikeSteps(_ page: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/v2/user/\(s_uid)/like/steps?page=\(page)&uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func getConsume(_ type: String, coins: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/consume?uid=\(s_uid)&shell=\(s_shell)", content: ["type": type, "coins": "\(coins)"], callback: callback)
    }
    
    /* 拖进小黑屋 */
    static func postBlackAdd(_ uid: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/blacklist/add?uid=\(s_uid)&shell=\(s_shell)", content: ["user": "\(uid)"], callback: callback)
    }
    
    /* 取消小黑屋 */
    static func postBlackRemove(_ uid: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/blacklist/remove?uid=\(s_uid)&shell=\(s_shell)", content: ["user": "\(uid)"], callback: callback)
    }
}


// MARK: - 和宠物相关的 API
extension  Api {
    
    /**
     抽取宠物
     
     - parameter callback: <#callback description#>
     */
    static func postPetLottery(_ tag: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        let _sha256String = ((s_uid + s_shell) as NSString).sha256()!
        V.httpPostForJson("http://api.nian.so/pet/extract?uid=\(s_uid)&&shell=\(s_shell)&tag=\(tag)", content: ["luckcode": _sha256String], callback: callback)
    }
    
    /**
     获得用户的宠物
     
     - parameter page:     <#page description#>
     - parameter callback: <#callback description#>
     */
    static func getUserPet(_ page: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/user/\(s_uid)/pets?uid=\(s_uid)&&shell=\(s_shell)&&page=\(page)", callback: callback)
    }
    
    static func getPetUpgrade(_ pet: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/pet/\(pet)/upgrade?uid=\(s_uid)&&shell=\(s_shell)", callback: callback)
    }
    
    static func getAllPets(_ callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/pets?uid=\(s_uid)&&shell=\(s_shell)", callback: callback)
    }
    
}

// MARK: - 新的注册 API
extension Api {
    
    static func postSignUp(_ name: String, password: String, email: String, daily: Int, callback: @escaping V.JsonCallback) {
        //        loadCookies()
        V.httpPostForJson("http://api.nian.so/user/signup", content: ["username": "\(name)", "email": "\(email)", "password": "\(password)", "daily": daily], callback: callback)
    }
    
}

// MARK: - 新广场 API
extension Api {
    static func postAddReddit(_ title: String, content: String, tags: NSArray, callback: @escaping V.JsonCallback) {
        loadCookies()
        //        if tags == "" {
        if tags.count == 0 {
            V.httpPostForJson("http://api.nian.so/topic?uid=\(s_uid)&shell=\(s_shell)", content: ["title": "\(title)", "content": "\(content)", "type": "question"], callback: callback)
        } else {
            V.httpPostForJson("http://api.nian.so/topic?uid=\(s_uid)&shell=\(s_shell)", content: ["title": "\(title)", "content": "\(content)", "tags": tags, "type": "question"], callback: callback)
        }
    }
    
    /**
     编辑话题之后要上传 id
     */
    static func postEditReddit(_ id: String, title: String, content: String, tags: NSArray, callback: @escaping V.JsonCallback) {
        loadCookies()
        if tags.count == 0 {
            V.httpPostForJson("http://api.nian.so/topic/\(id)/edit?uid=\(s_uid)&shell=\(s_shell)", content: ["title": "\(title)", "content": "\(content)"], callback: callback)
        } else {
            V.httpPostForJson("http://api.nian.so/topic/\(id)/edit?uid=\(s_uid)&shell=\(s_shell)", content: ["title": "\(title)", "content": "\(content)", "tags": tags], callback: callback)
        }
    }
    
    static func postMention(_ topicId: String, commentId: String, mentions: NSArray, callback: @escaping V.JsonCallback) {
        loadCookies()
        if commentId == "" {
            V.httpPostForJson("http://api.nian.so/mention?uid=\(s_uid)&&shell=\(s_shell)", content: ["topic_id": "\(topicId)", "mentions": mentions], callback: callback)
        } else if topicId == "" {
            V.httpPostForJson("http://api.nian.so/mention?uid=\(s_uid)&&shell=\(s_shell)", content: ["comment_id": "\(commentId)", "mentions": mentions], callback: callback)
        }
    }
    
    static func postAddRedditComment(_ id: String, content: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/topic?uid=\(s_uid)&shell=\(s_shell)", content: ["content": "\(content)", "type": "answer", "question_id": "\(id)"], callback: callback)
    }
    
    static func getReddit(_ page: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/topics?page=\(page)&uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func getRedditFollow(_ page: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/user/\(s_uid)/follow/topics?page=\(page)&uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func getVoteUp(_ id: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/topic/\(id)/vote/up?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func getVoteDown(_ id: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/topic/\(id)/vote/down?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    
    static func getVoteUpDelete(_ id: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/topic/\(id)/vote/up/delete?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func getVoteDownDelete(_ id: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/topic/\(id)/vote/down/delete?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    //    GET /topic/{topic_id}/hot
    
    // 获得热门评论
    static func getTopicCommentHot(_ id: String, page: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/topic/\(id)/hot?uid=\(s_uid)&shell=\(s_shell)&page=\(page)", callback: callback)
    }
    
    // 获得最新评论
    static func getTopicCommentNew(_ id: String, page: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/topic/\(id)/newest?uid=\(s_uid)&shell=\(s_shell)&page=\(page)", callback: callback)
    }
    
    // 获得记本信息
    static func getDream(_ id: String, callback : @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/topic/dream/\(id)", callback: callback)
    }
    
    // 获得话题顶部
    static func getTopic(_ id: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/topic/\(id)?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    // 发布评论的评论
    static func postTopicCommentComment(_ id: String, content: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/topic/comment?uid=\(s_uid)&shell=\(s_shell)", content: ["topic_id": "\(id)", "content": content], callback: callback)
    }
    
    // 获得评论的评论
    static func getTopicCommentComment(_ id: String, page: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/topic/answer/\(id)/comments?uid=\(s_uid)&shell=\(s_shell)&page=\(page)", callback: callback)
    }
    
    // 删除某个回应
    static func getTopicDelete(_ id: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/topic/\(id)/delete?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    // 删除回应的回应
    static func getTopicCommentDelete(_ id: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/topic/comment/\(id)/delete?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    // 查询通行证
    static func getPassportStatus(_ callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/passport?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    // 购买通行证
    static func getPassport(_ callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/passport/exchange?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
}


// MARK: - 活动 API
extension Api {
    static func getRewardsActivity(_ activity: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/rewardsactivity.php?uid=\(s_uid)&shell=\(s_shell)&activity=\(activity)", callback: callback)
    }
    
    static func getRewards(_ activity: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/rewards.php?uid=\(s_uid)&shell=\(s_shell)&activity=\(activity)", callback: callback)
    }
}

extension Api {
    // 获得用户第三方账号绑定情况
    static func getUserAllOauth(_ callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/oauth/all?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    // 获得用户的设置，如是否日更，性别，手机号等
    static func getUserInfoAndSetting(_ callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/user/\(s_uid)?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    // 绑定第三方账号
    static func bindThirdAccount(_ id: String, nameFrom3rd: String, type: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/oauth/auth/binding?uid=\(s_uid)&shell=\(s_shell)", content: ["nickname": "\(nameFrom3rd)", "auth_id": "\(id)", "type": "\(type)"], callback: callback)
    }
    
    // 解除绑定第三方账号
    static func relieveThirdAccount(_ type: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/oauth/remove?uid=\(s_uid)&shell=\(s_shell)&type=\(type)", callback: callback)
    }
    
    // 更改封面
    static func changeCoverImage(_ coverURL: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/user/\(s_uid)/cover/edit?uid=\(s_uid)&shell=\(s_shell)", content: ["cover": coverURL], callback: callback)
    }
    
    // 绑定邮箱
    static func bindEmail(_ email: String, password: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/oauth/email/binding?uid=\(s_uid)&shell=\(s_shell)", content: ["email": email, "password": password], callback: callback)
    }
    
    // 更新账号信息和设置
    static func updateUserInfo(_ settingInfo: Dictionary<String, String>, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/user/\(s_uid)/edit?uid=\(s_uid)&shell=\(s_shell)", content: settingInfo as AnyObject, callback: callback)
    }
    
    // 检查邮箱格式是否正确
    static func checkEmailValidation(_ email: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/check/email?email=\(email)", callback: callback)
    }
    
    // 登录
    static func logIn(_ email: String, password: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/user/login", content: ["email": "\(email)", "password": "\(password)"], callback: callback)
    }
    
    // 注册
    static func register(_ email: String, password: String, username: String, daily: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/user/signup", content: ["username": "\(username)", "email": "\(email)", "password": "\(password)", "daily": "\(daily)"], callback: callback)
    }
    
    // 通过第三方注册
    static func registerVia3rd(_ id: String, type: String, name: String, nameFrom3rd: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/oauth/attempt", content: ["username": "\(name)", "nickname": "\(nameFrom3rd)", "auth_id": "\(id)", "type": "\(type)"], callback: callback)
    }
    
    // 重置密码
    static func resetPassword(_ email: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/password/reset/mail", content: ["email": "\(email)"], callback: callback)
    }
    
    // 通过第三方登录
    static func logInVia3rd(_ id: String, type: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/oauth/login", content: ["auth_id": "\(id)", "type": "\(type)"], callback: callback)
    }
    
    // 检查昵称格式是否正确
    static func checkNameAvailability(_ name: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/user/check?username=\(SAEncode(SAHtml(name)))", callback: callback)
    }
    
    // 获得微信名
    static func getWechatName(_ accessToken: String, openid: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("https://api.weixin.qq.com/sns/userinfo?access_token=\(accessToken)&openid=\(openid)&lang=zh_CN", callback: callback)
    }
    
    // 获得微信名
    static func getWeiboName(_ accessToken: String, openid: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("https://api.weibo.com/2/users/show.json?access_token=\(accessToken)&uid=\(openid)", callback: callback)
    }
    
    // 获得 QQ 名
    static func getQQName(_ accessToken: String, openid: String, appid: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("https://graph.qq.com/user/get_user_info?oauth_consumer_key=\(appid)&access_token=\(accessToken)&openid=\(openid)", callback: callback)
    }
    
    // 检查第三方授权
    static func check3rdOauth(_ id: String, type: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/oauth/check", content: ["auth_id": "\(id)", "type": "\(type)"], callback: callback)
    }
    
    
}

extension Api {
    
    /* 获取融云 IM 的 Token */
    static func getRongToken(_ callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/message/token?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    /* 获取融云 IM 的开发环境的 Token */
    static func getRongTokenDevelopment(_ callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/message/test/token?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func getPlankton(_ callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/plankton/all?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func getPlanktonIncrease(_ callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/plankton/increase?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    /* 记本邀请好友一同更新 */
    static func getMultiInviteList(_ id: String, page: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/multidream/\(id)/invite/users?uid=\(s_uid)&shell=\(s_shell)&page=\(page)", callback: callback)
    }
    
    /* 发送邀请 */
    static func getInvite(_ id: String, uid: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/multidream/invite/user/\(uid)/dream/\(id)?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    /* 接受邀请 */
    static func postJoin(_ id: String, cuid: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/multidream/join/dream/\(id)?uid=\(s_uid)&shell=\(s_shell)", content: ["cuid": cuid], callback: callback)
    }
    
    /* 获取多人记本成员列表 */
    static func getMultiDreamList(_ id: String, page: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/multidream/\(id)/users?uid=\(s_uid)&shell=\(s_shell)&page=\(page)", callback: callback)
    }
    
    /* 移除多人记本成员 */
    static func getKick(_ id: String, uid: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/multidream/\(id)/kick/user/\(uid)?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    /* 离开多人记本 */
    static func getQuit(_ id: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/multidream/leave/dream/\(id)?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    /* 微信支付获取订单 */
    static func postWechatPay(_ price: String, coins: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/payment/wxpay/order?uid=\(s_uid)&shell=\(s_shell)", content: ["price": price, "coins": coins], callback: callback)
    }
    
    /* 支付宝支付获取订单 */
    static func postAlipayPay(_ price: String, coins: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/payment/alipay/order?uid=\(s_uid)&shell=\(s_shell)", content: ["price": price, "coins": coins], callback: callback)
    }
    
    /* 微信支付购买会员 */
    static func postWechatMember(_ callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/payment/wxpay/order?uid=\(s_uid)&shell=\(s_shell)", content: ["type": "member"], callback: callback)
    }
    
    /* 支付宝支付购买会员 */
    static func postAlipayMember(_ callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/payment/alipay/order?uid=\(s_uid)&shell=\(s_shell)", content: ["type": "member"], callback: callback)
    }
    
    /* 微信支付奖励 */
    static func postWechatPremium(_ price: String, stepId: String, receiver: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        var coins = "0"
        if price == "0.50" {
            coins = "0"
        } else if price == "1.00" {
            coins = "1"
        } else if price == "5.00" {
            coins = "2"
        } else if price == "10.00" {
            coins = "3"
        } else if price == "50.00" {
            coins = "4"
        } else if price == "200.00" {
            coins = "5"
        }
        V.httpPostForJson("http://api.nian.so/payment/wxpay/order?uid=\(s_uid)&shell=\(s_shell)", content: ["type": "reward", "price": price, "stepid": stepId, "receiver": receiver, "coins": coins], callback: callback)
    }
    
    /* 支付宝支付奖励 */
    static func postAlipayPremium(_ price: String, stepId: String, receiver: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        var coins = "0"
        if price == "0.50" {
            coins = "0"
        } else if price == "1.00" {
            coins = "1"
        } else if price == "5.00" {
            coins = "2"
        } else if price == "10.00" {
            coins = "3"
        } else if price == "50.00" {
            coins = "4"
        } else if price == "200.00" {
            coins = "5"
        }
        V.httpPostForJson("http://api.nian.so/payment/alipay/order?uid=\(s_uid)&shell=\(s_shell)", content: ["type": "reward", "price": price, "stepid": stepId, "receiver": receiver, "coins": coins], callback: callback)
    }
    
    
    //    POST /payment/alipay/order/test 测试地址
    
    /* 获取表情列表 */
    static func getEmoji(_ callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/shop/products?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    /* 购买表情 */
    static func postEmojiBuy(_ code: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/shop/buy?uid=\(s_uid)&shell=\(s_shell)", content: ["code": code], callback: callback)
    }
    
    /* 请假 */
    static func postLeave(_ callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/exchange?uid=\(s_uid)&shell=\(s_shell)", content: ["type": "leave"], callback: callback)
    }
    
    /* 购买毕业证 */
    static func getGraduate(_ callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/shop/graduate/buy?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    /* 推广 */
    static func postPromo(_ id: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://api.nian.so/shop/promote/buy?uid=\(s_uid)&shell=\(s_shell)", content: ["dream": id], callback: callback)
    }
    
    /* 获取用户奖励余额 */
    static func getBalance(_ callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/user/\(s_uid)/balance?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    /* 提取用户奖励余额 */
    static func getExchange(_ callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/user/\(s_uid)/exchange?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    /* 获取进展中的赞列表 */
    static func getLike(_ page: Int, stepId: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/v2/step/\(stepId)/like/users?page=\(page)&uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    /* 获取记本中的关注列表 */
    static func getDreamFollow(_ dreamId: String, page: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/multidream/\(dreamId)/followers?page=\(page)&uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    /* 获取记本中的关注列表 */
    static func getDreamLike(_ dreamId: String, page: Int, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/multidream/\(dreamId)/likes?page=\(page)&uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    /* 完成记本 */
    static func getDreamComplete(_ dreamId: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/dream/\(dreamId)/complete?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    /* 不完成记本 */
    static func getDreamInComplete(_ dreamId: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/dream/\(dreamId)/incomplete?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    
    /* 赞记本 */
    static func getDreamLike(_ dreamId: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/dream/\(dreamId)/like?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    /* 不赞记本 */
    static func getDreamUnLike(_ dreamId: String, callback: @escaping V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://api.nian.so/dream/\(dreamId)/unlike?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
}

