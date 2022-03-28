//
//  CategoriesViewController.swift
//  ShoppingCiscoKurnosov
//
//  Created by Алексей Курносов on 23.03.2022.
//

import UIKit

protocol PrepareDropTargetDelegate: AnyObject {
    func setPreparedForDropEnabled(_ enabled: Bool)
}

class CategoriesViewController:
    UIViewController,
    CategoriesView,
    PrepareDropTargetDelegate,
    UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var itemsCollectionView: UICollectionView?
    @IBOutlet weak var categoriesCollectionView: UICollectionView?
    @IBOutlet weak var basketButtonCollectionView: UICollectionView?
    @IBOutlet weak var basketButton: UIButton?
    @IBOutlet weak var basketBadgeLabel: UILabel?
    
    @IBOutlet weak var basketYOffset: NSLayoutConstraint?
    @IBOutlet weak var basketXOffset: NSLayoutConstraint?
    
    
    lazy private var presenter: CategoriesPresenter = {
        let service = CategoriesService()
        let persistenceService = CoreDataService()
        
        let presenter = CategoriesPresenter(
            view: self,
            service: service,
            persistenceService: persistenceService
        )
        
        return presenter
    }()
    
    private let itemsCollectionHandler = ItemsCollectionHandler()
    private let categoriesCollectionHandler = CategoriesCollectionHandler()
    private var basketTargetCollectionHandler: BasketTargetCollectionHandler?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureViews()
        configureViewHandlers()
        configureGestures()
        
        presenter.requestData()
    }
    
    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        
        alignBasket(fromScratch: true)
        
        adjustPopoverArrowDirections()
    }
    
    
    // MARK: - Configuring
    
    private func configureViews() {
        basketBadgeLabel?.layer.cornerRadius = 10
        basketBadgeLabel?.clipsToBounds = true
    }
    
    private func configureViewHandlers() {
        if let itemsCollectionView = itemsCollectionView {
            itemsCollectionHandler.configureCollectionView(itemsCollectionView)
            itemsCollectionHandler.prepareDropTargetDelegate = self
        }
        
        if let categoryCollectionView = categoriesCollectionView {
            categoriesCollectionHandler.configureCollectionView(categoryCollectionView)
            categoriesCollectionHandler.presenter = presenter
        }
        
        if let basketButtonCollectionView = basketButtonCollectionView {
            basketTargetCollectionHandler = .init(
                presenter: presenter,
                collectionView: basketButtonCollectionView
            )
        }
    }
    
    func configureGestures() {
        if let itemsCollectionView = itemsCollectionView {
            let leftScrollMainHorizontal = UISwipeGestureRecognizer(
                target: self,
                action: #selector(swipeMainCollection(_:))
            )
            
            let rightScrollMainHorizontal = UISwipeGestureRecognizer(
                target: self,
                action: #selector(swipeMainCollection(_:))
            )
            
            leftScrollMainHorizontal.direction = .left
            rightScrollMainHorizontal.direction = .right
            
            itemsCollectionView.addGestureRecognizer(leftScrollMainHorizontal)
            itemsCollectionView.addGestureRecognizer(rightScrollMainHorizontal)
        }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(dragBasket(_:)))
        basketButton?.addGestureRecognizer(panGesture)
        
        basketButton?.addTarget(self, action: #selector(basketButtonClick), for: .touchUpInside)
    }
    
    
    // MARK: - CategoriesView
    
    func showCategories(list: [Category]) {
        categoriesCollectionHandler.categories = list
        
        DispatchQueue.main.async {
            self.categoriesCollectionView?.reloadData()
        }
    }
    
    func showItems(
        list: [Item],
        color: UIColor,
        animation: PagingAnimation?
    ) {
        itemsCollectionHandler.items = list
        itemsCollectionHandler.color = color
        
        DispatchQueue.main.async {
            if let animation = animation {
                self.turnPage(animation: animation)
            }
            else {
                self.itemsCollectionView?.reloadData()
            }
        }
    }
    
    func turnPage(animation: PagingAnimation) {
        var firstAction = moveScreenLeft
        var secondAction = moveScreenRight
        
        if PagingAnimation.left == animation {
            firstAction = moveScreenRight
            secondAction = moveScreenLeft
        }
        
        DispatchQueue.main.async {
            UIView.animate(
                withDuration: 0.1,
                animations: {
                    firstAction()
                }
            ) { res in
                self.itemsCollectionView?.reloadData()
                secondAction()
                UIView.animate(
                    withDuration: 0.1,
                    delay: 0.1,
                    animations: {
                        self.moveScreenCenter()
                    }
                )
            }
        }
    }
    
    private func moveScreenLeft() {
        itemsCollectionView?.transform = .init(translationX: -.screenWidth, y: 0)
    }
    
    private func moveScreenRight() {
        itemsCollectionView?.transform = .init(translationX: .screenWidth, y: 0)
    }
    
    private func moveScreenCenter() {
        itemsCollectionView?.transform = .identity
    }
    
    func setSelectedCategory(selectedNumber: Int) {
        categoriesCollectionHandler.selectedNumber = selectedNumber
    }
    
    func showBasketBagdeNumber(_ number: Int) {
        DispatchQueue.main.async {
            self.basketBadgeLabel?.isHidden = (number <= 0)
            
            self.basketBadgeLabel?.text = "\(number)"
        }
    }
    
    private var popoverController: UIPopoverPresentationController?
    func showBasket(isVisible: Bool) {
        DispatchQueue.main.async {
            
            if isVisible {
                let popover = BasketViewController(nibName: "BasketViewController", bundle: nil)
                popover.presenter = self.presenter
                popover.modalPresentationStyle = .popover
                
                guard let popoverController = popover.popoverPresentationController else {
                    return
                }
                
                self.popoverController = popoverController
                
                popoverController.delegate = self
                self.adjustPopoverArrowDirections()
                
                if let basketButton = self.basketButton {
                    popoverController.sourceView = basketButton
                }
                
                self.present(popover, animated: true)
            }
            else {
                self.dismiss(animated: true)
            }
        }
    }
    
    private func adjustPopoverArrowDirections() {
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            popoverController?.permittedArrowDirections = [.left, .right]
        default:
            popoverController?.permittedArrowDirections = [.up, .down]
        }
    }
    
    
    // MARK: - PrepareDropTargetDelegate
    
    func setPreparedForDropEnabled(_ enabled: Bool) {
        basketButtonCollectionView?.isUserInteractionEnabled = enabled
        basketButton?.isUserInteractionEnabled = !enabled
    }
    
    
    // MARK: - UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    // MARK: - swipe main screen
    
    @objc func swipeMainCollection(_ sender:UISwipeGestureRecognizer) {
        switch sender.direction {
        case .right:
            presenter.showPrevPage()
        case .left:
            presenter.showNextPage()
        default:
            break
        }
    }
    
    
    // MARK: - basket button handling
    
    @objc private func basketButtonClick() {
        presenter.showBasket(isVisible: true)
    }
    
    @objc private func dragBasket(_ sender: UIPanGestureRecognizer){
        let translation = sender.translation(in: view)
        
        guard sender.state != .ended
            && sender.state != .cancelled
            && sender.state != .failed
        else {
            alignBasket()
            return
        }
        
        basketXOffset?.constant -= translation.x
        basketYOffset?.constant -= translation.y
        
        sender.setTranslation(CGPoint.zero, in: view)
    }
    
    private func alignBasket(fromScratch: Bool = false) {
        guard let basketButton = basketButton else {
            return
        }
        
        let xConstant: CGFloat
        let yConstant: CGFloat
        
        if basketButton.center.x < UIScreen.main.bounds.width / 2, !fromScratch {
            xConstant = UIScreen.main.bounds.width
                - view.safeAreaInsets.left
                - view.safeAreaInsets.right
                - basketButton.frame.width
                - 15
        }
        else {
            xConstant = 15
        }
        
        if basketButton.center.y < UIScreen.main.bounds.height / 2, !fromScratch {
            yConstant = UIScreen.main.bounds.height
                - basketButton.frame.height
                - view.safeAreaInsets.top
                - view.safeAreaInsets.bottom
                - 30
        }
        else {
            yConstant = 15
        }
        
        basketXOffset?.constant = xConstant
        basketYOffset?.constant = yConstant
    }
}

extension UIViewController: CanShowAlert {
    func showAlert(text: String, okCallback: (() -> Void)?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: nil,
                message: text,
                preferredStyle: .alert
            )
            
            alert.addAction(
                UIAlertAction(
                    title: "OK",
                    style: .default,
                    handler: { _ in
                        okCallback?()
                    }
                )
            )
            
            self.present(alert, animated: true)
        }
    }
}
