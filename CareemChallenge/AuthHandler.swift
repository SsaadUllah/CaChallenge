//
//  AuthHandler.swift
//  CareemChallenge
//
//  Created by SSaad Ullah on 10/16/17.
//  Copyright © 2017 SSaad Ullah. All rights reserved.
//

import Foundation

class AuthHandler: BaseService{
    
    
    //- Mark: User Get Cities List ----- HOME PAGE
    
    func getMovies( queryString: String, selectedPage: Int , success: @escaping (_ response: [Results]) -> Void, fail: @escaping (_ error: [String], _ isUnAuthorizedRequestError: Bool) -> Void) {
        
        let headers:  [String: String] = [:]
        
        let parameters: [String: Any] = [:]
        
        let url = queryString + (page + "\(selectedPage)")
        let baseHttpReq = BaseHTTP()
        baseHttpReq.makeJSONRequest(withPartialUrl: url, method: "GET", headers: headers , parameters: parameters as [String : AnyObject],
                                    
                                    success: { (responseObject) in
                                        
                                        print("Success in AUTHHand Get Cities : \(responseObject)")
                                        
                                        
                                        let baseResponse = BaseClass.init(object: responseObject) // Error,Status,Response Message
                                        if baseResponse.totalPages != nil{
                                            totalPages = baseResponse.totalPages!
                                        }
                                        
                                        if baseResponse.page != nil{
                                             currentPage = baseResponse.page!
                                        }
                                       
                                        if baseResponse.totalPages != nil{//baseResponse.errors?.count == 0 && baseResponse.errors?[0] == nil{
                                            
                                            totalPages = baseResponse.totalPages!
                                            success(baseResponse.results!)
                                        }else{
                                            let error = baseResponse.errors?[0]
                                            print("ERROR: \(error)")
                                            fail(baseResponse.errors!, true)
                                        }
                                        //
                                        
                                        
                                        
        }) { (error, code , responseObject) in
            
            let obj  = self.isUnAuthorizedRequestError(responseObject, error: error)
            if(obj.isUnAuthorizedRequest){
                print("unauthorized with error : \(obj.errorMessage)")
                fail([obj.errorMessage], true)
                
            }else{
                print("not unauthorized with error : \(obj.errorMessage)")
                fail([obj.errorMessage], false)
            }
            
        }
    }
    
}
