//
//  Helper.swift
//  ResidencyRanker
//
//  Created by Tony Jiang on 9/1/18.
//  Copyright © 2018 Tony Jiang. All rights reserved.
//

import Foundation

extension UIViewController {
    func alert(message: NSString, title: NSString) {
        let alert = UIAlertController(title: title as String, message: message as String, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func heavyShake(object: AnyObject!) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 20
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: (object?.center.x)! - 50, y: object.center.y + 50))
        animation.toValue = NSValue(cgPoint: CGPoint(x: object.center.x + 50, y: object.center.y - 50))
        object.layer.add(animation, forKey: "position")
    }
    
    func fullRotate(object: AnyObject!) {
        let fullRotation = CABasicAnimation(keyPath: "transform.rotation")
        fullRotation.delegate = self as? CAAnimationDelegate
        fullRotation.fromValue = NSNumber(floatLiteral: 0)
        fullRotation.toValue = NSNumber(floatLiteral: Double(CGFloat.pi * 2))
        fullRotation.duration = 0.4
        fullRotation.repeatCount = 5
        object.layer.add(fullRotation, forKey: "360")
    }
    
    
    func shake(object: AnyObject!) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: (object?.center.x)! - 10, y: object.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: object.center.x + 10, y: object.center.y))
        object.layer.add(animation, forKey: "position")
    }
    
    func editLabel(label: UILabel!, text: String) {
        label.text = text
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.font = UIFont(name: "Avenir", size: (Env.iPad ? 24 : 16))
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        view.addSubview(label)
    }
    
    func editButton(button: UIButton!, text: String, font: CGFloat) {
        button.setTitle(text, for: .normal)
        button.contentHorizontalAlignment = .center
        button.titleLabel?.font = UIFont(name: "Avenir", size: (Env.iPad ? font * 1.5 : font))
        button.setTitleColor(.white, for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 2
        button.backgroundColor = UIColor(red: 0.0/255.0, green: 195.0/255.0, blue: 240.0/255.0, alpha: 1)
        //button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = button.frame.height/5
        button.clipsToBounds = true
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.lineBreakMode = .byWordWrapping;
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.5
        view.addSubview(button)
    }
}

extension String {
    var containsWhitespace : Bool {
        return (self.rangeOfCharacter(from: .whitespacesAndNewlines) != nil)
    }
    
    var isContainsLetters : Bool{
        let letters = CharacterSet.letters
        return self.rangeOfCharacter(from: letters) != nil
    }
}

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
    
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var alreadyAdded = Set<Iterator.Element>()
        return self.filter { alreadyAdded.insert($0).inserted }
    }
}

class Env {
    static var iPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}

extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.font: UIFont.boldSystemFont(ofSize: 18)]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let normal = NSAttributedString(string: text)
        append(normal)
        
        return self
    }
}
