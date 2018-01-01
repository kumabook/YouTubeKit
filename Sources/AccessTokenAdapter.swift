//
//  AccessTokenAdapter.swift
//  YouTubeKit
//
//  Created by Hiroki Kumamoto on 2018/01/01.
//  Copyright © 2018 Hiroki Kumamoto. All rights reserved.
//

import Foundation
import Alamofire

public class AccessTokenAdapter: RequestAdapter {
    public var accessToken: String?
    init(accessToken: String?) {
        self.accessToken = accessToken
    }

    public func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        guard let token = accessToken else { return urlRequest }
        guard let urlString = urlRequest.url?.absoluteString else { return urlRequest }
        if urlString.hasPrefix("https://www.googleapis.com") {
            urlRequest.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        }
        return urlRequest
    }
}
