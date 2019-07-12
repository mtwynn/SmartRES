//
//  NativeGeocoding.swift
//  SmartRES
//
//  Created by Tam Nguyen on 7/10/19.
//  Copyright © 2019 Tam Nguyen. All rights reserved.
//
import CoreLocation
import PromiseKit
class NativeGeocoding {
    
    var address : String
    lazy var geocoder = CLGeocoder()
    
    init(_ address: String) {
        self.address = address
    }
    
    func geocode() -> Promise<Geocoding> {
        return Promise { fulfill, reject in
            firstly{
                self.geocodeAddressString()
                }.then{(placemarks) -> Promise<Geocoding> in
                    self.processResponse(withPlacemarks: placemarks)
                }.then{ (geocoding) -> Void in
                    fulfill(geocoding)
                }.catch{ (error) in
                    reject(error)
            }
        }
    }
    
    private func geocodeAddressString() -> Promise<[CLPlacemark]> {
        return Promise<[CLPlacemark]> { fulfill, reject in
            geocoder.geocodeAddressString(address) { (placemarks, error) in
                if (error != nil) {
                    reject(error!)
                } else {
                    fulfill(placemarks!)
                }
            }
        }
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]) -> Promise<Geocoding> {
        return Promise { fulfill, reject in
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.coumnt > 0 {
                location.placemarks.first?.location
            }
            
            if let location = location {
                let geocoding = Geocoding(coordinates: location.coordinate)
                fulfill(geocoding)
            } else {
                reject(Errors.noMatchingLocation)
            }
        }
    }
}
