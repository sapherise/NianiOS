//
//  Vote.swift
//  Nian iOS
//
//  Created by Sa on 15/9/10.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation

struct Vote {
    static func onUp(data: NSDictionary, delegate: RedditDelegate?, index: Int) {
        let id = data.stringAttributeForKey("id")
        let vote = data.stringAttributeForKey("vote")
        let numLike = Int(data.stringAttributeForKey("like_count"))
        let numDislike = Int(data.stringAttributeForKey("dislike_count"))
        if vote == "0" {
            delegate?.updateData(index, key: "like_count", value: "\(numLike! + 1)")
            delegate?.updateData(index, key: "vote", value: "1")
            Api.getVoteUp(id) { json in
            }
        } else if vote == "-1" {
            delegate?.updateData(index, key: "like_count", value: "\(numLike! + 1)")
            delegate?.updateData(index, key: "dislike_count", value: "\(numDislike! - 1)")
            delegate?.updateData(index, key: "vote", value: "1")
            Api.getVoteUp(id) { json in
            }
        } else if vote == "1" {
            delegate?.updateData(index, key: "like_count", value: "\(numLike! - 1)")
            delegate?.updateData(index, key: "vote", value: "0")
            Api.getVoteUpDelete(id) { json in
            }
        }
        delegate?.updateTable()
    }
    
    static func onDown(data: NSDictionary, delegate: RedditDelegate?, index: Int) {
        let id = data.stringAttributeForKey("id")
        let vote = data.stringAttributeForKey("vote")
        let numLike = Int(data.stringAttributeForKey("like_count"))
        let numDislike = Int(data.stringAttributeForKey("dislike_count"))
        if vote == "0" {
            delegate?.updateData(index, key: "dislike_count", value: "\(numDislike! + 1)")
            delegate?.updateData(index, key: "vote", value: "-1")
            Api.getVoteDown(id) { json in
            }
        } else if vote == "1" {
            delegate?.updateData(index, key: "like_count", value: "\(numLike! - 1)")
            delegate?.updateData(index, key: "dislike_count", value: "\(numDislike! + 1)")
            delegate?.updateData(index, key: "vote", value: "-1")
            Api.getVoteDown(id) { json in
            }
        } else if vote == "-1" {
            delegate?.updateData(index, key: "dislike_count", value: "\(numDislike! - 1)")
            delegate?.updateData(index, key: "vote", value: "0")
            Api.getVoteDownDelete(id) { json in
            }
        }
        delegate?.updateTable()
    }
    
    func setupVoteUp(selected: Bool, viewUp: UIImageView, labelNum: UILabel, viewVoteLine: UIView) {
        if selected {
            viewUp.layer.borderColor = SeaColor.CGColor
            viewUp.backgroundColor = SeaColor
            labelNum.textColor = UIColor.whiteColor()
            viewVoteLine.backgroundColor = UIColor.whiteColor()
            viewUp.image = UIImage(named: "voteupwhite")
        } else {
            viewUp.layer.borderColor = UIColor.e6().CGColor
            viewUp.backgroundColor = UIColor.whiteColor()
            labelNum.textColor = UIColor.b3()
            viewVoteLine.backgroundColor = UIColor.e6()
            viewUp.image = UIImage(named: "voteup")
        }
    }
    
    func setupVoteDown(selected: Bool, viewDown: UIImageView) {
        if selected {
            viewDown.layer.borderColor = SeaColor.CGColor
            viewDown.backgroundColor = SeaColor
            viewDown.image = UIImage(named: "votedownwhite")
        } else {
            viewDown.layer.borderColor = UIColor.e6().CGColor
            viewDown.backgroundColor = UIColor.whiteColor()
            viewDown.image = UIImage(named: "votedown")
        }
    }
    
    func setupVote(data: NSDictionary, viewUp: UIImageView, viewDown: UIImageView, viewVoteLine: UIView, labelNum: UILabel) {
        let vote = data.stringAttributeForKey("vote")
        if vote == "1" {
            Vote().setupVoteUp(true, viewUp: viewUp, labelNum: labelNum, viewVoteLine: viewVoteLine)
            setupVoteDown(false, viewDown: viewDown)
        } else if vote == "-1" {
            setupVoteUp(false, viewUp: viewUp, labelNum: labelNum, viewVoteLine: viewVoteLine)
            setupVoteDown(true, viewDown: viewDown)
        } else {
            setupVoteUp(false, viewUp: viewUp, labelNum: labelNum, viewVoteLine: viewVoteLine)
            setupVoteDown(false, viewDown: viewDown)
        }
    }
}