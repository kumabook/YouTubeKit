//
//  APIClient.swift
//  YouTubeKit
//
//  Created by Hiroki Kumamoto on 2017/04/07.
//  Copyright © 2017 Hiroki Kumamoto. All rights reserved.
//

import Alamofire
import SwiftyJSON

public protocol ResponseObjectSerializable {
    init?(response: HTTPURLResponse, representation: Any)
}

public protocol JSONSerializable {
    init(json: JSON)
}

public struct PaginatedResponse<T: JSONSerializable>: ResponseObjectSerializable {
    public init?(response: HTTPURLResponse, representation: Any) {
        let json = JSON(representation)
        self.init(json: json)
    }

    public var nextPageToken: String?
    public var items:         [T]
    public init(json: JSON) {
        items         = json["items"].arrayValue.map { T(json: $0) }
        nextPageToken = json["nextPageToken"].string
    }
}

open class APIClient {
    public static var shared = APIClient()
    public var API_KEY: String = ""
    public var accessToken: String? {
        didSet {
            adapter?.accessToken = accessToken
        }
    }
    public var manager: Alamofire.SessionManager = Alamofire.SessionManager()
    public var adapter: AccessTokenAdapter? {
        return manager.adapter as? AccessTokenAdapter
    }

    init() {
        manager.adapter = AccessTokenAdapter(accessToken: accessToken)
    }

    public func fetch<T: Resource>(_ params: [String:String], completionHandler: @escaping (DataResponse<PaginatedResponse<T>>) -> Void) -> Request {
        var parameters: [String: Any] = ["part": "snippet",
                                         "maxResults": 10]
        for k in params.keys {
            parameters[k] = params[k]
        }
        if accessToken == nil {
            parameters["key"] = API_KEY
        }
        return manager.request(T.url, method: .get, parameters: parameters, encoding:  URLEncoding.default)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseObject(completionHandler: completionHandler)
    }

    public func fetchGuideCategories(regionCode: String, pageToken: String?, completionHandler: @escaping (DataResponse<PaginatedResponse<GuideCategory>>) -> Void) -> Request {
        let url = "https://www.googleapis.com/youtube/v3/guideCategories"
        var params: [String : Any] = ["part": "snippet", "maxResults": 10, "regionCode": regionCode]
        if let token = pageToken {
            params["pageToken"] = token
        }
        if accessToken == nil {
            params["key"] = API_KEY
        }
        return manager.request(url, method: HTTPMethod.get, parameters: params, encoding:  URLEncoding.default)
                      .validate(statusCode: 200..<300)
                      .validate(contentType: ["application/json"])
                      .responseObject(completionHandler: completionHandler)
    }

    public func fetchMyChannels(pageToken: String?, completionHandler: @escaping (DataResponse<PaginatedResponse<MyChannel>>) -> Void) -> Request {
        var params = ["part": "snippet, contentDetails", "mine": "true"]
        if let token = pageToken {
            params["pageToken"] = token
        }
        return fetch(params, completionHandler: completionHandler)
    }
    
    public func fetchChannels(of category: GuideCategory, pageToken: String?, completionHandler: @escaping (DataResponse<PaginatedResponse<Channel>>) -> Void) -> Request {
        var params = ["categoryId": category.id]
        if let token = pageToken {
            params["pageToken"] = token
        }
        return fetch(params, completionHandler: completionHandler)
    }
    
    public func fetchSubscriptions(pageToken: String?, completionHandler: @escaping(DataResponse<PaginatedResponse<Subscription>>) -> Void) -> Request {
        var params = ["mine": "true"]
        if let token = pageToken {
            params["pageToken"] = token
        }
        return fetch(params, completionHandler: completionHandler)
    }
    
    public func searchChannel(by query: String?, pageToken: String?, completionHandler: @escaping (DataResponse<PaginatedResponse<Channel>>) -> Void) -> Request {
        let url = "https://www.googleapis.com/youtube/v3/search"
        var params: [String: Any] = ["part"       : "snippet",
                                     "maxResults" : 10,
                                     "regionCode" : "JP",
                                     "type"       : "channel",
                                     "channelType": "any"]
        if let token = pageToken {
            params["pageToken"] = token
        }
        if let q = query {
            params["q"] = q as Any?
        }
        if accessToken == nil {
            params["key"] = API_KEY
        }
        return manager.request(url, method: .get, parameters: params, encoding:  URLEncoding.default)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseObject(completionHandler: completionHandler)
    }

    public func fetchPlaylist(_ id: String, pageToken: String?, completionHandler: @escaping (DataResponse<PaginatedResponse<Playlist>>) -> Void) -> Request {
        var params = ["playlistId": id]
        if let token = pageToken {
            params["pageToken"] = token
        }
        return fetch(params, completionHandler: completionHandler)
    }
    
    public func fetchMyPlaylists(pageToken: String?, completionHandler: @escaping (DataResponse<PaginatedResponse<Playlist>>) -> Void) -> Request {
        var params = ["mine": "true"]
        if let token = pageToken {
            params["pageToken"] = token
        }
        return fetch(params, completionHandler: completionHandler)
    }
    
    public func fetchPlaylistItems(_ id: String, pageToken: String?, completionHandler: @escaping (DataResponse<PaginatedResponse<PlaylistItem>>) -> Void) -> Request {
        var params = ["playlistId": id, "part": "snippet, contentDetails"]
        if let token = pageToken {
            params["pageToken"] = token
        }
        return fetch(params, completionHandler: completionHandler)
    }
    
    public func fetchPlaylistItems(of playlist: Playlist, pageToken: String?, completionHandler: @escaping (DataResponse<PaginatedResponse<PlaylistItem>>) -> Void) -> Request {
        return fetchPlaylistItems(playlist.id, pageToken: pageToken, completionHandler: completionHandler)
    }
}
