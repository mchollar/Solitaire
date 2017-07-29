//
//  SolitaireCardDeck.swift
//  Solitaire
//
//  Created by Micah Chollar on 7/22/17.
//  Copyright © 2017 Micah Chollar. All rights reserved.
//

import Foundation

class SolitaireCardDeck: Deck {
    
    override init() {
        super.init()
        for suit in SolitaireCard.validSuits() {
            for rank in 1...SolitaireCard.maxRank() {
                let card = SolitaireCard()
                card.rank = rank
                card.suit = suit
                add(card: card)
                //print("\(card.contents) added")
            }
        }
        print("New solitaire card deck created")
    }

}
