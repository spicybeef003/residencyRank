//
//  FianlResultsViewController.swift
//  DankRanks
//
//  Created by Jiang, Tony on 12/7/17.
//  Copyright © 2017 Jiang, Tony. All rights reserved.
//

import UIKit
import StoreKit
import Disk
import LGButton
import SwiftMessages
import DHSmartScreenshot
import StoreKit

class FinalResultsViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var shareButtonOutlet: LGButton!
    @IBOutlet weak var homeButtonOutlet: LGButton!
    @IBOutlet weak var changeRanksOutlet: UIBarButtonItem!
    
    var myRanks: [Rank]!
    var thisRank: Rank!
    var rankFinished: Bool!
    var newRank = true
    var rankResult: UIImage!
    
    var queryRunning: Int = 0
    
    var type:String!
    var finalRankArray:[String] = [] // holds final ranking
    var finalRankImageArray:[UIImage] = [] // holds final ranking for images
    var finalRankImageArrayFullSize:[UIImage] = [] // full size images
    
    var rankName: String!
    var numObj: Int!
    var numSubsets: Int!
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if rankFinished {
            self.rankResult = tableView.screenshot()

            shareButtonOutlet.isHidden = false
            homeButtonOutlet.isHidden = false
            
            if !defaults.bool(forKey: "premium") {
                if var numberRanks = defaults.object(forKey: "numberRanks") as? Int {
                    if numberRanks == 7 { // every 6 or 7 ranks get asked
                        if #available( iOS 10.3,*) {
                            SKStoreReviewController.requestReview()
                        }
                        numberRanks = 0
                    }
                    numberRanks = numberRanks + 1
                    defaults.set(numberRanks, forKey: "numberRanks")
                }
                else {
                    defaults.set(1, forKey: "numberRanks")
                }
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        self.title = "My Rankings"
        
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 110
        tableView.delegate = self
        tableView.register(UINib(nibName: "ImageCellNib", bundle: nil), forCellReuseIdentifier: "imageCell")
        
    
        if !rankFinished {
            shareButtonOutlet.isHidden = true
            homeButtonOutlet.isHidden = true
            let doneItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.donePressed))
            self.navigationItem.rightBarButtonItem = doneItem
        }
    }
    

    @IBAction func changeRanksPressed(_ sender: UIBarButtonItem) {
        if changeRanksOutlet.title == "Change Ranks" {
            tableView.isEditing = true
            changeRanksOutlet.title = "Done"
            changeRanksOutlet.style = .done
        }
        else {
            tableView.isEditing = false
            changeRanksOutlet.title = "Change Ranks"
            changeRanksOutlet.style = .plain
        }
    }
    
    
    @IBAction func compilationPressed(_ sender: LGButton) {
        self.performSegue(withIdentifier: "toCompilationFromFinalResults", sender: self)
    }
    
    
    @objc func donePressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
  
    // MARK: start Tableview markup
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return finalRankArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath)
        cell.selectionStyle = .none
        
        let formattedString = NSMutableAttributedString()
        formattedString
            .bold("#\(indexPath.row + 1): ")
            .normal("\(finalRankArray[indexPath.row])")
        
        cell.textLabel?.attributedText = formattedString
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        let currentText = finalRankArray[sourceIndexPath.row]
        finalRankArray.remove(at: sourceIndexPath.row)
        finalRankArray.insert(currentText, at: destinationIndexPath.row)
        
        tableView.reloadData()
    }
    
    // MARK: end Tableview markup
    

    @IBAction func sharePressed(_ sender: LGButton) {
        self.rankResult = tableView.screenshot()
        let activityViewController = UIActivityViewController(activityItems: [self.rankResult], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [.print, .assignToContact, .addToReadingList, .postToFlickr, .postToVimeo, .postToTencentWeibo]
        
        self.present(activityViewController, animated: true, completion: nil)
        activityViewController.completionWithItemsHandler = { activity, completed, items, error in
            if completed {
                SwiftMessages.show {
                    let view = MessageView.viewFromNib(layout: .cardView)
                    view.configureTheme(.success)
                    view.configureDropShadow()
                    view.configureContent(title: "Success!", body: "")
                    view.button?.isHidden = true
                    return view
                }
            }
        }
    }
    
    @IBAction func goHomePressed(_ sender: LGButton) {
        let tabbarVC = storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        self.present(tabbarVC, animated: false, completion: nil)
    }
    
}



