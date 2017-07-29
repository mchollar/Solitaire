//
//  PlayingCard.swift
//  Matchismo
//
//  Created by Micah Chollar on 7/2/17.
//  Copyright © 2017 Micah Chollar. All rights reserved.
//

import Foundation

class PlayingCard: Card {
    
    private var _suit: String?
    var suit: String? {
        set {
            if newValue != nil, PlayingCard.validSuits().contains(newValue!) {
                _suit = newValue
            } else {
                _suit = nil
            }
        }
        
        get {
            return _suit
        }
    }
    
    private var _rank: Int?
    var rank: Int? {
        get { return _rank }
        set {
            if newValue != nil, newValue! <= PlayingCard.maxRank() {
                _rank = newValue
            } else {
                _rank = nil
            }
        }
    }
    
    override var contents: String {
        get {
            let rankStrings = PlayingCard.rankStrings()
            return String("\(rankStrings[rank ?? 0])\(suit ?? "?")")
        }
        set { super.contents = newValue }
    }
    
    class func validSuits() -> [String] {
        return ["♥️", "♦️", "♣️", "♠️"]
    }
    
    class func rankStrings() -> [String] {
        return ["?", "A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
    }
    
    class func maxRank() -> Int {
        return self.rankStrings().count - 1
    }
    
    override func match(otherCards: [Card]) -> Int {
        var score = 0
        
        var rankMatchedCards = 0
        var suitMatchedCards = 0
        
        if otherCards.count == 1 {
            if let otherCard = otherCards.first as! PlayingCard? {
                if otherCard.rank != nil, otherCard.rank == rank {
                    score = 4
                } else if otherCard.suit != nil, otherCard.suit == suit {
                    score = 1
                }
            }
        } else if otherCards.count > 1 {
            var temp = 0
            for otherCard in otherCards {
                temp += 1
                if let otherPlayingCard = otherCard as? PlayingCard {
                    if otherPlayingCard.rank != nil, otherPlayingCard.rank == rank {
                        rankMatchedCards += 1
                    } else if otherPlayingCard.suit != nil, otherPlayingCard.suit == suit {
                        suitMatchedCards += 1
                    }
                }
            }
            if rankMatchedCards == otherCards.count {
                score += 4
            }
            if suitMatchedCards == otherCards.count {
                score += 1
            }
        }
        
        return score
    }

    
    
}
