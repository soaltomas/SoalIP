import UIKit
import AudioToolbox

class IPv4ViewController: UIViewController, UITextFieldDelegate {
    
    let ipManager = IPManager.manager
    
    let dotButton: UIButton = DotButton()
    var activeField: UITextField = UITextField()
    var radix: UInt8 = 10
    var labelFont = UIFont.systemFont(ofSize: 20.0)
    
    var isValidIP = false
    var isValidMask = false
    
    @IBOutlet weak var addressField: UITextField! {
        didSet {
            addressField.layer.shadowRadius = 4.0
            addressField.layer.shadowOpacity = 0.6
            addressField.layer.shadowOffset = CGSize.zero
        }
    }

    @IBOutlet weak var prefixField: UITextField! {
        didSet {
            prefixField.layer.shadowRadius = 4.0
            prefixField.layer.shadowOpacity = 0.6
            prefixField.layer.shadowOffset = CGSize.zero
        }
    }
    
    @IBOutlet weak var maskField: UITextField! {
        didSet {
            maskField.layer.shadowRadius = 4.0
            maskField.layer.shadowOpacity = 0.6
            maskField.layer.shadowOffset = CGSize.zero
        }
    }
    
    @IBOutlet weak var prefixSlider: UISlider!
    
    @IBOutlet weak var calculateButton: CustomButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var outputStackView: UIStackView!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var maskLabel: UILabel!
    @IBOutlet weak var networkLabel: UILabel!
    @IBOutlet weak var broadcastLabel: UILabel!
    @IBOutlet weak var hostCountLabel: UILabel!
    @IBOutlet weak var minHostLabel: UILabel!
    @IBOutlet weak var maxHostLabel: UILabel!
    
    @IBOutlet weak var radixSwitcher: UISegmentedControl!
    
    @IBAction func radixSwitch(_ sender: Any) {
        
        switch radixSwitcher.selectedSegmentIndex {
        case 0:
            radix = 2
            labelFont = UIFont.systemFont(ofSize: 12.0)
        case 1:
            radix = 10
            labelFont = UIFont.systemFont(ofSize: 20.0)
        default:
            radix = 10
            labelFont = UIFont.systemFont(ofSize: 20.0)
        }
        self.calculate(self)
    }
    
    @IBAction func changePrefix(_ sender: UISlider) {
        let currentPrefix = UInt8(sender.value)
        prefixField.text = String(currentPrefix)
        self.maskField.text = ipManager.prefixToMask(currentPrefix)

        isValidMask = true
        calculateButton.isEnabled = isValidIP && isValidMask
    }
    
