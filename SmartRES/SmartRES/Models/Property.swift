//
//  Property.swift
//  SmartRES
//
//  Created by Tam Nguyen on 7/2/19.
//  Copyright © 2019 Tam Nguyen. All rights reserved.
//

import UIKit
import Parse
import Foundation

struct Property {
    let id: String
    let address: String
    let city: String
    let state: String
    let zip: String
    let type: String
    let bed: NSNumber
    let bath: NSNumber
    let price: NSNumber
    let latitude: NSNumber
    let longitude: NSNumber
    var image: UIImage
    let agent: PFUser
}
