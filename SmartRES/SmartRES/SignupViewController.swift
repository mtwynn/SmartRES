//
//  SignupViewController.swift
//  SmartRES
//
//  Created by Tam Nguyen on 6/25/19.
//  Copyright © 2019 Tam Nguyen. All rights reserved.
//

import UIKit
import Parse

class SignupViewController: UIViewController, UITextViewDelegate {

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
        if (usernameField.text == nil) {
            user.username = emailField.text
        } else {
            user.username = usernameField.text
        }
        user.password = passwordField.text
        
        if (!(firstnameField!.text != nil) || !(lastnameField!.text != nil) || !(emailField!.text != nil) || !(phoneField!.text != nil) || !(passwordField!.text != nil) || !(pwConfirmField != nil) || (passwordField.text != pwConfirmField.text)) {
            let alert = UIAlertController(title: "Error", message: "Please fill out all the fields or double check your passwords", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
        } else {
            user["firstName"] = firstnameField.text
            user["lastName"] = lastnameField.text
            user["email"] = emailField.text
            user["phone"] = phoneField.text
            user["bio"] = bioField.text
            // Sign user up
            user.signUpInBackground { (success, error) in
                if success { // Sign up successful
                    let alert = UIAlertController(title: "Success", message: "Successfully signed up!", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                            self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else { // Sign up failed
                    let alert = UIAlertController(title: "Error", message: "Could not sign up. That username or email already exists.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
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
