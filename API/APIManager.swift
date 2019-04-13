//
//  APIConfig.swift
//
//  Created by Ashish on 04/06/18.
//  Copyright © 2018 Ashish. All rights reserved.
//

import Moya
import Alamofire
import SwiftyJSON

class APIManager: Alamofire.SessionManager {

    static let shared: APIManager = {

        let configuration = URLSessionConfiguration.default
        //        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 10000 // as seconds, you can set your request timeout
        configuration.timeoutIntervalForResource = 10000 // as seconds, you can set your resource timeout
        //        configuration.requestCachePolicy = .useProtocolCachePolicy
        return APIManager(configuration: configuration)

    }()

    static let background: APIManager = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.myapi.task")
        return APIManager(configuration: configuration)
    }()
}

class API {
//    static let provider = MoyaProvider<UserAPI>(manager: APIManager.background, plugins: [NetworkLoggerPlugin(verbose: true)])
    static let provider = MoyaProvider<UserAPI>(plugins: [NetworkLoggerPlugin(verbose: true)])

    static func request(target: UserAPI, success successCallback: @escaping (JSON) -> Void, error errorCallback: @escaping (Swift.Error) -> Void, failure failureCallback: @escaping (MoyaError) -> Void) {
        provider.request(target, progress: { (response) in
            if target.path ==  "post"{
//                print(response.progress)
            }
        }, completion: { (result) in
            switch result {
            case .success(let response):
                if response.statusCode == 401 {
                    
                } else if response.statusCode >= 200 && response.statusCode <= 300 {
                    if let json = try? JSON.init(data: response.data, options: JSONSerialization.ReadingOptions.allowFragments) {
                        successCallback(json)
                    } else {
                        let error = NSError(domain: "com.google.networkLayer", code: 0, userInfo: [NSLocalizedDescriptionKey: "Parsing Error"])
                        errorCallback(error)
                    }
                } else {
                    let error = NSError(domain: "com.google.networkLayer", code: 0, userInfo: [NSLocalizedDescriptionKey: "Parsing Error"])
                    errorCallback(error)
                }

            case .failure(let error):
                // 3:
                failureCallback(error)

            }
        })
    }
}
