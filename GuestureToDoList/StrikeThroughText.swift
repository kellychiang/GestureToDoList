//
//  StrikeThroughText.swift
//  GuestureToDoList
//
//  Created by kelly on 2014/11/22.
//  Copyright (c) 2014年 kelly. All rights reserved.
//

import UIKit
import QuartzCore

class StrikeThroughText: UITextField {
    let strikeThroughLayer: CALayer
    // A Boolean value that determines wheter the label should have a strikethrough.
    var strikeThrough : Bool {
        didSet {
            strikeThroughLayer.hidden = !strikeThrough
            if strikeThrough {
                resizeStrikeThrough()
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(frame: CGRect) {
        strikeThroughLayer = CALayer()
        strikeThroughLayer.backgroundColor = UIColor.whiteColor().CGColor
        strikeThroughLayer.hidden = true
        strikeThrough = false
        
        super.init(frame: frame)
        layer.addSublayer(strikeThroughLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        resizeStrikeThrough()
    }
    
    let kStrikeOutthickeness: CGFloat = 2.0
    func resizeStrikeThrough() {
        let textSize = text!.sizeWithAttributes([NSFontAttributeName: font])
        strikeThroughLayer.frame = CGRect(x: 0, y: bounds.size.height / 2, width: textSize.width, height: kStrikeOutthickeness)
    }

}
