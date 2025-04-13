//
//  ViewController.swift
//  Barcode
//
//  Created by Angel Ricardo Nieto Garcia on 4/12/25.
//

import UIKit
import BarcodeScannerSDK
import AVFoundation

class ViewController: UIViewController {
    
    var barcodeManager: BarcodeScannerSDKManager?
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var barcodeOutputLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        barcodeManager = BarcodeScannerSDKManager()
        let allowedBarcodes = [AVMetadataObject.ObjectType.upce,
                                       AVMetadataObject.ObjectType.code39,
                                       AVMetadataObject.ObjectType.code39Mod43,
                                       AVMetadataObject.ObjectType.ean13,
                                       AVMetadataObject.ObjectType.ean8,
                                       AVMetadataObject.ObjectType.code93,
                                       AVMetadataObject.ObjectType.code128,
                                       AVMetadataObject.ObjectType.pdf417,
                                       AVMetadataObject.ObjectType.qr,
                                       AVMetadataObject.ObjectType.aztec
                ]
        
        let configuration: BarcodeConfiguration = [.playSound, .vibration, .displayBoundingBox]

        barcodeManager?.startUpdates(view: self.previewView,
                                     configuration:configuration,
                                     boundingBoxColor: UIColor.blue,
                                     codeTypes: allowedBarcodes,
                                        handler: {(stringValue: String?, error: Error?) in
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

