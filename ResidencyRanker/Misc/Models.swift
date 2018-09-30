//
//  Models.swift
//  ResidencyRanker
//
//  Created by Tony Jiang on 8/29/18.
//  Copyright © 2018 Tony Jiang. All rights reserved.
//

import Foundation

let defaults = UserDefaults.standard

class Rank: Codable {
    var projectName: String = ""
    var currentComparisonIndex: Int = 0
    var numTotalComparisons: Int = 0
    var countIndex: Int = 0
    var specialty: String = ""
    var numObj: Int!
    var numSubsets: Int!
    let dateCreated: Date = Date()
    var rankFinished: Bool = false
    let uniqueID: String = UUID().uuidString
    
    var textArray: [String] = [] // will hold image names if image type
    var shuffledTexArray: [String] = []
    var nextGroup: [String] = []
    var finalRankTextArray: [String] = []
}

