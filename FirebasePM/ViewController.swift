//
//  ViewController.swift
//  FirebasePM
//
//  Created by Kamil Tustanowski on 11.07.2017.
//  Copyright © 2017 Kamil Tustanowski. All rights reserved.
//

import UIKit
import FirebasePerformance

class ViewController: UIViewController {

    fileprivate var preparingHomeTrace: Trace?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (UIApplication.shared.delegate as? AppDelegate)?.loadingHomeTrace?.stop()
        
        preparingHomeTrace = Performance.startTrace(name: "preparing home")
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        preparingHomeTrace?.stop()
        (UIApplication.shared.delegate as? AppDelegate)?.applicationStartTrace?.stop()
    }

}

