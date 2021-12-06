//
//  PSBusiness.swift
//  PSChallenge
//
//  Created by Akshay Gohel on 05/12/21.
//  Copyright © 2021 Akshay Gohel. All rights reserved.
//

import Foundation

struct PSBusiness {
    let identifier: String?
    let name: String?
    let imageUrl: String?
    let rating: Double?
    let businessWebsite: String?
    
    init(_ businessDictionary: NSDictionary) {
        if businessDictionary.count > 0 {
            if let identifier = businessDictionary["id"] as? String {
                self.identifier = identifier
            } else { self.identifier = nil }
            if let name = businessDictionary["name"] as? String {
                self.name = name
            } else { self.name = nil }
            if let imageUrl = businessDictionary["image_url"] as? String {
                self.imageUrl = imageUrl
            } else { self.imageUrl = nil }
            if let rating = businessDictionary["rating"] as? Double {
                self.rating = rating
            } else { self.rating = nil }
            if let businessWebsite = businessDictionary["url"] as? String {
                self.businessWebsite = businessWebsite
            } else { self.businessWebsite = nil }
        } else {
            self.identifier = nil
            self.name = nil
            self.imageUrl = nil
            self.rating = nil
            self.businessWebsite = nil
        }
    }
}
