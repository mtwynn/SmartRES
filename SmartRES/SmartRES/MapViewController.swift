//
//  MapViewController.swift
//  SmartRES
//
//  Created by Tam Nguyen on 7/10/19.
//  Copyright © 2019 Tam Nguyen. All rights reserved.
//

import UIKit
import MapKit
import Parse

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var properties = [Property]()
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        let mapSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            let locValue = locationManager.location
            let coordinates = CLLocationCoordinate2D(latitude: locValue!.coordinate.latitude, longitude: locValue!.coordinate.longitude)
            let region = MKCoordinateRegion(center: coordinates, span: mapSpan)
            mapView.setRegion(region, animated: false)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            annotation.title = "Current Location"
            mapView.addAnnotation(annotation)
        }
        let geoCoder = CLGeocoder()
        var addresses = [String]()
        for property in properties {
            let address = "\(property.address), \(property.city) \(property.state), \(property.zip)"
            addresses.append(address)
            
            /*geoCoder.geocodeAddressString(address) { (placemarks, error) in
                guard
                    let placemarks = placemarks,
                    let location = placemarks.first?.location
                    else {
                        print("No location for \(address)")
                        return
                }
                
                
                let lat = location.coordinate.latitude
                let long = location.coordinate.longitude
                print("\(lat) \(long)")
                let coord = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let tempAnnot = MKPointAnnotation()
                tempAnnot.coordinate = coord
                tempAnnot.title = address
                self.mapView.addAnnotation(tempAnnot)
                
                
            }*/
        }
        print(addresses)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        print("locations = \(locValue.latitude) and \(locValue.longitude)")
        
        
    }
    

}
