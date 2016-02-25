import Foundation



struct PercentageFilter: PixelFilter
{
    var redAdjustment: Float = 1
    var greenAdjustment: Float = 1
    var blueAdjustment: Float = 1
    var alphaAdjustment: Float = 1

    var filterName: PixelFilterType {
        get {
            return PixelFilterType.Percentage
        }
    }

    func filter() -> ((Pixel) -> (Pixel))
    {
        func filter(var pixel: Pixel) -> (Pixel)
        {
            let red = redAdjustment * Float(pixel.red)
            let green = greenAdjustment * Float(pixel.green)
            let blue = blueAdjustment * Float(pixel.blue)
            let alpha = alphaAdjustment * Float(pixel.alpha)

            pixel.red = UInt8(red)
            pixel.green = UInt8(green)
            pixel.blue = UInt8(blue)
            pixel.alpha = UInt8(alpha)

            return pixel
        }

        return filter
    }
}
