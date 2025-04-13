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
    @IBOutlet weak var barcodeOutputLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        barcodeManager = BarcodeScannerSDKManager()
        barcodeManager?.startUpdates(view: self.previewView, handler: {(stringValue: String?, error: Error?) in
            if let localStringValue = stringValue {
                DispatchQueue.main.async {
                    self.barcodeOutputLabel.text = localStringValue
                }
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        barcodeManager?.restartUpdates()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        barcodeManager?.stopUpdates()
    }
    
    @IBAction func restart(_ sender: Any) {
        barcodeManager?.restartUpdates()
    }
}

