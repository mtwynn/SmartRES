//
//  User.swift
//  SmartRES
//
//  Created by Tam Nguyen on 7/18/19.
//  Copyright © 2019 Tam Nguyen. All rights reserved.
//
import Foundation
import Firebase
import UIKit

struct User {
    let uid: String
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let bio: String
    let logo: UIImage
    
    init(authData: Firebase.User) {
        uid = authData.uid
        email = authData.email!
        firstName = ""
        lastName = ""
        phone = ""
        bio = ""
        logo = UIImage()
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
        firstName = ""
        lastName = ""
        phone = ""
        bio = ""
        logo = UIImage()
    }
}
