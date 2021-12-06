//
//  PSWebServiceProtocol.swift
//  PSChallenge
//
//  Created by Akshay Gohel on 05/12/21.
//  Copyright © 2021 Akshay Gohel. All rights reserved.
//

import Foundation

protocol PSWebServiceProtocol {
    func getSearchResults(url urlString: String, parameters: [String: Any], _ completion: @escaping ( _ success: Bool, _ businesses: [PSBusiness]?, _ error: PSWebServiceError? ) -> ())
}
