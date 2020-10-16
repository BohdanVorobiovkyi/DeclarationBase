//
//  NetworkService.swift
//  Empat
//
//  Created by Богдан Воробйовський on 16.10.2020.
//

import Foundation

enum NetworkResult: Swift.Error {
    case noValidUrl
    case wrongPath
    case noData
    case errorOccured
    case unknownError
}

class NetworkService {
    
    static let baseUrl: String = "https://public-api.nazk.gov.ua/v1/declaration/"
//    static var querry: String = "?q=tetris&sort=stars&order=desc"
    
    
    
     static func performRequest(querry: String? , cahcePolicy: URLRequest.CachePolicy, completion: @escaping (Result<Data, Error>) -> Void)  {
        
        func generateUrl(path: String, queryParams: String?) -> URL {
            var urlComponents = URLComponents()
            urlComponents.scheme = "https" //self.networkProtocol // "https"
            urlComponents.host = "public-api.nazk.gov.ua" // self.url // "1d9fbe45.ngrok.io"
            urlComponents.path = "/v1/declaration/"   // "/api/mobile/user-logged-in"
            
            urlComponents.queryItems = [
                   URLQueryItem(name: "?q", value: queryParams)
               ]
             
            if let queryParams = queryParams { // queryParams is nil in this case
                urlComponents.query = queryParams
            }
             
            guard let fullUrl: URL = urlComponents.url else { // No error is present because fullUrl = {}
                fatalError("Could not create URL from the given URL components.")
            }
             
            return fullUrl
        }
        
        guard let keyWords = querry else {return}
        let querry: String = "\(keyWords)"
        let uurl = generateUrl(path: "", queryParams: querry)
        print(uurl)
        let jsonUrl = "https://public-api.nazk.gov.ua/v1/declaration/?q=\(querry)"
//        let encodedUrl = jsonUrl.stringByAddingPercentEncodingWithAllowedCharacters()
        guard let url = URL(string: jsonUrl.encodeUrl) else {
            completion(.failure(NetworkResult.noValidUrl))
            return
        }
        
        let session = URLSession.shared
        var request = URLRequest(url: url, cachePolicy: cahcePolicy, timeoutInterval: 10)
        request.httpMethod = "GET"
  
        let dataTask = session.dataTask(with: request) {  data, response, error in
            if let error = error {
                completion(.failure(error))
            }  else if let data = data {
                 completion(.success(data))
            } else {
                completion(.failure(NetworkResult.unknownError))
            }
        }
        dataTask.resume()
    }
}
