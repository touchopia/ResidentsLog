//
//  MRNTableViewCell.swift
//  BlinkTest
//
//  Created by Phil Wright on 8/11/17.
//  Copyright © 2017 Touchopia, LLC. All rights reserved.
//

import UIKit
import RealmSwift

class MRNTableViewCell: UITableViewCell {
    
    let realm = try! Realm()
    var isLogged = false
    
    var formatter: DateFormatter {
        let format = DateFormatter()
        format.dateFormat = "MM/dd/yyyy"
        return format
    }
    
    var currentPatient: Patient? {
        didSet {
            setupUI()
        }
    }
    
    @IBOutlet weak var mrnLabel: UILabel!
    @IBOutlet weak var checkedButton: UIButton!
    
    func setupUI() {
        if let patient = currentPatient {
            
            //patient.debugDump()
            self.mrnLabel.text = patient.mrn
            
            if patient.isLogged {
                isLogged = true
                checkedButton.setImage(UIImage(named: "checked-icon"), for: .normal)
            } else {
                isLogged = false
                checkedButton.setImage(UIImage(named: "unchecked-icon"), for: .normal)
            }
        }
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        if isLogged {
            isLogged = false
            checkedButton.setImage(UIImage(named: "unchecked-icon"), for: .normal)
            updatePatient(logged: false)
        } else {
            isLogged = true
            checkedButton.setImage(UIImage(named: "checked-icon"), for: .normal)
            updatePatient(logged: true)
        }
    }
    
    func updatePatient(logged: Bool) {
        let mrn = currentPatient?.mrn ?? ""
        
        guard let patient = realm.objects(Patient.self).filter("mrn = %@", mrn).first else {
            return
        }
        
        do {
            try realm.write() { () -> Void in
                patient.isLogged = logged
            }
        } catch {
            print("An error occurred writing newPatient")
        }
    }
    
    
    
    
}
