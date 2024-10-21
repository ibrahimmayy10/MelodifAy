//
//  BottomSheetPresentationController.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 20.10.2024.
//

import Foundation
import UIKit

class BottomSheetPresentationController: UIPresentationController {
    
    var dimmingView: UIView!
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        return CGRect(x: 0, y: containerView.bounds.height * 0.6, width: containerView.bounds.width, height: containerView.bounds.height * 0.4)
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        
        dimmingView = UIView(frame: containerView.bounds)
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        dimmingView.alpha = 0.0
        
        containerView.addSubview(dimmingView)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        }, completion: { _ in
            self.dimmingView.removeFromSuperview()
        })
    }
}
