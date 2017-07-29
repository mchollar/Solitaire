//
//  PlayingCardView.swift
//  SuperCard
//
//  Created by Micah Chollar on 7/3/17.
//  Copyright © 2017 Micah Chollar. All rights reserved.
//

import UIKit


class PlayingCardView: UIView {
    
    //MARK: Properties
    var rank: Int? = 0 { didSet { setNeedsDisplay() } }
    var suit: String? = "" { didSet { setNeedsDisplay() } }
    var isFaceUp: Bool = false { didSet { setNeedsDisplay() } }
    override var description: String {
        get {
            return "\(self.rank ?? 0)\(self.suit ?? "?") \(self.isFaceUp ? "Face Up" : "Face Down")"
        }
    }
    
    let CORNER_FONT_STANDARD_HEIGHT = CGFloat(180.0)
    let CORNER_RADIUS = CGFloat(12.0)
    let DEFAULT_FACE_CARD_SCALE_FACTOR = CGFloat(0.90)
    let PIP_FONT_SCALE_FACTOR = CGFloat(0.20)
    let CORNER_OFFSET = CGFloat(2.0)
    
    private var cornerScaleFactor: CGFloat {
        get { return self.bounds.size.height / CORNER_FONT_STANDARD_HEIGHT }
    }
    private var cornerRadius: CGFloat {
        get { return CORNER_RADIUS * self.cornerScaleFactor }
    }
    private var cornerOffset: CGFloat {
        get { return self.cornerRadius / 3.0 }
    }
    
    private var _faceCardScaleFactor: CGFloat?
    private var faceCardScaleFactor: CGFloat {
        get {
            if _faceCardScaleFactor == nil { _faceCardScaleFactor = DEFAULT_FACE_CARD_SCALE_FACTOR }
            return _faceCardScaleFactor!
        }
        set {
            _faceCardScaleFactor = newValue
            setNeedsDisplay()
        }
    }
    
    //MARK: Initialization
    private func setup() {
        self.backgroundColor = nil
        self.isOpaque = false
        self.contentMode = .redraw
    }
    
    override func awakeFromNib() {
        self.setup()
    }
    
