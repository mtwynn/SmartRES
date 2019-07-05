
//  MainViewController.swift
//  SmartRES
//
//  Created by Tam Nguyen on 5/8/19.
//  Copyright © 2019 Tam Nguyen. All rights reserved.
//


import UIKit
import Parse
import ImageSlideshow
import Alamofire
import YPImagePicker

class MainViewController: UIViewController {
    
    /*var imageSource = [AlamofireSource(urlString: "https://images.unsplash.com/photo-1432679963831-2dab49187847?w=1080")!, AlamofireSource(urlString: "https://images.unsplash.com/photo-1447746249824-4be4e1b76d66?w=1080")!, AlamofireSource(urlString: "https://images.unsplash.com/photo-1463595373836-6e0b0a8ee322?w=1080")!]*/

    // Array of image sources for slideshow
    var imageSource = [ParseSource]()
    var updatedList = [ParseSource]()

    // Refresh control
    var refreshControl = UIRefreshControl()

    // Associated property
    var property: Property?

    let downloadGroup = DispatchGroup()
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var cityStateLabel: UILabel!
    @IBOutlet weak var zipLabel: UILabel!
    @IBOutlet weak var bedLabel: UILabel!
    @IBOutlet weak var bathLabel: UILabel!
    
    
    @IBOutlet weak var slideshow: ImageSlideshow!
    @IBOutlet weak var uploadButtonView: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set all information labels on finished loading
        priceLabel.text = "$\(property!.price.stringValue)"
        addressLabel.text = property!.address
        cityStateLabel.text = property!.city + ", " + property!.state
        zipLabel.text = property!.zip
        bedLabel.text = property!.bed.stringValue
        bathLabel.text = property!.bath.stringValue
        
        
        // Button stylings
        uploadButtonView.layer.cornerRadius = 0.5 * uploadButtonView.bounds.size.width
        uploadButtonView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        uploadButtonView.layer.shadowOffset = CGSize(width: 2.0, height: 3.0)
        uploadButtonView.layer.shadowOpacity = 1.0
        uploadButtonView.layer.shadowRadius = 3.0
        uploadButtonView.layer.masksToBounds = false
        uploadButtonView.imageEdgeInsets = UIEdgeInsets(top: 5, left: 7, bottom: 5, right: 3)
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.init(red: 0.0/255, green: 151/255, blue: 69/255, alpha: 1)
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.init(red: 0.0/255, green: 151/255, blue: 69/255, alpha: 1)
        
        
        // Refresh control
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        

        // Slideshow configuration
        let pageControl = LabelPageIndicator()
        slideshow.pageIndicator = pageControl
        slideshow.slideshowInterval = 5.0
        slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFill
        slideshow.delegate = self as ImageSlideshowDelegate
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.didTap))
        slideshow.addGestureRecognizer(recognizer)

        slideshow.setImageInputs(imageSource)
    }
    
    
    @IBAction func uploadButton(_ sender: Any) {
        
        // YPImagePicker configurations and initialization
        var config = YPImagePickerConfiguration()
        config.screens = [.library, .photo, .video]
        config.albumName = "SmartRES"
        config.startOnScreen = YPPickerScreen.library
        config.library.maxNumberOfItems = 10
        config.library.mediaType = YPlibraryMediaType.photoAndVideo
        let picker = YPImagePicker(configuration: config)

        // Function for picker finished picking
        picker.didFinishPicking { [unowned picker] items, _ in
            for item in items {
                switch item {
                // If photo
                case .photo(let photo):

                    let post = PFObject(className: "Pictures")
                    let imageData = photo.image.pngData()
                    let file = PFFileObject(data: imageData!)

                    post["image"] = file
                    post["propertyId"] = self.property?.id
                    post["agent"] = PFUser.current()!

                    // Save picture 
                    post.saveInBackground() { (success, error) in
                        if success {
                            let alert = UIAlertController(title: "Success", message: "Upload complete!", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            self.refresh()
                        } else {
                            let alert = UIAlertController(title: "Error", message: "Upload failed.", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                    
                // TODO --> User uploads video, must be displayed in slideshow
                case .video(let video):
                    print("uploading video...", video)
                }
            }
            picker.dismiss(animated: true, completion: nil)
        }
        self.present(picker, animated: true, completion: nil)
    }


    // Refresh button
    @IBAction func refreshButton(_ sender: Any) {
        downloadGroup.enter()
        refresh()
        downloadGroup.leave()
        downloadGroup.notify(queue: DispatchQueue.main, execute: {
            let alert = UIAlertController(title: "Refresh", message: "Refreshed successfully!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        })
    }


    @objc func refresh() {
        // Clear updated list
        self.updatedList.removeAll(keepingCapacity: true)

        let query = PFQuery(className: "Pictures")
        query.whereKey("agent", equalTo: PFUser.current()!)
        query.whereKey("propertyId", equalTo: self.property?.id)
        query.findObjectsInBackground() { (posts, error) in
            if posts != nil {
                for post in posts! {
                    let imageFile = post["image"] as! PFFileObject
                    self.updatedList.append(ParseSource(file: imageFile))
                }
            }
            self.imageSource = self.updatedList
            self.slideshow.setImageInputs(self.imageSource)
            self.slideshow.setNeedsDisplay()
            self.slideshow.bringSubviewToFront(self.priceLabel)
        }
    }
    

    // Full screens the slideshow
    @objc func didTap() {
        let fullScreenController = slideshow.presentFullScreenController(from: self)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
}


// For testing
extension MainViewController: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        print("current page:", page)
    }
}
