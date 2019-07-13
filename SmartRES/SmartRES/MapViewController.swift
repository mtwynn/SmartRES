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
        
        var addresses = [String]()
        for property in properties {
            print("\(property.address) has coordinates: \(property.latitude) \(property.longitude)")
            
            let coordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(property.latitude), longitude: CLLocationDegrees(property.longitude))
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            annotation.title = property.address
            mapView.addAnnotation(annotation)
        }
        print(addresses)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        print("locations = \(locValue.latitude) and \(locValue.longitude)")
        
        
    }
    
    func loadProperties() -> Void {
        
    }
    

}
