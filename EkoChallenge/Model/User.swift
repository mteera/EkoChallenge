//
//  User.swift
//  EkoChallenge
//
//  Created by Chace Teera on 18/01/2020.
//  Copyright © 2020 chaceteera. All rights reserved.
//

import Foundation

typealias JSON = [String:Any]


struct User {
    var id: Int
    var login: String
    var avatarUrl: String
    var url: String
    var type: String
    var siteAdmin: Bool
    var isFavourite: Bool
    
    init(json: JSON, isFavourite: Bool = false) {
        
        self.id = json["id"] as! Int
        self.login = json["login"] as! String
        self.avatarUrl = json["avatar_url"] as! String
        self.url = json["html_url"] as! String
        self.type = json["type"] as! String
        self.siteAdmin = json["site_admin"] as! Bool
        self.isFavourite = isFavourite
    }
    
    
}


struct ResultDTO: Codable {
    var isFavourite: Bool?
    

}

class Result: Decodable {
    var url: String { return _url ?? "Default Appleseed" }

    private var _url: String?

    enum CodingKeys: String, CodingKey {
        case _url = "url"
    }
}
