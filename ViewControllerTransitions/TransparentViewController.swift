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

        if let c = self.navigationController?.viewControllers.count, c > 1 {
            let title = pushButton.title(for: .normal)!
            pushButton.setTitle("\(title) (\(c))", for: .normal)
        } else {
            // Setup the first view controller in the stack.

            let layer = CAGradientLayer()
            layer.frame = self.view.frame
            layer.colors = [
                (h: 200, s: 70, b: 85, a: 1),
                (h: 160, s: 70, b: 85, a: 1)
                ]
                .map { UIColor(hue: $0.h/360, saturation: $0.s/100, brightness: $0.b/100, alpha: $0.a) }
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
