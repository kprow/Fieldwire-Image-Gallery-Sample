//
//  UIView+Extension.swift
//  FieldwireImageGallery
//
//  Created by Andrew Koprowski on 10/15/24.
//

import UIKit

extension UIView {
    /// Programatically add subviews
    /// - Parameter subview: The view to be added.
    public func addAutoLayoutSubview(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
    }

    public static let spacing8: CGFloat = 8
}
