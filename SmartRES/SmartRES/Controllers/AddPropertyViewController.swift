//
//  AddPropertyViewController.swift
//  SmartRES
//
//  Created by Tam Nguyen on 6/26/19.
//  Copyright © 2019 Tam Nguyen. All rights reserved.
//

import UIKit
import Alamofire
import YPImagePicker
import MapKit
import Firebase

class AddPropertyViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UINavigationBarDelegate {
    
    var delegate: controlsRefresh?
    let user = Auth.auth().currentUser
    
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var zipField: UITextField!
    @IBOutlet weak var stateField: UITextField!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var bedField: UITextField!
    @IBOutlet weak var bathField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var addThumbnailView: UIButton!
    @IBOutlet weak var deleteThumbnailView: UIButton!
    @IBOutlet weak var addButtonView: UIButton!
    
    var fromMaps = true
    var addressText = String("")
    var cityText = String("")
    var stateText = String("")
    var zipText = String("")
    var navBar = UINavigationBar()
    // States and their data
    var sortedStates = [String]()
    let stateDictionary = [ "Alabama": "AL",
                            "Alaska": "AK",
                            "Arizona": "AZ",
                            "Arkansas": "AR",
                            "California": "CA",
                            "Colorado": "CO",
                            "Connecticut": "CT",
                            "Delaware": "DE",
                            "Florida": "FL",
                            "Georgia": "GA",
                            "Hawaii": "HI",
                            "Idaho": "ID",
                            "Illinois": "IL",
                            "Indiana": "IN",
                            "Iowa": "IA",
                            "Kansas": "KS",
                            "Kentucky": "KY",
                            "Louisiana": "LA",
                            "Maine": "ME",
                            "Maryland": "MD",
                            "Massachusetts": "MA",
                            "Michigan": "MI",
                            "Minnesota": "MN",
                            "Mississippi": "MS",
                            "Missouri": "MO",
                            "Montana": "MT",
                            "Nebraska": "NE",
                            "Nevada": "NV",
                            "New Hampshire": "NH",
                            "New Jersey": "NJ",
                            "New Mexico": "NM",
                            "New York": "NY",
                            "North Carolina": "NC",
                            "North Dakota": "ND",
                            "Ohio": "OH",
                            "Oklahoma": "OK",
                            "Oregon": "OR",
                            "Pennsylvania": "PA",
                            "Rhode Island": "RI",
                            "South Carolina": "SC",
                            "South Dakota": "SD",
                            "Tennessee": "TN",
                            "Texas": "TX",
                            "Utah": "UT",
                            "Vermont": "VT",
                            "Virginia": "VA",
                            "Washington": "WA",
                            "West Virginia": "WV",
                            "Wisconsin": "WI",
                            "Wyoming": "WY"]
    
    // Types
    let typesArray = ["House", "Apartment", "Land"]
    
    // Beds and baths
    let bedArray = ["1", "2", "3", "4", "5", "6", "7"]
    let bathArray = ["1", "1.5", "2", "2.5", "3", "3.5", "4"]
    
    // Pickers 
    var statePicker : UIPickerView! = UIPickerView()
    var typePicker : UIPickerView! = UIPickerView()
    var bedPicker : UIPickerView! = UIPickerView()
    var bathPicker : UIPickerView! = UIPickerView()
    var myPicker : UIPickerView! = UIPickerView()


    //var ref: DatabaseReference!
    var thumbnail: UIImage! = UIImage()
    

