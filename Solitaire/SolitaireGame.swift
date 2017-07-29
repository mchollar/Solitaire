//
//  SolitaireGame.swift
//  Solitaire
//
//  Created by Micah Chollar on 7/22/17.
//  Copyright © 2017 Micah Chollar. All rights reserved.
//

import Foundation

class SolitaireGame {
    
    var stock = [SolitaireCard]()
    var waste = [SolitaireCard]()
    var tableaus = [Tableau]()
    var foundations = [Foundation]()
    var cardsPerDraw: Int
    var lastMoveWasSuccess: Bool = true
    
    struct Tableau {
        var stack = [SolitaireCard]()
        
        func canAccept(card: SolitaireCard) -> Bool {
            if stack.last != nil {
                if card.canBeMarriedTo(stack.last!) {
                    return true
                } else {
                    return false
                }
            }
            else if card.rank == SolitaireCard.maxRank() {      //If the stack is empty
                return true                                     //and the card is a King
            }
            
            return false
        }
        
        mutating func accept(card: SolitaireCard) {
            if canAccept(card: card) {
                stack.append(card)
                print("Tableau accept success")
            } else {
                print("Tableau accept fail")
            }
        }
        
        mutating func pull(cardsAtIndex: Int) -> [SolitaireCard] {
            var pulledCards = [SolitaireCard]()
            var card: SolitaireCard
            while cardsAtIndex < (stack.count) {
                card = stack.remove(at: cardsAtIndex)
                pulledCards.append(card)
            }
            return pulledCards
        }
    }
    
    struct Foundation {
        var stack = [SolitaireCard]()
        func canAccept(card: SolitaireCard) -> Bool {
            if let topCard = stack.last {
                if topCard.suit == card.suit && card.rank! - topCard.rank! == 1 {
                    return true
                }
            } else if card.rank! == 1 {
                return true
            }
            return false
        }
        
        mutating func accept(card: SolitaireCard) {
            if self.canAccept(card: card) {
                self.stack.append(card)
//                lastMoveWasSuccess = true
//            } else {
//                lastMoveWasSuccess = false
            }
        }
    }
    
    init?(cardsPerDraw: Int) {
        if cardsPerDraw == 3 || cardsPerDraw == 1 {
            self.cardsPerDraw = cardsPerDraw
        }
        else {
            return nil
        }
        
        for _ in 0..<7 {
            tableaus.append(Tableau())
        }
        for _ in 0..<4 {
            foundations.append(Foundation())
        }
        
        setupBoard()
    }
    
    func setupBoard() {
        
        let tempDeck = SolitaireCardDeck()
        
        //Set up tableaus
        for index in 0 ..< 7 {
            
            for _ in 0 ... index {
                if let card = tempDeck.drawRandomCard() as? SolitaireCard {
                    tableaus[index].stack.append(card)
                    print("SolitaireGame.swift setupBoard(): \(card.contents) added to \(index)")
                }
            }
            
            if let lastCard = tableaus[index].stack.last {
                lastCard.isFaceUp = true
                lastCard.isAvailable = true
            }

        }
        
        //Set up stock
        var card = tempDeck.drawRandomCard() as? SolitaireCard
        while
            card != nil {
                stock.append(card!)
                card = tempDeck.drawRandomCard() as? SolitaireCard
        }
    }
    
    func drawFromStock() {
        for _ in 0 ..< cardsPerDraw {
            if let card = stock.popLast() {
                waste.append(card)
                card.isFaceUp = true
            }
        }
    }
    
    func resetStockFromWaste() {
        var card = waste.popLast()
        while card != nil {
            card!.isFaceUp = false
            stock.append(card!)
            card = waste.popLast()
        }
    }
    
    func flipCardInTableau(_ tableauIndex: Int, at index: Int) {
        if index < (tableaus[tableauIndex].stack.count) {
            tableaus[tableauIndex].stack[index].isFaceUp = true
        }
    }
    
