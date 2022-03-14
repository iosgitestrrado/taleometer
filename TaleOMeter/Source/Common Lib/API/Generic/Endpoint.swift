//
//  Endpoint.swift
//  TaleOMeter
//
//  Created by Durgesh on 08/03/22.
//  Copyright © 2022 Durgesh. All rights reserved.
//

import Foundation

/// Protocol for easy construction of URls, ideally an enum will be the one conforming to this protocol.
protocol Endpoint {
    var base:  String { get }
    var path: String { get }
}

extension Endpoint {
    
    var urlComponents: URLComponents? {
        guard var components = URLComponents(string: base) else { return nil }
        components.path = path
        return components
    }
    
    var request: URLRequest? {
        guard let url = urlComponents?.url ?? URL(string: "\(self.base)\(self.path)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return nil }
        let request = URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 60.0)
        return request
    }

    func getRequest<T: Encodable>(_ query: T) -> URLRequest? {
        guard let url = URL(string: "\(self.base)\(self.path)\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return nil }
        
        let headers = [HTTPHeader.contentType("application/json"), HTTPHeader.authorization(APIClient.shared.getAuthentication())]
        var request = URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 60.0)
        request.httpMethod = HTTPMethods.get.rawValue
        headers.forEach { request.addValue($0.header.value, forHTTPHeaderField: $0.header.field) }
        return request
    }

//    func getDeleteRequest<T: Encodable>(_ query: T, headers: [HTTPHeader]) -> URLRequest? {
//        guard let url = URL(string: "\(self.base)\(self.path)\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return nil }
//        var request = URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 60.0)
//        request.httpMethod = HTTPMethods.delete.rawValue
//        headers.forEach { request.addValue($0.header.value, forHTTPHeaderField: $0.header.field) }
//        return request
//    }
    
    func deleteRequest<T: Encodable>(_ query: String, parameters: T) -> URLRequest? {
        guard let url = URL(string: "\(self.base)\(self.path)\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return nil }
        var request = URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 60.0)
        request.httpMethod = HTTPMethods.delete.rawValue
        let headers = [HTTPHeader.contentType("application/json"), HTTPHeader.authorization(APIClient.shared.getAuthentication())]

        do {
            request.httpBody = try JSONEncoder().encode(parameters)
        } catch let error {
            print(APIError.postParametersEncodingFalure("\(error)").customDescription)
            return nil
        }
        headers.forEach { request.addValue($0.header.value, forHTTPHeaderField: $0.header.field) }
        return request
    }

    func postRequest<T: Encodable>(_ query: String, parameters: T) -> URLRequest? {
        guard let url = URL(string: "\(self.base)\(self.path)\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return nil }
        var request = URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 60.0)
        request.httpMethod = HTTPMethods.post.rawValue
        let headers = [HTTPHeader.contentType("application/json"), HTTPHeader.authorization(APIClient.shared.getAuthentication())]

        do {
            request.httpBody = try JSONEncoder().encode(parameters)
        } catch let error {
            print(APIError.postParametersEncodingFalure("\(error)").customDescription)
            return nil
        }
        headers.forEach { request.addValue($0.header.value, forHTTPHeaderField: $0.header.field) }
        return request
    }

//    func postRequest<T: Encodable>(_ parameters: T, headers: [HTTPHeader]) -> URLRequest? {
//        guard var request = self.request else { return nil }
//        request.httpMethod = HTTPMethods.post.rawValue
//        do {
//            request.httpBody = try JSONEncoder().encode(parameters)
//        } catch let error {
//            print(APIError.postParametersEncodingFalure("\(error)").customDescription)
//            return nil
//        }
//        headers.forEach { request.addValue($0.header.value, forHTTPHeaderField: $0.header.field) }
//        return request
//    }
}
