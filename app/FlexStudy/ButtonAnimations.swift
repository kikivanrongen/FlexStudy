import Foundation
import UIKit

extension UIButton {
    
    // pulse animation for buttons
    func pulsate() {
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        
        // set properties
        pulse.duration = 0.6
        pulse.fromValue = 0.95
        pulse.toValue = 1
        pulse.autoreverses = true
        pulse.repeatCount = 1
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        
        layer.add(pulse, forKey: nil)
    }
}
