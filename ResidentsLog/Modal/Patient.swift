//
//  Patient.swift
//  BlinkTest
//
//  Created by Phil Wright on 8/9/17.
//  Copyright © 2017 Touchopia, LLC. All rights reserved.
//

import RealmSwift

class Patient: Object {
    @objc dynamic var mrn = ""
    @objc dynamic var doctor = ""
    @objc dynamic var resident = ""
    @objc dynamic var procedure = ""
    @objc dynamic var createdAt = NSDate()
    @objc dynamic var isLogged = false
}

