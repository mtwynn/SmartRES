//
//  EditProfileViewController.swift
//  SmartRES
//
//  Created by Tam Nguyen on 7/18/19.
//  Copyright © 2019 Tam Nguyen. All rights reserved.
//

import UIKit
import YPImagePicker
import Parse

class EditProfileViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var editFirstName: UITextField!
    @IBOutlet weak var editLastName: UITextField!
    @IBOutlet weak var editEmail: UITextField!
    @IBOutlet weak var editPhone: UITextField!
    @IBOutlet weak var editBio: UITextView!
    @IBOutlet weak var editLogoView: UIImageView!
    
    
    var logoImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editFirstName.borderStyle = UITextField.BorderStyle.none
        editLastName.borderStyle = UITextField.BorderStyle.none
        editEmail.borderStyle = UITextField.BorderStyle.none
        editPhone.borderStyle = UITextField.BorderStyle.none
        editBio.delegate = self
        editBio.textColor = .lightGray
        editBio.layer.borderWidth = 1
        editBio.layer.borderColor = UIColor.init(red: 212/255, green: 212/255, blue: 212/255, alpha: 1).cgColor
        editBio.layer.cornerRadius = 5
        
        editFirstName.text = UserDefaults.standard.string(forKey: "firstName")!
        editLastName.text = UserDefaults.standard.string(forKey: "lastName")!
        editEmail.text = UserDefaults.standard.string(forKey: "email")!
        editPhone.text = UserDefaults.standard.string(forKey: "phone")!
        editBio.text = UserDefaults.standard.string(forKey: "bio")!
        editLogoView.image = logoImage
        
        
        // Keyboard dismissal functions
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tapGesture)
        let swipeDown = UISwipeGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(swipeDown)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButton(_ sender: Any) {
        if let user = PFUser.current(){
            let imageData = editLogoView.image!.jpeg(.lowest)
          
            let file = PFFileObject(data: imageData!)
            user["logo"] = file
            user["firstName"] = editFirstName.text!
            user["lastName"] = editLastName.text!
            user["email"] = editEmail.text!
            user["phone"] = editPhone.text!
            user["bio"] = editBio.text!
            
            user.saveInBackground() { (success, error) in
                if (success) {
                    let alert = UIAlertController(title: "Success", message: "Profile successfully added", preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                } else {
                    let alert = UIAlertController(title: "Error", message: "Failed to add profile pic", preferredStyle: UIAlertController.Style.alert)
                    
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                }
            }
        }
        
    }
    
    
    @IBAction func editLogoButton(_ sender: Any) {
        var config = YPImagePickerConfiguration()
        config.screens = [.library, .photo]
        config.albumName = "SmartRES"
        config.startOnScreen = YPPickerScreen.library
        config.library.maxNumberOfItems = 1
        config.library.mediaType = YPlibraryMediaType.photo
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                self.editLogoView.image = photo.image
                
                
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if (textView.text != "" && textView.textColor == .lightGray)
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
            textView.text = UserDefaults.standard.string(forKey: "bio")
            textView.textColor = .lightGray
        }
        textView.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 0
            }
        }
    }
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

}
