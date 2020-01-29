//
//  Service.swift
//  EkoChallenge
//
//  Created by Chace Teera on 18/01/2020.
//  Copyright © 2020 chaceteera. All rights reserved.
//

import Foundation

class Service {
    // Fetching jso from api, parsing it and mapping it to User object
    static let shared = Service()
    
    func getUsers(usersSince: Int, perPage: Int, completion: @escaping ([User]?, _ lastUserId: Int?,
        Error?)-> Void) {

        if let url = URL(string: "https://api.github.com/users?since=\(usersSince)&per_page=\(perPage)") {
           URLSession.shared.dataTask(with: url) { data, response, error in
            
              if let data = data {
                  do {
                    guard let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [JSON] else { return }
                    
                    var users: [User] = []

                    jsonArray.forEach { (json) in
                        let user = User(json: json)
                        users.append(user)
                    }
                    
                    guard let lastUserId = users.last?.id else { return }

                    
                    completion(users, lastUserId, nil)
                  } catch {
                    
                    completion(nil, nil, error)
                  }
               }
            
            completion(nil, nil, error)

           }.resume()
        }

    }
    
}
