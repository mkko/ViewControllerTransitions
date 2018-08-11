//
//  TransparentViewController.swift
//  ViewControllerTransitions
//
//  Created by Mikko Välimäki on 2018-08-11.
//  Copyright © 2018 Mikko. All rights reserved.
//

import UIKit

class TransparentViewController: UIViewController {

    @IBOutlet weak var pushButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        //self.parent?.view.backgroundColor = .white
        self.navigationController?.delegate = self

        if let c = self.navigationController?.viewControllers.count, c > 1 {
            let title = pushButton.title(for: .normal)!
            pushButton.setTitle("\(title) (\(c))", for: .normal)
        } else {

            let layer = CAGradientLayer()
            layer.frame = self.view.frame
            layer.colors = [
                UIColor(hue: 82/360, saturation: 32/100, brightness: 96/100, alpha: 1),
                UIColor(hue: 102/360, saturation: 28/100, brightness: 79/100, alpha: 1)
                ]
                .map { $0.cgColor }

            UIGraphicsBeginImageContext(self.view.frame.size)
            layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()

            self.parent?.view.backgroundColor = UIColor(patternImage: image)

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TransparentViewController: UINavigationControllerDelegate {

    public func navigationController(_ navigationController: UINavigationController,
                                     animationControllerFor operation: UINavigationControllerOperation,
                                     from fromVC: UIViewController,
                                     to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TransparentPushAnimator(operation: operation)
    }
}

