
import UIKit

class ViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var input: UITextView!
    @IBOutlet weak var result: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        input.delegate = self
        result.delegate = self
        
        let app: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let expr: String = app.expr ?? "ceil(pi * 2) * sqrt(36) + cos(pi) + log2(2)"

        input.text = expr
        result.text = Calculator.shared.evaluate(input: expr)
    }
    
    func textView(_ view: UITextView, shouldChangeTextIn: NSRange, replacementText: String) -> Bool {
        if (view == self.input) {
            if replacementText == "\n" {
                result.text = Calculator.shared.evaluate(input: input.text)
                self.input.endEditing(true)
                return false
            }
        }

        // otherwise, it will return true and the text will be replaced
        return true
    }
    
}

