//
//  EnterResidenciesViewController.swift
//  ResidencyRanker
//
//  Created by Tony Jiang on 9/1/18.
//  Copyright © 2018 Tony Jiang. All rights reserved.
//

import UIKit
import LGButton
import Disk

class EnterResidenciesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, SelectResidencyViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var projectTitleOutlet: UITextField!
    @IBOutlet weak var startRankingButtonOutlet: LGButton!
    @IBOutlet weak var premiumLabel: UILabel!
    
    var myRanks: [Rank]!
    var thisRank: Rank!
    var numObjects: Int = 0
    var textArray: [String] = []
    var thisRankIndexPathRow: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        setupTableView()
        
        if !defaults.bool(forKey: "premium") {
            startRankingButtonOutlet.titleString = "Start Ranking*"
            premiumLabel.isHidden = false
        }
        else {
            startRankingButtonOutlet.titleString = "Start Ranking"
            premiumLabel.isHidden = true
        }
        
        projectTitleOutlet.layer.borderWidth = 1
        projectTitleOutlet.layer.borderColor = UIColor.black.cgColor
        projectTitleOutlet.layer.cornerRadius = 5
        
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
    }
    
    @objc func deleteCell(_ gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: self.tableView)
        if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
            let myAlert = UIAlertController(title: "Remove \(textArray[tapIndexPath.row])?", message: nil, preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
                self.textArray.remove(at: tapIndexPath.row)
                self.numObjects = self.numObjects - 1
                DispatchQueue.main.async {
                    let range = NSMakeRange(0, self.tableView.numberOfSections)
                    let sections = NSIndexSet(indexesIn: range)
                    self.tableView.reloadSections(sections as IndexSet, with: .automatic)
                }
            }
            
            let cancelAction = UIAlertAction(title: "No", style: .default) { _ in
            }
            
            myAlert.addAction(yesAction)
            myAlert.addAction(cancelAction)
            
            if let popoverController = myAlert.popoverPresentationController {
                popoverController.sourceView = self.view
            }
            self.present(myAlert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func addPressed(_ sender: LGButton) {
        self.performSegue(withIdentifier: "toResidencyList", sender: self)
    }
 
    
    
    @objc func didFinishTyping(_ textField: UITextField) {
        let pointInTable = textField.convert(textField.bounds.origin, to: self.tableView)
        let textFieldIndexPath = self.tableView.indexPathForRow(at: pointInTable)
        textArray[textFieldIndexPath!.row] = textField.text ?? ""
        print(textArray)
    }
    
    @objc func textChanged(_ sender: AnyObject) {
        let tf = sender as! UITextField
        var resp: UIResponder = tf
        while !(resp is UIAlertController) { resp = resp.next! }
        let alert = resp as! UIAlertController
        
        if let numObj = Int(tf.text!) {
            (alert.actions[1] as UIAlertAction).isEnabled = numObj > 0
        }
    }
    
    @IBAction func createRankPressed(_ sender: LGButton) {
        if numObjects < thisRank.numSubsets {
            alert(message: "", title: "Please rank at least \(thisRank.numSubsets!) residencies" as NSString)
            shake(object: sender)
            return
        }
        
        thisRank.numObj = numObjects
        thisRank.textArray = textArray
        thisRank.projectName = projectTitleOutlet.text!.count == 0 ? "Untitled" : projectTitleOutlet.text!
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.myRanks.append(self.thisRank)
            self.thisRankIndexPathRow = self.myRanks.count - 1
            try? Disk.save(self.myRanks, to: .documents, as: "myRanks.json")
            DispatchQueue.main.async {
                self.goToRankingVC()
            }
        }
    }
    
    func goToRankingVC() {
        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "RankingViewController") as! RankingViewController
        myVC.thisRank = thisRank
        myVC.myRanks = myRanks
        myVC.thisRankIndexPathRow = thisRankIndexPathRow
        self.navigationController?.pushViewController(myVC, animated: true)
    }
    
    func residenciesSelected(residencies: [String]) {
        numObjects = residencies.count
        textArray = residencies
        self.tableView.reloadData()
    }
    
    // MARK: Tableview setup
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! textObjectCell
        cell.separatorInset = .zero
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        
        cell.objectNumberLabel.text = "#\(indexPath.row + 1)"
        
        cell.objectTextField.text = textArray[indexPath.row]
        cell.objectTextField.delegate = self
        cell.objectTextField.addTarget(self, action: #selector(didFinishTyping), for: .editingDidEnd)
        
        cell.deleteIconOutlet.tag = indexPath.row
        let deleteTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.deleteCell))
        deleteTapGesture.delegate = self
        cell.deleteIconOutlet.addGestureRecognizer(deleteTapGesture)
        
        return cell
    }
    
    // MARK: end tableview setup
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SelectResidencyViewController {
            destination.delegate = self
            destination.specialty = thisRank.specialty
            destination.selectedResidencies = textArray
        }
    }
    
}


class textObjectCell: UITableViewCell {
    @IBOutlet weak var objectNumberLabel: UILabel!
    @IBOutlet weak var objectTextField: UITextField!
    @IBOutlet weak var deleteIconOutlet: UIImageView!
    
    var numObjects: Int!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        objectNumberLabel.text = nil
        objectTextField.text = nil
    }
}
