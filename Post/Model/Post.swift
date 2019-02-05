//
//  Post.swift
//  Post
//
//  Created by Chris Grayston on 2/4/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import Foundation

struct Post: Codable {
    // MARK: - Properties
    let username: String
    let text: String
    let timestamp: TimeInterval
    
    // MARK: - Initilizer Memberwise
    init(username: String, text: String, timestamp: TimeInterval = Date().timeIntervalSince1970) {
        self.username = username
        self.text = text
        self.timestamp = timestamp
    }
    
    // computed Property
    var queryTimestamp: TimeInterval {
        return self.timestamp - 0.00001
    }
    
    // Black Diamond Day One
    var date: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: Date(timeIntervalSince1970: timestamp))
    }
}
