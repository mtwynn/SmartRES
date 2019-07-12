//
//  EditPropertyViewController.swift
//  SmartRES
//
//  Created by Tam Nguyen on 7/9/19.
//  Copyright © 2019 Tam Nguyen. All rights reserved.
//

import UIKit
import YPImagePicker
import Parse

class EditPropertyViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    //var property: Property
    @IBOutlet weak var navBar: UINavigationItem!
    var delegate: controlsPropertyRefresh?
    var property: Property?
    var propertyThumbnail: UIImage?
    
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var zipField: UITextField!
    @IBOutlet weak var stateField: UITextField!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var bedField: UITextField!
    @IBOutlet weak var bathField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    
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
    
    
    
    @IBAction func editThumbnailButton(_ sender: Any) {
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
            } else {
                self.thumbnailView.layer.borderWidth = 1
                self.thumbnailView.layer.borderColor = UIColor.lightGray.cgColor
            }
            
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
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
        self.addressField.borderStyle = UITextField.BorderStyle.none
        self.cityField.borderStyle = UITextField.BorderStyle.none
        self.zipField.borderStyle = UITextField.BorderStyle.none
        self.stateField.borderStyle = UITextField.BorderStyle.none
        self.typeField.borderStyle = UITextField.BorderStyle.none
        self.bedField.borderStyle = UITextField.BorderStyle.none
        self.bathField.borderStyle = UITextField.BorderStyle.none
        self.priceField.borderStyle = UITextField.BorderStyle.none
        self.addressField.text = property?.address
        self.cityField.text = property?.city
        self.stateField.text = property?.state
        self.zipField.text = property?.zip
        self.typeField.text = property?.type
        self.bedField.text = property?.bed.stringValue
        self.bathField.text = property?.bath.stringValue
        self.priceField.text = property?.price.stringValue
        
        self.thumbnailView.layer.borderWidth = 2
        self.thumbnailView.layer.borderColor = UIColor.init(red: 0.0/255, green: 151/255, blue: 69/255, alpha: 0.8).cgColor
        self.thumbnailView.layer.cornerRadius = 5
        
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
        
        priceField.addTarget(self, action: #selector(priceAppend), for: UIControl.Event.editingDidEnd)
        
        
        // Keyboard dismissal functions
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        self.view.addGestureRecognizer(tapGesture)
        let swipeDown = UISwipeGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(swipeDown)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButton(_ sender: Any) {
        let query = PFQuery(className: "Property")
        query.getObjectInBackground(withId: property!.id) { (property: PFObject?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else if let property = property {
                property["address"] = self.addressField.text!.trim()
                property["city"] = self.cityField.text!.trim()
                property["state"] = self.stateField.text!.trim()
                property["zip"] = self.zipField.text!.trim()
                property["type"] = self.typeField.text!
                
                // Helper number formatter to convert strings to nums
                let formatter = NumberFormatter()
                formatter.generatesDecimalNumbers = true
                
                // Data that needs to be converted
                property["bed"] = formatter.number(from: self.bedField.text!) as? NSDecimalNumber ?? 0
                property["bath"] = formatter.number(from: self.bathField.text!) as? NSDecimalNumber ?? 0
                property["price"] = formatter.number(from: self.priceField.text!) as? NSDecimalNumber ?? 0
                if (self.thumbnailView.image != nil) {
                    let imageData = self.thumbnailView.image?.jpeg(.lowest)
                    //let imageData = thumbnailView.image?.pngData()
                    let file = PFFileObject(data: imageData!)
                    property["thumbnail"] = file
                }
                property.saveInBackground() {(success, error) in
                    if success {
                        self.delegate?.refresh()
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        let alert = UIAlertController(title: "Error", message: "Editing failed.", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @objc func priceAppend() {
        let counts = self.priceField.text!.split(separator: ".")
        let reqDecLength = counts[0].count + 3
        if (!self.priceField.text!.contains(".") && self.priceField.text! != "") {
            self.priceField.text!.append(".00")
        } else if (self.priceField.text!.contains(".") && self.priceField.text!.count < reqDecLength) {
            let decimals = String(repeating: "0", count: reqDecLength - self.priceField.text!.count)
            self.priceField.text!.append(decimals)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}