    func playWasteToTableau(index: Int) {
        
        //Test to see if it's a valid play
        if let testCard = waste.last {
            if !tableaus[index].canAccept(card: testCard) {
                lastMoveWasSuccess = false
                print("Card: \(testCard.contents) rejected from tableau: \(index)")
                return
            }
        }
        if let card = waste.popLast() {
            tableaus[index].accept(card: card)
            lastMoveWasSuccess = true
            print("Card: \(card.contents) placed on tableau: \(index)")
        }
    }
    
    func playWasteToFoundation(index: Int) {
        
        //Test to see if it's a valid play
        if let testCard = waste.last {
            if !foundations[index].canAccept(card: testCard) {
                lastMoveWasSuccess = false

                print("Card: \(testCard.contents) rejected from foundation: \(index)")

                return
            }
        }
        if let card = waste.popLast() {
            foundations[index].accept(card: card)
            lastMoveWasSuccess = true
            print("Card: \(card.contents) placed on foundation: \(index)")
        }
    }
    

    func playTableauToTableau(tableauIndex: Int, cardIndex: Int, destinationIndex: Int) {
        
        //first test to see if it's a valid play
        var testCard: SolitaireCard
        if cardIndex < (tableaus[tableauIndex].stack.count) {
            testCard = tableaus[tableauIndex].stack[cardIndex]
            if !tableaus[destinationIndex].canAccept(card: testCard) ||
                tableauIndex == destinationIndex { //If test fails, return
                lastMoveWasSuccess = false

                print("Card: \(testCard.contents) rejected from tableau: \(destinationIndex)")

                return
            }
        
        }
        
        //Determine if it's one card, or multiple being moved
        let numberOfCards = tableaus[tableauIndex].stack.count - cardIndex
        
        if numberOfCards > 1 {  //Multiple cards to be moved
            let cardsPulled = tableaus[tableauIndex].pull(cardsAtIndex: cardIndex)
            if cardsPulled.count > 0 {
                tableaus[destinationIndex].stack += cardsPulled
                lastMoveWasSuccess = true
                print("Cards: \(cardsPulled) placed on tableau: \(destinationIndex)")
            }
        }
        
        if let cardPulled = tableaus[tableauIndex].stack.popLast() { //Single card, just move it to destination
            tableaus[destinationIndex].accept(card: cardPulled)
            lastMoveWasSuccess = true
            print("Card: \(cardPulled.contents) placed on tableau: \(destinationIndex)")
        }
    }
    
    func playTableauToFoundation(tableauIndex: Int, destinationIndex: Int) {
 
        //First, test to see if it's a valid play. If not, return.
        if let testCard = tableaus[tableauIndex].stack.last {
            if !foundations[destinationIndex].canAccept(card: testCard) {
                lastMoveWasSuccess = false
                print("Card: \(testCard.contents) rejected from foundation: \(destinationIndex)")

                return
            }
        }
        
        //Go ahead and move the card
        if let cardPulled = tableaus[tableauIndex].stack.popLast() {
            foundations[destinationIndex].accept(card: cardPulled)
            lastMoveWasSuccess = true
            print("Card: \(cardPulled.contents) placed on foundation: \(destinationIndex)")
        }
    }
    
    func playFoundationToTableau(foundationIndex: Int, destinationIndex: Int) {
        
        //First, test to make sure it's a valid play. If not, return.
        if let testCard = foundations[foundationIndex].stack.last {
            if !tableaus[destinationIndex].canAccept(card: testCard) {
                lastMoveWasSuccess = false
                print("Card: \(testCard.contents) rejected from tableau: \(destinationIndex)")

                return
            }
        }
        
        if let cardPulled = foundations[foundationIndex].stack.popLast() {
            tableaus[destinationIndex].accept(card: cardPulled)
            lastMoveWasSuccess = true
            print("Card: \(cardPulled.contents) placed on tableau: \(destinationIndex)")
        }
    }

}
