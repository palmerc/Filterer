import Foundation



struct ContrastFilter: PixelFilter
{
    var contrast: Int = 20

    var filterName: PixelFilterType
    {
        get {
            return PixelFilterType.Contrast
        }
    }

    func filter() -> ((Pixel) -> (Pixel))
    {
        var factor: Double {
            get {
                return Double(259 * (contrast + 255)) / Double(255 * (259 - contrast))
            }
        }
        
        func filter(var pixel: Pixel) -> (Pixel)
        {
            let red = factor * (Double(pixel.red) - 128) + 128
            let green = factor * (Double(pixel.green) - 128) + 128
            let blue = factor * (Double(pixel.blue) - 128) + 128

            let filteredRed = clampValue(Int(red), toRange: 0...255)
            let filteredGreen = clampValue(Int(green), toRange: 0...255)
            let filteredBlue = clampValue(Int(blue), toRange: 0...255)

            pixel.red = filteredRed!
            pixel.green = filteredGreen!
            pixel.blue = filteredBlue!

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

