//
//  Card.swift
//  Matchismo
//
//  Created by Micah Chollar on 7/2/17.
//  Copyright © 2017 Micah Chollar. All rights reserved.
//

import Foundation

class Card: AnyObject, Equatable {
    
    var contents: String = ""
    var isMatched = false
    var isChosen = false
    
    func match(otherCards: [Card]) -> Int {
        var score = 0
        
        for card in otherCards {
            if card.contents == self.contents {
                score += 1
            }
        }
        return score
    }
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.contents == rhs.contents 
    }
}
