

import UIKit

class LaunchScreenViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "BeReal."
        label.font = .systemFont(ofSize: 42, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateLogo()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func animateLogo() {
        // Initial scale
        titleLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        // Spring animation for bouncy effect
        UIView.animate(withSpring: 0.7,
                      bounce: 0.3) {
            self.titleLabel.transform = .identity
        }
        
        // Shake animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.shakeAnimation()
        }
    }
    
    private func shakeAnimation() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-10.0, 10.0, -8.0, 8.0, -5.0, 5.0, -3.0, 3.0, 0.0]
        titleLabel.layer.add(animation, forKey: "shake")
    }
}

// Extension for simpler spring animations
extension UIView {
    static func animate(withSpring dampingRatio: CGFloat,
                       bounce: CGFloat,
                       animations: @escaping (() -> Void)) {
        UIView.animate(withDuration: 0.5,
                      delay: 0,
                      usingSpringWithDamping: dampingRatio,
                      initialSpringVelocity: bounce,
                      options: .curveEaseInOut,
                      animations: animations)
    }
}
