//
//  SecondViewController.swift
//  ResidencyRanker
//
//  Created by Tony Jiang on 8/29/18.
//  Copyright © 2018 Tony Jiang. All rights reserved.
//

import UIKit
import Disk

class MyRanksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var premiumOutlet: UIBarButtonItem!
    
    var myRanks: [Rank] = []
    let dateFormatter = DateFormatter()
    var emptyLabel = UILabel()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if defaults.bool(forKey: "premium") {
            premiumOutlet.title = ""
            premiumOutlet.isEnabled = false
        }
        else {
            premiumOutlet.title = "Go Premium"
            premiumOutlet.isEnabled = true
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            if Disk.exists("myRanks.json", in: .documents) {
                self.myRanks = try! Disk.retrieve("myRanks.json", from: .documents, as: [Rank].self)
            }
            else {
                try? Disk.save(self.myRanks, to: .documents, as: "myRanks.json")
            }
            DispatchQueue.main.async {
                if self.myRanks.count == 0 {
                    self.loadEmptyLabel()
                }
                else {
                    self.emptyLabel.isHidden = true
                }
                self.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(emptyLabel)
        
        dateFormatter.dateFormat = "MMM d, yyyy hh:mm aaa"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func loadEmptyLabel() {
        self.emptyLabel.text = "Start ranking residencies by tapping ➕ in the upper right corner"
        self.emptyLabel.textColor = UIColor.black
        self.emptyLabel.textAlignment = .center
        self.emptyLabel.font = UIFont(name: "Avenir", size: (Env.iPad ? 30 : 20))
        self.emptyLabel.numberOfLines = 0
        self.emptyLabel.lineBreakMode = .byWordWrapping
        self.emptyLabel.adjustsFontSizeToFitWidth = true
        self.emptyLabel.minimumScaleFactor = 0.5
        self.emptyLabel.frame.size = CGSize(width: self.view.frame.width*0.9, height: self.view.frame.height/4)
        self.emptyLabel.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/5*2)
        self.emptyLabel.isHidden = false
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myRanks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! MyRankCell
        cell.separatorInset = .zero
        
        let thisRank = myRanks[myRanks.count - 1 - indexPath.row] // go from bottom to top
        
        let fontStyle = UIFont(name: "Avenir", size: (Env.iPad ? 24 : 16))
        
        cell.rankName.text = thisRank.projectName.isEmpty ? "Untitled" : thisRank.projectName
        cell.rankName.font = UIFont(name: "Avenir", size: (Env.iPad ? 33 : 22))
        cell.sizeToFit()
        
        cell.specialty.text = "Type: \(thisRank.specialty)"
        cell.specialty.font = fontStyle
        
        cell.objectNumAndSubset.text = "\(thisRank.numObj!) objects, subset size of \(thisRank.numSubsets!)"
        cell.objectNumAndSubset.font = fontStyle
        
        cell.rankDate.text = "Created: " + dateFormatter.string(from: thisRank.dateCreated)
        cell.rankDate.font = fontStyle
        
        cell.statusLabel.text = thisRank.rankFinished ? "Status: Complete" : "Status: In Progress"
        cell.statusLabel.font = fontStyle
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let thisRank = myRanks[myRanks.count - 1 - indexPath.row]
        if thisRank.rankFinished { // already completed so just see results
            let destination = self.storyboard?.instantiateViewController(withIdentifier: "FinalResultsViewController") as! FinalResultsViewController
            destination.rankName = thisRank.projectName
            destination.numObj = thisRank.numObj
            destination.numSubsets = thisRank.numSubsets
            destination.thisRank = thisRank
            destination.myRanks = myRanks
            destination.rankFinished = true
            
            destination.finalRankArray = thisRank.finalRankTextArray
           
            self.navigationController?.pushViewController(destination, animated: true)
        }
        else {
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "RankingViewController") as! RankingViewController
            myVC.myRanks = myRanks
            myVC.thisRank = myRanks[myRanks.count - 1 - indexPath.row]
            myVC.thisRankIndexPathRow = myRanks.count - 1 - indexPath.row
            self.navigationController?.pushViewController(myVC, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let myAlert = UIAlertController(title: "Delete rank?", message: nil, preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) { (ACTION) in
                self.myRanks.remove(at: (self.myRanks.count - 1 - indexPath.row))
                try! Disk.save(self.myRanks, to: .documents, as: "myRanks.json")
                
                DispatchQueue.main.async {
                    let range = NSMakeRange(0, self.tableView.numberOfSections)
                    let sections = NSIndexSet(indexesIn: range)
                    self.tableView.reloadSections(sections as IndexSet, with: .automatic)
                    self.tableView.isEditing = false
                    if self.myRanks.count == 0 {
                        self.loadEmptyLabel()
                    }
                }
            }
            let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.default) { (ACTION) in
                
            }
            myAlert.addAction(yesAction)
            myAlert.addAction(noAction)
            
            if let popoverController = myAlert.popoverPresentationController {
                popoverController.sourceView = self.view
            }
            self.present(myAlert, animated: true, completion: nil)
        }
    }
    
    // MARK: end tableview markup
    
    @IBAction func addRankPressed(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "toChooseRankType", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SetupRankOptionsViewController {
            destination.myRanks = self.myRanks
        }
    }
    
    @IBAction func goPremiumPressed(_ sender: UIBarButtonItem) {
        let tabbarVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        tabbarVC.selectedIndex = 2
        self.present(tabbarVC, animated: true, completion: {
            let vc = tabbarVC.viewControllers![2] as! SettingsViewController
            vc.purchase(purchase: .bingle)
        })
    }
}

class MyRankCell: UITableViewCell {
    @IBOutlet weak var specialty: UILabel!
    @IBOutlet weak var rankName: UILabel!
    @IBOutlet weak var rankDate: UILabel!
    @IBOutlet weak var objectNumAndSubset: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        specialty.text = ""
        rankName.text = ""
        rankDate.text = ""
        objectNumAndSubset.text = ""
        statusLabel.text = ""
    }
}

