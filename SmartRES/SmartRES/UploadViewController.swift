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
        profilePicView.af_setImage(withURL: URL(string: "https://lh3.googleusercontent.com/OCiNH6oPdYtU5d_nYxG35nhl2mZWMlz7XwtdfQgf6RQIwb70vgE1IfMGXjxSM57o9trY4Exj5JYL6K4epB2MGbrz2bc91CM8ui2Pb8qvP4dX12shhk6vsO4rlu-3Fb5EqUaRhZZJ86pZMIqgKd77FpzA5q9lGWhEHdb5XbvpqxJjoBdhY39FHrcJxXlQGgNYMzGiAys93IX_DOzVBBM8gTrYh_FNukThhMBsZ-11ftS4A-J-zQ5b911goPkFfTy39b1NxTSKxjWUvbuY7mA1avunSUjdubXg9eX9yK-YXJB8D4lvV9YMazMnSdiENB4famYw9jz3UTSUXRO7rhH9sFyBPnqG6dcJ50vJ-TwdtvzImcErvQLzSB9rCzSDq6cJttIhunOuVBVFPVHil9MTv0YQ_WIIbNbZhDdXyH4tHm6om-510yScl1spJMSMCvt3wHXHZJeX-yRVQiMnAhjO4GYA6AMu3vCjkFOyteAqJ4Fhli-vIgu9pyaB75udeCo3PLWSouAf0W_4wusja3vpTJ4c9GBorFSeyW5ZZmaXdPBwFywXqFhgarl3rwLGDofXqKFuucvXkIh8kPbnnX8w-mkT_pLfdju_YdU5U8gsJW13sYrG0Lj35VeA9TvZdhWgVRQVfN9WRvOzRuQZBiqcwhlhJk3N0Yc=w2278-h1518-no")!)
        
    }
    
}
