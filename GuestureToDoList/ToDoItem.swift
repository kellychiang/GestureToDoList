//
//  ToDoItem.swift
//  GuestureToDoList
//
//  Created by kelly on 2014/11/22.
//  Copyright (c) 2014年 kelly. All rights reserved.
//

import UIKit

class ToDoItem: NSObject {
    // A text description of this item.
    var text: String
    
    // A Boolean value that determines the completed status of tj=his item.
    var completed: Bool
    
    // Return a ToDoItem initialized with the given text and default completed value
    init(text: String) {
        self.text = text
        self.completed = false
    }
    
}
