import UIKit

class DotButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentHorizontalAlignment = .center
        self.contentVerticalAlignment = .center
        self.setTitleColor(UIColor.white, for: UIControlState())
        self.adjustsImageWhenHighlighted = false
    }
}
