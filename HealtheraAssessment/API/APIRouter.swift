//
//  APIRouter.swift
//  HealtheraAssessment
//
//  Created by Jithin Prakash on 6/11/19.
//  Copyright © 2019 Aparna kishan. All rights reserved.
//

import Alamofire

enum APIRouter: URLRequestConvertible {

    case login(username:String, password:String)
    case adherences(patientId: String, start:Int, end:Int)
    case remedy(patientId: String, remedyId: String)
    case logout
    
    // MARK: - HTTPMethod
    private var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        case .adherences,.remedy:
            return .get
        case .logout:
            return .delete
        }
    }
    
    // MARK: - Path
    private var path: String {
        switch self {
        case .login,.logout:
            return "/tokens"
        case .adherences(let patientId,let start,let end):
            return "/patients/\(patientId)/adherences?start=\(start)&end=\(end)"
        case .remedy(let patientId, let remedyId):
            return "/patients/\(patientId)/remedies/\(remedyId)"

        }
    }
    
    // MARK: - Parameters
    private var parameters: Parameters? {
        switch self {
        case .login(let username,let password):
            return ["username":username, "user_password":password]
        case .adherences,.remedy,.logout:
            return nil
        }
    }
    
    // MARK: - URLRequestConvertible
    func asURLRequest() -> URLRequest {
        let url = URL(string: "https://api.84r.co")!
        let urlPath = url.appendingPathComponent(path).absoluteString.removingPercentEncoding!
        var urlRequest = URLRequest(url: URL(string: urlPath)!)
        
        // HTTP Method
        urlRequest.httpMethod = method.rawValue
        
        // Common Headers
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue(CLIENT_ID, forHTTPHeaderField: "client-id")
        
        // Custom Headers
        switch self {
        case .login:
            break
        case .adherences,.remedy,.logout:
            let defaults = UserDefaults.standard
            let token = defaults.string(forKey: "token")
            urlRequest.setValue(token, forHTTPHeaderField: "token")
            urlRequest.setValue("ios", forHTTPHeaderField: "app-platform")
            urlRequest.setValue("1.4", forHTTPHeaderField: "app-version")
        }
        // Parameters
        if let parameters = parameters {
//            do {
                urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: [])
//            } catch {
//                throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
//            }
        }
        
        return urlRequest
}

}
