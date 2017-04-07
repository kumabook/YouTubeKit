//
//  DataRequestExtension.swift
//  YouTubeKit
//
//  Created by Hiroki Kumamoto on 2017/04/07.
//  Copyright © 2017 Hiroki Kumamoto. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension DataRequest {
    @discardableResult
    public func responseObject<T: ResponseObjectSerializable>(_ queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        let responseSerializer = DataResponseSerializer<T> { request, response, data, error in
            guard error == nil else { return .failure(APIError.network(error: error!)) }
            
            let jsonResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = jsonResponseSerializer.serializeResponse(request, response, data, nil)
            
            guard case let .success(jsonObject) = result else {
                return .failure(APIError.jsonSerialization(error: result.error!))
            }
            
            guard let response = response, let responseObject = T(response: response, representation: jsonObject) else {
                return .failure(APIError.objectSerialization(reason: "JSON could not be serialized: \(jsonObject)"))
            }
            
            return .success(responseObject)
        }
        return response(queue: queue, responseSerializer: responseSerializer, completionHandler: completionHandler)
    }

    public func response(_ completionHandler: @escaping (DataResponse<Void>) -> Void) -> Self {
        return responseString(encoding: String.Encoding.utf8) { response in
            if response.result.isSuccess {
                completionHandler(DataResponse<Void>(request: response.request,
                                                     response: response.response,
                                                     data: response.data,
                                                     result: Result.success()))
            } else {
                completionHandler(DataResponse<Void>(request: response.request,
                                                     response: response.response,
                                                     data: response.data,
                                                     result: Result.failure(response.result.error!)))
            }
        }
    }
}
