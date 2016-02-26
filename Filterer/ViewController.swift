import UIKit



enum FilterType: Int {
    case None = 0
    case Red = 1
    case Green = 2
    case Blue = 3
    case Yellow = 4
    case Purple = 5
}

enum ImageViewPosition: Int {
    case Front = 0
    case Back
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource
{
    @IBOutlet var originalView: UIView!
    @IBOutlet var frontImageView: UIImageView!
    @IBOutlet var backImageView: UIImageView!

    @IBOutlet var editMenu: UIView!
    @IBOutlet var secondaryMenu: UIView!
    @IBOutlet var bottomMenu: UIView!

    @IBOutlet var filterButton: UIButton!

    @IBOutlet var editButton: UIButton!
    @IBOutlet var editSlider: UISlider!

    @IBOutlet var compareButton: UIButton!

    var originalImage: UIImage?
    var filteredImage: UIImage?

    var crossfadeAnimate: Bool = true
    var currentImageView: ImageViewPosition = .Front
    private var _currentImage: UIImage?
    var currentImage: UIImage? {
        get {
            return self._currentImage
        }
        set {
            let newImage = newValue
            if self.currentImage != newImage {
                if currentImageView == .Front {
                    self.backImageView.image = newImage

                    if crossfadeAnimate {
                        self.backImageView.alpha = 0
                        UIView.animateWithDuration(0.25, animations: {
                            self.frontImageView.alpha = 0
                            self.backImageView.alpha = 1
                        })
                    } else {
                        self.frontImageView.alpha = 0
                        self.backImageView.alpha = 1
                    }

                    self.currentImageView = .Back
                } else {
                    self.frontImageView.image = newImage

                    if crossfadeAnimate {
                        self.frontImageView.alpha = 0
                        UIView.animateWithDuration(0.25, animations: {
                            self.frontImageView.alpha = 1
                            self.backImageView.alpha = 0
                        })
                    } else {
                        self.frontImageView.alpha = 1
                        self.backImageView.alpha = 0
                    }

                    self.crossfadeAnimate = false
                    self.currentImageView = .Front
                }
            }

            if newImage == self.originalImage {
                self.originalView.hidden = false
            } else {
                self.originalView.hidden = true
            }

            self._currentImage = newImage
        }
    }

    private var _displayFilteredImage: Bool = false
    var displayFilteredImage: Bool {
        get {
            return self._displayFilteredImage
        }
        set {
            if filters != nil {
                let displayFilteredImage = newValue

                if displayFilteredImage {
                    let imageProcessor = ImageProcessor(image: self.originalImage, withPixelFilters: self.filters)
                    self.filteredImage = imageProcessor.processImage()
                    self.currentImage = self.filteredImage
                } else {
                    self.currentImage = self.originalImage
                }
                self._displayFilteredImage = displayFilteredImage
            }
        }
    }
    private var _filteringAccessoriesEnabled: Bool = false
    var filteringAccessoriesEnabled: Bool {
        get {
            return self._filteringAccessoriesEnabled
        }
        set {
            let filteringAccessoriesEnabled = newValue

            self.editButton.enabled = filteringAccessoriesEnabled
            self.compareButton.enabled = filteringAccessoriesEnabled
            self._filteringAccessoriesEnabled = filteringAccessoriesEnabled
        }
    }
    private var _currentFilter: FilterType = .None
    var currentFilter: FilterType {
        get {
            return _currentFilter
        }
        set {
            let newFilter = newValue
            if newFilter != self.currentFilter {
                self.crossfadeAnimate = true
            }

            let grayscaleFilter = GrayscaleFilter()
            var percentageFilter = PercentageFilter()

            switch (newFilter) {
            case .Red:
                percentageFilter.redAdjustment = self.scalingFactor
                percentageFilter.blueAdjustment = 0
                percentageFilter.greenAdjustment = 0
                break
            case .Green:
                percentageFilter.redAdjustment = 0
                percentageFilter.greenAdjustment = self.scalingFactor
                percentageFilter.blueAdjustment = 0
                break
            case .Blue:
                percentageFilter.redAdjustment = 0
                percentageFilter.greenAdjustment = 0
                percentageFilter.blueAdjustment = self.scalingFactor
                break
            case .Yellow:
                percentageFilter.redAdjustment = self.scalingFactor
                percentageFilter.greenAdjustment = self.scalingFactor
                percentageFilter.blueAdjustment = 0
                break
            case .Purple:
                percentageFilter.redAdjustment = self.scalingFactor
                percentageFilter.greenAdjustment = 0
                percentageFilter.blueAdjustment = self.scalingFactor
                break
            default:
                break
            }

            let tintingFilters: [PixelFilter] = [grayscaleFilter, percentageFilter]
            self.filters = tintingFilters
            self.displayFilteredImage = true
            self.filteringAccessoriesEnabled = true
            self._currentFilter = newValue
        }
    }
    var scalingFactor: Float = 0
    var filters: [PixelFilter]?
    var selectedSecondaryButton: UIButton?


    // MARK: UIViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.scalingFactor = 1

        self.originalImage = UIImage(named: "scenery")
        self.currentImage = self.originalImage
        self.filteringAccessoriesEnabled = false
        self.displayFilteredImage = false

        self.secondaryMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.80)
        self.secondaryMenu.translatesAutoresizingMaskIntoConstraints = false

