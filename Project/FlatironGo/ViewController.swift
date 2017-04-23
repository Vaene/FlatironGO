//
//  ViewController.swift
//  FlatironGo
//
//  Created by Jim Campagno on 7/13/16.
//  Copyright © 2016 Gamesmith, LLC. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion


final class ViewController: UIViewController {
    
    var treasure: Treasure!
    var foundImageView: UIImageView!
    var dismissButton: UIButton!
    var foundTreasure = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupDismissButton()
        
        
        
    }
    
    
}

// MARK: - AVFoundation Methods
extension ViewController {
    
    private func setupCaptureCameraDevice() {
        let cameraDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let cameraDeviceInput = try? AVCaptureDeviceInput(device: cameraDevice)
        guard let camera = cameraDeviceInput , captureSession.canAddInput(camera) else { return }
        captureSession.addInput(camera)
        captureSession.startRunning()
    }
    
}



// --------- Helper Methods Provided For you ------------


// MARK: - Dismiss Button
extension ViewController {
    fileprivate func setupDismissButton() {
        dismissButton = UIButton(type: .system)
        dismissButton.setTitle("❌", for: UIControlState())
        dismissButton.titleLabel?.font = UIFont.systemFont(ofSize: 25.0)
        dismissButton.setTitleColor(UIColor.red, for: UIControlState())
        dismissButton.addTarget(self, action: #selector(dismiss1), for: .touchUpInside)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.alpha = 0.0
        view.addSubview(dismissButton)
        dismissButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -14.0).isActive = true
        dismissButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func dismiss1() {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func animateInDismissButton() {
        UIView.transition(with: dismissButton, duration: 2.5, options: .transitionCrossDissolve, animations: {
            self.dismissButton.alpha = 1.0
            }, completion: nil)
    }
    
}

// MARK: - Found Treasure
extension ViewController {
    
    func animateInTreasure() {
        let frame = treasure.item.frame
        let image = treasure.image!
        foundImageView = UIImageView(image: image)
        foundImageView.alpha = 0.0
        foundImageView.frame = frame
        view.addSubview(foundImageView)
        
        UIView.animate(withDuration: 1.5, delay: 0.8, options: [], animations: {
            self.foundImageView.alpha = 1.0
            }, completion: nil)
    }
    
    func displayDiscoverLabel() {
        let label = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "AvenirNext-Regular", size: 30.0)
        label.text = "Caught❗️"
        label.numberOfLines = 1
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.white
        label.alpha = 0.0
        
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 50.0).isActive = true
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 14.0).isActive = true
        label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -14.0).isActive = true
        
        label.center.x -= 800
        label.alpha = 1.0
        
        UIView.animate(withDuration: 1.5, delay: 0.5, usingSpringWithDamping: 0.8, initialSpringVelocity: 4.0, options: [], animations: {
            label.center.x = self.view.center.x
            }, completion: nil)
    }
    
    func displayNameOfTreasure() {
        let label = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "AvenirNext-Regular", size: 45.0)
        label.text = treasure.name
        label.numberOfLines = 1
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.flatironBlueColor()
        label.alpha = 0.0
        
        view.addSubview(label)
        
        label.centerXAnchor.constraint(equalTo: foundImageView.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: foundImageView.bottomAnchor, constant: 14.0).isActive = true
        label.centerYAnchor.constraint(equalTo: foundImageView.centerYAnchor).isActive = false
        label.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        
        let originalCenterY = label.center.y
        label.center.y += 400
        label.alpha = 1.0
        
        UIView.animate(withDuration: 2.5, delay: 0.5, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: [], animations: {
            label.center.y = originalCenterY
            }, completion: nil)
    }
}


// MARK: - Spring and Fade Animations
extension CALayer {
    
    func springToMiddle(withDuration duration: CFTimeInterval, damping: CGFloat, inView view: UIView) {
        let springX = CASpringAnimation(keyPath: "position.x")
        springX.damping = damping
        springX.fromValue = self.center.x
        springX.toValue = view.frame.midX
        springX.duration = duration
        self.add(springX, forKey: nil)
        
        let springY = CASpringAnimation(keyPath: "position.y")
        springY.damping = damping
        springY.fromValue = self.center.y
        springY.toValue = view.frame.midY
        springY.duration = duration
        self.add(springY, forKey: nil)
    }
    
    func centerInView(_ view: UIView) {
        self.center = CGPoint(x: view.frame.midX, y: view.frame.midY)
    }
    
    func fadeOutWithDuration(_ duration: CFTimeInterval) {
        let fadeOut = CABasicAnimation(keyPath: "opacity")
        //fadeOut.delegate = self
        fadeOut.duration = duration
        fadeOut.autoreverses = false
        fadeOut.fromValue = 1.0
        fadeOut.toValue = 0.6
        fadeOut.fillMode = kCAFillModeBoth
        fadeOut.isRemovedOnCompletion = false
        self.add(fadeOut, forKey: "myanimation")
    }
    
}

// MARK: - Center Point to CALayer
extension CALayer {
    
    var center: CGPoint {
        get {
            return CGPoint(x: self.frame.midX, y: self.frame.midY)
        }
        
        set {
            self.frame.origin.x = newValue.x - (self.frame.size.width / 2)
            self.frame.origin.y = newValue.y - (self.frame.size.height / 2)
        }
    }
    
    var width: CGFloat {
        return self.bounds.width
    }
    
    var height: CGFloat {
        return self.bounds.height
    }
    
    var origin: CGPoint {
        return CGPoint(x: self.center.x - (self.width / 2), y: self.center.y - (self.height / 2))
    }
    
}

// MARK: - CGPoint Functions
extension CGPoint {
    
    func isInRangeOfTreasure(_ treasure: CGPoint) -> Bool {
        return true
    }
    
}




