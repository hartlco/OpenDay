import Foundation
import SwiftUI

#if os(macOS)
import AppKit

public typealias OKImage = NSImage
#endif

#if os(iOS)
import UIKit

public typealias OKImage = UIImage
#endif

public extension OKImage {
    var data: Data? {
        #if os(macOS)
        let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        guard let jpegData = bitmapRep.representation(using: .jpeg, properties: [:]) else {
            return nil
        }

        return jpegData
        #endif

        #if os(iOS)
        return jpegData(compressionQuality: 90)
        #endif
    }

    var thumbnail: Data? {
        let width: CGFloat = 200
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))

        #if os(iOS)
        let format = imageRendererFormat
        format.opaque = true
        return UIGraphicsImageRenderer(size: canvas, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: canvas))
        }.data
        #endif

        #if os(macOS)
        if let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: Int(canvas.width), pixelsHigh: Int(canvas.height),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
        ) {
            bitmapRep.size = canvas
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
            draw(in: NSRect(x: 0, y: 0, width: canvas.width, height: canvas.height),
                 from: .zero, operation: .copy, fraction: 1.0)
            NSGraphicsContext.restoreGraphicsState()

            let resizedImage = NSImage(size: canvas)
            resizedImage.addRepresentation(bitmapRep)
            return resizedImage.data
        }

        return nil
        #endif
    }
}

public extension Image {
    init(okImage: OKImage) {
        #if os(macOS)
        self.init(nsImage: okImage)
        #endif

        #if os(iOS)
        self.init(uiImage: okImage)
        #endif
    }

    init(okImageData: Data) {
        let image = OKImage(data: okImageData)!
        self.init(okImage: image)
    }
}
