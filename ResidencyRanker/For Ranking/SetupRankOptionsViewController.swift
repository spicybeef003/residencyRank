//
//  SubsetSizeViewController.swift
//  Dank Ranks Revisited
//
//  Created by Tony Jiang on 8/25/18.
//  Copyright © 2018 Tony Jiang. All rights reserved.
//

import UIKit
import LGButton

class SetupRankOptionsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var subsetNumberSegmented: UISegmentedControl!
    @IBOutlet weak var createRanksButtonOutlet: LGButton!
    @IBOutlet weak var questionLabel: UILabel!
    
    var type: String!
    var myRanks: [Rank]!
    var thisRank = Rank()
    
    var pickerData: [String] = []
    var selectedSpecialty: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        questionLabel.isHidden = true
        subsetNumberSegmented.isHidden = true
        createRanksButtonOutlet.isHidden = true
        
        setupPicker()
    }
    
    func setupPicker() {
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        self.pickerView.layer.borderColor = UIColor(red: 212.0/255.0, green: 212.0/255.0, blue: 212.0/255.0, alpha: 1.0).cgColor
        self.pickerView.layer.borderWidth = 2.0
        self.pickerView.layer.cornerRadius = 10
        self.pickerView.layer.masksToBounds = true
        
        let path: String = Bundle.main.path(forResource: "ResidencyFields", ofType: "xlsx")!
        let spreadsheet: BRAOfficeDocumentPackage = BRAOfficeDocumentPackage.open(path)
        let worksheet: BRAWorksheet = spreadsheet.workbook.worksheets[0] as! BRAWorksheet
        
        pickerData = []
        for (index,row) in worksheet.rows.enumerated() {
            pickerData.append(worksheet.cell(forCellReference: "A\(index+1)").stringValue())
        }
        pickerView.reloadAllComponents()
    }
    
    @IBAction func createRanksPressed(_ sender: LGButton) {
        thisRank.specialty = pickerData[pickerView.selectedRow(inComponent: 0)]
        
        switch subsetNumberSegmented.selectedSegmentIndex {
            case 0: thisRank.numSubsets = 2
            case 1: thisRank.numSubsets = 3
            case 2: thisRank.numSubsets = 4
            default: ()
        }
        
        self.performSegue(withIdentifier: "toAddResidencies", sender: self)
    }

    
    
    // picker setup
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 && selectedSpecialty {
            UIView.animate(withDuration: 0.4, animations: {
                self.questionLabel.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
                self.subsetNumberSegmented.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
                self.createRanksButtonOutlet.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
            }, completion: { _ in
                self.questionLabel.isHidden = true
                self.subsetNumberSegmented.isHidden = true
                self.createRanksButtonOutlet.isHidden = true
            })
            selectedSpecialty = false
        }
        else if !selectedSpecialty {
            self.questionLabel.isHidden = false
            self.questionLabel.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
            self.subsetNumberSegmented.isHidden = false
            self.subsetNumberSegmented.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
            self.createRanksButtonOutlet.isHidden = false
            self.createRanksButtonOutlet.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
            UIView.animate(withDuration: 0.4, animations: {
                self.questionLabel.transform = CGAffineTransform.identity
                self.subsetNumberSegmented.transform = CGAffineTransform.identity
                self.createRanksButtonOutlet.transform = CGAffineTransform.identity
            }, completion: { _ in
                
            })
            selectedSpecialty = true
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.black
        pickerLabel.text = pickerData[row]
        pickerLabel.font = UIFont(name: "Helvetica", size: (Env.iPad ? 33 : 22))
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EnterResidenciesViewController {
            destination.thisRank = thisRank
            destination.myRanks = myRanks
        }
    }
}
