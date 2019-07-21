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
import Firebase

struct Property {
    let id: String
    let address: String
    let city: String
    let state: String
    let zip: String
    let type: String
    var bed: NSNumber
    var bath: NSNumber
    var price: NSNumber
    var latitude: NSNumber
    var longitude: NSNumber
    var image: UIImage
    let agent: PFUser
    let ref: DatabaseReference?
    let addedByUser: String
    
    func toAnyObject() -> Any {
        return [
            "address": address,
            "city": city,
            "state": state,
            "zip": zip,
            "type": type,
            "bed": bed,
            "bath": bath,
            "price": price,
            "agent": addedByUser,
            "latitude": latitude,
            "longitude": longitude,
            "id": "123456789"
        ]
    }
}
