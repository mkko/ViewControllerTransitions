//
//  TransparentPushAnimator.swift
//  ViewControllerTransitions
//
//  Created by Mikko Välimäki on 2018-08-11.
//  Copyright © 2018 Mikko. All rights reserved.
//

import UIKit

open class TransparentPushAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    fileprivate class FrameView: UIView {

        class ShadowView: UIView {
            override class var layerClass: AnyClass {
                return CAGradientLayer.self
            }
        }

        private let shadowEdge = ShadowView()

        var shadowOpacity: CGFloat {
            get { return shadowEdge.alpha }
            set { shadowEdge.alpha = newValue }
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) not supported")
        }

        func setup() {
            let layer = shadowEdge.layer as! CAGradientLayer

            layer.colors = [UIColor.clear.cgColor, UIColor(white: 0, alpha: 0.07).cgColor]
            layer.startPoint = CGPoint(x: 0, y: 0)
            layer.endPoint = CGPoint(x: 1, y: 0)

            shadowEdge.translatesAutoresizingMaskIntoConstraints  = false
            self.addSubview(shadowEdge)

            NSLayoutConstraint.activate([
                shadowEdge.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                shadowEdge.widthAnchor.constraint(equalToConstant: 16),
                shadowEdge.topAnchor.constraint(equalTo: self.topAnchor),
                shadowEdge.bottomAnchor.constraint(equalTo: self.bottomAnchor)
                ])
        }

        override func layoutSubviews() {
            self.bringSubview(toFront: shadowEdge)
        }
    }

    private let operation: UINavigationControllerOperation

    private let isInteractive: Bool

    public init(operation: UINavigationControllerOperation, isInteractive: Bool) {
        self.operation = operation
        self.isInteractive = isInteractive
    }

    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }

    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let vc1 = transitionContext.viewController(
            forKey: operation == .push ? .from : .to)
        let vc2 = transitionContext.viewController(
            forKey: operation == .push ? .to : .from)

        guard let viewController1 = vc1, let viewController2 = vc2 else {
            return
        }

        let containerView = UIView(frame: transitionContext.containerView.bounds)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let clippingView = FrameView(frame: containerView.frame)
        clippingView.clipsToBounds = true

        containerView.addSubview(viewController1.view)
        clippingView.addSubview(containerView)
        transitionContext.containerView.addSubview(clippingView)

        transitionContext.containerView.addSubview(viewController2.view)

        let f2 = viewController2.view.frame
        let f1 = CGRect(x: f2.maxX, y: f2.minY, width: f2.width, height: f2.height)

        viewController2.view.frame = operation == .push ? f1 : f2

        let shift: CGFloat = 110.0

        let c1 = clippingView.frame
        let c2 = CGRect(
            x: clippingView.frame.minX - shift,
            y: clippingView.frame.minY,
            width: shift,
            height: clippingView.frame.height)

        clippingView.frame = (operation == .push ? c1 : c2)
        clippingView.layoutIfNeeded()
        clippingView.shadowOpacity = 1.0

        let duration = self.transitionDuration(using: transitionContext)
        let options: UIViewAnimationOptions = self.isInteractive
            ? [.curveLinear]
            : [.curveEaseInOut]
        UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
            clippingView.frame = (self.operation == .push ? c2 : c1)
            clippingView.shadowOpacity = 0
            clippingView.layoutIfNeeded()

            viewController2.view.frame = self.operation == .push ? f2 : f1
        }, completion: { _ in
            let didComplete = !transitionContext.transitionWasCancelled
            if didComplete {
                // If we did a pop, clean up view hierarchy.
                clippingView.removeFromSuperview()
                viewController1.view.removeFromSuperview()

                if self.operation == .pop {
                    transitionContext.containerView.addSubview(viewController1.view)
                }
            }

            transitionContext.completeTransition(didComplete)

        })
    }
}

class TransparentNavigationController: UINavigationController {

    private var interactionController: UIPercentDrivenInteractiveTransition?

    private var edgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self

        self.edgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(pan(_:)))
        self.edgePanGestureRecognizer.edges = .left
        self.edgePanGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(edgePanGestureRecognizer)
    }

    var vc: UIViewController?

    @objc func pan(_ sender: UIScreenEdgePanGestureRecognizer) {
        guard let view = sender.view else {
            return
        }

        let percentComplete = sender.translation(in: view).x / view.bounds.width

        switch sender.state {
        case .began:
            self.interactionController = UIPercentDrivenInteractiveTransition()
            vc = popViewController(animated: true)
        case .changed:
            interactionController?.update(percentComplete)
        case .ended:
            if percentComplete >= 0.5 && sender.state != .cancelled {
                interactionController?.finish()
            } else {
                interactionController?.cancel()
            }
            interactionController = nil
        default:
            break
        }
    }
}

extension TransparentNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let isInteractive = (self.interactionController != nil)
        return TransparentPushAnimator(operation: operation, isInteractive: isInteractive)
    }

    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
}

extension TransparentNavigationController: UIGestureRecognizerDelegate {

}
