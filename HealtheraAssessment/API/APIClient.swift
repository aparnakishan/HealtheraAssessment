//
//  APIClient.swift
//  HealtheraAssessment
//
//  Created by Jithin Prakash on 6/11/19.
//  Copyright © 2019 Aparna kishan. All rights reserved.
//

import Foundation
import Alamofire

class APIClient {

    @discardableResult
    private static func performRequest(request:URLRequest, decoder: JSONDecoder = JSONDecoder(), completion:@escaping (Result<Any>)->Void) -> DataRequest {
        return Alamofire.request(request).responseJSON { (response:DataResponse<Any>) in
            completion(response.result)
        }
    }
    
    static func login(user: String, user_password: String, completion:@escaping (Result<Any>)->Void) {
        performRequest(request: APIRouter.login(username: user, password: user_password).asURLRequest(), completion: completion)
    }
    
    static func logout(completion:@escaping (Result<Any>)->Void) {
        performRequest(request: APIRouter.logout.asURLRequest(), completion: completion)
    }

    static func adherences(patient_id: String, startDate:Int, endDate: Int, completion:@escaping (Result<Any>)->Void) {
        performRequest(request: APIRouter.adherences(patientId: patient_id, start:startDate, end:endDate).asURLRequest(), completion: completion)
    }
    
    static func remedy(patient_id: String, remedy_id: String, completion:@escaping (Result<Any>)->Void) {
        performRequest(request: APIRouter.remedy(patientId: patient_id, remedyId: remedy_id).asURLRequest(), completion: completion)
    }

}
