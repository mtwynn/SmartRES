//
//  SignupViewController.swift
//  SmartRES
//
//  Created by Tam Nguyen on 6/25/19.
//  Copyright © 2019 Tam Nguyen. All rights reserved.
//

import UIKit
import Parse
import Firebase

class SignupViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var firstnameField: UITextField!
    @IBOutlet weak var lastnameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var pwConfirmField: UITextField!
    @IBOutlet weak var bioField: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set input field styles
        firstnameField.borderStyle = UITextField.BorderStyle.none
        lastnameField.borderStyle = UITextField.BorderStyle.none
        usernameField.borderStyle = UITextField.BorderStyle.none
        emailField.borderStyle = UITextField.BorderStyle.none
        phoneField.borderStyle = UITextField.BorderStyle.none
        passwordField.borderStyle = UITextField.BorderStyle.none
        pwConfirmField.borderStyle = UITextField.BorderStyle.none
        phoneField.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        phoneField.delegate = self
        bioField.delegate = self
        bioField.text = "Details about you (optional)"
        bioField.textColor = .lightGray
        bioField.layer.borderWidth = 1
        bioField.layer.borderColor = UIColor.init(red: 212/255, green: 212/255, blue: 212/255, alpha: 1).cgColor
        bioField.layer.cornerRadius = 5
        // Keyboard dismissal functions
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tapGesture)
        let swipeDown = UISwipeGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(swipeDown)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Back button to dismiss signup page 
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.hidesBackButton = false
    }
    

    @IBAction func createUser(_ sender: Any) {
        let user = PFUser()
        
        
        let loadingAlert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        loadingAlert.view.addSubview(loadingIndicator)
        loadingAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { action in
            loadingAlert.dismiss(animated: false, completion: nil)
        }))
        self.present(loadingAlert, animated: true, completion: nil)
        var username = ""
        var password = ""
        
        if (usernameField.text == nil) {
            username = emailField.text!
        } else {
            username = usernameField.text!
        }
        
        password = passwordField.text!
        
        let validEmail = isValidEmail(emailStr: emailField.text!)
        
        if (firstnameField!.text == "") || (lastnameField!.text == "") || (usernameField!.text == "") || (emailField!.text == "") || (phoneField!.text == "") || (passwordField!.text == "") || (pwConfirmField!.text == "") {
            loadingAlert.dismiss(animated: false, completion: nil)
            let alert = UIAlertController(title: "Error", message: "Please fill out all the fields", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if (passwordField.text != pwConfirmField.text) {
            loadingAlert.dismiss(animated: false, completion: nil)
            let alert = UIAlertController(title: "Error", message: "Passwords do not match", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if (!validEmail) {
            loadingAlert.dismiss(animated: false, completion: nil)
            let alert = UIAlertController(title: "Error", message: "Please enter a valid email", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            print("reached")
            Auth.auth().createUser(withEmail: self.emailField.text!, password: password) { (user, error) in
                if error == nil {
                    Analytics.setUserProperty(self.firstnameField.text!, forName: "first_name")
                    Analytics.setUserProperty(self.lastnameField.text!, forName: "last_name")
                   
                    Analytics.setUserProperty(self.usernameField.text!, forName: "username")
                    Analytics.setUserProperty(self.phoneField.text!, forName: "phone")
                    Analytics.setUserProperty(self.bioField.text!, forName: "bio")
                    Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!)
                } else {
                    let alert = UIAlertController(title: "Signup failed", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            
            
            
            user["firstName"] = firstnameField.text
            user["lastName"] = lastnameField.text
            user["email"] = emailField.text
            user["phone"] = phoneField.text
            if (bioField.text == "Details about you (optional)") {
                user["bio"] = ""
            } else {
                user["bio"] = bioField.text
            }
            // Sign user up
            user.signUpInBackground { (success, error) in
                if success { // Sign up successful
                    let alert = UIAlertController(title: "Success", message: "Successfully signed up!", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                            self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else { // Sign up failed
                    let alert = UIAlertController(title: "Error", message: "That user or email already exists. Please try something different.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    // Field verification functions
    
    func isValidEmail(emailStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailStr)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 10
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if (textView.text == "Details about you (optional)" && textView.textColor == .lightGray)
        {
            textView.text = ""
            textView.textColor = .black
        }
        textView.becomeFirstResponder() //Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if (textView.text == "")
        {
            textView.text = "Details about you (optional)"
            textView.textColor = .lightGray
        }
        textView.resignFirstResponder()
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
