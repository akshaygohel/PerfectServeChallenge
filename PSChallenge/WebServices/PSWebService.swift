//
//  PSWebService.swift
//  PSChallenge
//
//  Created by Akshay Gohel on 05/12/21.
//  Copyright © 2021 Akshay Gohel. All rights reserved.
//

import Foundation

enum PSWebServiceError {
    case networkError
    case internalError
    case customError(message: String)
    
    var rawValue: String {
        switch self {
        case .networkError: return "Seems you are not connected to internet."
        case .internalError: return "Something went wrong. Please try again later."
        case .customError(let message): return message
        }
    }
}

class PSWebService: PSWebServiceProtocol {
    let BUSINESSES_TO_SHOW = Int.max
    
    func getSearchResults(url urlString: String, parameters: [String: Any], _ completion: @escaping (_ success: Bool, _ topics: [PSBusiness]?, _ error: PSWebServiceError?) -> ()) {
        
        // This can later be changed to stop specific task with this url.
        URLSession.shared.cancelAllRunningtasks()
        
        if urlString.count > 0 {
            var components = URLComponents(string: urlString)!
            components.queryItems = parameters.map { (arg) -> URLQueryItem in
                let (key, value) = arg
                if let value = value as? Int {
                    return URLQueryItem(name: key, value: "\(value)")
                } else if let value = value as? Double {
                    return URLQueryItem(name: key, value: "\(value)")
                } else {
                    return URLQueryItem(name: key, value: value as? String)
                }
            }
            components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
            if let url = components.url {
                let session = URLSession.shared;
                
                let authHeader = "Bearer O5H9A0D9qSnN2Q-MQerhCuUljXnNlRaYGZdxv0HM5SLfznvtTDj_lwhMg-_RF7Tq-pwB7-KeNvoFRDoEL0Or7xndhButRGOohZn2l8nanLQAIIe2MISSmvw525SmYXYx"
                
                var urlRequest = URLRequest(url: url)
                urlRequest.setValue(authHeader, forHTTPHeaderField: "Authorization")

                let loadTask = session.dataTask(with: urlRequest) { (data, response, error) in
                    if let errorResponse = error {
                        completion(false, nil, PSWebServiceError.customError(message: errorResponse.localizedDescription))
                    } else if let httpResponse = response as? HTTPURLResponse {
#if DEBUG
                        if let data = data {
                            let str = String(decoding: data, as: UTF8.self)
                            // This will print only in DEBUG Mode. Check file PSLogger.swift
                            print(str)
                        }
#endif
                        if httpResponse.statusCode != 200 {
                            var errorMessage: String?
                            if let data = data {
                                do {
                                    let jsonResponse = try JSONSerialization.jsonObject(with:data, options: [])
                                    if let jsonDict =  jsonResponse as? NSDictionary, let errorDict =  jsonDict["error"] as? NSDictionary {
                                        if let errorDescription = errorDict["description"] as? String {
                                            errorMessage = errorDescription
                                        }
                                    }
                                } catch let parsingError {
                                    // This will print only in DEBUG Mode. Check file PSLogger.swift
                                    print("Error", parsingError)
                                }
                            }
                            let errorResponse = NSError(domain: "Domain", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey : "Http error occured"])
                            completion(false, nil, PSWebServiceError.customError(message:errorMessage ?? errorResponse.localizedDescription))
                        } else {
                            let businesses = self.parseResponse(data: data)
                            completion(true, businesses, nil)
                        }
                    }
                }
                loadTask.resume()
                return
            }
        }
        completion(false, nil, PSWebServiceError.internalError)
    }

    private func parseResponse(data: Data?) -> [PSBusiness] {
        var businesses = [PSBusiness]()
        
        if let data = data {
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with:data, options: [])
                if let jsonDict =  jsonResponse as? NSDictionary {
                    guard let businessesArray = jsonDict["businesses"] as? Array<NSDictionary> else {
                        return businesses
                    }
                    for business in businessesArray {
                        businesses.append(self.createBusinessFromData(business))
                        if businesses.count >= BUSINESSES_TO_SHOW {
                            return businesses
                        }
                    }
                }
            } catch let parsingError {
                // This will print only in DEBUG Mode. Check file PSLogger.swift
                print("Error", parsingError)
            }
        }
        
        return businesses
    }
    
    func createBusinessFromData(_ businessDictionary: NSDictionary) -> PSBusiness {
        return PSBusiness.init(businessDictionary)
    }
    
}
