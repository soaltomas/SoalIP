import UIKit
import AudioToolbox

class TrackingViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var addressField: UITextField! {
        didSet {
            addressField.layer.shadowRadius = 4.0
            addressField.layer.shadowOpacity = 0.6
            addressField.layer.shadowOffset = CGSize.zero
        }
    }
    @IBOutlet weak var ipLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var organizationLabel: UILabel!
    
    @IBOutlet weak var goButton: CustomButton!
    @IBOutlet weak var outputStackView: UIStackView!
    
    let dotButton: UIButton = DotButton()
    
    let ipManager = IPManager.manager
    
    let requestFactory = RequestFactory()
    
    @IBAction func getIpInformation(_ sender: Any) {
        view.endEditing(true)
        guard
            let address = addressField.text
        else {
            return
        }
        getIpInformation(ip: address)
        stackViewAnimation()
    }
    @IBAction func getMyIp(_ sender: Any) {
        view.endEditing(true)
        getIpInformation()
        stackViewAnimation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dotButton.addTarget(self, action: #selector(self.inputDotToField), for: UIControlEvents.touchUpInside)
        
        addressField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        ipLabel.text = ""
        countryLabel.text = ""
        cityLabel.text = ""
        organizationLabel.text = ""
        
        getIpInformation()
        stackViewAnimation()
    }
    
    func getIpInformation(ip: String = "") {
        requestFactory.getIpInformation(ip: ip) { [weak self] response in
            switch response.result {
            case .success(let value):
                DispatchQueue.main.async {
                    self?.ipLabel.text = "Address: \(value.ip ?? "---")"
                    self?.countryLabel.text = "Country: \(value.country ?? "---")"
                    self?.cityLabel.text = "City: \(value.city ?? "---")"
                    self?.organizationLabel.text = "Organization: \(value.organization ?? "---")"
                }
            case .failure(let error):
                print("Error: \(String(describing: self?.viewErrorMessage(title: "Error!", error: error)))")
            }
            
        }
    }
    
    func stackViewAnimation() {
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
    
    @objc func inputDotToField() {
        guard
            var currentText = addressField.text
            else {
                return
        }
        currentText += "."
        addressField.text = currentText
        AudioServicesPlaySystemSound(1123)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) -> Void {
        DispatchQueue.main.async { () -> Void in
                self.dotButton.isHidden = false

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
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard
            let currentText = textField.text as NSString?
        else {
            return true
        }

        let replacingChars = currentText.replacingCharacters(in: range, with: string)
        
            if ipManager.validationIP(ip: replacingChars) {
                goButton.isEnabled = true
            } else {
                goButton.isEnabled = false
            }
        if replacingChars.count <= 15 {
            return true
        }
        
        return false
    }
}

extension UIViewController {
    
    /// Displays popup messages when network error occur
    ///
    /// - Parameters:
    ///   - title: message header
    ///   - error: occured error
    /// - Returns: error message
    func viewErrorMessage(title: String, error: Error) -> String {
        let networkError = error as? NetworkError
        if networkError == nil {
            return "No NetworkError!"
        }
        if networkError != .serializationFailed {
            let alert = UIAlertController(title: title, message: error.message(), preferredStyle: UIAlertControllerStyle.alert)
            let alertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)
            alert.addAction(alertAction)
            present(alert, animated: true)
        }
        return error.message()
    }
}

