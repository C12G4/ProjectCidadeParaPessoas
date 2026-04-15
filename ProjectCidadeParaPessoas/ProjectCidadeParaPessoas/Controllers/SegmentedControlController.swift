//
//  SegmentedControlController.swift
//  ProjectCidadeParaPessoas
//
//  Created by Vinicius Marques on 13/04/26.
//

import Foundation
import UIKit


class SegmentedControl: UISegmentedControl {
    override func layoutSubviews() {
        super.layoutSubviews()
        //background
        layer.cornerRadius = bounds.height/2
        layer.backgroundColor = UIColor.purple.cgColor

        //foreground
        let foregroundIndex = numberOfSegments
        if subviews.indices.contains(foregroundIndex), let foregroundImageView = subviews[foregroundIndex] as? UIImageView {
            foregroundImageView.bounds = foregroundImageView.bounds.insetBy(dx: CGFloat(foregroundIndex), dy: CGFloat(foregroundIndex))
            foregroundImageView.image = UIImage(color: .systemPink)
            foregroundImageView.layer.removeAnimation(forKey: "SelectionBounds")
            foregroundImageView.layer.masksToBounds = true
            foregroundImageView.layer.cornerRadius = foregroundImageView.bounds.height/2
        }
    }
}

//creates a UIImage given a UIColor
extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
