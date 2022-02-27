//
//  ViewController.swift
//  Test2
//
//  Created by Kee Kai Xun on 26/2/22.
//

import UIKit
import HealthKit
import SwiftUICharts
import SwiftUI

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let health = HealthKitData()
        health.authorizeHealthKit()
        sleep(2)
        health.latestRespiratoryRate()
        sleep(2)
        // Do any additional setup after loading the view.
        let labelRect = CGRect(x:50, y:200, width:200, height:100)
        let label = UILabel(frame:labelRect)
        label.text = "Respiratory Data"
        label.numberOfLines = 2
        view.addSubview(label)
        
        let msg = health.scenario1()
        sleep(2)
        let label1rect = CGRect(x:50, y:350, width:200, height:100)
        
        let label1 = UILabel(frame:label1rect)
        
        label1.text = msg
            
        label.numberOfLines = 2
        view.addSubview(label1)
        
        let msg2 = health.scenario2()
        
        
        let label2rect = CGRect(x:50, y:500, width:400, height:100)
        
        let label2 = UILabel(frame:label2rect)
        
        label2.text = msg2
            
        label.numberOfLines = 2
        view.addSubview(label2)
        
    }
    
}




