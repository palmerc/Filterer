import Foundation



struct GammaFilter: PixelFilter
{
    var gamma: Double = 0.25

    var filterName: PixelFilterType
    {
        get {
            return PixelFilterType.Gamma
        }
    }

    func filter() -> ((Pixel) -> (Pixel))
    {
        func filter(var pixel: Pixel) -> (Pixel)
        {
            let red = 255 * pow(Double(pixel.red) / 255, gamma)
            let green = 255 * pow(Double(pixel.green) / 255, gamma)
            let blue = 255 * pow(Double(pixel.blue) / 255, gamma)

            pixel.red = clampValue(Int(red), toRange: 0...255)!
            pixel.green = clampValue(Int(green), toRange: 0...255)!
            pixel.blue = clampValue(Int(blue), toRange: 0...255)!

            return pixel
        }

        func clampValue(value: Int, toRange range: Range<Int>) -> UInt8?
        {
            var clampedValue: UInt8?
            if value < range.minElement() {
                clampedValue = UInt8(range.minElement()!)
            } else if value > range.maxElement() {
                clampedValue = UInt8(range.maxElement()!)
            } else {
                clampedValue = UInt8(value)
            }
            
            return clampedValue
        }
        
        return filter
    }
}


