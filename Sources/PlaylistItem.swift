//
//  PlaylistItem.swift
//  YouTubeKit
//
//  Created by Hiroki Kumamoto on 2017/04/07.
//  Copyright © 2017 Hiroki Kumamoto. All rights reserved.
//

import Foundation
import SwiftyJSON

open class PlaylistItem: Resource, Hashable, Equatable, JSONSerializable {
    open class var url: String { return "https://www.googleapis.com/youtube/v3/playlistItems" }
    open class var params: [String:String] { return [:] }
    open let etag:        String
    open let id:          String
    open let kind:        String
    open let title:       String!
    open let description: String!
    open let publishedAt: String?
    open let thumbnails: [String:String]
    open let resourceId: [String:String]
    
    open let position:      UInt
    open let videoId:       String
    open let startAt:       String?
    open let endAt:         String?
    open let note:          String?
    open let privacyStatus: String?
    
    open let channelId:     String
    open let channelTitle:  String
    
    open var hashValue: Int { return id.hashValue }
    
    public required init(json: JSON) {
        let snippet        = json["snippet"].dictionaryValue
        let contentDetails = json["contentDetails"].dictionaryValue
        let status         = json["status"].dictionaryValue
        etag               = json["etag"].stringValue
        id                 = json["id"].stringValue
        kind               = json["kind"].stringValue
        title              = snippet["title"]?.stringValue ?? ""
        description        = snippet["description"]?.stringValue ?? ""
        publishedAt        = snippet["publishedAt"]?.string
        thumbnails         = ChannelResource.thumbnails(snippet)
        resourceId         = ChannelResource.resourceId(snippet)
        
        position           = snippet["position"]?.uIntValue ?? 0
        videoId            = contentDetails["videoId"]!.stringValue
        startAt            = contentDetails["startAt"]?.stringValue
        endAt              = contentDetails["endAt"]?.stringValue
        note               = contentDetails["note"]?.stringValue
        privacyStatus      = status["privacyStatus"]?.stringValue

        channelId          = snippet["channelId"]?.stringValue ?? ""
        channelTitle       = snippet["channelTitle"]?.stringValue ?? ""
    }
    
    open var thumbnailURL: URL? {
        if let url = thumbnails["default"] { return URL(string: url) }
        else if let url = thumbnails["medium"] { return URL(string: url) }
        else if let url = thumbnails["high"]   { return URL(string: url) }
        else                                   { return nil }
    }
    open var artworkURL: URL? {
        if let url = thumbnails["high"]         { return URL(string: url) }
        else if let url = thumbnails["medium"]  { return URL(string: url) }
        else if let url = thumbnails["default"] { return URL(string: url) }
        else                                    { return nil }
    }
}

public func ==(lhs: PlaylistItem, rhs: PlaylistItem) -> Bool {
    return lhs.id == rhs.id
}
