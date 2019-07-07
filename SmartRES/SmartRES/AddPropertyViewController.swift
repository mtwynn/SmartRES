//
//  AddPropertyViewController.swift
//  SmartRES
//
//  Created by Tam Nguyen on 6/26/19.
//  Copyright © 2019 Tam Nguyen. All rights reserved.
//

import UIKit
import Parse
import Alamofire
import YPImagePicker

class AddPropertyViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var delegate: controlsRefresh?
    
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
    
    // States and their data
    var sortedStates = [String]()
    var stateDictionary = [ "Alabama": "AL",
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
    var typesArray = ["House", "Apartment", "Land"]
    
    // Pickers 
    var statePicker : UIPickerView! = UIPickerView()
    var typePicker : UIPickerView! = UIPickerView()
    var myPicker : UIPickerView! = UIPickerView()


    //var ref: DatabaseReference!
    var thumbnail: UIImage! = UIImage()
    

    override func viewDidLoad() {
        // Initialize all pickers 
        super.viewDidLoad()
        self.statePicker = UIPickerView(frame: CGRect(x: 0, y: 40, width: 0, height: 0))
        self.typePicker = UIPickerView(frame: CGRect(x: 0, y: 40, width: 0, height: 0))
        self.typePicker.delegate = self
        self.typePicker.dataSource = self
        
        self.statePicker.tag = 1
        self.typePicker.tag = 2
        self.stateField.delegate = self
        self.statePicker.delegate = self
        self.statePicker.dataSource = self
        
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
        
        // Add toolbar (Cancel/Done) to Pickers
        let toolBar = UIToolbar()
        statePicker.showsSelectionIndicator = true
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
        self.stateField.inputAccessoryView = toolBar
        self.typeField.inputAccessoryView = toolBar

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
    

    @IBAction func stateButton(_ sender: Any) {
        self.stateField.becomeFirstResponder()
    }
    

    func cancelPicker(sender: UIButton) {
        self.stateField.resignFirstResponder()
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
        config.screens = [.library, .photo]
        config.albumName = "SmartRES"
        config.startOnScreen = YPPickerScreen.library
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
        let property = PFObject(className: "Property")
        
        property["agent"] = PFUser.current()!
        property["address"] = self.addressField.text!
        property["city"] = self.cityField.text!
        property["state"] = self.stateField.text!
        property["zip"] = self.zipField.text!
        property["type"] = self.typeField.text!
        
        // Helper number formatter to convert strings to nums
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        
        // Data that needs to be converted
        property["bed"] = formatter.number(from: self.bedField.text!) as? NSDecimalNumber ?? 0
        property["bath"] = formatter.number(from: self.bathField.text!) as? NSDecimalNumber ?? 0
        property["price"] = formatter.number(from: self.priceField.text!) as? NSDecimalNumber ?? 0
        
        // Check if thumnail exists before trying to add it
        if (thumbnailView.image != nil) {
            let imageData = thumbnailView.image?.jpeg(.lowest)
            //let imageData = thumbnailView.image?.pngData()
            let file = PFFileObject(data: imageData!)
            property["thumbnail"] = file
        }
        
        let alert = UIAlertController(title: "Confirmation", message: "Would you like to add this property?", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {action in
                property.saveInBackground() { (success, error) in
                    if success {
                        self.delegate?.loadProperties()
                        print(property.objectId)
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
                    } else {
                        let alert = UIAlertController(title: "Error", message: "Adding property failed.", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
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
        return (pickerView.tag == 1) ? stateDictionary.count : typesArray.count
    }
    

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (pickerView.tag == 1) ? self.sortedStates[row] : typesArray[row]
    }
    

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView.tag == 1) {
            stateField.text = stateDictionary[self.sortedStates[row]]!
        } else {
            typeField.text = typesArray[row]
        }
    }

    @objc func donePicker() {
        
        stateField.resignFirstResponder()
        typeField.resignFirstResponder()
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
    

    // Keyboard functions
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height - keyboardSize.height)
            }
        }
    }
    

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
}
    /*func addPropertyButton(_ sender: Any) {
        ref.child("users/tammn4/password").setValue("test4321")
    }*/

