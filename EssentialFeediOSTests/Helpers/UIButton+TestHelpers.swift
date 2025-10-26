//
//  UIButton+TestHelpers.swift
//  EssentialFeed
//
//  Created by Mukesh Kondreddy on 26/10/25.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
