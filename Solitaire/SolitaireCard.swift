//
//  SolitaireCard.swift
//  Solitaire
//
//  Created by Micah Chollar on 7/22/17.
//  Copyright © 2017 Micah Chollar. All rights reserved.
//

import Foundation

class SolitaireCard: PlayingCard {
    
    var isAvailable = false
    var isFaceUp = false
    var color: String? {
        if self.suit == "♥️" || self.suit == "♦️" {
            return "red"
        } else if self.suit == "♣️" || self.suit == "♠️" {
            return "black"
        } else {
            return nil
        }
    }
    
    func canBeMarriedTo(_ card: SolitaireCard) -> Bool {
        
        if self.color != nil, card.color != nil, self.rank != nil, card.rank != nil {
            
            if (self.color != card.color) && (card.rank! - self.rank! == 1) {
                return true
            }
        }
        return false
    }
    
    
    
}
