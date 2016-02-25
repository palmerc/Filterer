import Foundation



public enum PixelFilterType: String {
    case Brightness = "Brightness"
    case Contrast = "Contrast"
    case Gamma = "Gamma"
    case Grayscale = "Grayscale"
    case Invert = "Invert"
    case Percentage = "Percentage"
}

public protocol PixelFilter
{
    var filterName: PixelFilterType { get }
    func filter() -> ((Pixel) -> (Pixel))
}

public class PixelFilterFactory
{
    class func filterByType(pixelFilterType: PixelFilterType) -> PixelFilter?
    {
        var pixelFilter: PixelFilter?
        switch pixelFilterType {
        case .Brightness:
            pixelFilter = BrightnessFilter()
            break
        case .Contrast:
            pixelFilter = ContrastFilter()
            break
        case .Gamma:
            pixelFilter = GammaFilter()
            break
        case .Grayscale:
            pixelFilter = GrayscaleFilter()
            break
        case .Invert:
            pixelFilter = InvertFilter()
            break
        case .Percentage:
            pixelFilter = PercentageFilter()
            break
        default:
            break
        }

        return pixelFilter
    }
}