//
//  NewsData.swift
//  reign
//
//  Created by Gerardo Villarroel on 31-05-22.
//

import UIKit
import os.log

class NewsData {
    
    //MARK: Properties
    var storyId: Int64
    var storyTitle: String
    var author: String
    var createdAt: String
    var timeInterval: TimeInterval
    var storyUrl: String
    
    //MARK: Inicialization
    init?(storyId: Int64, storyTitle: String, author: String, createdAt: String, timeInterval: TimeInterval, storyUrl: String) {
        guard !storyTitle.isEmpty && !author.isEmpty else { return nil }
        
        self.storyId = storyId
        self.storyTitle = storyTitle
        self.author = author
        self.createdAt = createdAt
        self.timeInterval = timeInterval
        self.storyUrl = storyUrl
    }
}
