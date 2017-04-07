//
//  MyChannel.swift
//  YouTubeKit
//
//  Created by Hiroki Kumamoto on 2017/04/07.
//  Copyright © 2017 Hiroki Kumamoto. All rights reserved.
//

import Foundation
import SwiftyJSON

open class MyChannel: Channel {
    var relatedPlaylists: [String: String]
    
    public required init(json: JSON) {
        self.relatedPlaylists = [:]
        super.init(json: json)
        if let contentDetails = json["contentDetails"].dictionary {
            if let relatedPlaylists = contentDetails["relatedPlaylists"]?.dictionary {
                for key in relatedPlaylists.keys {
                    self.relatedPlaylists[key] = relatedPlaylists[key]!.stringValue
                }
            }
        }
    }
}
