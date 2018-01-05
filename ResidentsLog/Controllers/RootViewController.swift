//
//  RootViewController.swift
//  ResidentsLog
//
//  Created by Phil Wright on 10/5/17.
//  Copyright © 2017 Touchopia, LLC. All rights reserved.
//

import UIKit
import RealmSwift

class RootViewController: UITableViewController {
    
    // Setup Realm
    private let realm = try! Realm()
    
    // Patient Data
    private var patients = [Patient]()
    private let segueIdentifier = "ShowPatient"
    
    var currentPatient: Patient?
    
    // MARK: -
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createRefreshControl()
        self.tableView.rowHeight = 60
        reloadData()
    }
    
    //MARK: -
    //MARK: - Public Methods
    
    func reloadData() {
        let allPatients = realm.objects(Patient.self).sorted(byKeyPath: "createdAt", ascending: false)
        self.patients.removeAll()
        
        for p in allPatients {
            self.patients.append(p)
        }
        self.tableView.reloadData()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        reloadData()
        refreshControl.endRefreshing()
    }
    
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        currentPatient = nil
        performSegue(withIdentifier: segueIdentifier, sender: self)
    }
    
    @IBAction func unwindToRootViewController(segue: UIStoryboardSegue) {
    }
    
    // MARK: -
    // MARK: - Private Methods
    
    private func createRefreshControl() {
        let rControl = UIRefreshControl()
        rControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControlEvents.valueChanged)
        rControl.tintColor = UIColor.red
        self.refreshControl = rControl
    }
}

//MARK: -
//MARK: - UITableViewDataSource

extension RootViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patients.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MRNTableViewCell
        cell.currentPatient = patients[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let patient = patients[indexPath.row]
            
            do {
                try realm.write {
                    realm.delete(patient)
                    
                    DispatchQueue.main.async {
                        self.patients.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            } catch {
                print("unable to delete patient")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentPatient = self.patients[indexPath.row]
        self.performSegue(withIdentifier: segueIdentifier, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier {
            if let destController = segue.destination as? ResidentViewController {
                destController.currentPatient = currentPatient
            }
        }
    }
}
