//
//  GameDataStore.swift
//  Wither
//
//  Created by Amy Joscelyn on 8/19/16.
//  Copyright © 2016 Amy Joscelyn. All rights reserved.
//

import Foundation

class GameDataStore
{   
    static let sharedInstance = GameDataStore()
    private init() {}
    
    var totalPlayerScore = 0
    var totalAIScore = 0
    
    func updateScores(scores: [Int])
    {
        let playerScore = scores.first!
        let aiScore = scores.last!
        
        totalPlayerScore += playerScore
        totalAIScore += aiScore
    }
    
    var playerCardTrackerArray: [Int] = []
    
//    func trackColumn(column: Int)
//    {
//        if self.playerCardTrackerArray.count > 5
//        {
//            self.playerCardTrackerArray.removeFirst()
//        }
//        self.playerCardTrackerArray.append(column)
//        
//        print("GameDataStore tracked columns: \(self.playerCardTrackerArray)")
//    }
}
