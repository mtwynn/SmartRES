
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

protocol controlsPropertyRefresh {
    func refresh()
}

class MainViewController: UIViewController {
    
    /*var imageSource = [AlamofireSource(urlString: "https://images.unsplash.com/photo-1432679963831-2dab49187847?w=1080")!, AlamofireSource(urlString: "https://images.unsplash.com/photo-1447746249824-4be4e1b76d66?w=1080")!, AlamofireSource(urlString: "https://images.unsplash.com/photo-1463595373836-6e0b0a8ee322?w=1080")!]*/

    // Array of image sources for slideshow
    var imageSource = [ParseSource]()
    var updatedList = [ParseSource]()
    var slideshowImgIds = [String]()

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
    @IBOutlet weak var deleteButtonView: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set all information labels on finished loading
        priceLabel.text = "$\(property!.price.stringValue)"
        addressLabel.text = "ID: \(property!.id)"
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
        deleteButtonView.layer.cornerRadius = 0.5 * uploadButtonView.bounds.size.width
        deleteButtonView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        deleteButtonView.layer.shadowOffset = CGSize(width: 2.0, height: 3.0)
        deleteButtonView.layer.shadowOpacity = 1.0
        deleteButtonView.layer.shadowRadius = 3.0
        deleteButtonView.layer.masksToBounds = false
        deleteButtonView.imageEdgeInsets = UIEdgeInsets(top: 5, left: 7, bottom: 5, right: 3)
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

                    let post = PFObject(className: "Picture")
                    let resizedImage = self.resizeImage(image: photo.image, targetSize: CGSize(width:600.0, height:600.0))
                    let imageData = resizedImage.jpeg(.lowest)
                    //let imageData = resizedImage.pngData()
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
    
    @IBAction func deleteButton(_ sender: Any) {
        let alert = UIAlertController(title: "Delete a slideshow image", message: "Enter a number, a range of numbers, or a list of numbers separated by commas for images to delete: ", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "(e.g. \"1\" |  \"1, 3, 4, 5\" |  \"1-5\")"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { [weak alert] (_) in

            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            let input = textField!.text!
            if input.contains(",") {
                /*
                let imageNums = input.split(separator: ",").map{ Int($0)! - 1 }
                let query = PFQuery(className: "Pictures")
                for imageNum in imageNums.sorted().reversed() {
                    let imgToDel = self.slideshowImgIds[imageNum]
                    self.slideshowImgIds.remove(at: imageNum)
                    query.getObjectInBackground(withId: imgToDel) { (img: PFObject?, error: Error?) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            img?.deleteInBackground() {(success, error: Error?) in
                                if success {
                                    self.refresh()
                                    self.slideshow.setImageInputs(self.imageSource)
                                    self.slideshow.setNeedsDisplay()
                                    let alert = UIAlertController(title: "Success", message: "Image deleted!", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                } else {
                                    print(error!.localizedDescription)
                                }
                            }
                        }
                    }
                }*/
            } else {
                let imageNum = Int(input)! - 1
                let query = PFQuery(className: "Picture")
                let imgToDel = self.slideshowImgIds[imageNum]
                self.slideshowImgIds.remove(at: imageNum)
                query.getObjectInBackground(withId: imgToDel) { (img: PFObject?, error: Error?) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        img?.deleteInBackground() {(success, error: Error?) in
                            if success {
                                self.refresh()
                                self.slideshow.setImageInputs(self.imageSource)
                                self.slideshow.setNeedsDisplay()
                                let alert = UIAlertController(title: "Success", message: "Image deleted!", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            } else {
                                print(error!.localizedDescription)
                            }
                        }
                    }
                }
            }
        }));
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }


    // Refresh button
    @IBAction func editButton(_ sender: Any) {
        self.performSegue(withIdentifier: "editPropertySegue", sender: self)
    }


    @objc func refresh() {
        // Clear updated list
        self.updatedList.removeAll(keepingCapacity: true)

        let query = PFQuery(className: "Picture")
        query.whereKey("agent", equalTo: PFUser.current()!)
        query.whereKey("propertyId", equalTo: self.property?.id)
        query.findObjectsInBackground() { (posts, error) in
            if posts != nil {
                for post in posts! {
                    let imageFile = post["image"] as! PFFileObject
                    self.updatedList.append(ParseSource(file: imageFile))
                    self.slideshowImgIds.append(post.objectId!)
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
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}


// For testing
extension MainViewController: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        print("current page:", page)
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}
