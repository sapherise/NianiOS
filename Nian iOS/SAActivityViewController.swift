//
//  SAActivityViewController.swift
//  Nian iOS
//
//  Created by Sa on 15/7/16.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

class SAActivityViewController {
    class func shareSheetInView(_ activityItems: [AnyObject], applicationActivities: [UIActivity], isStep: Bool = false) -> UIActivityViewController {
        var newArray: [UIActivity] = applicationActivities
        let WeChatSession = WeChatSessionActivity()
        WeChatSession.isStep = isStep
        let WeChatMoments = WeChatMomentsActivity()
        WeChatMoments.isStep = isStep
        newArray.append(WeChatSession)
        newArray.append(WeChatMoments)
        let avc = UIActivityViewController(activityItems: activityItems, applicationActivities: newArray)
        avc.excludedActivityTypes = [UIActivityType.addToReadingList, UIActivityType.airDrop, UIActivityType.assignToContact, UIActivityType.postToFacebook, UIActivityType.postToFlickr, UIActivityType.postToVimeo, UIActivityType.print]
        return avc
    }
}
