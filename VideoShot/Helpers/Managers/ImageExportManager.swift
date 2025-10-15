//
//  ImageExportManager.swift
//  FreezeFrame
//
//  Created by admin on 12/10/25.
//

import AppKit
import ImageIO
import CoreServices
import AVFoundation

protocol ImageExportManagerDelegate: AnyObject {
    func exportDidStart()
    func exportDidProgress(_ current: Int, total: Int)
    func exportDidComplete(urls: [URL])
    func exportDidFail(error: ImageExportError)
}

enum ImageExportError: LocalizedError {
    case invalidImage
    case encodingFailed
    case writeFailed
    case invalidQuality
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "invalid.image".localized
        case .encodingFailed:
            return "image.encoding".localized
        case .writeFailed:
            return "file.write.error".localized
        case .invalidQuality:
            return "invalid.quality".localized
        }
    }
}

final class ImageExportManager {
    weak var delegate: ImageExportManagerDelegate?
    
    private let queue = DispatchQueue(label: "com.freezeframe.export", qos: .userInitiated)
    private var exportDirectory: URL?
    
    init(delegate: ImageExportManagerDelegate? = nil) {
        self.delegate = delegate
    }
    
    // MARK: - Public Methods
    
    func exportImages(
        _ images: [NSImage],
        format: ImageFormatType,
        quality: Int
    ) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.allowsMultipleSelection = false
        openPanel.prompt = "select.folder".localized
        openPanel.title = "choose.folder".localized

        openPanel.begin { [weak self] response in
            guard response == .OK, let directoryURL = openPanel.url else { return }

            self?.queue.async {
                self?.performExport(images, format: format, quality: quality, toDirectory: directoryURL)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func performExport(
        _ images: [NSImage],
        format: ImageFormatType,
        quality: Int,
        toDirectory directory: URL?
    ) {
        guard quality >= 1 && quality <= 100 else {
            DispatchQueue.main.async {
                self.delegate?.exportDidFail(error: .invalidQuality)
            }
            return
        }
        
        DispatchQueue.main.async {
            self.delegate?.exportDidStart()
        }
        
        let exportDir = directory ?? createExportDirectory()
        var exportedURLs: [URL] = []
        
        for (index, image) in images.enumerated() {
            do {
                let fileName = "VideoShot_image_\(index + 1)_\(UUID().uuidString.prefix(8))"
                let url = exportDir.appendingPathComponent(fileName).appendingPathExtension(format.fileExtension)
                
                try exportImage(image, to: url, format: format, quality: quality)
                exportedURLs.append(url)
                
                DispatchQueue.main.async {
                    self.delegate?.exportDidProgress(index + 1, total: images.count)
                }
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.exportDidFail(error: .writeFailed)
                }
                return
            }
        }
        
        DispatchQueue.main.async {
            self.delegate?.exportDidComplete(urls: exportedURLs)
        }
    }
    
    private func exportImage(
        _ image: NSImage,
        to url: URL,
        format: ImageFormatType,
        quality: Int
    ) throws {
        guard let tiffData = image.tiffRepresentation else {
            throw ImageExportError.invalidImage
        }
        
        guard let bitmapImage = NSBitmapImageRep(data: tiffData) else {
            throw ImageExportError.invalidImage
        }
        
        let fileData = try createImageData(from: bitmapImage, format: format, quality: quality)
        try fileData.write(to: url)
    }
    
    private func createImageData(
        from bitmap: NSBitmapImageRep,
        format: ImageFormatType,
        quality: Int
    ) throws -> Data {
        let compressionFactor = CGFloat(quality) / 100.0
        switch format {
        case .jpg:
            guard let data = bitmap.representation(
                using: .jpeg,
                properties: [.compressionFactor: compressionFactor]
            ) else {
                throw ImageExportError.encodingFailed
            }
            return data
            
        case .png:
            guard let data = bitmap.representation(using: .png, properties: [.compressionFactor: compressionFactor]) else {
                throw ImageExportError.encodingFailed
            }
            return data
            
        case .tiff:
            guard let data = bitmap.representation(using: .tiff, properties: [.compressionFactor: compressionFactor]) else {
                throw ImageExportError.encodingFailed
            }
            return data
            
        case .gif:
            guard let data = bitmap.representation(using: .gif, properties: [.compressionFactor: compressionFactor]) else {
                throw ImageExportError.encodingFailed
            }
            return data
            
        case .heic:
               guard let cgImage = bitmap.cgImage else {
                   throw ImageExportError.encodingFailed
               }
               let data = NSMutableData()
               guard let destination = CGImageDestinationCreateWithData(
                   data,
                   AVFileType.heic as CFString,
                   1,
                   nil
               ) else {
                   throw ImageExportError.encodingFailed
               }
               CGImageDestinationAddImage(destination, cgImage, [
                   kCGImageDestinationLossyCompressionQuality: CGFloat(quality) / 100.0
               ] as CFDictionary)
               guard CGImageDestinationFinalize(destination) else {
                   throw ImageExportError.encodingFailed
               }
               return data as Data
        case .pdf:
            guard let cgImage = bitmap.cgImage else {
                throw ImageExportError.encodingFailed
            }
            
            let data = NSMutableData()
            guard let consumer = CGDataConsumer(data: data as CFMutableData) else {
                throw ImageExportError.encodingFailed
            }
            
            var mediaBox = CGRect(origin: .zero, size: CGSize(width: cgImage.width, height: cgImage.height))
            guard let pdfContext = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
                throw ImageExportError.encodingFailed
            }
            
            pdfContext.beginPDFPage(nil)
            pdfContext.draw(cgImage, in: mediaBox)
            pdfContext.endPDFPage()
            pdfContext.closePDF()
            
            return data as Data
           }
    }
    
    private func createExportDirectory() -> URL {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(
            for: .downloadsDirectory,
            in: .userDomainMask
        ).first ?? fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        
        let exportPath: URL
        if #available(macOS 12.0, *) {
            exportPath = documentsPath.appendingPathComponent("FreezeFrame_Export_\(Date().formatted())")
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
            let formattedDate = formatter.string(from: Date())
            exportPath = documentsPath.appendingPathComponent("FreezeFrame_Export_\(formattedDate)")
        }
        
        try? fileManager.createDirectory(
            at: exportPath,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        return exportPath
    }
}

// MARK: - ImageFormatType Extension

extension ImageFormatType {
    var fileExtension: String {
        switch self {
        case .jpg:
            return "jpg"
        case .png:
            return "png"
        case .heic:
            return "heic"
        case .tiff:
            return "tiff"
        case .gif:
            return "gif"
        case .pdf:
            return "pdf"
        }
    }
}
