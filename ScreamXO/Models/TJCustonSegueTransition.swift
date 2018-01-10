
import Foundation
class TJCustonSegueTransition: UIStoryboardSegue
{
    override func perform() {
        let fromVC = source.view as UIView!
        let toVC = destination.view as UIView!
        
        let window = UIApplication.shared.keyWindow
        window?.insertSubview(toVC!, belowSubview: fromVC!)
        
        toVC?.transform = (toVC?.transform.scaledBy(x: 0.8, y: 0.8))!
        toVC?.alpha = 0.5
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            fromVC?.transform = (toVC?.transform.scaledBy(x: 0.8, y: 0.8))!
            fromVC?.alpha = 0.0
            }, completion: { (Finished) -> Void in
                
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    toVC?.transform = CGAffineTransform.identity
                            toVC?.alpha = 1.0
                    }, completion: { (Finished) -> Void in
                        
                        fromVC?.transform = CGAffineTransform.identity
                        
                        self.source.present(self.destination, animated: false, completion: nil)
                })
        }) 
    }
}

