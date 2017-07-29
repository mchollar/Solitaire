//
//  GameViewController.swift
//  Solitaire
//
//  Created by Micah Chollar on 7/22/17.
//  Copyright © 2017 Micah Chollar. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    
    //MARK: PROPERTIES
        
    @IBOutlet weak var stockView: CardStackView!
    @IBOutlet weak var wasteView: CardStackView!
    @IBOutlet var foundationViews: [CardStackView]!
    @IBOutlet var tableauViews: [CardStackView]!
    
    private var dragOrigin: CardStackView?
    
    var game: SolitaireGame?
    
    let CARDWIDTH = CGFloat(50)
    let CARDHEIGHT = CGFloat(70)
    //need card size stuff, offset stuff (hor/vert)
    
    
    //MARK: LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        game = SolitaireGame(cardsPerDraw: 1)
        for index in 0 ..< 7 {
            tableauViews[index].tag = index
            tableauViews[index].stackType = .tableau
        }
        for index in 0 ..< 4 {
            foundationViews[index].tag = index
            foundationViews[index].stackType = .foundation
        }
        wasteView.stackType = .waste
        stockView.stackType = .stock
        setupUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setupUI() {
        // Go through each stack, and setup views for the cards found there
        if let game = self.game {
            
            for stockCard in game.stock {
                let cardIndex = game.stock.index(of: stockCard)
                let newCardView = startNewViewWith(card: stockCard, at: cardIndex!)
                newCardView.currentStack = stockView
                newCardView.currentCardIndex = cardIndex
                stockView.addSubview(newCardView)
                newCardView.frame = newCardView.frame.offsetBy(dx: CGFloat(cardIndex!) * 0.15, dy: 0)
            }
            print("Stock complete")
            
            //Now cycle through the Tableaus and set up their views
            
            for tableauIndex in 0 ..< game.tableaus.count {
                
                let tableau = game.tableaus[tableauIndex]
                    
                for tableauCard in tableau.stack {
                    let cardIndex = tableau.stack.index(of: tableauCard)
                    let newCardView = startNewViewWith(card: tableauCard, at: cardIndex!)
                    newCardView.currentStack = tableauViews[tableauIndex]
                    newCardView.currentCardIndex = cardIndex
                    tableauViews[tableauIndex].addSubview(newCardView)
                    newCardView.frame = newCardView.frame.offsetBy(dx: 0.0, dy: CGFloat(cardIndex!) * 2)
                    addTapGestureTo(newCardView)
                    print("Tableau card: \(newCardView.description) added to Tableau: \(tableauIndex) at \(cardIndex ?? -1)")
                }
                print("Tableau: \(tableauIndex) complete")
                print("Tableau count = \(tableauViews[tableauIndex].subviews.count)")
            }
        }
        
    }
    
    //MARK: CREATE AND UPDATE VIEWS
    
    private func startNewViewWith(card: SolitaireCard, at index: Int) -> SolitaireCardView {
        let cardView = createViewFor(card: card)
        cardView.tag = index
        let drag = UIPanGestureRecognizer(target: self, action: #selector (panHandler(reactingTo:)))
        cardView.addGestureRecognizer(drag)
        
        cardView.frame = CGRect(x: 0,
                                y: 0,
                                width: CARDWIDTH,
                                height: CARDHEIGHT)
        return cardView
        
    }
    
    private func createViewFor(card: SolitaireCard) -> SolitaireCardView {
        let cardView = SolitaireCardView()
        update(cardView, for: card)
        return cardView
    }
    
    private func update(_ view: UIView, for card: SolitaireCard) {
        if let cardView = view as? SolitaireCardView
        {
            cardView.rank = card.rank
            cardView.suit = card.suit
            cardView.isFaceUp = card.isFaceUp
            print("Card update - card: \(card.contents), cardView: \(cardView)")
            
        }
    }
    
    private func updateCardIndexes() {
        for tableau in tableauViews {
            var cardIndex = 0
            var cardView = tableau.subviews.first as? SolitaireCardView
            while cardView != nil {
                cardView?.currentCardIndex = cardIndex
                cardIndex += 1
                cardView = cardView?.subviews.first as? SolitaireCardView
            }
        }
        for foundation in foundationViews {
            var cardIndex = 0
            var cardView = foundation.subviews.first as? SolitaireCardView
            while cardView != nil {
                cardView?.currentCardIndex = cardIndex
                cardIndex += 1
                cardView = cardView?.subviews.first as? SolitaireCardView
            }
        }

    }
    
    private func titleFor(card: Card) -> String? {
        return card.isChosen ? card.contents : nil
    }
    
    private func backGroundImageFor(card: Card) -> UIImage? {
        return UIImage(named: card.isChosen ? "cardfront" : "cardback")
    }

    private func addTapGestureTo(_ cardView: SolitaireCardView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector (flipCard(_:)))
        cardView.addGestureRecognizer(tap)
    }
    
    func flipCard(_ sender: UITapGestureRecognizer) {
        
        if sender.state == .ended,
            let game = self.game,
            let cardView = sender.view as? SolitaireCardView {
            if !cardView.isFaceUp { //Not what I need, I need to know if it's fully exposed
                animateFlipOf(cardView: cardView)
                if cardView.currentStack != nil, cardView.currentCardIndex != nil {
                    game.flipCardInTableau(cardView.currentStack!.tag, at: cardView.currentCardIndex!)
                }
            }
        }
    }
    
    //MARK: DRAG AND DROP BEHAVIOR
    func panHandler(reactingTo pan: UIPanGestureRecognizer) {
        if pan.view != nil {
            if pan.state == .began {
                dragOrigin = pan.view!.superview as? CardStackView //setting origin, for    use later
                //get view's top view to bring to front (to avoid weird overlapping
                if let topView = getTopViewOf(pan.view!) {
                //view.bringSubview(toFront: pan.view!.superview!)
                    view.bringSubview(toFront: topView)
                }
            }
            let translation = pan.translation(in: view)
            pan.view?.frame.origin.x += translation.x
            pan.view?.frame.origin.y += translation.y
            pan.setTranslation(CGPoint.zero, in: view)
            
            if pan.state == .ended, game != nil, let cardView = pan.view as? SolitaireCardView {
                
                let destination = closestViewTo(cardView)
                
                //If it started and ended in wasteView, no changes to game necessary
                if destination == wasteView && dragOrigin == wasteView {
                    returnToWaste(cardView)
                }
                
                if dragOrigin != nil,
                    dragOrigin?.stackType != nil,
                    destination.stackType != nil {
                    
                    switch dragOrigin!.stackType! {
                        
                    case .waste:
                        if destination.stackType! == .tableau {
                            game!.playWasteToTableau(index: destination.tag)
                            if game!.lastMoveWasSuccess {
                                cardView.removeFromSuperview()
                                snap(card: cardView, to: destination)
                            } else {
                                returnToWaste(cardView)
                            }
                        } else if destination.stackType! == .foundation {
                            game!.playWasteToFoundation(index: destination.tag)
                            if game!.lastMoveWasSuccess {
                                cardView.removeFromSuperview()
                                stack(card: cardView, on: destination)
                            } else {
                                returnToWaste(cardView)
                            }
                        }
                        
                    case .tableau:
                        if destination.stackType! == .tableau {
                            game!.playTableauToTableau(tableauIndex: dragOrigin!.tag, cardIndex: cardView.currentCardIndex!, destinationIndex: destination.tag)
                            if game!.lastMoveWasSuccess {
                                cardView.removeFromSuperview()
                                snap(card: cardView, to: destination)
                            } else {
                                cardView.removeFromSuperview()
                                snap(card: cardView, to: dragOrigin!)
                            }
                        } else if destination.stackType! == .foundation {
                            game!.playTableauToFoundation(tableauIndex: dragOrigin!.tag, destinationIndex: destination.tag)
                            if game!.lastMoveWasSuccess {
                                cardView.removeFromSuperview()
                                stack(card: cardView, on: destination)
                            } else {
                                cardView.removeFromSuperview()
                                snap(card: cardView, to: dragOrigin!)
                            }
                        }
                        
                    case .foundation:
                        if destination.stackType! == .tableau {
                            game!.playFoundationToTableau(foundationIndex: dragOrigin!.tag, destinationIndex: destination.tag)
                            if game!.lastMoveWasSuccess {
                                cardView.removeFromSuperview()
                                snap(card: cardView, to: destination)
                            } else {
                                cardView.removeFromSuperview()
                                stack(card: cardView, on: dragOrigin!)
                            }
                        }
                        
                    default:
                        break
                    }
                }
                updateCardIndexes()
                dragOrigin = nil
            }
        }
    }
    
    private func closestViewTo(_ cardView: SolitaireCardView) -> CardStackView {
        
        var closestView = CardStackView()
        var shortestDistance = Float(1000)
        
        if let cardCenter = cardView.superview?.convert(cardView.center, to: self.view) {
            for view in tableauViews {
                if let viewCenter = view.superview?.convert(view.center, to: self.view) {
                    
                    //print("ClosestViewTo - Checking against \(view.description)")
                    let distance = hypotf(Float(viewCenter.x - cardCenter.x), Float(viewCenter.y - cardCenter.y))
                    if distance < shortestDistance {
                        shortestDistance = distance
                        closestView = view
                    }
                }
            }
            for view in foundationViews {
                if let viewCenter = view.superview?.convert(view.center, to: self.view) {
                    
                    //print("ClosestViewTo - Checking against \(view.description)")
                    let distance = hypotf(Float(viewCenter.x - cardCenter.x), Float(viewCenter.y - cardCenter.y))
                    if distance < shortestDistance {
                        shortestDistance = distance
                        closestView = view
                    }
                }
            }
            let viewCenter = wasteView.center
            let distance = hypotf(Float(viewCenter.x - cardCenter.x), Float(viewCenter.y - cardCenter.y))
            if distance < shortestDistance {
                shortestDistance = distance
                closestView = wasteView
            }

        }
        return closestView
    }
    
    private func getTopViewOf(_ cardview: UIView) -> UIView? {
        var cardSuper = cardview.superview
        while (cardSuper is SolitaireCardView) {
            cardSuper = cardSuper?.superview
        }
        return cardSuper
    }
    
    private func snap(card: SolitaireCardView, to view: UIView) {
        
        if var topCardView = view.subviews.last as? SolitaireCardView {
            while topCardView.subviews.count != 0 {
              topCardView = (topCardView.subviews.last as? SolitaireCardView)!
            }
            topCardView.addSubview(card)
            var newOrigin = CGPoint.zero
            if topCardView.isFaceUp {
                newOrigin.y += 20
            }
            card.frame = CGRect(origin: newOrigin, size: card.frame.size)
        } else {
            view.addSubview(card)
            let newOrigin = CGPoint.zero
            card.frame = CGRect(origin: newOrigin, size: card.frame.size)
        }
    }
    
    private func stack(card: SolitaireCardView, on foundationView: UIView) {
        card.frame = CGRect(origin: CGPoint.zero, size: card.frame.size)
        foundationView.addSubview(card)
    }
    
    private func returnToWaste(_ cardView: SolitaireCardView) {
        
        let cardTarget = wasteView.subviews[wasteView.subviews.count-2]
        var newOrigin = cardTarget.frame.origin
        if newOrigin.x > 0 {
            newOrigin.x += 10
        }
        cardView.frame = CGRect(origin: newOrigin, size: cardView.frame.size)
    }
    
    
    private func getCardFor(cardview: SolitaireCardView, origin: UIView) -> SolitaireCard? {

        
        
        return nil
    }
    
    //MARK: GAME INTERACTION
    private func getCardFor(cardview: SolitaireCardView, foundation: UIView) -> SolitaireCard? {
        if let index = foundation.subviews.index(of: cardview) {
            let foundationIndex = foundation.tag
            let card = game?.foundations[foundationIndex].stack[index]
            return card
        }
        return nil
    }
    
    
    @IBAction func drawFromStack(_ sender: UITapGestureRecognizer) {
        if let game = self.game {
            let firstStockCount = game.stock.count
            if firstStockCount > 0 {    //If there are cards to draw, draw them, otherwise we'll have to flip the waste
                                        //back to the stock
                game.drawFromStock()
                let stockChange = firstStockCount - game.stock.count
                
                //Animate the movement of cards, starting by stacking the waste, then drawing three from the stock and adding them
                
                for cardView in wasteView.subviews {
                    if cardView.frame.origin.x > 0 {
                        
                        UIView.animate(withDuration: 0.2, animations: {
                            //Animate stacking the waste
                            cardView.frame = cardView.frame.offsetBy(dx: -cardView.frame.origin.x, dy: 0.0)
                        })
                    }
                }
                
                //Now draw cards and animate adding them to the waste
                for index in 0 ..< stockChange {
                    if let drawnCardView = stockView.subviews.last as? SolitaireCardView {
                        
                        
                        
                        drawnCardView.removeFromSuperview()
                        self.wasteView.addSubview(drawnCardView)
                        drawnCardView.superview?.bringSubview(toFront: drawnCardView)
                        
                        //Temporarily move the frame of the card to its old location, so the animation looks right
                        drawnCardView.frame = drawnCardView.frame.offsetBy(dx: self.stockView.frame.origin.x - self.wasteView.frame.origin.x, dy: 0.0)
                        
                        //Now animate the movement
                        UIView.animate(withDuration: 0.2,
                                       delay: Double(index) * 0.1,
                                       options: .beginFromCurrentState,
                                       animations: {
                                        print("Animating drawn card: \(drawnCardView)")
                                        drawnCardView.frame = drawnCardView.frame.offsetBy(dx: self.wasteView.frame.origin.x - self.stockView.frame.origin.x + CGFloat(index * 10), dy: 0.0)
                                        //self.animateFlipOf(cardView: drawnCardView)
                                        
                                        
                        },
                                       completion: { (finished) in
                                        self.animateFlipOf(cardView: drawnCardView)
                                        drawnCardView.frame = CGRect(x: CGFloat(index * 10), y: 0.0, width: self.CARDWIDTH, height: self.CARDHEIGHT)
                                        print("Drawn card animation complete: \(drawnCardView)")
                        })
                    }
                }
            } else {    // If no cards in stock, flip the waste back to the stock
                game.resetStockFromWaste()
                stackCardViews(wasteView.subviews)
                var cardView = wasteView.subviews.last as? SolitaireCardView
                while cardView != nil {
                    cardView!.isFaceUp = false
                    cardView!.removeFromSuperview()
                    stockView.addSubview(cardView!)
                    cardView = wasteView.subviews.last as? SolitaireCardView
                }
                

            }
        }
    }

    private func animateFlipOf(cardView: SolitaireCardView) {
        UIView.transition(with: cardView,
                          duration: 0.2,
                          options: .transitionFlipFromRight,
                          animations: {
                            cardView.isFaceUp = !cardView.isFaceUp
                            },
                          completion: nil)
    }
    
    private func stackCardViews(_ array: [UIView]) {
        for cardView in array {
                if cardView.frame.origin.x > 0 {
                    cardView.frame = cardView.frame.offsetBy(dx: -cardView.frame.origin.x, dy: 0.0)
                }
                if cardView.frame.origin.y > 0 {
                    cardView.frame = cardView.frame.offsetBy(dx: 0.0, dy: -cardView.frame.origin.y)
                }
            if let cardIndex = array.index(of: cardView) {
                cardView.frame = cardView.frame.offsetBy(dx: CGFloat(cardIndex) * -0.15, dy: 0.0)
            
            }
        }
    }
    
    
    //Not sure I need these
    private func fanCardViews(_ array: [SolitaireCardView]) {
        
    }
    
    private func move(cardView: SolitaireCardView, from orig: [SolitaireCardView], to dest: [SolitaireCardView]) {
        //Remove card from orig viewArray, then add to dest viewArray
        
    }
    
    private func move(stackOfCardViews: [SolitaireCard], from orig: [SolitaireCardView], to dest: [SolitaireCardView]) {
        
    }

    

}

