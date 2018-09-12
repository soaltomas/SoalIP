import UIKit

class CustomButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 5
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 0.6
        layer.shadowOffset = CGSize.zero
    }
}
