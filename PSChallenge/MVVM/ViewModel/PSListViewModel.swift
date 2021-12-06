//
//  PSListViewModel.swift
//  PSChallenge
//
//  Created by Akshay Gohel on 05/12/21.
//  Copyright © 2021 Akshay Gohel. All rights reserved.
//

import Foundation

class PSListViewModel {
    
    var isFetchedOnce: Bool = false // To restrict fetching again and again on viewDidAppear
    private let baseUrlString = "https://api.yelp.com/v3/businesses/search"///?q=apple&format=json&pretty=1"
    
    private let webService: PSWebServiceProtocol
    
    private var businesses: [PSBusiness] = [PSBusiness]()
    
    var reloadTableViewClosure: (()->())?
    var showAlertClosure: (()->())?
    var updateLoadingIndicatorClosure: (()->())?
    
    var shouldAllowSegue: Bool = false
    var selectedBusiness: PSBusiness?

    private var cellModels: [PSListCellModel] = [PSListCellModel]() {
        didSet {
            self.reloadTableViewClosure?()
        }
    }

    var isFetching: Bool = false {
        didSet {
            self.updateLoadingIndicatorClosure?()
        }
    }

    var alertMessage: String? {
        didSet {
            self.showAlertClosure?()
        }
    }

    var numberOfCells: Int {
        return cellModels.count
    }

    init(webService: PSWebServiceProtocol = PSWebService()) {
        self.webService = webService
    }

    func fetchSearchResults(searchTerm searchString: String = "", location: String) {
        self.isFetching = true
        let langStr = Locale.current.identifier

        self.webService.getSearchResults(url: baseUrlString, parameters: ["term":searchString, "locale":langStr, "radius": 2000, "location": location], { [weak self] (success, businesses, error) in
            self?.isFetching = false
            if let error = error {
                if error.rawValue != "cancelled" {
                    self?.alertMessage = error.rawValue
                }
            } else {
                self?.processBusinesses(businesses)
            }
        })
    }

    func getCellViewModel(atIndexPath indexPath: IndexPath) -> PSListCellModel {
        return self.cellModels[indexPath.row]
    }

    private func createCellViewModel(fromBusiness business: PSBusiness) -> PSListCellModel {
        return PSListCellModel(titleText: business.name, rating: business.rating, imageUrl: business.imageUrl)
    }

    private func processBusinesses(_ businesses: [PSBusiness]?) {
        if let businesses = businesses {
            self.businesses = businesses
            var cellModels = [PSListCellModel]()
            for business in businesses {
                cellModels.append(createCellViewModel(fromBusiness: business))
            }
            self.cellModels = cellModels
        } else {
            self.alertMessage = PSWebServiceError.internalError.rawValue
        }
    }
    
}

//MARK: -

extension PSListViewModel {
    
    func clearData() {
        self.businesses = []
        self.cellModels = [PSListCellModel]()
    }
    
}

//MARK: - User Action

extension PSListViewModel {
    func userTappedBusiness(atIndexPath indexPath: IndexPath) {
        if self.businesses.count > indexPath.row {
            let business = self.businesses[indexPath.row]
            self.shouldAllowSegue = true
            self.selectedBusiness = business
        } else {
            self.shouldAllowSegue = false
            self.selectedBusiness = nil
            self.alertMessage = "Some error occured"
        }
    }
}
