//
//  TableViewCell.swift
//  GuestureToDoList
//
//  Created by kelly on 2014/11/22.
//  Copyright (c) 2014年 kelly. All rights reserved.
//

import UIKit
import QuartzCore

// A protocol that the TableViewCell uses to inform its delegate of state change
protocol TableViewCellDelegate {
    // Indicates that the given item has benn deleted
    func toDoItemDeleted(toDoItem : ToDoItem)
    // Indicates that the edit process has begun for the given cell
    func cellDidBeginEditing(editingCell: TableViewCell)
    // Indicates that the edit process has committed for the given cell
    func cellDidEndEditing(editingCell: TableViewCell)
}

class TableViewCell: UITableViewCell , UITextFieldDelegate {
    
    
    let gradientLayer = CAGradientLayer()
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false, completeOnDragRelease = false
    let label: StrikeThroughText
    let itemCompleteLayer = CALayer ()
    var tickLabel: UILabel!, crossLabel: UILabel!
    
    
    // The object that acts as delegate for this cell.
    var delegate: TableViewCellDelegate?
    // The item that this cell renders.
    var toDoItem: ToDoItem? {
        didSet {
            label.text = toDoItem!.text
            label.strikeThrough = toDoItem!.completed
            itemCompleteLayer.hidden = !label.strikeThrough
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        // create a label that renders the to-do item text
        label = StrikeThroughText(frame: CGRect.nullRect)
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.boldSystemFontOfSize(16)
        label.backgroundColor = UIColor.clearColor()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        label.delegate = self
        label.contentVerticalAlignment = .Center
        
        //gradient layer for cell
        gradientLayer.frame = bounds
        let color1 = UIColor(white: 1.0, alpha: 0.2).CGColor as CGColorRef
        let color2 = UIColor(white: 1.0, alpha: 0.1).CGColor as CGColorRef
        let color3 = UIColor.clearColor().CGColor as CGColorRef
        let color4 = UIColor(white: 0.0, alpha: 0.1).CGColor as CGColorRef
        gradientLayer.colors = [color1, color2, color3, color4]
        gradientLayer.locations = [0.0 , 0.01, 0.95 , 1.0]
        layer.insertSublayer(gradientLayer, atIndex: 0)
        
        // add a pan recognizer
        var recognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
        
        // add a layer that renders a green background when an item is complete
        itemCompleteLayer = CALayer(layer: layer)
        itemCompleteLayer.backgroundColor = UIColor(red: 0.0, green: 0.6, blue: 0.0, alpha: 1.0).CGColor
        itemCompleteLayer.hidden = true
        layer.insertSublayer(itemCompleteLayer, atIndex: 0)
        
        // tick and cross labels for context cues
        tickLabel = createCueLabel()
        tickLabel.text = "\u{2713}"
        tickLabel.textAlignment = .Right
        crossLabel = createCueLabel()
        crossLabel.text = "\u{2717}"
        crossLabel.textAlignment = .Left
      
        addSubview(label)
        addSubview(tickLabel)
        addSubview(crossLabel)
        // remove the default blue highlight for selected cells
        selectionStyle = .None
    }
    
    let kLabelLeftMargin: CGFloat = 15.0
    let kUICuesMargin: CGFloat = 10.0, kUICuesWidth:  CGFloat = 50.0
    // utility method for creating the contextual cues
    func createCueLabel () -> UILabel {
        let label = UILabel(frame: CGRect.nullRect)
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.boldSystemFontOfSize(32.0)
        label.backgroundColor = UIColor.clearColor()
        
        return label
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // ensure the gradient layer occupies the full bounds
        gradientLayer.frame = bounds
        itemCompleteLayer.frame = bounds
        label.frame = CGRect(x: kLabelLeftMargin, y: 0, width: bounds.size.width - kLabelLeftMargin, height: bounds.size.height)
        tickLabel.frame = CGRect(x:  -kUICuesWidth - kUICuesMargin, y: 0, width: kUICuesWidth, height: bounds.size.height)
        crossLabel.frame = CGRect(x: bounds.size.width + kUICuesMargin, y: 0, width: kUICuesWidth, height: bounds.size.height)
    }
    
    // MARK: horizontal pan guesture methods
    func handlePan(recognizer: UIPanGestureRecognizer) {
        // start
        if recognizer.state == .Began {
            // when the gesture begins, record the current center location
            originalCenter = center
        }
        
        // change
        if recognizer.state == .Changed {
            // fade the contextual clues
            let cueAlpha = fabs(frame.origin.x) / (frame.size.width / 2.0)
            tickLabel.alpha = cueAlpha
            crossLabel.alpha = cueAlpha
            // indicate when the user has pulled the item far enough to invoke the given action
            tickLabel.textColor = completeOnDragRelease ? UIColor.greenColor() : UIColor.whiteColor()
            crossLabel.textColor = deleteOnDragRelease ? UIColor.redColor() : UIColor.whiteColor()
            
            let translation = recognizer.translationInView(self)
            center = CGPointMake(originalCenter.x + translation.x, originalCenter.y)
            // has the user dragged the item far enough to initiate a delete/complete?
            deleteOnDragRelease = frame.origin.x < -frame.size.width / 2.0
            completeOnDragRelease = frame.origin.x > frame.size.width / 2.0
        }
        
        // end
        if recognizer.state == .Ended {
            // the frame this cell had before user dragged it
            let originalFrame = CGRect(x: 0, y: frame.origin.y , width: bounds.size.width, height: bounds.size.height)
            if deleteOnDragRelease {
                if delegate != nil && toDoItem != nil {
                    // notify the delegate that this item should be deleted
                    delegate!.toDoItemDeleted(toDoItem!)
                }
            } else if completeOnDragRelease {
                if toDoItem != nil {
                    toDoItem!.completed = true
                }
                label.strikeThrough = true
                itemCompleteLayer.hidden = false
                UIView.animateWithDuration(0.2, animations: { self.frame = originalFrame })
                
            } else {
                // if the item is not being deleted, snap back to the original location
                UIView.animateWithDuration(0.2, animations: { self.frame = originalFrame })

            }
        }
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translationInView(superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        
        return false
    }
    
    // MARK: - UITextFieldDelegate methods
    func textFieldDidBeginEditing(textField: UITextField) {
        if delegate != nil {
            delegate!.cellDidBeginEditing(self)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // close the keyboard on Enter
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        // disable editing of completed to-do items
        if toDoItem != nil {
            return !toDoItem!.completed
        }
        return false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if toDoItem != nil {
            if textField.text == "" {
                delegate!.toDoItemDeleted(toDoItem!)
            } else {
            toDoItem!.text = textField.text
            }
        }
        
        if delegate != nil {
            delegate!.cellDidEndEditing(self)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
