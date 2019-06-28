//
//  AddPropertyViewController.swift
//  SmartRES
//
//  Created by Tam Nguyen on 6/26/19.
//  Copyright © 2019 Tam Nguyen. All rights reserved.
//

import UIKit

class AddPropertyViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var addressField: UITextField!
    
    @IBOutlet weak var cityField: UITextField!
    
    @IBOutlet weak var zipField: UITextField!
    @IBOutlet weak var stateField: UITextField!
    
    
    let picker_values = ["CA", "NV", "VA", "WA"]
    var myPicker : UIPickerView! = UIPickerView()
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return picker_values.count
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.myPicker = UIPickerView(frame: CGRect(x: 0, y: 40, width: 0, height: 0))
        self.stateField.delegate = self
        self.myPicker.delegate = self
        self.myPicker.dataSource = self
        
        self.addressField.borderStyle = UITextField.BorderStyle.none
        self.cityField.borderStyle = UITextField.BorderStyle.none
        self.zipField.borderStyle = UITextField.BorderStyle.none
        self.stateField.borderStyle = UITextField.BorderStyle.none
        
        
        
        // Keyboard functions
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        
        self.view.addGestureRecognizer(tapGesture)
        
        let swipeDown = UISwipeGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(swipeDown)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        
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
}
