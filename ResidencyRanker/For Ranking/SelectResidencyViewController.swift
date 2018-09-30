//
//  SelectResidencyViewController.swift
//  ResidencyRanker
//
//  Created by Tony Jiang on 8/31/18.
//  Copyright © 2018 Tony Jiang. All rights reserved.
//

import UIKit

protocol SelectResidencyViewControllerDelegate: class {
    func residenciesSelected(residencies: [String])
}

class SelectResidencyViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var specialty: String!
    var searchActive: Bool!
    var selectedResidencies: [String]!
    var residencyList: [String] = []
    var resourceName: String!
    var filteredArray: [String] = []
    
    var delegate: SelectResidencyViewControllerDelegate?
    
    func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .all
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchBar()
        setupTableView()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = .clear
        tableView.separatorColor = .black
        let px: CGFloat = 0.5
        let frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: px)
        let line = UIView(frame: frame)
        self.tableView.tableHeaderView = line
        line.backgroundColor = self.tableView.separatorColor
        tableView.estimatedRowHeight = 50
        
        switch specialty {
        case "Anesthesiology": resourceName = "AnesResidencyList"
        case "Dermatology": resourceName = "DermResidencyList"
        case "Emergency Medicine": resourceName = "EMResidencyList"
        case "Family Medicine": resourceName = "FMResidencyList"
        case "General Surgery": resourceName = "GenSurgResidencyList"
        case "Internal Medicine": resourceName = "IMResidencyList"
        case "Interventional Radiology": resourceName = "IRResidencyList"
        case "Neurology": resourceName = "NeurologyResidencyList"
        case "Neurosurgery": resourceName = "NeurosurgeryResidencyList"
        case "Obstetrics & Gynecology": resourceName = "OBGYNResidencyList"
        case "Otolaryngology (ENT)": resourceName = "ENTResidencyList"
        case "Orthopedic Surgery": resourceName = "OrthoResidencyList"
        case "Pathology": resourceName = "PathologyResidencyList"
        case "Pediatrics":  resourceName = "PediatricsResidencyList"
        case "Plastic Surgery": resourceName = "PlasticsResidencyList"
        case "Physical Medicine & Rehabilitation": resourceName = "PMRResidencyList"
        case "Psychiatry": resourceName = "PsychResidencyList"
        case "Radiology": resourceName = "RadiologyResidencyList"
        case "Radiation Oncology": resourceName = "RadOncResidencyList"
        case "Urology": resourceName = "UrologyResidencyList"
        case "Vascular Surgery": resourceName = "VascularResidencyList"
        default: ()
        }
        let path: String = Bundle.main.path(forResource: resourceName, ofType: "xlsx")!
        let spreadsheet: BRAOfficeDocumentPackage = BRAOfficeDocumentPackage.open(path)
        let worksheet: BRAWorksheet = spreadsheet.workbook.worksheets[0] as! BRAWorksheet
        
        residencyList = []
        for (index,row) in worksheet.rows.enumerated() {
            if index > 0 { // skip first row
                residencyList.append(worksheet.cell(forCellReference: "C\(index+1)").stringValue())
            }
        }
        
        filteredArray = residencyList
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.singleTap))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func singleTap() {
        self.searchBar.resignFirstResponder()
    }

    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        delegate?.residenciesSelected(residencies: selectedResidencies)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: search bar setup
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("begin editing")
        searchActive = true
        
        if searchBar.text!.count == 0 {
            searchActive = false
            self.tableView.reloadData()
        }
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("end Edit")
        searchBar.resignFirstResponder()
        searchActive = searchBar.text!.count == 0 ? false : true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            filteredArray = residencyList
        }
        else {
            searchActive = true
            
            //filteredArray = residencyList.filter { $0 == searchText }
            filteredArray = residencyList.filter { $0.range(of: searchText) != nil }
        }
        self.tableView.reloadData()
    }
    
    // MARK: Tableview setup
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath)
        cell.separatorInset = .zero
        cell.backgroundColor = .clear
        
        cell.textLabel?.text = filteredArray[indexPath.row]
        cell.textLabel?.lineBreakMode = .byWordWrapping
        
        if selectedResidencies.contains(filteredArray[indexPath.row]) {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if let residency = cell.textLabel?.text {
                if selectedResidencies.contains(residency) {
                    print("1")
                    cell.accessoryType = .none
                    selectedResidencies.remove(at: selectedResidencies.index(of: residency)!)
                }
                else {
                    print("3")
                    if selectedResidencies.count >= 8 {
                        print("2")
                        if defaults.bool(forKey: "premium") {
                            cell.accessoryType = .checkmark
                            selectedResidencies.append(residency)
                        }
                        else {
                            let myAlert = UIAlertController(title: "Premium status is needed to rank more than 8 residencies.", message: nil, preferredStyle: .alert)
                            
                            let yesAction = UIAlertAction(title: "Go Premium", style: .cancel) { _ in
                                let vc = SettingsViewController()
                                vc.purchase(purchase: RegisteredPurchase.bingle)
                            }
                            
                            let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in
                            }
                            
                            myAlert.addAction(cancelAction)
                            myAlert.addAction(yesAction)
                            
                            if let popoverController = myAlert.popoverPresentationController {
                                popoverController.sourceView = self.view
                            }
                            self.present(myAlert, animated: true, completion: nil)
                        }
                    }
                    else {
                        cell.accessoryType = .checkmark
                        selectedResidencies.append(residency)
                    }
                }
                
                
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

