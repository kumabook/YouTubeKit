//
//  Subscription.swift
//  YouTubeKit
//
//  Created by Hiroki Kumamoto on 2017/04/07.
//  Copyright © 2017 Hiroki Kumamoto. All rights reserved.
//

import Foundation

open class Subscription: ChannelResource, Resource {
    open class var url: String { return "https://www.googleapis.com/youtube/v3/subscriptions" }
    open class var params: [String:String] { return ["mine": "true"] }
}
