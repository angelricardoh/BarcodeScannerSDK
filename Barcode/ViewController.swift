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
        barcodeManager = BarcodeScannerSDKManager()
        barcodeManager?.startUpdates(view: self.previewView, handler: {(value: String?, error: Error?) in
            if let value = value {
                print(value)
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        barcodeManager?.restartUpdates()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        barcodeManager?.stopUpdates()
    }
}

