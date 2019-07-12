//
//  Geocoding.swift
//  SmartRES
//
//  Created by Tam Nguyen on 7/12/19.
//  Copyright © 2019 Tam Nguyen. All rights reserved.
//
import CoreLocation


class Geocoding {
    var coordinates: CLLocationCoordinate2D
    var name: String?
    var formattedAddress: String?
    var boundNorthEast: CLLocationCoordinate2D?
    var boundSouthWest: CLLocationCoordinate2D?
    
    init(coordinates: CLLocationCoordinate2D) {
        self.coordinates = coordinates
    }
}
