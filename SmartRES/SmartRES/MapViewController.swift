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

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var recenterButtonView: UIButton!
    
    @IBOutlet weak var shadowButtonView: UIView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let locationManager = CLLocationManager()
    var properties = [Property]()
    var currentLoc = CLLocationCoordinate2D()
    var mapSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        searchBar.delegate = self
        locationManager.requestAlwaysAuthorization()
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        mapView.addGestureRecognizer(tapGesture)
            
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
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let address = self.searchBar.text!
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    let alert = UIAlertController(title: "Error", message: "No location exists for this property. Please try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
            }
        
            
            
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let searchSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: coordinates, span: searchSpan)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            annotation.title = address
            self.mapView.addAnnotation(annotation)
            self.mapView.animatedZoom(zoomRegion: region, duration: 3)
        }
    }
}


extension MKMapView {
    func animatedZoom(zoomRegion:MKCoordinateRegion, duration:TimeInterval) {
        MKMapView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.setRegion(zoomRegion, animated: true)
        }, completion: nil)
    }
}