    @IBAction func calculate(_ sender: Any) {
        
        view.endEditing(true)
        
        guard
            let stringAddress = addressField.text
        else{
            return
        }
        
        let prefixString = prefixField.text
        var prefix: UInt8
        var maskString: String
        var mask: UInt32 = UINT32_MAX
        
        if prefixString != nil && !(prefixString?.isEmpty)! {
            guard
                let uintPrefix = UInt8(prefixString!)
            else {
                print("----Prefix isn't nil!")
                return
            }
            prefix = uintPrefix
            mask >>= 32 - prefix
            mask <<= 32 - prefix
        } else {
            guard
                let _maskString = maskField.text
            else {
                print("----Prefix is nil!")
                return
            }
            maskString = _maskString
            mask = ipManager.stringAddressToUInt(maskString)
            prefix = UInt8(32 - String(~mask, radix: 2).count)
            prefixField.text = String(prefix)
            prefixSlider.value = Float(prefix)
        }
        
        maskString = ipManager.uintAddressToString(mask, radix: 10)
        
        guard
            let addressString = addressField.text
        else {
            return
        }
        addressLabel.text = "Address: \(ipManager.uintAddressToString(ipManager.stringAddressToUInt(addressString), radix: radix))"
        addressLabel.font = labelFont
        maskLabel.text = "Mask: \(ipManager.uintAddressToString(ipManager.stringAddressToUInt(maskString), radix: radix))"
        maskLabel.font = labelFont
        
        let address = ipManager.stringAddressToUInt(stringAddress)
        
        let networkString = ipManager.uintAddressToString(address & mask, radix: 10)
        
        networkLabel.text = "Network: \(ipManager.uintAddressToString(ipManager.stringAddressToUInt(networkString), radix: radix))"
        networkLabel.font = labelFont
        
        let broadcast = ~mask | address
        
        broadcastLabel.text = "Broadcast: \(ipManager.uintAddressToString(broadcast, radix: radix))"
        broadcastLabel.font = labelFont
        
        let hostCount = pow(2, Int(32-prefix)) - 2
        hostCountLabel.text = "Host count: \(hostCount)"
        hostCountLabel.font = labelFont
        
        let minHost = ipManager.uintAddressToString((address & mask) + 1, radix: 10)
        minHostLabel.text = "Min host: \(ipManager.uintAddressToString(ipManager.stringAddressToUInt(minHost), radix: radix))"
        minHostLabel.font = labelFont
        
        let maxHost = ipManager.uintAddressToString(broadcast - 1, radix: 10)
        maxHostLabel.text = "Max host: \(ipManager.uintAddressToString(ipManager.stringAddressToUInt(maxHost), radix: radix))"
        maxHostLabel.font = labelFont
        
        if outputStackView.isHidden {
            UIView.animate(withDuration: 0.3) {
                self.outputStackView.isHidden = false
            }
        } else {
            UIView.animate(withDuration: 0.3,
                           animations: {
                                self.outputStackView.isHidden = true
                           },
                           completion: { _ in
                                UIView.animate(withDuration: 0.3) {
                                    self.outputStackView.isHidden = false
                                }
                           }
            )
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        dotButton.addTarget(self, action: #selector(self.inputDotToField), for: UIControlEvents.touchUpInside)
        
        addressField.delegate = self
        prefixField.delegate = self
        maskField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func inputDotToField() {
        guard
            var currentText = activeField.text
        else {
            return
        }
        currentText += "."
        activeField.text = currentText
        AudioServicesPlaySystemSound(1123)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) -> Void {
        DispatchQueue.main.async { () -> Void in
            if self.activeField.accessibilityIdentifier == "address" || self.activeField.accessibilityIdentifier == "mask" {
                self.dotButton.isHidden = false
            } else {
                self.dotButton.isHidden = true
            }
            let keyBoardWindow = UIApplication.shared.windows.last
            guard
                let keyBoardHeight = keyBoardWindow?.frame.size.height
            else {
                return
            }
            self.dotButton.frame = CGRect(x: 0, y: keyBoardHeight-53, width: 106, height: 53)
            self.dotButton.setTitle(".", for: UIControlState())
            keyBoardWindow?.addSubview(self.dotButton)
            keyBoardWindow?.bringSubview(toFront: self.dotButton)
            
            UIView.animate(withDuration: (((notification.userInfo! as NSDictionary).object(forKey: UIKeyboardAnimationCurveUserInfoKey) as AnyObject).doubleValue)!, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                self.view.frame = self.view.frame.offsetBy(dx: 0, dy: 0)
            }, completion: nil)
        }
        
        mainStackView.frame.origin.y -= mainStackView.frame.origin.y/2
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard
            let fieldId = textField.accessibilityIdentifier,
            let currentText = textField.text as NSString?
        else {
            return true
        }
        let replacingChars = currentText.replacingCharacters(in: range, with: string)
        
        switch fieldId {
        case "address":
            if ipManager.validationIP(ip: replacingChars) {
                isValidIP = true
            } else {
                isValidIP = false
            }
            calculateButton.isEnabled = isValidIP && isValidMask
            if replacingChars.count <= 15 {
                return true
            }
        case "prefix":
            guard
                let currentPrefix = UInt8(replacingChars)
            else {
                return true
            }
            if replacingChars.count <= 2 && currentPrefix > 0 && currentPrefix < 32 {
                self.maskField.text = ipManager.prefixToMask(currentPrefix)
                prefixSlider.value = Float(currentPrefix)
                isValidMask = true
                calculateButton.isEnabled = isValidIP && isValidMask
                return true
            } else {
                isValidMask = false
                calculateButton.isEnabled = isValidIP && isValidMask
            }
        case "mask":
            if ipManager.validationMask(mask: replacingChars) {
                isValidMask = true
            } else {
                isValidMask = false
            }
            calculateButton.isEnabled = isValidIP && isValidMask
            if replacingChars.count <= 15 {
                return true
            }
        default:
            return true
        }
        
        return false
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        mainStackView.frame.origin.y += mainStackView.frame.origin.y/2
    }
}
