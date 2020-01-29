//
//  Service.swift
//  EkoChallenge
//
//  Created by Chace Teera on 18/01/2020.
//  Copyright © 2020 chaceteera. All rights reserved.
//

import Foundation

class Service {

    static let shared = Service()
    
    
    func fetchGenericJSONData<T: Decodable>(urlString: String, completion: @escaping (T?, Error?) -> ()) {
        
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, resp, err) in
            if let err = err {
                completion(nil, err)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                let objects = try decoder.decode(T.self, from: data!)

                // success
                
                completion(objects, nil)
            } catch {
                
                debugPrint(error)

                completion(nil, error)
            }
            }.resume()
    }
    
    func getUsers(usersSince: Int, perPage: Int, completion: @escaping ([User]?, _ lastUserId: Int?,
        Error?)-> Void) {

        if let url = URL(string: "https://api.github.com/users?since=0&per_page=20") {
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
