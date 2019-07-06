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

protocol loadUser {
    func loadInfo()
}

class ProfileViewController: UIViewController {

    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var addProfilePicView: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var logoView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadInfo()
        let tap = UITapGestureRecognizer(target: self, action: #selector(addProfilePic))
        profilePicView.addGestureRecognizer(tap)
        profilePicView.isUserInteractionEnabled = true
        profilePicView.layer.masksToBounds = true
        profilePicView.layer.cornerRadius = profilePicView.frame.height / 2
        profilePicView.layer.borderWidth = 2
        profilePicView.layer.borderColor = UIColor.init(red: 0.0/255, green: 151/255, blue: 69/255, alpha: 1).cgColor
        addProfilePicView.layer.cornerRadius = addProfilePicView.frame.height / 2
        
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.init(red: 0.0/255, green: 151/255, blue: 69/255, alpha: 1)
        
        // For testing
       
        let url = URL(string: "https://cmkt-image-prd.global.ssl.fastly.net/0.1.0/ps/3652954/910/607/m1/fpnw/wm0/real-estate-logo-.png?1511872497&s=ed290198990284688a4f3afc2ffd7128")!
        let data = try? Data(contentsOf: url)
        let pic = UIImage(data: data!)
        logoView.image = pic
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
                
                if let user = PFUser.current(){
                    let imageData = photo.image.pngData()
                    let file = PFFileObject(data: imageData!)
                    user["profilePic"] = file
                    user.saveEventually()
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
    
    func loadInfo() {
        if let user = PFUser.current(){
            user.fetchInBackground() { (result, error) in
                let result = result as! PFUser
                self.nameLabel.text = (result["firstName"] as! String) + " " + (result["lastName"] as! String)
                
                
                self.emailLabel.text = result["username"] as? String
                self.phoneLabel.text = result["phone"] as? String
                
                if result["profilePic"] != nil {
                    let imageFile = result["profilePic"] as! PFFileObject
                    let url = URL(string: imageFile.url!)!
                    let data = try? Data(contentsOf: url)
                    self.profilePicView.image = UIImage(data: data!)
                }
            }
        }
    }
}
