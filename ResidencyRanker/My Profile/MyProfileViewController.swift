//
//  FirstViewController.swift
//  ResidencyRanker
//
//  Created by Tony Jiang on 8/29/18.
//  Copyright © 2018 Tony Jiang. All rights reserved.
//

import UIKit
import Eureka
import SwiftyStoreKit
import Disk
import Firebase

class MyProfileViewController: FormViewController, MedicalSchoolSelectorControllerDelegate {
    
    let bundleID = "com.TianProductions"
    var bingle = RegisteredPurchase.bingle
    
    var degreeSought: String?
    var schoolName: String?
    var numInterviewsReceived: Int?
    var numInterviewsExecuted: Int?
    var stepScore: String?
    
    var myRanks: [Rank] = []
    var rankListArray: [String] = []
    var rankID: String?
    var specialty: String?
    
    var degreeTypes: [String] = []
    var MDSchoolList: [String] = []
    var DOSchoolList: [String] = []
    var stepScoreList: [String] = []
    var combinedSchoolList: [String] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadPreferences()
        
        updateTables()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "My Profile"
        
        hideKeyboardWhenTappedAround()
        loadPreferences()
        loadStepScores()
        loadDegreeTypes()
        loadSchoolLists()
        
        // PROFILE STATUS
        form +++ Section("Profile Status") { section in
            section.footer = HeaderFooterView(title: defaults.bool(forKey: "premium") ? "Welcome to the club!" : "Upgrade to premium to unlock the ability to rank more than 10 residencies.")
            }
            <<< ButtonRow("status") {
                $0.title = defaults.bool(forKey: "premium") ? "Privileges: Premium" : "Privileges: Guest"
                $0.onCellSelection( { cell, row in
                    let myAlert = UIAlertController(title: "Options", message: "", preferredStyle: .alert)
                    
                    let yesAction = UIAlertAction(title: "Go Premium", style: .cancel) { _ in
                        let tabbarVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                        tabbarVC.selectedIndex = 2
                        self.present(tabbarVC, animated: true, completion: {
                            let vc = tabbarVC.viewControllers![2] as! SettingsViewController
                            vc.purchase(purchase: .bingle)
                        })
                    }
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in
                        self.heavyShake(object: cell)
                        self.fullRotate(object: cell)
                    }
                    
                    myAlert.addAction(cancelAction)
                    myAlert.addAction(yesAction)
                    
                    if let popoverController = myAlert.popoverPresentationController {
                        popoverController.sourceView = self.view
                    }
                    self.present(myAlert, animated: true, completion: nil)
                    
                })
            }
            <<< ButtonRow("restore") {
                $0.hidden = defaults.bool(forKey: "premium") ? true : false
                $0.title = "Restore my purchase"
                $0.onCellSelection({ cell, row in
                    let tabbarVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                    tabbarVC.selectedIndex = 2
                    self.present(tabbarVC, animated: true, completion: {
                        let vc = tabbarVC.viewControllers![2] as! SettingsViewController
                        vc.restorePurchases()
                    })
                })
            }
        
        // PROGRAM TYPE
        let programType = SelectableSection<ListCheckRow<String>>("Degree(s) Sought", selectionType: .singleSelection(enableDeselection: true))
        for (index,degree) in degreeTypes.enumerated() {
            programType <<< ListCheckRow<String>(degree) { listRow in
                listRow.title = degree
                listRow.selectableValue = degree
                listRow.value = nil
                listRow.tag = "\(index)"
                if let _ = degreeSought {
                    if degree == degreeSought! {
                        listRow.value = "3"
                    }
                }
            }
        }
        
        
        form +++ programType
        programType.tag = "programType"
        programType.onSelectSelectableRow = { (cell, cellRow) in
            if cellRow.title! == self.degreeSought {
                self.degreeSought = nil
            }
            else {
                self.degreeSought = cellRow.title!
            }
            defaults.set(self.degreeSought, forKey: "degreeSought")
        }
        
        // MEDICAL SCHOOL
        form +++ Section("Medical School")
            <<< ButtonRow("school") {
                if let _ = defaults.object(forKey: "schoolName") as? String {
                    $0.title = defaults.string(forKey: "schoolName")
                }
                else {
                    $0.title = "Select Medical School"
                }
                $0.onCellSelection( { cell, row in
                    self.performSegue(withIdentifier: "toChooseSchool", sender: self)
                }).cellUpdate { cell, row in
                    cell.textLabel?.textAlignment = .center
                    cell.textLabel?.textColor = .black
                    cell.textLabel?.numberOfLines = 0
                }
        }
        
        // STEP SCORE
        let stepScoreSelection = SelectableSection<ListCheckRow<String>>("Step 1 Score", selectionType: .singleSelection(enableDeselection: true))
        for (index,score) in stepScoreList.enumerated() {
            stepScoreSelection <<< ListCheckRow<String>(score) { listRow in
                listRow.title = score
                listRow.selectableValue = score
                listRow.value = nil
                listRow.tag = "a" + score
                if score == stepScore {
                    listRow.value = "3"
                }
            }
        }
        
        form +++ stepScoreSelection
        stepScoreSelection.tag = "stepScore"
        stepScoreSelection.onSelectSelectableRow = { (cell, cellRow) in
            if let _ = self.stepScore {
                if self.stepScore == cellRow.title! {
                    self.stepScore = nil
                }
                else {
                    self.stepScore = cellRow.title!
                }
            }
            else {
                self.stepScore = cellRow.title!
            }
            defaults.set(self.stepScore, forKey: "stepScore")
        }
        
        // NUMBER INTERVIEWS
        form +++ Section("Number of interviews")
            <<< IntRow("received") {
                $0.title = "# Interviews Received"
                $0.placeholder = "# here"
                if let _ = numInterviewsReceived {
                    $0.value = numInterviewsReceived
                }
                }.onChange { row in
                    if let _ = row.value {
                        self.numInterviewsReceived = row.value!
                    }
                    else {
                        self.numInterviewsReceived = nil
                    }
                    defaults.set(self.numInterviewsReceived, forKey: "numInterviewsReceived")
            }
        
            <<< IntRow("executed") {
                $0.title = "# Interviews Attended"
                $0.placeholder = "# here"
                if let _ = defaults.object(forKey: "numInterviewsExecuted") as? Int {
                    $0.value = defaults.integer(forKey: "numInterviewsExecuted")
                }
                }.onChange { row in
                    if let _ = row.value {
                        self.numInterviewsExecuted = row.value!
                    }
                    else {
                        self.numInterviewsExecuted = nil
                    }
                    defaults.set(self.numInterviewsExecuted, forKey: "numInterviewsExecuted")
            }
        
        // SELECT FINAL RANK
        if Disk.exists("myRanks.json", in: .documents) {
            myRanks = try! Disk.retrieve("myRanks.json", from: .documents, as: [Rank].self)
        }
        
        let rankListSelection = SelectableSection<ListCheckRow<String>>("Select final rank list", selectionType: .singleSelection(enableDeselection: true))
        form +++ rankListSelection
        rankListSelection.tag = "chooseRankList"
        rankListSelection.onSelectSelectableRow = { (cell, cellRow) in
            if cellRow.title! == "Make my rank list" {
                if let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                    tabBarController.selectedIndex = 1
                    self.present(tabBarController, animated: true, completion: nil)
                }
            }
            else {
                for rank in self.myRanks {
                    if cellRow.tag! == self.rankID {
                        self.rankID = nil
                        self.rankListArray = []
                        self.specialty = nil
                    }
                    else {
                        self.rankID = cellRow.tag!
                        self.rankListArray = rank.finalRankTextArray
                        self.specialty = rank.specialty
                    }
                }
                if let rankList = self.form.sectionBy(tag: "rankList") {
                    rankList.evaluateHidden()
                    if !self.rankListArray.isEmpty {
                        rankList.removeAll()
                        for (index, school) in self.rankListArray.enumerated() {
                            rankList <<< ListCheckRow<String>(school) { listRow in
                                listRow.title = "#\(index + 1): " + school
                                listRow.selectableValue = school
                                listRow.value = nil
                                listRow.tag = "b" + school
                                }.cellSetup { cell, row in
                                    cell.textLabel?.numberOfLines = 0
                                    cell.isUserInteractionEnabled = false
                            }
                        }
                    }
                }
            }
        }
        
        
        // ACTUAL RANK LIST
        let rankList = SelectableSection<ListCheckRow<String>>("My Rankings", selectionType: .singleSelection(enableDeselection: false))
        
        form +++ rankList
        rankList.tag = "rankList"
        rankList.hidden = Condition.function([]) { form in
            return self.rankListArray.isEmpty ? true : false
        }
        rankList.evaluateHidden()
        
        // SUBMIT BUTTON
        form +++ Section(footer: "All data collected is completely de-identified. We will not contact you regarding your submitted information. All data collected is strictly for research purposes.")
            <<< ButtonRow("submit") {
                $0.title = "Submit to database"
                $0.onCellSelection( { cell, row in
                    guard let _ = defaults.string(forKey: "degreeSought") else {
                        self.alert(message: "Please select your degree", title: "Missing Information")
                        self.shake(object: cell)
                        return
                    }
                    
                    guard let _ = defaults.string(forKey: "stepScore") else {
                        self.alert(message: "Please select your Step 1 score category", title: "Missing Information")
                        self.shake(object: cell)
                        return
                    }
                    
                    guard let _ = defaults.string(forKey: "schoolName") else {
                        self.alert(message: "Please select your school's name", title: "Missing Information")
                        self.shake(object: cell)
                        return
                    }
                    
                    guard let _ = defaults.object(forKey: "numInterviewsReceived") as? Int else {
                        self.alert(message: "Please enter the number of interviews you have received", title: "Missing Information")
                        self.shake(object: cell)
                        return
                    }
                    
                    guard let _ = defaults.object(forKey: "numInterviewsExecuted") as? Int else {
                        self.alert(message: "Please enter the number of interviews you plan on attending", title: "Missing Information")
                        self.shake(object: cell)
                        return
                    }
                    
                    if self.specialty == nil || self.rankListArray.isEmpty {
                        self.alert(message: "Please select your final rank list", title: "Missing Information")
                        self.shake(object: cell)
                        return
                    }
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMM d, YYYY"
                    let values = ["degree": self.degreeSought!, "specialty": self.specialty!, "homeSchoolName": self.schoolName!, "numInterviewsReceived": self.numInterviewsReceived!, "numInterviewsAttended": self.numInterviewsExecuted!, "stepScore": self.stepScore!, "numRanked": "\(self.rankListArray.count)", "rankList": self.rankListArray, "userPhoneID": UIDevice.current.identifierForVendor!.uuidString, "dateUploaded": dateFormatter.string(from: Date())] as [String : Any]
                    
                    Auth.auth().signInAnonymously(completion: { result, error in
                        if error == nil {
                            Database.database().reference().child("users").childByAutoId().updateChildValues(values, withCompletionBlock: { (err, _) in
                                if err == nil {
                                    self.alert(message: "Thank you for your contribution!", title: "Success!")
                                }
                            })
                        }
                        else {
                            self.alert(message: "Please try again later.", title: "Unable to upload information at this time.")
                        }
                    })
                })
            }
    }
        
    func updateTables() {
        if let programType = form.sectionBy(tag: "programType") {
            programType.removeAll()
            for (index,degree) in degreeTypes.enumerated() {
                programType <<< ListCheckRow<String>(degree) { listRow in
                    listRow.title = degree
                    listRow.selectableValue = degree
                    listRow.value = nil
                    listRow.tag = "\(index)"
                    if let _ = self.degreeSought {
                        if degree == degreeSought! {
                            listRow.value = "3"
                        }
                    }
                }
            }
        }
        
        if let rankListSelection = form.sectionBy(tag: "chooseRankList") {
            rankListSelection.removeAll()
            if !myRanks.isEmpty {
                for rank in myRanks {
                    rankListSelection <<< ListCheckRow<String>(rank.projectName) { listRow in
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MMM d, yyyy"
                        listRow.title = rank.projectName + " (Created: " + dateFormatter.string(from: rank.dateCreated) + ")"
                        listRow.selectableValue = rank.projectName
                        listRow.value = nil
                        listRow.tag = rank.uniqueID
                    }
                }
            }
            else {
                rankListSelection <<< ListCheckRow<String>("dummy") { listRow in
                    listRow.title = "Make my rank list"
                    listRow.selectableValue = "Make my rank list"
                    listRow.value = nil
                    listRow.tag = "Make my rank list"
                }.cellUpdate { cell, row in
                    cell.textLabel?.textAlignment = .center
                    cell.textLabel?.textColor = self.view.tintColor
                    cell.accessoryType = .none
                }
            }
            
            
        }
        
        
        
    }
    
    func schoolSelected(school: String?) {
        if let buttonRow = form.rowBy(tag: "school") {
            if let school = school {
                buttonRow.title = school
                self.schoolName = school
            }
            else {
                buttonRow.title = "Select Medical School"
                self.schoolName = nil
            }
            defaults.set(school, forKey: "schoolName")
            buttonRow.reload()
        }
        
    }
    
    func loadPreferences() {
        if Disk.exists("myRanks.json", in: .documents) {
            myRanks = try! Disk.retrieve("myRanks.json", from: .documents, as: [Rank].self)
        }
        
        if let _ = defaults.object(forKey: "degreeSought") as? String {
            degreeSought = defaults.string(forKey: "degreeSought")
        }
        
        if let _ = defaults.object(forKey: "schoolName") as? String {
            schoolName = defaults.string(forKey: "schoolName")
        }
        
        if let _ = defaults.object(forKey: "numInterviewsReceived") as? Int {
            numInterviewsReceived = defaults.integer(forKey: "numInterviewsReceived")
        }
        
        if let _ = defaults.object(forKey: "numInterviewsExecuted") as? Int {
            numInterviewsExecuted = defaults.integer(forKey: "numInterviewsExecuted")
        }
        
        if let _ = defaults.object(forKey: "stepScore") as? String {
            stepScore = defaults.string(forKey: "stepScore")
        }
    }
    
    func loadStepScores() {
        let path: String = Bundle.main.path(forResource: "Step1Scores", ofType: "xlsx")!
        let spreadsheet: BRAOfficeDocumentPackage = BRAOfficeDocumentPackage.open(path)
        let worksheet: BRAWorksheet = spreadsheet.workbook.worksheets[0] as! BRAWorksheet
        
        stepScoreList = []
        for (index,_) in worksheet.rows.enumerated() {
            stepScoreList.append(worksheet.cell(forCellReference: "A\(index+1)").stringValue())
        }
    }
    
    func loadDegreeTypes() {
        let path: String = Bundle.main.path(forResource: "DegreeTypes", ofType: "xlsx")!
        let spreadsheet: BRAOfficeDocumentPackage = BRAOfficeDocumentPackage.open(path)
        let worksheet: BRAWorksheet = spreadsheet.workbook.worksheets[0] as! BRAWorksheet
        
        degreeTypes = []
        for (index,_) in worksheet.rows.enumerated() {
            degreeTypes.append(worksheet.cell(forCellReference: "A\(index+1)").stringValue())
        }
    }
        
    func loadSchoolLists() {
        let path: String = Bundle.main.path(forResource: "MDSchoolList", ofType: "xlsx")!
        let spreadsheet: BRAOfficeDocumentPackage = BRAOfficeDocumentPackage.open(path)
        let worksheet: BRAWorksheet = spreadsheet.workbook.worksheets[0] as! BRAWorksheet
        
        MDSchoolList  = []
        for (index,_) in worksheet.rows.enumerated() {
            MDSchoolList.append(worksheet.cell(forCellReference: "B\(index+1)").stringValue())
        }
        
        let path2: String = Bundle.main.path(forResource: "DOSchoolList", ofType: "xlsx")!
        let spreadsheet2: BRAOfficeDocumentPackage = BRAOfficeDocumentPackage.open(path2)
        let worksheet2: BRAWorksheet = spreadsheet2.workbook.worksheets[0] as! BRAWorksheet
        
        DOSchoolList = []
        for (index,_) in worksheet2.rows.enumerated() {
            DOSchoolList.append(worksheet2.cell(forCellReference: "B\(index+1)").stringValue())
        }
        
        let path3: String = Bundle.main.path(forResource: "CombinedSchoolList", ofType: "xlsx")!
        let spreadsheet3: BRAOfficeDocumentPackage = BRAOfficeDocumentPackage.open(path3)
        let worksheet3: BRAWorksheet = spreadsheet3.workbook.worksheets[0] as! BRAWorksheet
        
        combinedSchoolList = []
        for (index,_) in worksheet3.rows.enumerated() {
            combinedSchoolList.append(worksheet3.cell(forCellReference: "B\(index+1)").stringValue())
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MedicalSchoolSelectorViewController {
            if let _ = degreeSought {
                switch degreeSought {
                case "MD": destination.schoolList = MDSchoolList
                case "MD/Masters": destination.schoolList = MDSchoolList
                case "MD/PhD": destination.schoolList = MDSchoolList
                case "DO": destination.schoolList = DOSchoolList
                case "DO/Masters": destination.schoolList = DOSchoolList
                case "DO/PhD": destination.schoolList = DOSchoolList
                default: ()
                }
            }
            else {
                destination.schoolList = combinedSchoolList
            }
           
            if let school = defaults.object(forKey: "schoolName") as? String {
                destination.selectedSchool = school
            }
            destination.delegate = self
        }
    }

}