        self.editMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.80)
        self.editMenu.translatesAutoresizingMaskIntoConstraints = false

        let filterImage = UIImage(named: "filter-original")?.imageWithRenderingMode(.AlwaysTemplate)
        self.filterButton.setImage(filterImage, forState: UIControlState.Normal)
    }

    // MARK: Share
    @IBAction func onShare(sender: AnyObject) {
        let activityController = UIActivityViewController(activityItems: ["Check out our really cool app", self.frontImageView.image!], applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }
    
    // MARK: New Photo
    @IBAction func onNewPhoto(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { action in
            self.showCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Album", style: .Default, handler: { action in
            self.showAlbum()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func showCamera() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .Camera
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .PhotoLibrary
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }

    // MARK: UIView Touches

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        if touch != nil {
            let point = touch?.locationInView(self.view)
            let frontImageViewRect = self.frontImageView.frame
            let adjustedHeight = CGRectGetHeight(frontImageViewRect) - CGRectGetHeight(self.secondaryMenu.frame)
            let adjustedRect = CGRectMake(frontImageViewRect.origin.x, frontImageViewRect.origin.y, frontImageViewRect.size.width, adjustedHeight)
            if CGRectContainsPoint(adjustedRect, point!) {
                if self.compareButton.selected {
                    self.compareButton.selected = false
                }
                self.displayFilteredImage = false
            }
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        if touch != nil {
            let point = touch?.locationInView(self.view)
            if CGRectContainsPoint(self.frontImageView.frame, point!) {
                self.displayFilteredImage = true
            }
        }
    }

    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.frontImageView.image = image
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Filter Menu
    @IBAction func onFilter(sender: UIButton) {
        if (sender.selected) {
            hideSecondaryMenu()
            sender.selected = false
        } else {
            hideEditMenu()
            showSecondaryMenu()
            sender.selected = true
        }
    }
    
    func showSecondaryMenu() {
        view.addSubview(self.secondaryMenu)
        
        let bottomConstraint = self.secondaryMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = self.secondaryMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = self.secondaryMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        
        let heightConstraint = self.secondaryMenu.heightAnchor.constraintEqualToConstant(52)
        
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        
        self.secondaryMenu.alpha = 0
        UIView.animateWithDuration(0.4) {
            self.secondaryMenu.alpha = 1.0
        }
    }

    func hideSecondaryMenu() {
        UIView.animateWithDuration(0.4, animations: {
            self.secondaryMenu.alpha = 0
            }) { completed in
                if completed == true {
                    self.secondaryMenu.removeFromSuperview()
                }
        }
    }


    // MARK: Edit
    @IBAction func didPressEditButton(sender: UIButton) {
        if (sender.selected) {
            hideEditMenu()
            sender.selected = false
        } else {
            hideSecondaryMenu()
            showEditMenu()
            sender.selected = true
        }
    }

    func showEditMenu() {
        view.addSubview(self.editMenu)

        let bottomConstraint = self.editMenu.bottomAnchor.constraintEqualToAnchor(self.bottomMenu.topAnchor)
        let leftConstraint = self.editMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = self.editMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)

        let heightConstraint = self.editMenu.heightAnchor.constraintEqualToConstant(44)

        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])

        view.layoutIfNeeded()

        self.editSlider.value = self.scalingFactor
        self.editMenu.alpha = 0
        UIView.animateWithDuration(0.4) {
            self.editMenu.alpha = 1.0
        }
    }

    func hideEditMenu() {
        self.editButton.selected = false
        UIView.animateWithDuration(0.4, animations: {
            self.editMenu.alpha = 0
            }) { completed in
                if completed == true {
                    self.editMenu.removeFromSuperview()
                }
        }
    }
    @IBAction func didSlideSlider(sender: UISlider) {
        self.scalingFactor = sender.value
        self.currentFilter = self._currentFilter
    }

    // MARK: Compare
    @IBAction func didPressCompareButton(sender: UIButton) {
        let displayOriginalImage = !self.compareButton.selected
        self.compareButton.selected = displayOriginalImage
        if displayOriginalImage {
            self.displayFilteredImage = false
        } else {
            self.displayFilteredImage = true
        }
    }

    // MARK: Secondary Menu
    @IBAction func didSelectFilter(sender: UIButton) {
        if selectedSecondaryButton != nil {
            self.selectedSecondaryButton?.selected = false
            self.selectedSecondaryButton = nil
        }

        let button = sender
        self.currentFilter = FilterType(rawValue: sender.tag)!

        button.selected = true
        self.selectedSecondaryButton = button
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 25
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SecondaryCollectionCellReuseIdentifier", forIndexPath: indexPath)

        let button = UIButton()
        cell.addSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false
        let bottomConstraint = button.bottomAnchor.constraintEqualToAnchor(cell.bottomAnchor)
        let leftConstraint = button.leftAnchor.constraintEqualToAnchor(cell.leftAnchor)
        let rightConstraint = button.rightAnchor.constraintEqualToAnchor(cell.rightAnchor)
        let topConstraint = button.topAnchor.constraintEqualToAnchor(cell.topAnchor)
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, topConstraint])
        cell.layoutIfNeeded()

        let filterImage = UIImage(named: "filter-original")?.imageWithRenderingMode(.AlwaysTemplate)
        button.setImage(filterImage, forState: UIControlState.Normal)

        var tintColor: UIColor?
        var filterIndex = 0
        if indexPath.row < 5 {
            filterIndex = indexPath.row + 1
            button.tag = filterIndex
            button.addTarget(self, action: "didSelectFilter:", forControlEvents: UIControlEvents.TouchDown)
        }
        let filter = FilterType(rawValue: filterIndex)!
        switch filter {
        case .None:
            tintColor = UIColor.lightGrayColor()
            break
        case .Red:
            tintColor = UIColor.redColor()
            break
        case .Green:
            tintColor = UIColor.greenColor()
            break
        case .Blue:
            tintColor = UIColor.blueColor()
            break
        case .Yellow:
            tintColor = UIColor.yellowColor()
            break
        case .Purple:
            tintColor = UIColor.purpleColor()
            break
        }
        button.tintColor = tintColor!

        return cell
    }
}

