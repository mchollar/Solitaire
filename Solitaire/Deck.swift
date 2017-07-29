//
//  Deck.swift
//  Matchismo
//
//  Created by Micah Chollar on 7/2/17.
//  Copyright © 2017 Micah Chollar. All rights reserved.
//

import Foundation

class Deck: AnyObject
{
    
    private var cards: [Card] = []
    
    var numberOfCardsInDeck: Int {
        get { return self.cards.count }
    }
    
    func add(card: Card, atTop: Bool) {
        
        if atTop {
            cards.insert(card, at: 0)
        } else {
            cards.append(card)
        }
        
    }
    
    func add(card: Card) {
        add(card: card, atTop: false)
    }
    
    func drawRandomCard() -> Card? {
        
        if cards.count > 0 {
            let index = Int(arc4random()) % cards.count
            let randomCard = cards[index]
            cards.remove(at: index)
            return randomCard
        }
        else {
            return nil
        }
    }
    
    
}
