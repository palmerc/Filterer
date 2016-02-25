import Foundation



struct GrayscaleFilter: PixelFilter
{
    var filterName: PixelFilterType
    {
        get {
            return PixelFilterType.Grayscale
        }
    }

    func filter() -> ((Pixel) -> (Pixel))
    {
        func filter(var pixel: Pixel) -> (Pixel)
        {
            let red = 0.2989 * Double(pixel.red)
            let green = 0.5870 * Double(pixel.green)
            let blue = 0.1140 * Double(pixel.blue)
            let grayscaleIntensity = UInt8(red + green + blue)
            pixel.red = grayscaleIntensity
            pixel.green = grayscaleIntensity
            pixel.blue = grayscaleIntensity
            
            return pixel
        }
        
        return filter
    }
}