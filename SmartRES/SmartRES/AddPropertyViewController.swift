//
//  AddPropertyViewController.swift
//  SmartRES
//
//  Created by Tam Nguyen on 6/26/19.
//  Copyright © 2019 Tam Nguyen. All rights reserved.
//

import UIKit
import Parse
import FirebaseCore
import FirebaseDatabase

class AddPropertyViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var addressField: UITextField!
    
    @IBOutlet weak var cityField: UITextField!
    
    @IBOutlet weak var zipField: UITextField!
    @IBOutlet weak var stateField: UITextField!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var bedField: UITextField!
    @IBOutlet weak var bathField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    
    var stateDictionary = ["Alabama": "AL",
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
    
    var sortedStates = [String]()
    var typesArray = ["House", "Apartment", "Land"]
    var statePicker : UIPickerView! = UIPickerView()
    var typePicker : UIPickerView! = UIPickerView()

    let picker_values = ["CA", "NV", "VA", "WA"]
    var myPicker : UIPickerView! = UIPickerView()
    var ref: DatabaseReference!
    
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
    

    override func viewDidLoad() {
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
        
        self.addressField.borderStyle = UITextField.BorderStyle.none
        self.cityField.borderStyle = UITextField.BorderStyle.none
        self.zipField.borderStyle = UITextField.BorderStyle.none
        self.stateField.borderStyle = UITextField.BorderStyle.none
        self.typeField.borderStyle = UITextField.BorderStyle.none
        self.bedField.borderStyle = UITextField.BorderStyle.none
        self.bathField.borderStyle = UITextField.BorderStyle.none
        self.priceField.borderStyle = UITextField.BorderStyle.none
        
        //self.myPicker.data
        
        statePicker.showsSelectionIndicator = true
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(donePicker))
    
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        self.stateField.inputView = self.statePicker
        self.typeField.inputView = self.typePicker
        self.stateField.inputAccessoryView = toolBar
        self.typeField.inputAccessoryView = toolBar
        self.sortedStates = (Array(stateDictionary.keys).sorted())
        
        // Keyboard functions
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        
        self.view.addGestureRecognizer(tapGesture)
        
        let swipeDown = UISwipeGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(swipeDown)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let ref = Database.database().reference()
        
        
    }
    
    @IBAction func stateButton(_ sender: Any) {
        self.stateField.becomeFirstResponder()
    }
    
    func cancelPicker(sender: UIButton) {
        self.stateField.resignFirstResponder()
    }
    
    
    @IBAction func textField(sender: UITextField) {
        //Create the view
        let tintColor: UIColor = UIColor(red: 101.0/255.0, green: 98.0/255.0, blue: 164.0/255.0, alpha: 1.0)
        let inputView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 240))
        myPicker.tintColor = tintColor
        myPicker.center.x = inputView.center.x
        inputView.addSubview(myPicker) // add date picker to UIView
        let doneButton = UIButton(frame: CGRect(x: 100/2, y: 0, width: 100, height: 50))
        doneButton.setTitle("Done", for: UIControl.State.highlighted)
        doneButton.setTitleColor(tintColor, for: UIControl.State.highlighted)
        inputView.addSubview(doneButton) // add Button to UIView
        doneButton.addTarget(self, action: Selector(("doneButton:")), for: UIControl.Event.touchUpInside) // set button click event
        
        let cancelButton = UIButton(frame: CGRect(x: (self.view.frame.size.width - 3*(100/2)), y: 0, width: 100, height: 50))
        cancelButton.setTitle("Cancel", for: UIControl.State.highlighted)
        cancelButton.setTitleColor(tintColor, for: UIControl.State.highlighted)
        inputView.addSubview(cancelButton) // add Button to UIView
        cancelButton.addTarget(self, action: Selector(("cancelPicker:")), for: UIControl.Event.touchUpInside) // set button click event
        sender.inputView = inputView
    }
    
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
    
    @objc func donePicker() {
        
        stateField.resignFirstResponder()
        typeField.resignFirstResponder()
    }
    
    @IBAction func addButton(_ sender: Any) {
        let property = PFObject(className: "Property")
        property["agent"] = PFUser.current()!
        property["address"] = self.addressField.text!
        property["city"] = self.cityField.text!
        property["state"] = self.stateField.text!
        property["zip"] = self.zipField.text!
        property["type"] = self.typeField.text!
        if let intBed = Int(self.bedField.text!) {
            property["bed"] = NSNumber(value:intBed)
        }
        if let intBath = Int(self.bathField.text!) {
            property["bath"] = NSNumber(value:intBath)
        }
        
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        
        property["price"] = formatter.number(from: self.priceField.text!) as? NSDecimalNumber ?? 0
    
        property.saveInBackground() { (success, error) in
            if success {
                let alert = UIAlertController(title: "Success", message: "Property added! Please refresh to see changes.", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Error", message: "Adding property failed.", preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
    /*func addPropertyButton(_ sender: Any) {
        ref.child("users/tammn4/password").setValue("test4321")
    }*/

