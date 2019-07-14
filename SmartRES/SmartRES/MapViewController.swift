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
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            guard let locValue = locationManager.location else {
                print("Error")
                return
            }
            currentLoc.latitude = locValue.coordinate.latitude
            currentLoc.longitude = locValue.coordinate.longitude
            let region = MKCoordinateRegion(center: currentLoc, span: mapSpan)
            mapView.setRegion(region, animated: false)
            let annotation = CustomPointAnnotation(pinColor: MKPinAnnotationView.greenPinColor())
            annotation.coordinate = currentLoc
            annotation.title = "Current Location"
            mapView.addAnnotation(annotation)
        }
        for property in properties {
            print("\(property.address) has coordinates: \(property.latitude) \(property.longitude)")
            
            let coordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(property.latitude), longitude: CLLocationDegrees(property.longitude))
            let annotation = CustomPointAnnotation(pinColor: MKPinAnnotationView.redPinColor())
            annotation.image = property.image
            annotation.address = "\(property.address), \(property.city) \(property.state), \(property.zip)"
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "myAnnotationView"
        let customAnnotation = annotation as! CustomPointAnnotation
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        if (annotationView == nil) {
            let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            view.pinTintColor = customAnnotation.pinColor
            annotationView = view
            annotationView?.canShowCallout = true
            annotationView?.leftCalloutAccessoryView = UIImageView(frame: CGRect(x:0, y:0, width: 60, height:60))
        }
        
        
        let rightCalloutButton = OpenMapsUIButton(type: .detailDisclosure)
        
        rightCalloutButton.address = customAnnotation.address
        rightCalloutButton.addTarget(self, action: #selector(openMaps), for: UIControl.Event.touchUpInside)
        annotationView?.rightCalloutAccessoryView = rightCalloutButton
        
        let imageView = annotationView?.leftCalloutAccessoryView as! UIImageView
        
        
        imageView.image = customAnnotation.image
        
        return annotationView
    }
    
    @objc func openMaps(sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let customButton = sender as! OpenMapsUIButton
        guard let address = customButton.address else {
            return
        }
        let formattedAddress = address.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        // Open Apple Maps with given lat/long coordinates
        alert.addAction(UIAlertAction(title: "Open with Apple Maps", style: .default, handler: {action in
            guard let appleMapsURL = URL(string: "http://maps.apple.com/?address=\(formattedAddress)") else { return }
            //guard let appleMapsURL = URL(string: "http://maps.apple.com/?q=\(latitude),\(longitude)") else { return }
            UIApplication.shared.open(appleMapsURL, options: [:], completionHandler: nil)
        }));
        
        // Open Google Maps with given lat/long coordinates
        alert.addAction(UIAlertAction(title: "Open with Google Maps", style: .default, handler: {action in
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                UIApplication.shared.openURL(URL(string:
                    "comgooglemaps://?q=\(formattedAddress)&zoom=14&views=traffic")!)
            } else {
                print("Can't use comgooglemaps://");
            }
        }));
        
        
        //Copy to clipboard
        alert.addAction(UIAlertAction(title: "Copy to Clipboard", style: .default, handler: {action in
            UIPasteboard.general.string = address
        }));
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancel.setValue(UIColor.red, forKey: "titleTextColor")
        alert.addAction(cancel)
        
        
        self.present(alert, animated: true) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    @objc func dismissAlertController(){
        self.dismiss(animated: true, completion: nil)
    }
}


extension MKMapView {
    func animatedZoom(zoomRegion:MKCoordinateRegion, duration:TimeInterval) {
        MKMapView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.setRegion(zoomRegion, animated: true)
        }, completion: nil)
    }
}
