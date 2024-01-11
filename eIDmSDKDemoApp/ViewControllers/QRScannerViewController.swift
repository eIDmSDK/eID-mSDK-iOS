import UIKit
import AVFoundation

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    //barcode scanner
    private var session: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer!
    @IBOutlet private weak var scannerRectView: UIView!
    @IBOutlet private weak var previewHolderView: UIView!
    @IBOutlet private weak var noPersmissionsView: UIView!

    private let codeTypes = [
        AVMetadataObject.ObjectType.qr
    ]

    var completion: ((String?)->())?


    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        requestCameraAccess { [weak self] accessGranted in
            guard accessGranted else {
                return
            }

            self?.noPersmissionsView.isHidden = true

            // Set the captureDevice.
            let dev: AVCaptureDevice? = AVCaptureDevice.default(for: AVMediaType.video)

            guard let videoCaptureDevice = dev else {
                return
            }

            // Create a session object.
            let session = AVCaptureSession()
            self?.session = session

            // Create input object.
            let videoInput: AVCaptureDeviceInput?

            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                return
            }

            guard let videoInput = videoInput else {
                return
            }

            // Add input to the session.
            if (session.canAddInput(videoInput)) {
                session.addInput(videoInput)
            }

            // Create output object.
            let metadataOutput = AVCaptureMetadataOutput()

            // Add output to the session.
            if (session.canAddOutput(metadataOutput)) {
                session.addOutput(metadataOutput)

                // Send captured data to the delegate object via a serial queue.
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)

                // Set barcode types for which to scans
                metadataOutput.metadataObjectTypes = self?.codeTypes

            }

            // Add previewLayer and have it show the video data.
            let previewLayer = AVCaptureVideoPreviewLayer(session: session);
            previewLayer.frame = self?.view.layer.bounds ?? CGRect();
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill;
            self?.previewLayer = previewLayer
            self?.previewHolderView.layer.addSublayer(previewLayer);

            // Begin the capture session.
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.session?.startRunning()
            }
        }
    }

    private func setupUI() {
        navigationItem.title = "Naskenovať QR kód"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(cancelTapped))
    }

    private func requestCameraAccess(_ completion: @escaping (_ accessGranted: Bool) -> Void){
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .denied:
            completion(false)
        case .restricted, .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        default:
            completion(false)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // stop the capture session.
        session?.stopRunning()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutMask()
    }

    func layoutMask() {
        let maskLayer = self.subviewMaskLayer()
        let rect = CGRect(x: 25, y: 25, width: scannerRectView.frame.width-50, height: scannerRectView.frame.height-50)
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 20, height: 20))
        path.append(UIBezierPath(rect: scannerRectView.bounds))
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd;
        maskLayer.path = path.cgPath;
    }

    func subviewMaskLayer() -> CAShapeLayer {
        if let mask = scannerRectView.layer.mask as? CAShapeLayer {
            return mask
        }
        else {
            let mask = CAShapeLayer()
            scannerRectView.layer.mask = mask;
            return mask
        }
    }

    // MARK: - actions

    @objc private func cancelTapped() {
        session?.stopRunning()
        completion?(nil)
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Get the first object from the metadataObjects array.
        if let barcodeData = metadataObjects.first {
            // Turn it into machine readable code
            let barcodeReadable = barcodeData as? AVMetadataMachineReadableCodeObject;
            if let readableCode = barcodeReadable {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                session?.stopRunning()
                completion?(readableCode.stringValue)
            }
        }
    }
}
