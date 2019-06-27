//
//  AddPropertyViewController.swift
//  SmartRES
//
//  Created by Tam Nguyen on 6/26/19.
//  Copyright © 2019 Tam Nguyen. All rights reserved.
//

import UIKit

class AddPropertyViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
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
        
        
        
        
    }
    
    @IBAction func stateButton(_ sender: Any) {
        self.stateField.becomeFirstResponder()
    }
    
    func cancelPicker(sender: UIButton) {
        self.stateField.resignFirstResponder()
    }
    
}
