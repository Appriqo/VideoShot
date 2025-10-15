//
//  AspectFillImageView.swift
//  FreezeFrame
//
//  Created by admin on 5/10/25.
//

import AppKit

class AspectFillImageView : NSImageView {
  
override var image: NSImage? {
    set {
      self.layer = CALayer()
        self.layer?.contentsGravity = .resizeAspectFill
      self.layer?.contents = newValue
      self.wantsLayer = true
      
      super.image = newValue
    }
    
    get {
      return super.image
    }
  }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        if let theImage = image {
            self.image = theImage
        }
    }

}
