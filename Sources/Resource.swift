//
//  Resource.swift
//  YouTubeKit
//
//  Created by Hiroki Kumamoto on 2017/04/07.
//  Copyright © 2017 Hiroki Kumamoto. All rights reserved.
//

import Foundation
import SwiftyJSON

public protocol Resource {
    static var url: String { get }
    static var params: [String:String] { get }
    init(json: JSON)
}