    override func viewDidLoad() {
        // Initialize all pickers 
        super.viewDidLoad()
        
        
        self.statePicker = UIPickerView(frame: CGRect(x: 0, y: 40, width: 0, height: 0))
        self.typePicker = UIPickerView(frame: CGRect(x: 0, y: 40, width: 0, height: 0))
        self.bedPicker = UIPickerView(frame: CGRect(x: 0, y: 40, width: 0, height: 0))
        self.bathPicker = UIPickerView(frame: CGRect(x: 0, y: 40, width: 0, height: 0))
        self.typePicker.delegate = self
        self.typePicker.dataSource = self
        self.statePicker.dataSource = self
        self.statePicker.delegate = self
        self.bedPicker.dataSource = self
        self.bedPicker.delegate = self
        self.bathPicker.dataSource = self
        self.bathPicker.delegate = self
        self.statePicker.tag = 1
        self.typePicker.tag = 2
        self.bedPicker.tag = 3
        self.bathPicker.tag = 4
        
        self.stateField.delegate = self
        self.zipField.delegate = self
        
        
        // Set input field styles
        self.addressField.borderStyle = UITextField.BorderStyle.none
        self.cityField.borderStyle = UITextField.BorderStyle.none
        self.zipField.borderStyle = UITextField.BorderStyle.none
        self.stateField.borderStyle = UITextField.BorderStyle.none
        self.typeField.borderStyle = UITextField.BorderStyle.none
        self.bedField.borderStyle = UITextField.BorderStyle.none
        self.bathField.borderStyle = UITextField.BorderStyle.none
        self.priceField.borderStyle = UITextField.BorderStyle.none
        self.thumbnailView.layer.borderWidth = 1
        self.thumbnailView.layer.borderColor = UIColor.lightGray.cgColor
        addButtonView.isEnabled = false
        [addressField, cityField, zipField, stateField, typeField, bedField, bathField, priceField].forEach({ $0.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })
        
        priceField.addTarget(self, action: #selector(priceAppend), for: UIControl.Event.editingDidEnd)
        
        // Add toolbar (Cancel/Done) to Pickers
        let toolBar = UIToolbar()
        statePicker.showsSelectionIndicator = true
        typePicker.showsSelectionIndicator = true
        bedPicker.showsSelectionIndicator = true
        bathPicker.showsSelectionIndicator = true
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Initialize toolbar elements
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(donePicker))

        // Set items
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        self.stateField.inputView = self.statePicker
        self.typeField.inputView = self.typePicker
        self.bedField.inputView = self.bedPicker
        self.bathField.inputView = self.bathPicker
        self.stateField.inputAccessoryView = toolBar
        self.typeField.inputAccessoryView = toolBar
        self.bedField.inputAccessoryView = toolBar
        self.bathField.inputAccessoryView = toolBar

        self.sortedStates = (Array(stateDictionary.keys).sorted())
        
        // Keyboard dismissal functions
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tapGesture)
        let swipeDown = UISwipeGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(swipeDown)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //let ref = Database.database().reference()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        /*self.addressField?.text = addressText
        self.cityField?.text = cityText
        self.stateField?.text = stateText
        self.zipField?.text = zipText*/
        self.view.addSubview(navBar)
        // If this view controller instance was a destination from addPropertyFromMapsSegue, change button constraint here
        if (fromMaps) {
            self.view.addConstraint(NSLayoutConstraint(item: self.view.safeAreaLayoutGuide, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: addButtonView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 32+49))
        }
    }
    
    
    @IBAction func textField(sender: UITextField) {
        // Create view for picker fields
        let tintColor: UIColor = UIColor(red: 101.0/255.0, green: 98.0/255.0, blue: 164.0/255.0, alpha: 1.0)
        let inputView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 240))
        myPicker.tintColor = tintColor
        myPicker.center.x = inputView.center.x
        inputView.addSubview(myPicker) 
        let doneButton = UIButton(frame: CGRect(x: 100/2, y: 0, width: 100, height: 50))
        doneButton.setTitle("Done", for: UIControl.State.highlighted)
        doneButton.setTitleColor(tintColor, for: UIControl.State.highlighted)
        inputView.addSubview(doneButton) 
        doneButton.addTarget(self, action: Selector(("doneButton:")), for: UIControl.Event.touchUpInside) // set button click event
        
        let cancelButton = UIButton(frame: CGRect(x: (self.view.frame.size.width - 3*(100/2)), y: 0, width: 100, height: 50))
        cancelButton.setTitle("Cancel", for: UIControl.State.highlighted)
        cancelButton.setTitleColor(tintColor, for: UIControl.State.highlighted)
        inputView.addSubview(cancelButton) // add Button to UIView
        cancelButton.addTarget(self, action: Selector(("cancelPicker:")), for: UIControl.Event.touchUpInside) // set button click event
        sender.inputView = inputView
    }

    
    @IBAction func addThumbnail(_ sender: Any) {
        var config = YPImagePickerConfiguration()
        config.screens = [.photo, .library]
        config.albumName = "SmartRES"
        config.startOnScreen = YPPickerScreen.photo
        config.library.maxNumberOfItems = 1
        config.library.mediaType = YPlibraryMediaType.photo
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                self.thumbnailView.image = photo.image
                self.thumbnailView.isHidden = false
                self.addThumbnailView.isHidden = true
            } else {
                self.addThumbnailView.isHidden = false
                self.thumbnailView.layer.borderWidth = 1
                self.thumbnailView.layer.borderColor = UIColor.lightGray.cgColor
            }
            
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil) 
    }
    
    @IBAction func deleteThumbnail(_ sender: Any) {
        self.thumbnailView.image = nil
        self.addThumbnailView.isHidden = false
    }
    


    @IBAction func addButton(_ sender: Any) {
        // Initialize new PFObject for property
        let ref = Database.database().reference(withPath: "users/\(user!.uid)/properties")
        guard let address = self.addressField.text?.trim(),
            let city = self.cityField.text?.trim(),
                let state = self.stateField.text,
            let zip = self.zipField.text?.trim(),
            let type = self.typeField.text,
            let agent = Auth.auth().currentUser?.uid else {
                return
        }
        var firebaseProperty = Property.init(address: address, agent: agent, bath: 0, bed: 0, city: city, id: "", latitude: 0, longitude: 0, path: "", price: 0, state: state, type: type, zip: zip)
        
        // Helper number formatter to convert strings to nums
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        
        // Data that needs to be converted
        let bedNumber = formatter.number(from: self.bedField.text!) as? NSDecimalNumber ?? 0
        let bathNumber = formatter.number(from: self.bathField.text!) as? NSDecimalNumber ?? 0
        let priceNumber = formatter.number(from: self.priceField.text!) as? NSDecimalNumber ?? 0
        
        firebaseProperty.bed = bedNumber
        firebaseProperty.bath = bathNumber
        firebaseProperty.price = priceNumber
        
        // Geocode address
        let propertyAddressString = "\(self.addressField.text!.trim()), \(self.cityField.text!.trim()) \(self.stateField.text!.trim()), \(self.zipField.text!.trim())"
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(propertyAddressString) { (placemarks, error) in
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
            
            firebaseProperty.latitude = NSNumber(value: lat)
            firebaseProperty.longitude = NSNumber(value: long)
        }
        
        
        
        // Check if thumnail exists before trying to add it
        if (thumbnailView.image != nil) {
            
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("property_images").child(user!.uid).child("\(imageName).png")
            
            if let imageData = thumbnailView.image?.jpeg(.lowest) {
                storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error)
                        return
                    }
                    
                    if let propertyImageUrl = metadata?.path {
                        firebaseProperty.path = propertyImageUrl
                    }
                })
            }
            
        }
        
        
        // Confirm the addition of this property
        let alert = UIAlertController(title: "Confirmation", message: "Would you like to add this property?", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                //let text = self.addressField.text!.lowercased()
                let propertyRef = ref.childByAutoId()
                firebaseProperty.id = propertyRef.key!
                propertyRef.setValue(firebaseProperty.toAnyObject(), withCompletionBlock: { (error, reference: DatabaseReference) in
                    if error != nil {
                        let alert = UIAlertController(title: "Error", message: "Adding property failed.", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        self.delegate?.loadProperties()
                        let alert = UIAlertController(title: "Success", message: "Property, \(self.addressField.text!) has been added! Please use the provided PropertyID to view your images on the sign slideshow.", preferredStyle: UIAlertController.Style.alert)
                        self.addressField.text = ""
                        self.cityField.text = ""
                        self.stateField.text = ""
                        self.zipField.text = ""
                        self.typeField.text = ""
                        self.bedField.text = ""
                        self.bathField.text = ""
                        self.priceField.text = ""
                        self.thumbnailView.isHidden = true
                        self.addThumbnailView.isHidden = false
                        
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
        }))
            
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        
        self.present(alert, animated: true, completion: nil)
        
        // Save new property and reset all fields to blank
    }
    
    

    // Picker functions 
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var count = 0
        if (pickerView.tag == 1) {
            count = stateDictionary.count
        } else if (pickerView.tag == 2) {
            count = typesArray.count
        } else if (pickerView.tag == 3) {
            count = bedArray.count
        } else {
            count = bathArray.count
        }
        
        return count
    }
    

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var stringToReturn : String
        if (pickerView.tag == 1) {
            stringToReturn = self.sortedStates[row]
        } else if (pickerView.tag == 2) {
            stringToReturn = typesArray[row]
        } else if (pickerView.tag == 3) {
            stringToReturn = bedArray[row]
        } else {
            stringToReturn = bathArray[row]
        }
        
        return stringToReturn
    }
    

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView.tag == 1) {
            stateField.text = stateDictionary[self.sortedStates[row]]!
        } else if (pickerView.tag == 2) {
            typeField.text = typesArray[row]
        } else if (pickerView.tag == 3) {
            bedField.text = bedArray[row]
        } else {
            bathField.text = bathArray[row]
        }
    }

    @objc func donePicker() {
        if (typeField.text == "") {
            typeField.text = "House"
        }
        if (bedField.text == "") {
            bedField.text = "1"
        }
        if (bathField.text == "") {
            bathField.text = "1"
        }
        stateField.resignFirstResponder()
        typeField.resignFirstResponder()
        bedField.resignFirstResponder()
        bathField.resignFirstResponder()
    }
    
    // Field verification functions
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 5
    }

    @objc func editingChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        guard
            let address = addressField.text, !address.isEmpty,
            let city = cityField.text, !city.isEmpty,
            let state = stateField.text, !state.isEmpty,
            let zip = zipField.text, !zip.isEmpty,
            let type = typeField.text, !type.isEmpty,
            let bed = bedField.text, !bed.isEmpty,
            let bath = bathField.text, !bath.isEmpty,
            let price = priceField.text, !price.isEmpty
            else {
                self.addButtonView.isEnabled = false
                addButtonView.layer.backgroundColor = UIColor.init(red: 212/255, green: 212/255, blue: 212/255, alpha: 1).cgColor
                addButtonView.setTitleColor(UIColor.init(red: 157/255, green: 157/255, blue: 157/255, alpha: 1), for: .normal)
                return
        }
        addButtonView.isEnabled = true
        addButtonView.layer.backgroundColor = UIColor.init(red: 0.0/255, green: 151/255, blue: 69/255, alpha: 1).cgColor
        addButtonView.setTitleColor(UIColor.white, for: .normal)
    }
    
    @objc func priceAppend() {
        if self.priceField.text == "" {
            return
        }
        let counts = self.priceField.text!.split(separator: ".")
        let reqDecLength = counts[0].count + 3
        if (!self.priceField.text!.contains(".") && self.priceField.text! != "") {
            self.priceField.text!.append(".00")
        } else if (self.priceField.text!.contains(".") && self.priceField.text!.count < reqDecLength) {
            let decimals = String(repeating: "0", count: reqDecLength - self.priceField.text!.count)
            self.priceField.text!.append(decimals)
        }
    }
    
    @objc func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
    

    // Keyboard functions
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height - 200)
            }
        }
    }
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
}

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
    /*func addPropertyButton(_ sender: Any) {
        ref.child("users/tammn4/password").setValue("test4321")
    }*/

