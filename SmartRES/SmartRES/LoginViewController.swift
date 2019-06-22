//
//  LoginViewController.swift
//  SmartRES
//
//  Created by Tam Nguyen on 5/7/19.
//  Copyright © 2019 Tam Nguyen. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var loginButtonView: UIButton!
    
    // Show button
    var iconClick = true
    @IBAction func showPasswordButton(_ sender: Any) {
        if (iconClick == true) {
            passwordField.isSecureTextEntry = false
        } else {
            passwordField.isSecureTextEntry = true
        }
        iconClick = !iconClick
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        usernameField.borderStyle = UITextField.BorderStyle.none
        passwordField.borderStyle = UITextField.BorderStyle.none
        usernameField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 175/255, green:175/255, blue: 175/255, alpha: 0.75)])
        passwordField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 175/255, green:175/255, blue: 175/255, alpha: 0.75)])
        
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = #imageLiteral(resourceName: "loginBG-1")
        backgroundImage.contentMode =  UIView.ContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
        
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        
        self.view.addGestureRecognizer(tapGesture)
        
        let swipeDown = UISwipeGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(swipeDown)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @IBAction func loginButton(_ sender: Any) {
        let username = usernameField.text!
        let password = passwordField.text!
        
        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
            if user != nil {
                self.performSegue(withIdentifier: "mainSegue", sender: nil)
            } else {
                print("No user")
            }
        }
    }
    
    
    @IBAction func signupButton(_ sender: Any) {
        let user = PFUser()
        user.username = usernameField.text
        user.password = passwordField.text
        
        user.signUpInBackground { (success, error) in
            if success {
                print("Successfully signed up")
                self.performSegue(withIdentifier: "mainSegue", sender: nil)
            } else {
                print("Failed to sign up")
            }
        }
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height - 100)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

}
