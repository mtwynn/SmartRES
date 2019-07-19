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
        let user = PFUser.current()!
        editFirstName.text = user["firstName"] as! String
        editLastName.text = user["lastName"] as! String
        editEmail.text = user["email"] as! String
        editPhone.text = user["phone"] as! String
        editBio.text = user["bio"] as! String
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
                    let alert = UIAlertController(title: "Success", message: "Profile successfully updated!", preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Error", message: "Failed to update profile.", preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
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
    
    
    @IBAction func deleteLogoButton(_ sender: Any) {
        let user = PFUser.current()!
        if let logo = user["logo"] {
            let alert = UIAlertController(title: "Delete Logo", message: "Would you like to delete your real estate logo?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {action in
                user.remove(forKey: "logo")
                user.saveInBackground() {(success, error) in
                    if (success) {
                        let logoUrl = URL(string: "https://cmkt-image-prd.global.ssl.fastly.net/0.1.0/ps/3652954/910/607/m1/fpnw/wm0/real-estate-logo-.png?1511872497&s=ed290198990284688a4f3afc2ffd7128")!
                        let logoData = try? Data(contentsOf: logoUrl)
                        let pic = UIImage(data: logoData!)
                        self.editLogoView.image = pic
                        let alert = UIAlertController(title: "Success!", message: "Logo successfully deleted!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        let alert = UIAlertController(title: "Error.", message: "Failed to delete logo.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Delete Logo", message: "No logo to delete! You cannot remove the default logo.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true) {
                return
            }
        }
        
       
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
