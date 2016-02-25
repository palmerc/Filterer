import Foundation



struct BrightnessFilter: PixelFilter
{
    var brightness: Int = 100

    var filterName: PixelFilterType
    {
        get {
            return PixelFilterType.Brightness
        }
    }

    func filter() -> ((Pixel) -> (Pixel))
    {
        func filter(var pixel: Pixel) -> (Pixel)
        {
            let red = Int(pixel.red) + brightness
            let green = Int(pixel.green) + brightness
            let blue = Int(pixel.blue) + brightness

            pixel.red = clampValue(red, toRange: 0...255)!
            pixel.green = clampValue(green, toRange: 0...255)!
            pixel.blue = clampValue(blue, toRange: 0...255)!

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
