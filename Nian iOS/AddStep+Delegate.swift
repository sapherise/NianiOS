//
//  AddStep+Delegate.swift
//  Nian iOS
//
//  Created by Sa on 15/12/28.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation

extension AddStep {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCellWithIdentifier("AddStepCell", forIndexPath: indexPath) as! AddStepCell
        let data = self.dataArray[indexPath.row] as? NSDictionary
        c.data = data
        c.setup()
        return c
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.hidden = true
        let data = dataArray[indexPath.row] as! NSDictionary
        let id = data.stringAttributeForKey("id")
        let title = data.stringAttributeForKey("title")
        let image = data.stringAttributeForKey("image")
        let userImageURL = "http://img.nian.so/dream/\(image)!dream"
        self.imageDream.setImage(userImageURL)
        self.idDream = id
        self.labelDream.text = title
    }
}