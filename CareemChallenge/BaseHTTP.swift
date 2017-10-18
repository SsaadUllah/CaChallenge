//
//  BaseHTTP.swift
//  CareemChallenge
//
//  Created by SSaad Ullah on 10/16/17.
//  Copyright © 2017 SSaad Ullah. All rights reserved.
//



import Foundation
import Alamofire
import SwiftyJSON

class BaseHTTP {
    
    func getFullUrl(partialUrl:String) -> String {
        return "\(BASE_API)\(partialUrl)"
    }
    
    //This will get your method and return the HTTPMethod
    func getRequestMethodType(method requestMethod:String)->HTTPMethod{
        
        var requestMethodType:HTTPMethod = HTTPMethod.none
        
        switch requestMethod {
        case "GET":
            requestMethodType = .get
            break;
        case "POST":
            requestMethodType = .post
            break;
        case "PUT":
            requestMethodType = .put
            break;
        case "DELETE":
            requestMethodType = .delete
            break;
        default:
            print("ERROR IN HTTP METHOD")
            //requestMethodType = "N/A"//HTTPMethod(rawValue: "N/A")!
        }
        
        return requestMethodType
    }
    
    func makeJSONRequest(withPartialUrl url:String, method requestMethod:String,
                         headers requestHeaders:[String:String]? , parameters requestParameters:[String:Any]?,
                         success successHandler:@escaping(_ responseObject:Any)->Void ,
                         fail failHandler:@escaping(_ error:Error? ,_ code: Int , _ responseObject : Any)->Void){
        
        
        let completeUrl = getFullUrl(partialUrl:url)
        let safeURL = completeUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        print("EncodedURL: \(safeURL!)")
        
        
        if requestMethod != "GET"{
            self.makeJSONRequest(withUrl: completeUrl, method: requestMethod, headers: requestHeaders, parameters: requestParameters, success: successHandler, fail: failHandler)
        }else{
            self.makeJSONGETRequest(withUrl: completeUrl, method: requestMethod, headers: requestHeaders, parameters: requestParameters, success: successHandler, fail: failHandler)
        }
        
        
    }
    
    func makeJSONRequest(withUrl url:String, method requestMethod:String,
                         headers requestHeaders:[String:String]? , parameters requestParameters:[String:Any]?,
                         success successHandler:@escaping(_ responseObject:Any)->Void ,
                         fail failHandler:@escaping(_ error:Error? ,_ code: Int , _ responseObject : Any)->Void){
        
        //set request method
        let requestMethodType:HTTPMethod = self.getRequestMethodType(method: requestMethod)
        //if method is invalid then return
        if requestMethodType == HTTPMethod.none {
            return;
        }
        
        //check parameters
        var parameters : [String:Any]? = requestParameters
        if(parameters == nil){
            parameters = [String:Any]()
        }
        
        //check headers
        var headers : [String:String]? = requestHeaders
        if(headers == nil){
            headers = [String:String]()
        }
        
        //print request log
       // self.printRequestLog(url: url, method: requestMethodType, parameters: parameters!, headers: headers!)
        
        
        Alamofire.request(url).responseJSON { (response) in
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    print("SUCCESS SERVER RESPONSE :",response.result.value ?? "DefaultInBaseHTTP")
                    successHandler(response.result.value as Any)
                }
                break
                
            case .failure(let err):
                //print("Failure",response.result.error ?? "DefaultInBaseHTTP: ")
                
                var code = response.response?.statusCode
                
                print("Server Response: \(response.response?.statusCode)")
                
                if response.result.value != nil {
                    print("SERVER FAILED RESPONSE1 : \(response as Any)")
                    
                    if code != nil{
                        failHandler(err , code! , response as Any)
                    }else{
                        failHandler(err , 0 , response as Any)
                    }
                    
                }else{
                    print("SERVER FAILED RESPONSE2 : \(response.result.description as Any)")
                    
                    if code != nil{
                        failHandler(err , code! , response.result.description as Any)
                    }else{
                        failHandler(err , 0 , response.result.description as Any)
                    }
                }
        }
        