    private func rankStrings() -> [String] {
        return ["?", "A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
    }
    
    //MARK: Drawing
    override func draw(_ rect: CGRect) {
    
        let roundedRect = UIBezierPath(roundedRect: self.bounds,
                                       cornerRadius: cornerRadius)
        
        roundedRect.addClip()
        
        UIColor.white.setFill()
        UIRectFill(self.bounds)
        
        UIColor.black.setStroke()
        roundedRect.stroke()
        
        if self.isFaceUp, let rank = self.rank, let suit = self.suit {
            let faceImage = UIImage(named: "\(rankStrings()[rank])\(suit)")
            if faceImage != nil {
                let imageRect = bounds.insetBy(dx: bounds.size.width * (1.0-self.faceCardScaleFactor), dy: bounds.size.height * (1.0-self.faceCardScaleFactor) )
                faceImage!.draw(in: imageRect)
                //print("faceImage drawn: \(faceImage!)")
            } else {
                drawPips()
            }
            drawCorners()
        } else {
            UIImage(named: "cardback")?.draw(in: bounds)
        }
    }
    
    //MARK: Draw Pips
    let PIP_HOFFSET_PERCENTAGE = CGFloat (0.165)
    let PIP_VOFFSET1_PERCENTAGE = CGFloat (0.090)
    let PIP_VOFFSET2_PERCENTAGE = CGFloat (0.175)
    let PIP_VOFFSET3_PERCENTAGE = CGFloat (0.270)
    
    
    private func drawPips() {
        if ((self.rank == 1) || (self.rank == 5) || (self.rank == 9) || (self.rank == 3)) {
            drawPips(WithHorizontalOffset: 0,
                     verticalOffset: 0,
                     mirroredVertically: false)
        }
        if ((self.rank == 6) || (self.rank == 7) || (self.rank == 8)) {
            drawPips(WithHorizontalOffset: PIP_HOFFSET_PERCENTAGE,
                     verticalOffset: 0,
                     mirroredVertically: false)
        }
        if ((self.rank == 2) || (self.rank == 3) || (self.rank == 7) || (self.rank == 8) || (self.rank == 10)) {
            drawPips(WithHorizontalOffset: 0,
                     verticalOffset: PIP_VOFFSET2_PERCENTAGE,
                     mirroredVertically: (rank != 7))
        }
        if ((self.rank == 4) || (self.rank == 5) || (self.rank == 6) || (self.rank == 7) || (self.rank == 8) || (self.rank == 9) || (self.rank == 10)) {
                drawPips(WithHorizontalOffset: PIP_HOFFSET_PERCENTAGE,
                         verticalOffset: PIP_VOFFSET3_PERCENTAGE,
                         mirroredVertically: true)
        }
        if ((self.rank == 9) || (self.rank == 10)) {
            drawPips(WithHorizontalOffset: PIP_HOFFSET_PERCENTAGE,
                     verticalOffset: PIP_VOFFSET1_PERCENTAGE,
                     mirroredVertically: true)
        }
    }
        
    private func drawPips(WithHorizontalOffset hoffset: CGFloat,
                          verticalOffset voffset: CGFloat,
                          upsideDown: Bool)
    {
        
        if let suit = self.suit {
            if (upsideDown) { pushContextAndRotateUpsideDown() }
            let middle = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
            
            let tempFont = UIFont.preferredFont(forTextStyle: .body)
            let pipFont = tempFont.withSize(bounds.size.width * PIP_FONT_SCALE_FACTOR)
            
            
            let attributedSuit = NSAttributedString(string:suit,
                                                    attributes: [NSFontAttributeName : pipFont])
            
            let pipSize = attributedSuit.size()
            var pipOrigin = CGPoint(
                x: middle.x-pipSize.width/2.0-hoffset*self.bounds.size.width,
                y: middle.y-pipSize.height/2.0-voffset*self.bounds.size.height
            );
            attributedSuit.draw(at: pipOrigin)
            if (hoffset>0) {
                pipOrigin.x += hoffset*2.0*self.bounds.size.width;
                attributedSuit.draw(at: pipOrigin)
            }
            if (upsideDown) { popContext() }
        }
    }
    
    private func drawPips(WithHorizontalOffset hoffset: CGFloat,
                          verticalOffset voffset: CGFloat,
                          mirroredVertically: Bool) {
        drawPips(WithHorizontalOffset: hoffset,
                 verticalOffset: voffset,
                 upsideDown: false)
        if mirroredVertically {
            drawPips(WithHorizontalOffset: hoffset,
                     verticalOffset: voffset,
                     upsideDown: true)
        }
    }
    
    private func pushContextAndRotateUpsideDown()
    {
        if let context = UIGraphicsGetCurrentContext() {
            context.saveGState();
            context.translateBy(x: self.bounds.size.width, y: self.bounds.size.height);
            context.rotate(by: .pi);
        }
    }
    
    private func popContext()
    {
        UIGraphicsGetCurrentContext()?.restoreGState();
    }
    
    private func drawCorners() {
        if let suit = self.suit, let rank = self.rank {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let tempFont = UIFont.preferredFont(forTextStyle: .body)
            let cornerFont = tempFont.withSize(tempFont.pointSize * self.cornerScaleFactor)
            
            let cornerText = NSAttributedString(string: "\(rankStrings()[rank])\n\(suit)",
                attributes: [NSFontAttributeName : cornerFont,
                             NSParagraphStyleAttributeName : paragraphStyle])
            
            var textBounds = CGRect()
            textBounds.origin = CGPoint(x: self.cornerOffset, y: self.cornerOffset)
            textBounds.size = cornerText.size()
            cornerText.draw(in: textBounds)
            
            let context = UIGraphicsGetCurrentContext()
            context?.translateBy(x: bounds.size.width, y: bounds.size.height)
            context?.rotate(by: .pi)
            cornerText.draw(in: textBounds)
        }
    }

}
