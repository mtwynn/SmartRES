//
//  Property.swift
//  SmartRES
//
//  Created by Tam Nguyen on 7/2/19.
//  Copyright © 2019 Tam Nguyen. All rights reserved.
//

import UIKit
import Foundation
import Firebase

struct Property {
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
    var id: String
    var path: String
    var thumbnail: UIImage
    let agent: String
    let ref: DatabaseReference?
    
    
    init(address: String, agent: String, bath: NSNumber, bed: NSNumber, city: String, id: String, latitude: NSNumber, longitude: NSNumber, path: String, price: NSNumber, state: String, type: String, zip: String) {
        self.ref = nil
        self.id = id
        self.address = address
        self.agent = agent
        self.bath = bath
        self.bed = bed
        self.city = city
        self.latitude = latitude
        self.longitude = longitude
        self.path = path
        self.price = price
        self.state = state
        self.type = type
        self.zip = zip
        self.thumbnail = UIImage()
    }
    
    init?(snapshot: DataSnapshot, image: UIImage) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let address = value["address"] as? String,
            let agent = value["agent"] as? String,
            let bath = value["bath"] as? NSNumber,
            let bed = value["bed"] as? NSNumber,
            let city = value["city"] as? String,
            let id = value["id"] as? String,
            let latitude = value["latitude"] as? NSNumber,
            let longitude = value["longitude"] as? NSNumber,
            let path = value["path"] as? String,
            let price = value["price"] as? NSNumber,
            let state = value["state"] as? String,
            let type = value["type"] as? String,
            let zip = value["zip"] as? String else {
                return nil
        }
        
        self.ref = snapshot.ref
        self.id = id
        self.address = address
        self.agent = agent
        self.bath = bath
        self.bed = bed
        self.city = city
        self.latitude = latitude
        self.longitude = longitude
        self.path = path
        self.price = price
        self.state = state
        self.type = type
        self.zip = zip
        self.thumbnail = image
    }
    
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
            "path": path,
            "id": id,
            "agent": agent,
            "latitude": latitude,
            "longitude": longitude,
        ]
    }
}
