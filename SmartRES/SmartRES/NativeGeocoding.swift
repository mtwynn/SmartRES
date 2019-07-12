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
                }.then { (placemarks) -> Promise<Geocoding> in
                    self.processResponse(withPlacemarks: placemarks)
                }.then { (geocoding) -> Void in
                    fulfill(geocoding)
                }.catch { (error) in
                    reject(error)
            }
        }
    }
    
    // MARK: - Get an array of CLPlacemark
    private func geocodeAddressString() -> Promise<[CLPlacemark]> {
        return Promise { fulfill, reject in
            geocoder.geocodeAddressString(address) { (placemarks, error) in
                if (error != nil) {
                    reject(error!)
                } else {
                    fulfill(placemarks!)
                }
            }
        }
    }
    
    // MARK: - Convert an array of CLPlacemark to a Geocoding Object
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?) -> Promise<Geocoding> {
        return Promise { fulfill, reject in
        
            var location: CLLocation?
        
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            
            if let location = location {
                let geocoding = Geocoding(coordinates: location.coordinate)
                fulfill(geocoding)
            } else {
                reject( Errors.noMatchingLocation)
            }
        }
    }
    
}
