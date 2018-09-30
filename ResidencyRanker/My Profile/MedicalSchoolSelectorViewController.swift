//
//  MedicalSchoolSelectorViewController.swift
//  ResidencyRanker
//
//  Created by Tony Jiang on 9/1/18.
//  Copyright © 2018 Tony Jiang. All rights reserved.
//

import UIKit
import Eureka

protocol MedicalSchoolSelectorControllerDelegate: class {
    func schoolSelected(school: String?)
}

class MedicalSchoolSelectorViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {


    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchActive: Bool!
    var selectedResidencies: [String] = []
    var schoolList: [String] = []
    var selectedSchool: String?
    var filteredArray: [String] = []
    
    var delegate: MedicalSchoolSelectorControllerDelegate?
    
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
        
        filteredArray = schoolList
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
        delegate?.schoolSelected(school: selectedSchool)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: search bar setup
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
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
            filteredArray = schoolList
        }
        else {
            searchActive = true
            
            filteredArray = schoolList.filter { $0 == searchText }
            filteredArray = filteredArray + schoolList.filter { $0.range(of: searchText) != nil }
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
        
        if selectedSchool == filteredArray[indexPath.row] {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if selectedSchool == cell.textLabel?.text {
                cell.accessoryType = .none
                selectedSchool = nil
            }
            else {
                cell.accessoryType = .checkmark
                selectedSchool = cell.textLabel?.text
                tableView.reloadData()
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
