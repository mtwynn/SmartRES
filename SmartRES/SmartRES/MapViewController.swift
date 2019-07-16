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
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    let locationManager = CLLocationManager()
    var properties = [Property]()
    var currentLoc = CLLocationCoordinate2D()
    var addressToAdd = String()
    var zipToAdd = String()
    var mapSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        searchBar.delegate = self
        searchCompleter.delegate = self
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.isHidden = true
        //searchTableView.tableFooterView = UIView(frame: .zero)
        let swipeDown = UISwipeGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(swipeDown)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil); locationManager.requestAlwaysAuthorization()
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tapGesture.addTarget(self, action: #selector(self.hideSearch))
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
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0.05 * Double(indexPath.row),
            animations: {
                cell.alpha = 1
        })
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let address = self.searchBar.text!
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location,
                let zipCode = placemarks.first?.postalCode
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
            let annotation = CustomPointAnnotation(pinColor: MKPinAnnotationView.purplePinColor())
            annotation.coordinate = coordinates
            annotation.title = address
            annotation.zipCode = zipCode
            annotation.isSearchResult = true
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
        rightCalloutButton.zipCode = customAnnotation.zipCode
        rightCalloutButton.shouldShowAddProperty = customAnnotation.isSearchResult
        rightCalloutButton.addTarget(self, action: #selector(openMaps), for: UIControl.Event.touchUpInside)
        annotationView?.rightCalloutAccessoryView = rightCalloutButton
        
        let imageView = annotationView?.leftCalloutAccessoryView as! UIImageView
        
        
        imageView.image = customAnnotation.image
        
        return annotationView
    }
    
    @objc func openMaps(sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let customButton = sender as! OpenMapsUIButton
        guard
            let address = customButton.address,
            let zipCode = customButton.zipCode else {
            return
        }
        
        self.addressToAdd = address
        self.zipToAdd = zipCode
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
                UIApplication.shared.open(URL(string:
                    "comgooglemaps://?q=\(formattedAddress)&zoom=14&views=traffic")!, options: [:], completionHandler: nil)
            } else {
                print("Can't use comgooglemaps://");
            }
        }));
        
        if (customButton.shouldShowAddProperty!) {
            alert.addAction(UIAlertAction(title: "Add New Property", style: .default, handler: {action in
                self.performSegue(withIdentifier: "addPropertyFromMapsSegue", sender: self)
            }));
        }
        
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
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc func hideSearch() {
        self.searchTableView.isHidden = true
        searchBar.resignFirstResponder()
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "addPropertyFromMapsSegue") {
            print("Segueing to add property with---")
            let vc = segue.destination as! AddPropertyViewController
            var separatedAddress = self.addressToAdd.split(separator: ",")
            let street = String(separatedAddress.removeFirst()).trim()
            let city = String(separatedAddress.removeFirst()).trim()
            let state = String(separatedAddress.removeFirst()).trim()
            
            print("Street: \(street), City: \(city), State: \(state), Zip: \(zipToAdd)")
            
            let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
            navBar.backgroundColor = .clear
            vc.view.addSubview(navBar)
            let navItem = UINavigationItem(title: "Add Property")
            let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: nil, action: #selector(vc.dismissController))
            navItem.leftBarButtonItem = doneItem
            
            navBar.setItems([navItem], animated: false)
            navBar.delegate = vc
            
            navBar.translatesAutoresizingMaskIntoConstraints = false
            navBar.leftAnchor.constraint(equalTo: vc.view.leftAnchor).isActive = true
            navBar.rightAnchor.constraint(equalTo: vc.view.rightAnchor).isActive = true
            vc.view.addConstraint(NSLayoutConstraint(item: vc.addressField, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: vc.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 64+44))
            if #available(iOS 11, *) {
                navBar.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor).isActive = true
            } else {
                navBar.topAnchor.constraint(equalTo: vc.view.topAnchor).isActive = true
            }
            
            vc.fromMaps = true
            vc.navBar = navBar
            vc.addressText = street
            vc.cityText = city
            vc.stateText = state
            vc.zipText = zipToAdd
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

extension MapViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText == "") {
            self.searchTableView.isHidden = true
        } else {
            self.searchTableView.isHidden = false
        }
        searchCompleter.region = MKCoordinateRegion(center: currentLoc, span: mapSpan)

        searchCompleter.queryFragment = searchText
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchTableView.isHidden = true
        searchBar.resignFirstResponder()
    }
}

extension MapViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        searchTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
}

extension MapViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(searchResults.count)
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        return cell
    }
}

extension MapViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let completion = searchResults[indexPath.row]
        let fullAddress = "\(completion.title), \(completion.subtitle)"
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            self.searchTableView.isHidden = true
            self.searchBar.resignFirstResponder()
            let coordinates = response?.mapItems[0].placemark.coordinate
            let zipCode = String((response?.mapItems[0].placemark.postalCode)!)
            let searchSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: coordinates!, span: searchSpan)
            let annotation = CustomPointAnnotation(pinColor: MKPinAnnotationView.purplePinColor())
            annotation.address = fullAddress
            annotation.isSearchResult = true
            annotation.zipCode = zipCode
            annotation.coordinate = coordinates!
            annotation.title = completion.title
            self.mapView.addAnnotation(annotation)
            self.mapView.animatedZoom(zoomRegion: region, duration: 1.5)
        }
    }
}
