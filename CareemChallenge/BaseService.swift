//
//  BaseService.swift
//  Symo
//
//  Created by JZ-Mac on 9/28/17.
//  Copyright © 2017 Right Solution. All rights reserved.
//

import Foundation

class BaseService: NSObject {
    
    func isUnAuthorizedRequestError(_ response: Any, error: Error?) -> (isUnAuthorizedRequest:Bool,errorMessage:String) {
        let displayError = getErrorMessage(withResponceObject: response, andError: error)
        if (displayError == "Unauthorized Request") {
            return (true,displayError)
        }
        else {
            return (false,displayError)
        }
    }
    
    func getErrorMessage(withResponceObject responseObject: Any?, andError error: Error?) -> String {
        var errorMessage: String = "Unknown Error"
        
        if(responseObject != nil){
            let res : [String:Any]? = responseObject as? [String:Any]
            
            if(res != nil && res!.keys.contains("error")){
                let errorDic : [String:Any] = res!["error"] as! [String:Any]
                let messages:[String] = errorDic["message"] as! [String]
                
                if(messages.count > 0){
                    errorMessage = messages[0]
                }
            }
        }
        
        return errorMessage
    }
    
    
       
    
}





