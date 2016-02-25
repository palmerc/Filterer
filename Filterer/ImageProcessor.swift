import Foundation
import UIKit



public class ImageProcessor
{
    var pixelFilters: Array<PixelFilter>?
    var image: UIImage?

    public init(image: UIImage?, withPixelFilters pixelFilters: Array<PixelFilter>?)
    {
        self.image = image
        self.pixelFilters = pixelFilters
    }

    public convenience init(image: UIImage?, withPixelFilterTypes pixelFilterTypes: Array<PixelFilterType>?)
    {
        var pixelFilters: [PixelFilter]?
        if pixelFilterTypes != nil {
            var filters = [PixelFilter]()
            for pixelFilterType in pixelFilterTypes! {
                let pixelFilter = PixelFilterFactory.filterByType(pixelFilterType)
                if (pixelFilter != nil) {
                    filters.append(pixelFilter!)
                }
            }
            pixelFilters = filters
        }

        self.init(image: image, withPixelFilters: pixelFilters)
    }

    public convenience init(image: UIImage?, withPixelFilterNames pixelFilterNames: Array<String>?)
    {
        var pixelFilterTypes = [PixelFilterType]()
        if pixelFilterNames != nil {
            for pixelFilterName in pixelFilterNames! {
                let pixelFilterType = PixelFilterType(rawValue: pixelFilterName)
                pixelFilterTypes.append(pixelFilterType!)
            }
        }
        self.init(image: image, withPixelFilterTypes: pixelFilterTypes)
    }

    public func processImage() -> UIImage?
    {
        let mutableImage = RGBAImage(image: self.image!)

        for pixelFilter in self.pixelFilters! {
            for y in 0..<mutableImage!.height {
                for x in 0..<mutableImage!.width {
                    let index = y * mutableImage!.width + x
                    let pixel = mutableImage?.pixels[index]
                    let filter = pixelFilter.filter()
                    mutableImage?.pixels[index] = filter(pixel!)
                }
            }
        }

        return mutableImage?.toUIImage()
    }
}