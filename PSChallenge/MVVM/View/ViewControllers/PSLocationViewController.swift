//
//  PSLocationViewController.swift
//  PSChallenge
//
//  Created by Akshay Gohel on 05/12/21.
//  Copyright © 2021 Akshay Gohel. All rights reserved.
//

import UIKit

class PSLocationViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var containerViewHCenterConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.layoutViewUI()
        self.addKeyboardObservers()
    }
    
    // MARK: -
    
    private func layoutViewUI() {
        self.navigationItem.title = "Add Location"
        
        self.containerView.layer.cornerRadius = 5.0
        self.containerView.layer.masksToBounds = true
        self.containerView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let trimmedText = self.searchTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
        if trimmedText.count >= 5 {
            if let viewController = segue.destination as? PSListViewController {
                viewController.currentLocation = trimmedText
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "MoveToSearchList" {
            let trimmedText = self.searchTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
            if trimmedText.count >= 3 {
                return true
            } else if trimmedText.count > 0 {
                self.showAlert( "Try specifying a more exact location!" )
            }
            self.showAlert( "Please enter location!" )
        }
        return false
    }
    
}

extension PSLocationViewController {
    
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
            self.containerViewHCenterConstraint.constant = -keyboardFrame.height/2.0
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func keyboardWillDisappear(notification:Notification) {
        let keyboardInfo = notification.userInfo
        let duration = keyboardInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval

        UIView.animate(withDuration: duration) {
            self.containerViewHCenterConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
}

extension PSLocationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}
