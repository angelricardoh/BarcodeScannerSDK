//
//  ViewController.swift
//  Barcode
//
//  Created by Angel Ricardo Nieto Garcia on 4/12/25.
//

import UIKit
import BarcodeScannerSDK

class ViewController: UIViewController {
    
    var barcodeManager: BarcodeScannerSDKManager?
    @IBOutlet weak var previewView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("viewDidLoad")
        barcodeManager = BarcodeScannerSDKManager()
        barcodeManager?.startUpdates(view: self.previewView)
    }
}

