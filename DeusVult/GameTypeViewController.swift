//
//  GameTypeViewController.swift
//  DeusVult
//
//  Created by Paweł Szudrowicz on 14.05.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import UIKit

class GameTypeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cruscadeButtonTapped(sender:UIButton!) {
        let mapViewController = self.storyboard!.instantiateViewController(withIdentifier: "mapViewController")
        self.present(mapViewController, animated: true, completion: nil)
    }

    @IBAction func historyButtonTapped(sender:UIButton!) {
        let mapViewController = self.storyboard!.instantiateViewController(withIdentifier: "mapViewController")
        self.present(mapViewController, animated: true, completion: nil)
    }
}
