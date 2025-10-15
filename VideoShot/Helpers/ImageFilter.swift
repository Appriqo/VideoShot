//
//  ImageFilter.swift
//  FreezeFrame
//
//  Created by admin on 6/10/25.
//

import Foundation

enum ImageFilter: String, CaseIterable {
    case noir = "CIPhotoEffectNoir"
    case chrome = "CIPhotoEffectChrome"
    case instant = "CIPhotoEffectInstant"
    case fade = "CIPhotoEffectFade"
    case process = "CIPhotoEffectProcess"
    case transfer = "CIPhotoEffectTransfer"
    case sepia = "CISepiaTone"
    case vignette = "CIVignette"
    case bloom = "CIBloom"
    case sharpen = "CISharpenLuminance"
    case exposure = "CIExposureAdjust"
    case highlightShadow = "CIHighlightShadowAdjust"
    case temperatureTint = "CITemperatureAndTint"
    case colorInvert = "CIColorInvert"
    case colorMonochrome = "CIColorMonochrome"
    case motionBlur = "CIMotionBlur"
}
