//
//  AnimationHelper.swift
//  MelodifAy
//
//  Created by İbrahim Ay on 28.11.2024.
//

import UIKit

class AnimationHelper {
    static func animateCell(cell: UIView, in view: UIView, completion: @escaping () -> Void) {
        let originalFrame = cell.convert(cell.bounds, to: nil)
        let zoomedFrame = CGRect(x: originalFrame.origin.x - 20, y: originalFrame.origin.y - 20, width: originalFrame.size.width + 40, height: originalFrame.size.height + 40)
        
        let snapshot = cell.snapshotView(afterScreenUpdates: false)
        snapshot?.frame = originalFrame
        view.addSubview(snapshot!)
        
        UIView.animate(withDuration: 0.3, animations: {
            snapshot?.frame = zoomedFrame
            snapshot?.alpha = 0
        }, completion: { _ in
            snapshot?.removeFromSuperview()
            completion()
        })
    }
}
