//
//  FilterManager.swift
//  FreezeFrame
//
//  Created by admin on 6/10/25.
//

import AppKit

final class FilterManager {
    private var originalImage: NSImage?
    
    func applyFilter(_ name: String, to image: NSImage, parameters: [String: Any] = [:]) -> NSImage? {
        guard let tiffData = image.tiffRepresentation,
              let ciImage = CIImage(data: tiffData) else { return nil }
        
        let filter = CIFilter(name: name)
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        parameters.forEach { filter?.setValue($0.value, forKey: $0.key) }
        
        guard let output = filter?.outputImage else { return nil }
        let rep = NSCIImageRep(ciImage: output)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        return nsImage
    }
    
    func resetImage() -> NSImage? {
        return originalImage
    }
    
    func setOriginalImage(_ image: NSImage) {
        originalImage = image
    }
}
