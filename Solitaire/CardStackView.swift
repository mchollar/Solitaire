//
//  CardStackView.swift
//  Solitaire
//
//  Created by Micah Chollar on 7/23/17.
//  Copyright © 2017 Micah Chollar. All rights reserved.
//

import UIKit

class CardStackView: UIView {

    enum StackType: Int {
        case stock = 0
        case waste
        case tableau
        case foundation
    }
    
    var stackType: StackType?
    
}