        //make request
//        Alamofire.request(url, method: requestMethodType, parameters: parameters!, encoding: JSONEncoding.default, headers: headers!).responseJSON { (response:DataResponse<Any>) in
//            
//            print("Response: \(response)")
//            
//            switch(response.result) {
//            case .success(_):
//                if response.result.value != nil{
//                    print("SUCCESS SERVER RESPONSE :",response.result.value ?? "DefaultInBaseHTTP")
//                    successHandler(response.result.value as Any)
//                }
//                break
//                
//            case .failure(let err):
//                //print("Failure",response.result.error ?? "DefaultInBaseHTTP: ")
//                
//                var code = response.response?.statusCode
//                
//                print("Server Response: \(response.response?.statusCode)")
//                
//                if response.result.value != nil {
//                    print("SERVER FAILED RESPONSE1 : \(response as Any)")
//                    
//                    if code != nil{
//                        failHandler(err , code! , response as Any)
//                    }else{
//                        failHandler(err , 0 , response as Any)
//                    }
//                    
//                }else{
//                    print("SERVER FAILED RESPONSE2 : \(response.result.description as Any)")
//                    
//                    if code != nil{
//                        failHandler(err , code! , response.result.description as Any)
//                    }else{
//                        failHandler(err , 0 , response.result.description as Any)
//                    }
//                }
//            }
        }
    }
    
    
    
    func printRequestLog(url:String , method:HTTPMethod ,parameters:[String:Any] , headers:[String:String]){
        print("METHOD TYPE: \(method)")
        print("URL : \(url)")
        print("REQUEST HEADERS : \(headers)")
        print("REQUEST PARAMETERS : \(parameters)")
    }
    
    
    // This Will Return the String of Error RepsonseObject
    func responseDataToJSON(data responseData:Data?) -> Any? {
        
        if responseData == nil{
            return nil;
        }
        
        let responseString:String = String.init(data: responseData!, encoding: String.Encoding.utf8)!
        
        if(responseString != nil){
            do{
                let json = try JSONSerialization.jsonObject(with: responseData!, options: []) as? [String : Any]
                
                
                
                if(json != nil){
                    print("JSON Res: ",json ?? "Default JSON")
                    return json;
                }else{
                    return nil;
                }
            }catch let error{
                print(error.localizedDescription)
                return nil;
            }
        }else{
            return nil;
        }
        
        return nil;
    }
    
    
    
    
    /*---------------HTTP Request When JSON is not our response----------------*/
    
    
    func makeHttpRequest(withPartialUrl url:String, method requestMethod:String,
                         headers requestHeaders:[String:String]? , parameters requestParameters:[String:Any]?,
                         success successHandler:@escaping(_ responseObject:Any)->Void ,
                         fail failHandler:@escaping(_ error:Error? , _ responseObject : Any)->Void){
        
        self.makeHttpRequest(withUrl: self.getFullUrl(partialUrl: url), method: requestMethod, parameters: requestParameters, headers: requestHeaders, success: successHandler, fail: failHandler)
        
    }
    
    
    func makeHttpRequest(withUrl url:String, method requestMethod:String ,
                         parameters requestParameters:[String:Any]?,
                         headers requestHeaders:[String:String]?,
                         success successHandler:@escaping(_ responseObject:Any)->Void,
                         fail failHandler:@escaping(_ error:Error? , _ responseObject:Any)->Void){
        
        //set request method
        let requestMethodType:HTTPMethod = self.getRequestMethodType(method: requestMethod)
        //if method is invalid then return
        if requestMethodType == HTTPMethod.none {
            return;
        }
        
        //check parameters
        var parameters : [String:Any]? = requestParameters
        if(parameters == nil){
            parameters = [String:Any]()
        }
        
        //check headers
        var headers : [String:String]? = requestHeaders
        if(headers == nil){
            headers = [String:String]()
        }
        
        //print request log
        self.printRequestLog(url: url, method: requestMethodType, parameters: parameters!, headers: headers!)
        
        //make request
        Alamofire.request(url, method: requestMethodType, parameters: parameters!, encoding:URLEncoding.default, headers: headers!).validate().responseJSON { (response) in
            
            switch response.result {
            case .success:
                print("SUCCESS SERVER RESPONSE : \(response.result.value as Any)")
                successHandler(response.result.value as Any)
            case .failure(let err):
                print("REQUEST FAILED : \(err.localizedDescription)")
                let resObj = self.responseDataToJSON(data: response.data)
                if let data = resObj {
                    print("SERVER FAILED RESPONSE : \(data as Any)")
                    failHandler(err , data as Any)
                }else{
                    print("SERVER FAILED RESPONSE : \(response.result.value as Any)")
                    failHandler(err , response.result.value as Any)
                }
            }
        }
        
    }
    
    
    /*JSON GET REQUEST*/
    func makeJSONGETRequest(withUrl url:String, method requestMethod:String,
                            headers requestHeaders:[String:String]? , parameters requestParameters:[String:Any]?,
                            success successHandler:@escaping(_ responseObject:Any)->Void ,
                            fail failHandler:@escaping(_ error:Error? ,_ code: Int , _ responseObject : Any)->Void){
        
        //set request method
        let requestMethodType:HTTPMethod = self.getRequestMethodType(method: requestMethod)
        //if method is invalid then return
        if requestMethodType == HTTPMethod.none {
            return;
        }
        
        //check parameters
        var parameters : [String:Any]? = requestParameters
        if(parameters == nil){
            parameters = [String:Any]()
        }
        
        //check headers
        var headers : [String:String]? = requestHeaders
        if(headers == nil){
            headers = [String:String]()
        }
        
        //print request log
        self.printRequestLog(url: url, method: requestMethodType, parameters: parameters!, headers: headers!)
        
        //make request
        Alamofire.request(url, method: requestMethodType, encoding: JSONEncoding.default, headers: headers!).responseJSON { (response:DataResponse<Any>) in
            
            //print("Response: \(response)")
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    print("SUCCESS SERVER RESPONSE :",response.result.value ?? "DefaultInBaseHTTP")
                    successHandler(response.result.value as Any)
                }
                break
                
            case .failure(let err):
                //print("Failure",response.result.error ?? "DefaultInBaseHTTP: ")
                
                var code = response.response?.statusCode
                
                print("Server Response: \(response.response?.statusCode)")
                
                if response.result.value != nil {
                    print("SERVER FAILED RESPONSE1 : \(response as Any)")
                    
                    if code != nil{
                        failHandler(err , code! , response as Any)
                    }else{
                        failHandler(err , 0 , response as Any)
                    }
                    
                }else{
                    print("SERVER FAILED RESPONSE2 : \(response.result.description as Any)")
                    
                    if code != nil{
                        failHandler(err , code! , response.result.description as Any)
                    }else{
                        failHandler(err , 0 , response.result.description as Any)
                    }
                }
            }
        }
    }
    
    
}


/*
 
 switch response.result {
 case .success:
 print("SUCCESS SERVER RESPONSE : \(response.result.value as Any)")
 successHandler(response.result.value as Any)
 
 case .failure(let err):
 
 print("REQUEST FAILED : \(err.localizedDescription)")
 print("REQUEST FAILED2 : \(response.result)")
 print("REQUEST FAILED3 : \(response.result.value)")
 print("REQUEST FAILED4 : \(response.response?.statusCode)")
 //print("REQUEST FAILED4 : \(response.response?)")
 
 
 let code = response.response?.statusCode
 let resObj = JSON.init(data: response.data!)//self.responseDataToJSON(data: response.data)
 
 //let dictionary: Dictionary? = NSKeyedUnarchiver.unarchiveObject(with: response.data!) as! [String : Any]
 
 if resObj != nil {
 print("SERVER FAILED RESPONSE1 : \(resObj as Any)")
 failHandler(err , code! , resObj as Any)
 
 }else{
 print("SERVER FAILED RESPONSE2 : \(response.result.value as Any)")
 failHandler(err , code! , response.result.value as Any)
 }
 }
 
 
 */
