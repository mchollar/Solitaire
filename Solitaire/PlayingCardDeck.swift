//
//  PlayingCardDeck.swift
//  Matchismo
//
//  Created by Micah Chollar on 7/2/17.
//  Copyright © 2017 Micah Chollar. All rights reserved.
//

import Foundation

class PlayingCardDeck: Deck {
    
    override init() {
        super.init()
        for suit in PlayingCard.validSuits() {
            for rank in 1...PlayingCard.maxRank() {
                let card = PlayingCard()
                card.rank = rank
                card.suit = suit
                add(card: card)
                //print("\(card.contents) added")
            }
        }
        print("New playing card deck created")
    }
    
    
}
