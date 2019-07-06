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
    
    var user : PFUser? = nil
    // User credentials
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    // Login button
    @IBOutlet weak var loginButtonView: UIButton!
    
    // Show-password button
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
        
        // Set input field styles
        usernameField.borderStyle = UITextField.BorderStyle.none
        passwordField.borderStyle = UITextField.BorderStyle.none
        usernameField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 175/255, green:175/255, blue: 175/255, alpha: 0.75)])
        passwordField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 175/255, green:175/255, blue: 175/255, alpha: 0.75)])
        
        // Set background styles
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = #imageLiteral(resourceName: "loginBG-1")
        backgroundImage.contentMode =  UIView.ContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
        
        // Keyboard dismissal functions
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tapGesture)
        let swipeDown = UISwipeGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(swipeDown)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "userLoggedIn") == true && PFUser.current() != nil {
            self.user = PFUser.current()!
            self.performSegue(withIdentifier: "mainSegue", sender: self)
        }
    }
    
    
    @IBAction func loginButton(_ sender: Any) {
        let username = usernameField.text!
        let password = passwordField.text!
        
        // Login load screen
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { action in
            self.dismiss(animated: false, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
        // PF Login
        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
            if user != nil { // User exists
                self.user = user
                UserDefaults.standard.set(username, forKey: "email")
                self.dismiss(animated: true) {
                    self.performSegue(withIdentifier: "mainSegue", sender: nil)
                }
                
            } else { // Password incorrect, user nonexistent
                self.dismiss(animated: true) {
                    let alert = UIAlertController(title: "Message", message: "Incorrect username/password or no user exists", preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "Sign up", style: UIAlertAction.Style.default, handler: self.signupButton))
                    alert.addAction(UIAlertAction(title: "Try again", style: UIAlertAction.Style.cancel, handler: nil))
                    
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    @IBAction func signupButton(_ sender: Any) {
        self.performSegue(withIdentifier: "signupSegue", sender: nil)
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        UserDefaults.standard.set(true, forKey: "userLoggedIn")
        UserDefaults.standard.set(user!["firstName"], forKey: "firstName")
        UserDefaults.standard.set(user!["lastName"], forKey: "lastName")
        UserDefaults.standard.set(user!["phone"], forKey: "phone")
        if (user!["profilePic"] != nil) {
            let imageFile = user!["profilePic"] as! PFFileObject
            let url = URL(string: imageFile.url!)!
            UserDefaults.standard.set(url, forKey: "profilePic")
        }
    }
}
