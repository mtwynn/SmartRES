//
//  UploadViewController.swift
//  SmartRES
//
//  Created by Tam Nguyen on 5/8/19.
//  Copyright © 2019 Tam Nguyen. All rights reserved.
//

import UIKit
import Alamofire
import ImageSlideshow
import Parse
import YPImagePicker

class ProfileViewController: UIViewController {

    @IBOutlet weak var profilePicView: UIImageView!
    
    @IBOutlet weak var addProfilePicView: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicView.layer.masksToBounds = true
        profilePicView.layer.cornerRadius = profilePicView.frame.height / 2
        profilePicView.layer.borderWidth = 2
        profilePicView.layer.borderColor = UIColor.init(red: 0.0/255, green: 151/255, blue: 69/255, alpha: 1).cgColor
        addProfilePicView.layer.cornerRadius = addProfilePicView.frame.height / 2
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.init(red: 0.0/255, green: 151/255, blue: 69/255, alpha: 1)
        
        let query = PFQuery(className: "Users")
        query.getObjectInBackground(withId: PFUser.current()!.objectId!) { (user: PFObject?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else if let user = user {
                let imageFile = user["profilePic"] as! PFFileObject
                imageFile.getDataInBackground {(data: Data?, error: Error?) in
                    if let data = data, let image = UIImage(data: data) {
                        self.profilePicView.image = image
                    } else {
                        print("Error loading")
                    }
                }
            }
        }
        
        //profilePicView.af_setImage(withURL: URL(string: )!)
    }
    
    
    @IBAction func addProfilePic(_ sender: Any) {
        
        var config = YPImagePickerConfiguration()
        config.screens = [.library, .photo]
        config.albumName = "SmartRES"
        config.startOnScreen = YPPickerScreen.library
        config.library.maxNumberOfItems = 1
        config.library.mediaType = YPlibraryMediaType.photo
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                self.profilePicView.image = photo.image
                let query = PFQuery(className: "Users")
                query.getObjectInBackground(withId: PFUser.current()!.objectId!) { (user: PFObject?, error: Error?) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else if let user = user {
                        let imageData = photo.image.pngData()
                        let file = PFFileObject(data: imageData!)
                        user["profilePic"] = file
                        user.saveInBackground()
                    }
                }
            
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    
    @IBAction func logoutButton(_ sender: Any) {
        PFUser.logOut()
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.window?.rootViewController = loginViewController
    }
    
    
}
