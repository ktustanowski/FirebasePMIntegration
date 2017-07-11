//
//  ViewController.swift
//  FirebasePM
//
//  Created by Kamil Tustanowski on 11.07.2017.
//  Copyright © 2017 Kamil Tustanowski. All rights reserved.
//

import UIKit
import DurationReporter

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        DurationReporter.end(event: "Application start", action: "Loading Home")
        DurationReporter.begin(event: "Application start", action: "Preparing Home")
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        DurationReporter.end(event: "Application start", action: "Preparing Home")
        print(DurationReporter.generateReport()) /* needed to print the report - normally this would be handled differently 😉 */
    }

}

