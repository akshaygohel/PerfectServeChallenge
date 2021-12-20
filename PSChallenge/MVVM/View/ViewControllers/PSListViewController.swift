//
//  PSListViewController.swift
//  PSChallenge
//
//  Created by Akshay Gohel on 05/12/21.
//  Copyright © 2021 Akshay Gohel. All rights reserved.
//

import UIKit
import SDWebImage

class PSListViewController: UIViewController {
    
    var currentLocation: String = "Searched Location" {
        didSet {
            self.navigationItem.title = currentLocation
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    private var activitySpinner = UIActivityIndicatorView()
    
    lazy var viewModel: PSListViewModel = {
        return PSListViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.layoutViewUI()
        self.setupViewModel()
        self.addKeyboardObservers()
    }
    
    // MARK: -
    
    private func layoutViewUI() {
        self.infoLabel.text = "Please start by searching business."
        
        self.activitySpinner.color = .systemBlue
        self.activitySpinner.hidesWhenStopped = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.activitySpinner)
        
        self.tableView.estimatedRowHeight = 80.0
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    func setupViewModel() {
        self.viewModel.showAlertClosure = { [weak self] () in
            DispatchQueue.main.async {
                if let message = self?.viewModel.alertMessage {
                    self?.showAlert( message )
                }
            }
        }

        self.viewModel.updateLoadingIndicatorClosure = { [weak self] () in
            let isFetching = self?.viewModel.isFetching ?? false
            DispatchQueue.main.async {
                if isFetching {
                    self?.activitySpinner.startAnimating()
                } else {
                    self?.activitySpinner.stopAnimating()
                }
            }
        }

        viewModel.reloadTableViewClosure = { [weak self] () in
            self?.viewModel.isFetchedOnce = true
            
            DispatchQueue.main.async {
                if let isFetching = self?.viewModel.isFetching, !isFetching {
                    let trimmedText = self?.searchBar.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
                    self?.infoLabel.text = trimmedText.count > 0 ? "Seems your searched business is not on our platform yet. You may want to try searching other business." : "Please start by searching business."
                    
                    self?.infoLabel.isHidden = (self?.viewModel.numberOfCells ?? 0 > 0)
                } else {
                    self?.infoLabel.isHidden = true
                }
                self?.tableView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension PSListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as? PSListTableViewCell else {
            fatalError("Cell not exists in storyboard")
        }
        
        cell.favIconImageView.sd_cancelCurrentImageLoad()
        cell.favIconImageView.image = UIImage.init(named: "DummyAppIcon")
        
        let cellViewModel = viewModel.getCellViewModel(atIndexPath: indexPath)
        
        cell.titleLabel.text = cellViewModel.titleText
        cell.ratingView.rating = cellViewModel.rating ?? 0.0
        if let imageUrl = cellViewModel.imageUrl, imageUrl.count > 0 {
            cell.favIconImageView.sd_setImage(with: URL(string: imageUrl), completed: nil)
        }
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()

        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCells
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        self.viewModel.userTappedBusiness(atIndexPath: indexPath)
        if self.viewModel.shouldAllowSegue {
            return indexPath
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension PSListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        PSListViewController.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hitFetchRequest), object: nil)
        self.perform(#selector(hitFetchRequest), with: nil, afterDelay: 0.3)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
}

extension PSListViewController {
    
    @objc
    private func hitFetchRequest() {
        let trimmedText = self.searchBar.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
//        if trimmedText.count >= 2 {
            self.viewModel.fetchSearchResults(searchTerm: trimmedText, location: currentLocation)
//        }
    }
    
}

extension PSListViewController {
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    private func keyboardWillAppear(notification:Notification) {
        let keyboardInfo = notification.userInfo
        let duration = keyboardInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let keyboardFrame = keyboardInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect

        UIView.animate(withDuration: duration) {
            self.tableViewBottomConstraint.constant = -keyboardFrame.height
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func keyboardWillDisappear(notification:Notification) {
        let keyboardInfo = notification.userInfo
        let duration = keyboardInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval

        UIView.animate(withDuration: duration) {
            self.tableViewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
}
