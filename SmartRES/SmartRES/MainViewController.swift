//
//  MainViewController.swift
//  SmartRES
//
//  Created by Tam Nguyen on 5/8/19.
//  Copyright © 2019 Tam Nguyen. All rights reserved.
//

/* parse-dashboard --appId SmartRES --masterKey fur3l153 --serverURL "http://smart-res.herokuapp.com/parse" */

import UIKit
import Parse
import ImageSlideshow
import Alamofire
import YPImagePicker

class MainViewController: UIViewController {
    
    var imageSource = [AlamofireSource(urlString: "https://images.unsplash.com/photo-1432679963831-2dab49187847?w=1080")!, AlamofireSource(urlString: "https://images.unsplash.com/photo-1447746249824-4be4e1b76d66?w=1080")!, AlamofireSource(urlString: "https://images.unsplash.com/photo-1463595373836-6e0b0a8ee322?w=1080")!]
    
    var refreshControl = UIRefreshControl()
    
    
    @IBAction func refreshButton(_ sender: Any) {
        refresh()
    }
    
    @IBOutlet weak var slideshow: ImageSlideshow!

    
    @IBOutlet weak var uploadButtonView: UIButton!
    
    @IBAction func uploadButton(_ sender: Any) {
        var config = YPImagePickerConfiguration()
        config.screens = [.library, .photo, .video]
        config.albumName = "SmartRES"
        config.startOnScreen = YPPickerScreen.library
        config.library.maxNumberOfItems = 10
        config.library.mediaType = YPlibraryMediaType.photoAndVideo
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                let post = PFObject(className: "Pictures")
                
                post["agent"] = PFUser.current()!
                
                let imageData = photo.image.pngData()
                let file = PFFileObject(data: imageData!)
                post["image"] = file
                
                post.saveInBackground() { (success, error) in
                    if success {
                        self.refresh()
                    } else {
                        print("Error!")
                    }
                }
            }
            picker.dismiss(animated: true, completion: nil)
        }
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        delegate.window?.rootViewController = loginViewController
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Button stylings
        uploadButtonView.layer.cornerRadius = 0.5 * uploadButtonView.bounds.size.width
        uploadButtonView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        uploadButtonView.layer.shadowOffset = CGSize(width: 2.0, height: 3.0)
        uploadButtonView.layer.shadowOpacity = 1.0
        uploadButtonView.layer.shadowRadius = 3.0
        uploadButtonView.layer.masksToBounds = false
        uploadButtonView.imageEdgeInsets = UIEdgeInsets(top: 5, left: 7, bottom: 5, right: 3)
    
        
        
        // Refresh control
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        
        
        
        
        
        slideshow.slideshowInterval = 5.0
        slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFill
        
        let pageControl = LabelPageIndicator()
        slideshow.pageIndicator = pageControl
        
        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        slideshow.activityIndicator = DefaultActivityIndicator()
        slideshow.delegate = self as! ImageSlideshowDelegate
        
        // can be used with other sample sources as `afNetworkingSource`, `alamofireSource` or `sdWebImageSource` or `kingfisherSource`
        slideshow.setImageInputs(imageSource)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.didTap))
        slideshow.addGestureRecognizer(recognizer)
        
    }

    @objc func didTap() {
        let fullScreenController = slideshow.presentFullScreenController(from: self)
        // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
    
    @objc func refresh() {
        let query = PFQuery(className: "Pictures")
        query.whereKey("agent", equalTo: PFUser.current())
        query.findObjectsInBackground() { (posts, error) in
            if posts != nil {
                for post in posts! {
                    print (post["agent"])
                    let imageFile = post["image"] as! PFFileObject
                    let urlString = imageFile.url!
                    let url = URL(string: urlString)!
                    self.imageSource.append(AlamofireSource(url: url))
                    print(self.imageSource.count)
                }
            }
        }
        slideshow.setImageInputs(imageSource)
        slideshow.setNeedsDisplay()
    }
}

extension MainViewController: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        print("current page:", page)
    }
}
