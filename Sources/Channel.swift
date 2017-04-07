//
//  Channel.swift
//  YouTubeKit
//
//  Created by Hiroki Kumamoto on 2017/04/07.
//  Copyright © 2017 Hiroki Kumamoto. All rights reserved.
//

import Foundation

open class Channel: ChannelResource, Resource {
    open class var url: String { return "https://www.googleapis.com/youtube/v3/channels" }
    open class var params: [String:String] { return [:] }
    
    public convenience init(subscription: Subscription) {
        self.init(etag: subscription.etag,
                  id: subscription.resourceId["channelId"]!,
                  kind: subscription.resourceId["kind"]!,
                  title: subscription.title,
                  description: subscription.description,
                  publishedAt: subscription.publishedAt,
                  thumbnails: subscription.thumbnails,
                  resourceId: subscription.resourceId)
    }
}
