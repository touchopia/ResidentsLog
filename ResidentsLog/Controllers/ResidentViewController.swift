//
//  ViewController.swift
//  ResidentsLog
//
//  Created by Phil Wright on 9/28/17.
//  Copyright © 2017 Touchopia, LLC. All rights reserved.
//

import UIKit
import RealmSwift
import MicroBlink

class ResidentViewController: UIViewController, UITextFieldDelegate, PPScanningDelegate {
    
    // Realm Instance
    private let realm = try! Realm()

    // Scanning Controller
    private var scanningViewController: PPScanningViewController?
    private let rawOcrParserId = "Raw ocr"
    
    private var hasSaved = false
    var currentPatient: Patient?
    
    @IBOutlet weak var mrnTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var doctorTextfield: UITextField!
    @IBOutlet weak var notesTextField: UITextField!
   
    private var formatter: DateFormatter {
        let format = DateFormatter()
        format.dateFormat = "MM/dd/yyyy"
        return format
    }
    
    // MARK: -
    // MARK: - View Controller Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
    
    @IBAction func savePatient(_ sender: UIButton) {
        let mrn = currentPatient?.mrn ?? ""
        
        guard let patient = realm.objects(Patient.self).filter("mrn = %@", mrn).first else {
            do {
                try realm.write() { () -> Void in
                    let newPatient = Patient()
                    newPatient.mrn = self.mrnTextField.text ?? ""
                    newPatient.doctor = self.doctorTextfield.text ?? ""
                    newPatient.procedure = self.notesTextField.text ?? ""
                    realm.add(newPatient)
                    self.hasSaved = true
                }
            } catch {
                print("An error occurred writing newPatient")
            }
            return
        }
        
        do {
            try realm.write() { () -> Void in
                patient.doctor = self.doctorTextfield.text ?? ""
                patient.procedure = self.notesTextField.text ?? ""
                self.hasSaved = true
            }
        } catch {
            print("An error occurred writing patient")
        }
    }
    
    func setupUI() {
        if let patient = currentPatient {
            mrnTextField.text = patient.mrn
            dateTextField.text = formatter.string(from: patient.createdAt as Date)
            doctorTextfield.text = patient.doctor
            notesTextField.text = patient.procedure
        } else {
            dateTextField.text = formatter.string(from: Date())
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destController = segue.destination as? RootViewController {
            DispatchQueue.main.async {
                destController.reloadData()
            }
        }
    }
    
    func coordinatorWithError(error: NSErrorPointer) -> PPCameraCoordinator? {
        if PPCameraCoordinator.isScanningUnsupported(for: .back, error: error) {
            return nil
        }
        
        let settings = PPSettings()
        
        settings.licenseSettings.licenseKey = "<ENTER YOUR KEY HERE"
        
        let ocrRecognizerSettings = PPBlinkOcrRecognizerSettings()
        
        let parser = PPRegexOcrParserFactory(regex: "\\d\\d\\d\\d\\d\\d\\d\\d+")
        
        ocrRecognizerSettings.addOcrParser(parser!, name: self.rawOcrParserId)
        
        settings.scanSettings.add(ocrRecognizerSettings)
        
        let coordinator = PPCameraCoordinator(settings: settings, delegate: nil)
        
        return coordinator
    }
    
    func scanningViewControllerUnauthorizedCamera(_ scanningViewController: UIViewController & PPScanningViewController) {
        print("unauthorized")
    }
    
    func scanningViewController(_ scanningViewController: UIViewController & PPScanningViewController, didFindError error: Error) {
        print("didFindError")
    }
    
    func scanningViewControllerDidClose(_ scanningViewController: UIViewController & PPScanningViewController) {
        scanningViewController.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapped() {
        
        var error: NSError?
        
        if !PPCameraCoordinator.isScanningUnsupported(for: .back, error: nil) {
            
            if let coordinator = self.coordinatorWithError(error: &error) {
                
                if scanningViewController == nil {
                    scanningViewController = PPViewControllerFactory.cameraViewController(with: self, coordinator: coordinator, error: nil)
                }
                
                if let vc = scanningViewController {
                    vc.scanningRegion = CGRect(origin: CGPoint(x: 0.15, y: 0.4), size: CGSize(width: 0.7, height: 0.2))
                    
                    self.present(vc as! UIViewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func scanningViewController(_ scanningViewController: (UIViewController & PPScanningViewController)?, didOutputResults results: [PPRecognizerResult]) {
        
        if results.isEmpty {
            return
        }
        
        scanningViewController?.pauseScanning()
        
        for result in results {
            if let ocrResult = result as? PPBlinkOcrRecognizerResult {
                let mrn = ocrResult.parsedResult(forName: self.rawOcrParserId)
                scanningViewController?.dismiss(animated: true, completion: {
                    self.mrnTextField.text = mrn
                })
            }
        }
        scanningViewController?.resumeScanningAndResetState(false)
    }
}
