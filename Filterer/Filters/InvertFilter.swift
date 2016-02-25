import Foundation



struct InvertFilter: PixelFilter
{
    var filterName: PixelFilterType
    {
        get {
            return PixelFilterType.Invert
        }
    }

    func filter() -> ((Pixel) -> (Pixel))
    {
        func filter(var pixel: Pixel) -> (Pixel)
        {
            let red = 255 - pixel.red
            let green = 255 - pixel.green
            let blue = 255 - pixel.blue
            pixel.red = red
            pixel.green = green
            pixel.blue = blue

            return pixel
        }
        
        return filter
    }
}
