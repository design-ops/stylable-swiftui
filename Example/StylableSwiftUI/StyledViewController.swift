//
//  StyledViewController.swift
//  StylableSwiftUI_Example
//
//  Created by Kerr Marin Miller on 22/06/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import SwiftUI
import StylableSwiftUI

final class StyledControllerContainer: UIViewControllerRepresentable {

    let stylistContainer: UIKitStyleContainer

    init(container: UIKitStyleContainer) {
        self.stylistContainer = container
    }

    func updateUIViewController(_ uiViewController: StyledController, context: Context) { }

    func makeUIViewController(context: Context) -> StyledController {
        return StyledController(container: self.stylistContainer)
    }
}

final class StyledController: UIViewController {

    let stylistContainer: UIKitStyleContainer

    init(container: UIKitStyleContainer) {
        self.stylistContainer = container
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let capsLabel = UILabel(frame: .zero)
        capsLabel.attributedText = NSAttributedString(string: "This is caps test",
                                                      attributes: self.stylistContainer.textAttributes(for: "uppercase"))

        let lowerCaseLabel = UILabel(frame: .zero)
        lowerCaseLabel.attributedText = NSAttributedString(string: "This is LowERcAsE test",
                                                           attributes: self.stylistContainer.textAttributes(for: "lowercase"))

        let stack = UIStackView(arrangedSubviews: [capsLabel, lowerCaseLabel])
        stack.translatesAutoresizingMaskIntoConstraints = true
        stack.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stack.frame = self.view.bounds
        stack.axis = .vertical
        self.view.addSubview(stack)
    }
}
