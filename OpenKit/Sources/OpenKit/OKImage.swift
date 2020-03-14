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
}
