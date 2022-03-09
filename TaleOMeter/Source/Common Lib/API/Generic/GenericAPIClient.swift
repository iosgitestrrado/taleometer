//
//  GenericAPIClient.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//  Copyright © 2022 Durgesh. All rights reserved.
//

import Foundation

/// Generic client to avoid rewrite URL session code
protocol GenericAPIClient {
    var session: URLSession { get }
    func fetch<T: Decodable>(with request: URLRequest, decode: @escaping (Decodable) -> T?, completion: @escaping (Result<T, APIError>) -> Void)
}

extension GenericAPIClient {
    
    typealias JSONTaskCompletionHandler = (Decodable?, APIError?) -> Void
    
    private func decodingTask<T: Decodable>(with request: URLRequest, decodingType: T.Type, completionHandler completion: @escaping JSONTaskCompletionHandler) -> URLSessionDataTask {
        
        let task = session.dataTask(with: request) { data, response, error in
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, .requestFailed(error?.localizedDescription ?? "No description"))
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                if httpResponse.statusCode == 426 {
                    completion(nil, .applVersionNotvalid("\(httpResponse.statusCode)"))
                } else {
                    completion(nil, .responseUnsuccessful("\(httpResponse.statusCode): \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"))
                }
                return
            }
            
            guard let data = data else {
                completion(nil, .invalidData)
                return
            }
            
//            do {
//                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
//                print(jsonResponse) //Response result
//            } catch let parsingError {
//                print("Error", parsingError)
//            }
            
            do {
                let genericModel = try JSONDecoder().decode(decodingType, from: data)               
                completion(genericModel, nil)
            } catch let err {
                if decodingType != ResponseModelJSON.self {
                    do {
                        let genericModel = try JSONDecoder().decode(ResponseModelJSON.self, from: data)
                        completion(genericModel, nil)
                    } catch let err {
                        completion(nil, .jsonConversionFailure("\(err.localizedDescription)"))
                    }
                } else {
                    completion(nil, .jsonConversionFailure("\(err.localizedDescription)"))
                }
            }
        }
        return task
    }
    
    /// success respone executed on main thread.
    func fetch<T: Decodable>(with request: URLRequest, decode: @escaping (Decodable) -> T?, completion: @escaping (Result<T, APIError>) -> Void) {
        let task = decodingTask(with: request, decodingType: T.self) { (json , error) in
            DispatchQueue.main.async {
                guard let json = json else {
                    error != nil ? completion(.failure(.decodingTaskFailure("\(error!)"))) : completion(.failure(.invalidData))
                    return
                }
                guard let value = decode(json) else { completion(.failure(.jsonDecodingFailure)); return }
                completion(.success(value))
            }
        }
        task.resume()
    }
}
