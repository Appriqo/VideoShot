//
//  NSImage+Extension.swift
//  FreezeFrame
//
//  Created by admin on 6/10/25.
//

import AppKit
import CoreImage

extension NSImage {
    func applyingFilter(_ filterName: String, parameters: [String: Any] = [:]) -> NSImage? {
        guard let tiffData = self.tiffRepresentation,
              let ciImage = CIImage(data: tiffData),
              let filter = CIFilter(name: filterName) else { return nil }
        
        filter.setDefaults()
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        parameters.forEach { filter.setValue($1, forKey: $0) }
        
        guard let output = filter.outputImage else { return nil }
        let rep = NSCIImageRep(ciImage: output)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        return nsImage
    }
}
