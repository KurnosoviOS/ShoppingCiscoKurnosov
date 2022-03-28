//
//  ToastViewController.swift
//  ShoppingCiscoKurnosov
//
//  Created by Алексей Курносов on 28.03.2022.
//

import UIKit

class ToastViewController: UIViewController {
    
    var text: String?
    var disappearCallback: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let label = UILabel()
        view.addSubview(label)
        view.backgroundColor = .tertiarySystemBackground.withAlphaComponent(0.8)
        
        label.text = text
        
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(
            [
                label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ]
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disappearCallback?()
    }
}

extension UIViewController {
    func showToast(
        text: String,
        timeout: TimeInterval,
        targetFrame: CGRect,
        disappearCallback: (() -> Void)? = nil
    ) {
        DispatchQueue.main.async {
            
            let popover = ToastViewController()
            popover.text = text
            popover.disappearCallback = disappearCallback
            popover.modalPresentationStyle = .popover
            
            guard let popoverController = popover.popoverPresentationController else {
                return
            }
            
            popoverController.delegate = self
            popoverController.permittedArrowDirections = []
            popover.preferredContentSize = targetFrame.size
            
            popoverController.sourceView = self.view
            popoverController.sourceRect = targetFrame
            
            self.present(popover, animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
                if popover.presentingViewController == self {
                    self.dismiss(animated: true)
                }
            }
        }
    }
}

extension UIViewController: UIPopoverPresentationControllerDelegate {
    
    public func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        return .none
    }
}
