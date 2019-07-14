//
//  CustomPointAnnotation.swift
//  SmartRES
//
//  Created by Tam Nguyen on 7/14/19.
//  Copyright © 2019 Tam Nguyen. All rights reserved.
//


import UIKit
import MapKit

class CustomPointAnnotation: MKPointAnnotation {
    var image: UIImage!
    var address: String!
    var pinColor: UIColor
    
    init(pinColor: UIColor) {
        self.pinColor = pinColor
        super.init()
    }
}
