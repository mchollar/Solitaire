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
    
    var CARD_WIDTH = CGFloat(50)
    var CARD_HEIGHT = CGFloat(70)
    var FAN_HOR_OFFSET = CGFloat(15)
    var FAN_VERT_OFFSET = CGFloat(20)
    let STACK_VERT_OFFSET = CGFloat(2)
    let STACK_HOR_OFFSET = CGFloat(0.15)
    
    var cardsPerDraw = 1
    
    
    //MARK: LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        game = SolitaireGame(cardsPerDraw: cardsPerDraw)
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CARD_WIDTH = tableauViews[0].frame.size.width - 3
        CARD_HEIGHT = CARD_WIDTH * 1.4
        FAN_HOR_OFFSET = CARD_WIDTH * 0.2
        FAN_VERT_OFFSET = CARD_WIDTH * 0.3
        
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
                newCardView.frame = newCardView.frame.offsetBy(dx: CGFloat(cardIndex!) * STACK_HOR_OFFSET, dy: 0)
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
                    newCardView.frame = newCardView.frame.offsetBy(dx: 0.0, dy: CGFloat(cardIndex!) * STACK_VERT_OFFSET)
                    addTapGestureTo(newCardView)
                    print("Tableau card: \(newCardView.description) added to Tableau: \(tableauIndex) at \(cardIndex ?? -1)")
                }
                print("Tableau: \(tableauIndex) complete")
                print("Tableau count = \(tableauViews[tableauIndex].subviews.count)")
            }
        }
        
    }
    
    @IBAction func newGameButtonTouched(_ sender: UIButton) {
        
        for card in stockView.subviews {
            card.removeFromSuperview()
        }
        for card in wasteView.subviews {
            card.removeFromSuperview()
        }
        for tableau in tableauViews {
            for card in tableau.subviews {
                card.removeFromSuperview()
            }
        }
        for foundation in foundationViews {
            for card in foundation.subviews {
                card.removeFromSuperview()
            }
        }
        game = SolitaireGame(cardsPerDraw: cardsPerDraw)
        setupUI()
        
    }
    //MARK: CREATE AND UPDATE VIEWS
    
    private func startNewViewWith(card: SolitaireCard, at index: Int) -> SolitaireCardView {
        let cardView = createViewFor(card: card)
        cardView.tag = index
        let drag = UIPanGestureRecognizer(target: self, action: #selector (panHandler(reactingTo:)))
        cardView.addGestureRecognizer(drag)
        
        cardView.frame = CGRect(x: 0,
                                y: 0,
                                width: CARD_WIDTH,
                                height: CARD_HEIGHT)
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
        for card in stockView.subviews {
            if let solCard = card as? SolitaireCardView {
                solCard.currentStack = stockView
                solCard.currentCardIndex = stockView.subviews.index(of: solCard)
            }
        }
        for card in wasteView.subviews {
            if let solCard = card as? SolitaireCardView {
                solCard.currentStack = wasteView
                solCard.currentCardIndex = wasteView.subviews.index(of: solCard)
            }
        }
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
        if let cardView = pan.view as? SolitaireCardView {
            if pan.state == .began {
                
                dragOrigin = cardView.currentStack //setting origin, for    use later
                //get view's top view to bring to front (to avoid weird overlapping
                if let topView = getTopViewOf(pan.view!) {
                //view.bringSubview(toFront: pan.view!.superview!)
                    view.bringSubview(toFront: topView.superview!)
                    topView.superview!.bringSubview(toFront: topView)
                }
            }
            let translation = pan.translation(in: view)
            pan.view?.frame.origin.x += translation.x
            pan.view?.frame.origin.y += translation.y
            pan.setTranslation(CGPoint.zero, in: view)
            
            if pan.state == .ended, game != nil {
                
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
                                returnToOrigin(cardView)
                            }
                        } else if destination.stackType! == .foundation {
                            game!.playTableauToFoundation(tableauIndex: dragOrigin!.tag, destinationIndex: destination.tag)
                            if game!.lastMoveWasSuccess {
                                cardView.removeFromSuperview()
                                stack(card: cardView, on: destination)
                            } else {
                                returnToOrigin(cardView)
                            }
                        }
                        
                    case .foundation:
                        if destination.stackType! == .tableau {
                            game!.playFoundationToTableau(foundationIndex: dragOrigin!.tag, destinationIndex: destination.tag)
                            if game!.lastMoveWasSuccess {
                                cardView.removeFromSuperview()
                                snap(card: cardView, to: destination)
                            } else {
                                //cardView.removeFromSuperview()
                                //stack(card: cardView, on: dragOrigin!)
                                returnToOrigin(cardView)
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
                newOrigin.y += FAN_VERT_OFFSET
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
        
        var cardTarget = SolitaireCardView()
        if wasteView.subviews.count > 1 {
            cardTarget = wasteView.subviews[wasteView.subviews.count-2] as! SolitaireCardView
        }
        var newOrigin = cardTarget.frame.origin
        if newOrigin.x > 0 {
            newOrigin.x += FAN_HOR_OFFSET
        }
        cardView.frame = CGRect(origin: newOrigin, size: cardView.frame.size)
    }
    
    private func returnToOrigin(_ cardView: SolitaireCardView) {
        
        var cardTarget = SolitaireCardView()
        if dragOrigin?.subviews.count ?? 0 > 1 {
            cardTarget = dragOrigin?.subviews[cardView.currentCardIndex! - 1] as? SolitaireCardView ?? SolitaireCardView()
        }
        var newOrigin = cardTarget.frame.origin
        if dragOrigin?.stackType == .tableau {
        
            if newOrigin.y > 0, cardTarget.isFaceUp {
                newOrigin.y += FAN_VERT_OFFSET
            } else {
                newOrigin.y = CGFloat(cardView.currentCardIndex ?? 0) * STACK_VERT_OFFSET
            }
        }
        
        cardView.frame = CGRect(origin: newOrigin, size: cardView.frame.size)
        
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
                                        drawnCardView.frame = drawnCardView.frame.offsetBy(dx: self.wasteView.frame.origin.x - self.stockView.frame.origin.x + CGFloat(index) * self.FAN_HOR_OFFSET, dy: 0.0)
                                        //self.animateFlipOf(cardView: drawnCardView)
                                        
                                        
                        },
                                       completion: { (finished) in
                                        self.animateFlipOf(cardView: drawnCardView)
                                        drawnCardView.frame = CGRect(x: CGFloat(index) * self.FAN_HOR_OFFSET, y: 0.0, width: self.CARD_WIDTH, height: self.CARD_HEIGHT)
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
        updateCardIndexes()
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
                cardView.frame = cardView.frame.offsetBy(dx: CGFloat(cardIndex) * -STACK_HOR_OFFSET, dy: 0.0)
            
            }
        }
    }
    
}

