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


class UploadViewController: UIViewController {

    @IBOutlet weak var profilePicView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicView.layer.masksToBounds = true
        profilePicView.layer.cornerRadius = profilePicView.frame.height / 2
        profilePicView.af_setImage(withURL: URL(string: "https://scontent-sjc3-1.xx.fbcdn.net/v/t1.0-9/60851350_2569104719791117_9094202935537041408_o.jpg?_nc_cat=107&_nc_oc=AQkpbQIrKhVH7-S3PVqsclxZmhAHKeCJiPeERxeLTE20haxqH2X0WwqgzA4u63u2Owo&_nc_ht=scontent-sjc3-1.xx&oh=3e4b3c92f3df8f215833a88e00782cc7&oe=5DC6B722")!)
        
    }
    
}
