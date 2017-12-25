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
        didSet { renewManager() }
    }
    public var manager: Alamofire.SessionManager = Alamofire.SessionManager()

    func renewManager() {
        let configuration = manager.session.configuration
        var headers = configuration.httpAdditionalHeaders ?? [:]
        if let token = accessToken {
            headers["Authorization"] = "Bearer \(token)"
        } else {
            headers.removeValue(forKey: "Authorization")
        }
        configuration.httpAdditionalHeaders = headers
        manager = Alamofire.SessionManager(configuration: configuration)
    }

    public func fetch<T: Resource>(_ params: [String:String], completionHandler: @escaping (DataResponse<PaginatedResponse<T>>) -> Void) -> Request {
        var parameters: [String: AnyObject] = ["key": self.API_KEY as AnyObject,
                                              "part": "snippet" as AnyObject,
                                        "maxResults": 10 as AnyObject]
        for k in params.keys {
            parameters[k] = params[k] as AnyObject?
        }
        return manager.request(T.url, method: .get, parameters: parameters, encoding:  URLEncoding.default)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseObject(completionHandler: completionHandler)
    }

    public func fetchGuideCategories(regionCode: String, pageToken: String?, completionHandler: @escaping (DataResponse<PaginatedResponse<GuideCategory>>) -> Void) -> Request {
        let url = "https://www.googleapis.com/youtube/v3/guideCategories"
        var params: [String : Any] = ["key": API_KEY, "part": "snippet", "maxResults": 10, "regionCode": regionCode]
        if let token = pageToken {
            params["pageToken"] = token
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
        var params: [String: Any] = ["key"        : API_KEY   as AnyObject,
                                     "part"       : "snippet" as AnyObject,
                                     "maxResults" : 10        as AnyObject,
                                     "regionCode" : "JP"      as AnyObject,
                                     "type"       : "channel" as AnyObject,
                                     "channelType": "any"     as AnyObject]
        if let token = pageToken {
            params["pageToken"] = token as Any?
        }
        if let q = query {
            params["q"] = q as Any?
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
