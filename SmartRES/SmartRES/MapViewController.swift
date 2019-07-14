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
    
    @IBOutlet weak var recenterButtonView: UIButton!
    
    @IBOutlet weak var shadowButtonView: UIView!
    
    let locationManager = CLLocationManager()
    var properties = [Property]()
    var currentLoc = CLLocationCoordinate2D()
    var mapSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        locationManager.requestAlwaysAuthorization()
        
        
        recenterButtonView.layer.shadowColor = UIColor.black.cgColor
        recenterButtonView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        recenterButtonView.layer.masksToBounds = false
        recenterButtonView.layer.shadowRadius = 3.0
        recenterButtonView.layer.shadowOpacity = 0.5
        recenterButtonView.layer.cornerRadius = recenterButtonView.frame.width / 2
        
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            let locValue = locationManager.location
            currentLoc.latitude = locValue!.coordinate.latitude
            currentLoc.longitude = locValue!.coordinate.longitude
            let region = MKCoordinateRegion(center: currentLoc, span: mapSpan)
            mapView.setRegion(region, animated: false)
            let annotation = MKPointAnnotation()
            annotation.coordinate = currentLoc
            annotation.title = "Current Location"
            mapView.addAnnotation(annotation)
        }
        for property in properties {
            print("\(property.address) has coordinates: \(property.latitude) \(property.longitude)")
            
            let coordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(property.latitude), longitude: CLLocationDegrees(property.longitude))
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            annotation.title = property.address
            mapView.addAnnotation(annotation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        print("locations = \(locValue.latitude) and \(locValue.longitude)")
        
        
    }
    
    @IBAction func reCenter(_ sender: Any) {
        let region = MKCoordinateRegion(center: currentLoc, span: mapSpan)
        mapView.setRegion(region, animated: true)
    }
    
    
    func loadProperties() -> Void {
        
    }
    

}
