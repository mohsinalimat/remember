//
//  ChatInputView.swift
//  Remember
//
//  Created by Songbai Yan on 14/11/2016.
//  Copyright © 2016 Songbai Yan. All rights reserved.
//

import Foundation
import UIKit

class InputThingView : UIView, UITextFieldDelegate{
    
    private var textField:UITextField!
    
    var delegate:ThingInputDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.background()
        
        textField = InputTextField(frame: CGRect(x: 10, y: 10, width: frame.width - 20, height: frame.height - 20))
        textField.delegate = self
        self.addSubview(textField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let content = textField.text{
            if !content.isEmpty{
                let thing = ThingEntity(content: content, createdAt: NSDate())
                ThingRepository.sharedInstance.createThing(thing: thing)
                
                delegate?.input(inputView: self, thing: thing)
            }
        }
        
        endEditing()
        textField.text = ""
        
        return true
    }
    
    func endEditing() {
        self.textField.resignFirstResponder()
    }
}

protocol ThingInputDelegate : NSObjectProtocol{
    func input(inputView:InputThingView, thing:ThingEntity)
}
