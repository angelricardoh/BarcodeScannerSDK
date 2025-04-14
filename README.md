# BarcodeScannerSDK

BarcodeScannerSDKManager is a barcode scanning interface that provides a simple API for starting, restarting, and stopping barcode detection in a given view. It leverages the AVCaptureSession to manage camera input and barcode recognition using AVMetadataObject.

Special thanks to:
Dejan Agostini from https://gitlab.com/agostini.tech/ATBarcodeScanner I took the source code as a reference on how to attach a bounding box to the camera view.
Paul Hudson from https://www.hackingwithswift.com/example-code/media/how-to-scan-a-barcode I use its ViewController as the baseline of my SDK public class.

## BarcodeScannerResultBlock
public typealias BarcodeScannerResultBlock = (_ result: String?, _ error: BarcodeError?) -> Void
A completion block that returns the result of a barcode scan.

result: The scanned barcode string, if any.
error: An optional error indicating failure reason.
Enums

## BarcodeError
public enum BarcodeError: Error {
    case notSupported
    case unexpected
}
Represents possible errors during barcode scanning.

.notSupported: Indicates that the current device or configuration does not support barcode scanning.
.unexpected: Indicates an unexpected internal error.
Structs

## BarcodeConfiguration
public struct BarcodeConfiguration: OptionSet {
    public let rawValue: Int
    public static let vibration = BarcodeConfiguration(rawValue: 1 << 0)
    public static let playSound = BarcodeConfiguration(rawValue: 1 << 1)
    public static let displayBoundingBox = BarcodeConfiguration(rawValue: 1 << 2)
}
A bitmask-based configuration for customizing scanner behavior.

vibration: Triggers device vibration on successful scan.
playSound: Plays a sound on successful scan.
displayBoundingBox: Shows bounding box around detected barcodes.

## Class: BarcodeScannerManager
public class BarcodeScannerManager

Methods
public func startUpdates(
    view: UIView,
    queue: DispatchQueue,
    configuration: BarcodeConfiguration,
    boundingBoxColor: UIColor = UIColor.red,
    codeTypes: [AVMetadataObject.ObjectType],
    handler: @escaping BarcodeScannerResultBlock
)
Begins barcode detection with the given configuration, queue and receives barcode updates via a handler.

Parameters:
view: The UIView where the camera preview will be displayed.
queue: The DispatchQueue used for callback execution.
configuration: Custom behavior configuration using BarcodeConfiguration.
boundingBoxColor: (Optional) Color for bounding box overlay. Default is .red.
codeTypes: List of supported barcode types (e.g., .qr, .ean13, etc.).
handler: Completion block to receive results or errors.

public func restartUpdates()
Restarts the barcode scanning session if it is currently stopped. You might want to use it in viewWillAppear(_ animated: Bool) or to restart the camera session after a barcode has been detected.

public func stopUpdates()
Stops the barcode scanning session if it is currently running. It can be used when the view will disappear viewWillDisappear(_ animated: Bool) when the view controller will be destroyed.


## Notes

In order to be able to ask camera permission to the user and be able to use the camera preview in the UIView is needed to add the following key to your Info.plist
<key>NSCameraUsageDescription</key>
<string>"Your justification for using camera in this app"</string>
All scanning is handled asynchronously on the provided queue.
If setupBoundingBox is enabled and a barcode is detected, a visual overlay will be drawn.
