//
//  CameraService.swift
//  PunjabAppNew
//
//  Created by pc on 16/12/2025.
//  Updated to include SwiftyCam integration (ViewController, Button, RecordButton).
//

import Foundation
import AVFoundation
import UIKit
import SwiftUI
import CoreMotion

// MARK: - Camera Service Adapter
class CameraService: NSObject, ObservableObject, SwiftyCamViewControllerDelegate, SwiftyCamButtonDelegate {
    @Published var capturedImage: UIImage?
    @Published var isPermissionGranted = false
    @Published var flashMode: SwiftyCamViewController.FlashMode = .off
    @Published var isRecording = false // Drives UI state for button animation
    
    weak var viewController: SwiftyCamViewController?
    
    override init() {
        super.init()
        checkPermission()
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.isPermissionGranted = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { self.isPermissionGranted = granted }
            }
        default:
            self.isPermissionGranted = false
        }
    }
    
    func capturePhoto() {
        viewController?.takePhoto()
    }
    
    func switchCamera() {
        viewController?.switchCamera()
    }
    
    func toggleFlash() {
        let newMode: SwiftyCamViewController.FlashMode = (flashMode == .off) ? .on : .off
        flashMode = newMode
        viewController?.flashMode = newMode
    }
    
    func retake() {
        capturedImage = nil
        viewController?.session.startRunning()
    }
    
    // MARK: - SwiftyCamButtonDelegate
    
    func buttonWasTapped() {
        capturePhoto()
    }
    
    func buttonDidBeginLongPress() {
        viewController?.startVideoRecording()
    }
    
    func buttonDidEndLongPress() {
        viewController?.stopVideoRecording()
    }
    
    func longPressDidReachMaximumDuration() {
        viewController?.stopVideoRecording()
    }
    
    func setMaxiumVideoDuration() -> Double {
        return 10.0 // Default 10s or whatever
    }
    
    // MARK: - SwiftyCamViewControllerDelegate
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        DispatchQueue.main.async {
            self.capturedImage = photo
        }
    }
    
    func swiftyCamSessionDidStartRunning(_ swiftyCam: SwiftyCamViewController) {
        // Ready
    }
    
    func swiftyCamSessionDidStopRunning(_ swiftyCam: SwiftyCamViewController) {
        // Stopped
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        DispatchQueue.main.async { self.isRecording = true }
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        DispatchQueue.main.async { self.isRecording = false }
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        print("Video recorded at \(url)")
        // TODO: Handle video output (save/display)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFailToRecordVideo error: Error) {
        print("Video record failed: \(error)")
        DispatchQueue.main.async { self.isRecording = false }
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didSwitchCameras camera: SwiftyCamViewController.CameraSelection) {
        print("Camera switched to \(camera)")
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {}
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat) {}
    
    func swiftyCamDidFailToConfigure(_ swiftyCam: SwiftyCamViewController) {}
    
    func swiftyCamNotAuthorized(_ swiftyCam: SwiftyCamViewController) {
        DispatchQueue.main.async { self.isPermissionGranted = false }
    }
}

// MARK: - SwiftyCam Source Code

// MARK: SwiftyCamViewControllerDelegate
public protocol SwiftyCamViewControllerDelegate: AnyObject {
    func swiftyCamSessionDidStartRunning(_ swiftyCam: SwiftyCamViewController)
    func swiftyCamSessionDidStopRunning(_ swiftyCam: SwiftyCamViewController)
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage)
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection)
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection)
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL)
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFailToRecordVideo error: Error)
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didSwitchCameras camera: SwiftyCamViewController.CameraSelection)
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint)
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat)
    func swiftyCamDidFailToConfigure(_ swiftyCam: SwiftyCamViewController)
    func swiftyCamNotAuthorized(_ swiftyCam: SwiftyCamViewController)
}

public extension SwiftyCamViewControllerDelegate {
    func swiftyCamSessionDidStopRunning(_ swiftyCam: SwiftyCamViewController) {}
    func swiftyCamSessionDidStartRunning(_ swiftyCam: SwiftyCamViewController) {}
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {}
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {}
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {}
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {}
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFailToRecordVideo error: Error) {}
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didSwitchCameras camera: SwiftyCamViewController.CameraSelection) {}
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {}
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat) {}
    func swiftyCamDidFailToConfigure(_ swiftyCam: SwiftyCamViewController) {}
    func swiftyCamNotAuthorized(_ swiftyCam: SwiftyCamViewController) {}
}

// MARK: SwiftyCamViewController
open class SwiftyCamViewController: UIViewController {

    public enum CameraSelection: String {
        case rear = "rear"
        case front = "front"
    }
    
    public enum FlashMode {
        var AVFlashMode: AVCaptureDevice.FlashMode {
            switch self {
                case .on: return .on
                case .off: return .off
                case .auto: return .auto
            }
        }
        case auto, on, off
    }

    public enum VideoQuality {
        case high, medium, low, resolution352x288, resolution640x480, resolution1280x720, resolution1920x1080, resolution3840x2160, iframe960x540, iframe1280x720
    }

    fileprivate enum SessionSetupResult {
        case success, notAuthorized, configurationFailed
    }

    public weak var cameraDelegate: SwiftyCamViewControllerDelegate?
    public var maximumVideoDuration : Double     = 0.0
    public var videoQuality : VideoQuality       = .high
    
    public var flashMode:FlashMode               = .off

    public var pinchToZoom                       = true
    public var maxZoomScale                         = CGFloat.greatestFiniteMagnitude
    public var tapToFocus                        = true
    public var lowLightBoost                     = true
    public var allowBackgroundAudio              = true
    public var doubleTapCameraSwitch            = true
    public var swipeToZoom                     = true
    public var swipeToZoomInverted             = false
    public var defaultCamera                   = CameraSelection.rear
    public var shouldUseDeviceOrientation      = false {
        didSet {
            orientation.shouldUseDeviceOrientation = shouldUseDeviceOrientation
        }
    }
    public var allowAutoRotate                = false
    public var videoGravity                   : SwiftyCamVideoGravity = .resizeAspect
    public var audioEnabled                   = true
    public var shouldPrompToAppSettings       = true
    public var outputFolder: String           = NSTemporaryDirectory()
    
    fileprivate(set) public var pinchGesture  : UIPinchGestureRecognizer!
    fileprivate(set) public var panGesture    : UIPanGestureRecognizer!

    private(set) public var isVideoRecording      = false
    private(set) public var isSessionRunning     = false
    private(set) public var currentCamera        = CameraSelection.rear

    public let session                           = AVCaptureSession()
    fileprivate let sessionQueue                 = DispatchQueue(label: "session queue", attributes: [])
    fileprivate var zoomScale                    = CGFloat(1.0)
    fileprivate var beginZoomScale               = CGFloat(1.0)
    fileprivate var isCameraTorchOn              = false
    fileprivate var setupResult                  = SessionSetupResult.success
    fileprivate var backgroundRecordingID        : UIBackgroundTaskIdentifier? = nil
    fileprivate var videoDeviceInput             : AVCaptureDeviceInput!
    fileprivate var movieFileOutput              : AVCaptureMovieFileOutput?
    fileprivate var photoFileOutput              : AVCaptureStillImageOutput?
    fileprivate var videoDevice                  : AVCaptureDevice?
    fileprivate var previewLayer                 : PreviewView!
    fileprivate var flashView                    : UIView?
    fileprivate var previousPanTranslation       : CGFloat = 0.0
    fileprivate var orientation                  : Orientation = Orientation()
    fileprivate var sessionRunning               = false
    public var videoCodecType: AVVideoCodecType? = nil

    override open var shouldAutorotate: Bool {
        return allowAutoRotate
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        previewLayer = PreviewView(frame: view.frame, videoGravity: videoGravity)
        previewLayer.center = view.center
        view.addSubview(previewLayer)
        view.sendSubviewToBack(previewLayer)
        addGestureRecognizers()
        previewLayer.session = session
        
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized: break
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { [unowned self] granted in
                if !granted { self.setupResult = .notAuthorized }
                self.sessionQueue.resume()
            })
        default: setupResult = .notAuthorized
        }
        sessionQueue.async { [unowned self] in self.configureSession() }
    }

    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        if(shouldAutorotate){ layer.videoOrientation = orientation }
        else { layer.videoOrientation = .portrait }
        previewLayer.frame = self.view.bounds
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let connection =  self.previewLayer?.videoPreviewLayer.connection  {
            let currentDevice: UIDevice = UIDevice.current
            let orientation: UIDeviceOrientation = currentDevice.orientation
            let previewLayerConnection : AVCaptureConnection = connection
            if previewLayerConnection.isVideoOrientationSupported {
                switch (orientation) {
                case .portrait: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                case .landscapeRight: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                case .landscapeLeft: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                case .portraitUpsideDown: updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                default: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                }
            }
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(captureSessionDidStartRunning), name: .AVCaptureSessionDidStartRunning, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(captureSessionDidStopRunning),  name: .AVCaptureSessionDidStopRunning,  object: nil)
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldUseDeviceOrientation { orientation.start() }
        setBackgroundAudioPreference()
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
                DispatchQueue.main.async { self.previewLayer.videoPreviewLayer.connection?.videoOrientation = self.orientation.getPreviewLayerOrientation() }
            case .notAuthorized:
                if self.shouldPrompToAppSettings == true { self.promptToAppSettings() }
                else { self.cameraDelegate?.swiftyCamNotAuthorized(self) }
            case .configurationFailed:
                DispatchQueue.main.async { self.cameraDelegate?.swiftyCamDidFailToConfigure(self) }
            }
        }
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        sessionRunning = false
        if self.isSessionRunning == true {
            self.session.stopRunning()
            self.isSessionRunning = false
        }
        disableFlash()
        if shouldUseDeviceOrientation { orientation.stop() }
    }

    public func takePhoto() {
        guard let device = videoDevice else { return }
        if device.hasFlash == true && flashMode != .off {
            changeFlashSettings(device: device, mode: flashMode)
            capturePhotoAsyncronously(completionHandler: { (_) in })
        }else{
            if device.isFlashActive == true {
                changeFlashSettings(device: device, mode: flashMode)
            }
            capturePhotoAsyncronously(completionHandler: { (_) in })
        }
    }

    public func startVideoRecording() {
        guard sessionRunning == true else { return }
        guard let movieFileOutput = self.movieFileOutput else { return }
        if currentCamera == .rear && flashMode == .on { enableFlash() }
        if currentCamera == .front && flashMode == .on  {
            flashView = UIView(frame: view.frame)
            flashView?.backgroundColor = UIColor.white
            flashView?.alpha = 0.85
            previewLayer.addSubview(flashView!)
        }
        let previewOrientation = previewLayer.videoPreviewLayer.connection!.videoOrientation
        sessionQueue.async { [unowned self] in
            if !movieFileOutput.isRecording {
                if UIDevice.current.isMultitaskingSupported {
                    self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                }
                let movieFileOutputConnection = self.movieFileOutput?.connection(with: AVMediaType.video)
                if self.currentCamera == .front { movieFileOutputConnection?.isVideoMirrored = true }
                movieFileOutputConnection?.videoOrientation = self.orientation.getVideoOrientation() ?? previewOrientation
                let outputFileName = UUID().uuidString
                let outputFilePath = (self.outputFolder as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
                movieFileOutput.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
                self.isVideoRecording = true
                DispatchQueue.main.async { self.cameraDelegate?.swiftyCam(self, didBeginRecordingVideo: self.currentCamera) }
            } else {
                movieFileOutput.stopRecording()
            }
        }
    }

    public func stopVideoRecording() {
        if self.isVideoRecording == true {
            self.isVideoRecording = false
            movieFileOutput!.stopRecording()
            disableFlash()
            if currentCamera == .front && flashMode == .on && flashView != nil {
                UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: {
                    self.flashView?.alpha = 0.0
                }, completion: { (_) in
                    self.flashView?.removeFromSuperview()
                })
            }
            DispatchQueue.main.async { self.cameraDelegate?.swiftyCam(self, didFinishRecordingVideo: self.currentCamera) }
        }
    }

    public func switchCamera() {
        guard isVideoRecording != true else { return }
        guard session.isRunning == true else { return }
        switch currentCamera {
        case .front: currentCamera = .rear
        case .rear: currentCamera = .front
        }
        session.stopRunning()
        sessionQueue.async { [unowned self] in
            for input in self.session.inputs { self.session.removeInput(input ) }
            self.addInputs()
            DispatchQueue.main.async { self.cameraDelegate?.swiftyCam(self, didSwitchCameras: self.currentCamera) }
            self.session.startRunning()
        }
        disableFlash()
    }

    fileprivate func configureSession() {
        guard setupResult == .success else { return }
        currentCamera = defaultCamera
        session.beginConfiguration()
        configureVideoPreset()
        addVideoInput()
        addAudioInput()
        configureVideoOutput()
        configurePhotoOutput()
        session.commitConfiguration()
    }

    fileprivate func addInputs() {
        session.beginConfiguration()
        configureVideoPreset()
        addVideoInput()
        addAudioInput()
        session.commitConfiguration()
    }

    fileprivate func configureVideoPreset() {
        if currentCamera == .front {
            session.sessionPreset = AVCaptureSession.Preset(rawValue: videoInputPresetFromVideoQuality(quality: .high))
        } else {
            if session.canSetSessionPreset(AVCaptureSession.Preset(rawValue: videoInputPresetFromVideoQuality(quality: videoQuality))) {
                session.sessionPreset = AVCaptureSession.Preset(rawValue: videoInputPresetFromVideoQuality(quality: videoQuality))
            } else {
                session.sessionPreset = AVCaptureSession.Preset(rawValue: videoInputPresetFromVideoQuality(quality: .high))
            }
        }
    }

    fileprivate func addVideoInput() {
        switch currentCamera {
        case .front: videoDevice = SwiftyCamViewController.deviceWithMediaType(AVMediaType.video.rawValue, preferringPosition: .front)
        case .rear: videoDevice = SwiftyCamViewController.deviceWithMediaType(AVMediaType.video.rawValue, preferringPosition: .back)
        }
        if let device = videoDevice {
            do {
                try device.lockForConfiguration()
                if device.isFocusModeSupported(.continuousAutoFocus) {
                    device.focusMode = .continuousAutoFocus
                    if device.isSmoothAutoFocusSupported { device.isSmoothAutoFocusEnabled = true }
                }
                if device.isExposureModeSupported(.continuousAutoExposure) { device.exposureMode = .continuousAutoExposure }
                if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) { device.whiteBalanceMode = .continuousAutoWhiteBalance }
                if device.isLowLightBoostSupported && lowLightBoost == true { device.automaticallyEnablesLowLightBoostWhenAvailable = true }
                device.unlockForConfiguration()
            } catch { print("[SwiftyCam]: Error locking configuration") }
        }
        do {
            if let videoDevice = videoDevice {
                let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                if session.canAddInput(videoDeviceInput) {
                    session.addInput(videoDeviceInput)
                    self.videoDeviceInput = videoDeviceInput
                } else {
                    setupResult = .configurationFailed
                    session.commitConfiguration()
                    return
                }
            }
        } catch {
            setupResult = .configurationFailed
            return
        }
    }

    fileprivate func addAudioInput() {
        guard audioEnabled == true else { return }
        do {
            if let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio){
                let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
                if session.canAddInput(audioDeviceInput) { session.addInput(audioDeviceInput) }
            }
        } catch { print("[SwiftyCam]: Should not happen") }
    }

    fileprivate func configureVideoOutput() {
        let movieFileOutput = AVCaptureMovieFileOutput()
        if self.session.canAddOutput(movieFileOutput) {
            self.session.addOutput(movieFileOutput)
            if let connection = movieFileOutput.connection(with: AVMediaType.video) {
                if connection.isVideoStabilizationSupported { connection.preferredVideoStabilizationMode = .auto }
                if #available(iOS 11.0, *) {
                    if let videoCodecType = videoCodecType {
                        if movieFileOutput.availableVideoCodecTypes.contains(videoCodecType) == true {
                            movieFileOutput.setOutputSettings([AVVideoCodecKey: videoCodecType], for: connection)
                        }
                    }
                }
            }
            self.movieFileOutput = movieFileOutput
        }
    }

    fileprivate func configurePhotoOutput() {
        let photoFileOutput = AVCaptureStillImageOutput()
        if self.session.canAddOutput(photoFileOutput) {
            photoFileOutput.outputSettings  = [AVVideoCodecKey: AVVideoCodecJPEG]
            self.session.addOutput(photoFileOutput)
            self.photoFileOutput = photoFileOutput
        }
    }

    fileprivate func processPhoto(_ imageData: Data) -> UIImage {
        let dataProvider = CGDataProvider(data: imageData as CFData)
        let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
        let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: self.orientation.getImageOrientation(forCamera: self.currentCamera))
        return image
    }

    fileprivate func capturePhotoAsyncronously(completionHandler: @escaping(Bool) -> ()) {
        guard sessionRunning == true else { return }
        if let videoConnection = photoFileOutput?.connection(with: AVMediaType.video) {
            photoFileOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer!)
                    let image = self.processPhoto(imageData!)
                    DispatchQueue.main.async { self.cameraDelegate?.swiftyCam(self, didTake: image) }
                    completionHandler(true)
                } else { completionHandler(false) }
            })
        } else { completionHandler(false) }
    }

    fileprivate func promptToAppSettings() {
        DispatchQueue.main.async(execute: { [unowned self] in
            let message = NSLocalizedString("AVCam doesn't have permission to use the camera, please change privacy settings", comment: "Alert message when the user has denied access to the camera")
            let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .default, handler: { action in
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.openURL(appSettings)
                }
            }))
            self.present(alertController, animated: true, completion: nil)
        })
    }

    fileprivate func videoInputPresetFromVideoQuality(quality: VideoQuality) -> String {
        switch quality {
        case .high: return AVCaptureSession.Preset.high.rawValue
        case .medium: return AVCaptureSession.Preset.medium.rawValue
        case .low: return AVCaptureSession.Preset.low.rawValue
        case .resolution352x288: return AVCaptureSession.Preset.cif352x288.rawValue
        case .resolution640x480: return AVCaptureSession.Preset.vga640x480.rawValue
        case .resolution1280x720: return AVCaptureSession.Preset.hd1280x720.rawValue
        case .resolution1920x1080: return AVCaptureSession.Preset.hd1920x1080.rawValue
        case .iframe960x540: return AVCaptureSession.Preset.iFrame960x540.rawValue
        case .iframe1280x720: return AVCaptureSession.Preset.iFrame1280x720.rawValue
        case .resolution3840x2160: return AVCaptureSession.Preset.hd4K3840x2160.rawValue
        }
    }

    fileprivate class func deviceWithMediaType(_ mediaType: String, preferringPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        // Updated to use new API if available, else fallback logic
        if #available(iOS 10.0, *) {
            return AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType(rawValue: mediaType), position: position)
        } else {
             // Basic fallback
             let devices = AVCaptureDevice.devices(for: AVMediaType(rawValue: mediaType))
             return devices.filter{$0.position == position}.first
        }
    }

    fileprivate func changeFlashSettings(device: AVCaptureDevice, mode: FlashMode) {
        do {
            try device.lockForConfiguration()
            device.flashMode = mode.AVFlashMode
            device.unlockForConfiguration()
        } catch { print("[SwiftyCam]: \(error)") }
    }

    fileprivate func enableFlash() {
        if self.isCameraTorchOn == false { toggleFlash() }
    }

    fileprivate func disableFlash() {
        if self.isCameraTorchOn == true { toggleFlash() }
    }

    fileprivate func toggleFlash() {
        guard self.currentCamera == .rear else { return }
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        if (device?.hasTorch)! {
            do {
                try device?.lockForConfiguration()
                if (device?.torchMode == AVCaptureDevice.TorchMode.on) {
                    device?.torchMode = AVCaptureDevice.TorchMode.off
                    self.isCameraTorchOn = false
                } else {
                    try device?.setTorchModeOn(level: 1.0)
                    self.isCameraTorchOn = true
                }
                device?.unlockForConfiguration()
            } catch { print("[SwiftyCam]: \(error)") }
        }
    }

    fileprivate func setBackgroundAudioPreference() {
        guard allowBackgroundAudio == true else { return }
        guard audioEnabled == true else { return }
        do{
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .allowBluetooth, .allowAirPlay, .allowBluetoothA2DP])
            try AVAudioSession.sharedInstance().setActive(true)
            session.automaticallyConfiguresApplicationAudioSession = false
        } catch { print("[SwiftyCam]: Failed to set background audio preference") }
    }

    @objc private func captureSessionDidStartRunning() {
        sessionRunning = true
        DispatchQueue.main.async { self.cameraDelegate?.swiftyCamSessionDidStartRunning(self) }
    }

    @objc private func captureSessionDidStopRunning() {
        sessionRunning = false
        DispatchQueue.main.async { self.cameraDelegate?.swiftyCamSessionDidStopRunning(self) }
    }
    
    fileprivate func addGestureRecognizers() {
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoomGesture(pinch:)))
        pinchGesture.delegate = self
        previewLayer.addGestureRecognizer(pinchGesture)
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(singleTapGesture(tap:)))
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.delegate = self
        previewLayer.addGestureRecognizer(singleTapGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapGesture(tap:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.delegate = self
        previewLayer.addGestureRecognizer(doubleTapGesture)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(pan:)))
        panGesture.delegate = self
        previewLayer.addGestureRecognizer(panGesture)
    }
    
    @objc fileprivate func zoomGesture(pinch: UIPinchGestureRecognizer) {
        guard pinchToZoom == true && self.currentCamera == .rear else { return }
        do {
            let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) ?? AVCaptureDevice.devices().first
            try captureDevice?.lockForConfiguration()
            
            zoomScale = min(maxZoomScale, max(1.0, min(beginZoomScale * pinch.scale,  captureDevice!.activeFormat.videoMaxZoomFactor)))
            
            captureDevice?.videoZoomFactor = zoomScale
            
            DispatchQueue.main.async { self.cameraDelegate?.swiftyCam(self, didChangeZoomLevel: self.zoomScale) }
            
            captureDevice?.unlockForConfiguration()
        } catch { print("[SwiftyCam]: Error locking configuration") }
    }
    
    @objc fileprivate func singleTapGesture(tap: UITapGestureRecognizer) {
        guard tapToFocus == true else { return }
        
        let screenSize = previewLayer!.bounds.size
        let tapPoint = tap.location(in: previewLayer!)
        let x = tapPoint.y / screenSize.height
        let y = 1.0 - tapPoint.x / screenSize.width
        let focusPoint = CGPoint(x: x, y: y)
        
        if let device = videoDevice {
            do {
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported == true {
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = .autoFocus
                }
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                device.unlockForConfiguration()
                DispatchQueue.main.async { self.cameraDelegate?.swiftyCam(self, didFocusAtPoint: tapPoint) }
            } catch { print("[SwiftyCam]: Error focusing") }
        }
    }
    
    @objc fileprivate func doubleTapGesture(tap: UITapGestureRecognizer) {
        guard doubleTapCameraSwitch == true else { return }
        switchCamera()
    }
    
    @objc private func panGesture(pan: UIPanGestureRecognizer) {
        guard swipeToZoom == true && self.currentCamera == .rear else { return }
        let currentTranslation    = pan.translation(in: view).y
        let translationDifference = currentTranslation - previousPanTranslation
        
        do {
            let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) ?? AVCaptureDevice.devices().first
            try captureDevice?.lockForConfiguration()
            
            let currentZoom = captureDevice?.videoZoomFactor ?? 0.0
            
            if swipeToZoomInverted == true {
                zoomScale = min(maxZoomScale, max(1.0, min(currentZoom - (translationDifference / 75),  captureDevice!.activeFormat.videoMaxZoomFactor)))
            } else {
                zoomScale = min(maxZoomScale, max(1.0, min(currentZoom + (translationDifference / 75),  captureDevice!.activeFormat.videoMaxZoomFactor)))
            }
            
            captureDevice?.videoZoomFactor = zoomScale
            DispatchQueue.main.async { self.cameraDelegate?.swiftyCam(self, didChangeZoomLevel: self.zoomScale) }
            captureDevice?.unlockForConfiguration()
        } catch { print("[SwiftyCam]: Error locking configuration") }
        
        if pan.state == .ended || pan.state == .failed || pan.state == .cancelled {
            previousPanTranslation = 0.0
        } else {
            previousPanTranslation = currentTranslation
        }
    }
}

extension SwiftyCamViewController : UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UIPinchGestureRecognizer.self) {
            beginZoomScale = zoomScale;
        }
        return true
    }
}

extension SwiftyCamViewController : AVCaptureFileOutputRecordingDelegate {
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let currentBackgroundRecordingID = backgroundRecordingID {
            backgroundRecordingID = UIBackgroundTaskIdentifier.invalid
            if currentBackgroundRecordingID != UIBackgroundTaskIdentifier.invalid {
                UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
            }
        }
        if let currentError = error {
            DispatchQueue.main.async { self.cameraDelegate?.swiftyCam(self, didFailToRecordVideo: currentError) }
        } else {
            DispatchQueue.main.async { self.cameraDelegate?.swiftyCam(self, didFinishProcessVideoAt: outputFileURL) }
        }
    }
}

// MARK: - SwiftyCamButton & SwiftyRecordButton

// Delegate for SwiftyCamButton
public protocol SwiftyCamButtonDelegate: AnyObject {
    func buttonWasTapped()
    func buttonDidBeginLongPress()
    func buttonDidEndLongPress()
    func longPressDidReachMaximumDuration()
    func setMaxiumVideoDuration() -> Double
}

open class SwiftyCamButton: UIButton {
    public weak var delegate: SwiftyCamButtonDelegate?
    public var buttonEnabled = true
    fileprivate var timer : Timer?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        createGestureRecognizers()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createGestureRecognizers()
    }
    
    @objc fileprivate func Tap() {
        guard buttonEnabled == true else { return }
        delegate?.buttonWasTapped()
    }
    
    @objc fileprivate func LongPress(_ sender:UILongPressGestureRecognizer!)  {
        guard buttonEnabled == true else { return }
        switch sender.state {
        case .began:
            delegate?.buttonDidBeginLongPress()
            startTimer()
        case .cancelled, .ended, .failed:
            invalidateTimer()
            delegate?.buttonDidEndLongPress()
        default:
            break
        }
    }
    
    @objc fileprivate func timerFinished() {
        invalidateTimer()
        delegate?.longPressDidReachMaximumDuration()
    }
    
    fileprivate func startTimer() {
        if let duration = delegate?.setMaxiumVideoDuration() {
            if duration != 0.0 && duration > 0.0 {
                timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector:  #selector(SwiftyCamButton.timerFinished), userInfo: nil, repeats: false)
            }
        }
    }
    
    fileprivate func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    fileprivate func createGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SwiftyCamButton.Tap))
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(SwiftyCamButton.LongPress))
        self.addGestureRecognizer(tapGesture)
        self.addGestureRecognizer(longGesture)
    }
}

class SwiftyRecordButton: SwiftyCamButton {
    
    private var circleBorder: CALayer!
    private var innerCircle: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        drawButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        drawButton()
    }
    
    private func drawButton() {
        self.backgroundColor = UIColor.clear
        circleBorder = CALayer()
        circleBorder.backgroundColor = UIColor.clear.cgColor
        circleBorder.borderWidth = 6.0
        circleBorder.borderColor = UIColor.white.cgColor
        circleBorder.bounds = self.bounds
        circleBorder.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        circleBorder.cornerRadius = self.frame.size.width / 2
        layer.insertSublayer(circleBorder, at: 0)
    }
    
    public  func growButton() {
        innerCircle = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        guard let innerCircle = innerCircle else { return }
        
        innerCircle.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        innerCircle.backgroundColor = UIColor.red
        innerCircle.layer.cornerRadius = innerCircle.frame.size.width / 2
        innerCircle.clipsToBounds = true
        self.addSubview(innerCircle)
        
        UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveEaseOut, animations: {
            innerCircle.transform = CGAffineTransform(scaleX: 62.4, y: 62.4)
            self.circleBorder.setAffineTransform(CGAffineTransform(scaleX: 1.352, y: 1.352))
            self.circleBorder.borderWidth = (6 / 1.352)
        }, completion: nil)
    }
    
    public func shrinkButton() {
        guard let innerCircle = innerCircle else { return }
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            innerCircle.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.circleBorder.setAffineTransform(CGAffineTransform(scaleX: 1.0, y: 1.0))
            self.circleBorder.borderWidth = 6.0
        }, completion: { (success) in
            innerCircle.removeFromSuperview()
            self.innerCircle = nil
        })
    }
}

// MARK: - Helper Classes (Repeated for context if needed, but assuming one definition)
// (Orientation, PreviewView are above)

class Orientation  {
    var shouldUseDeviceOrientation: Bool  = false
    fileprivate var deviceOrientation : UIDeviceOrientation?
    fileprivate let coreMotionManager = CMMotionManager()
    
    init() { coreMotionManager.accelerometerUpdateInterval = 0.1 }
    
    func start() {
        self.deviceOrientation = UIDevice.current.orientation
        coreMotionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
            guard let data = data else { return }
            self?.handleAccelerometerUpdate(data: data)
        }
    }
    func stop() {
        self.coreMotionManager.stopAccelerometerUpdates()
        self.deviceOrientation = nil
    }
    
    func getImageOrientation(forCamera: SwiftyCamViewController.CameraSelection) -> UIImage.Orientation {
        guard shouldUseDeviceOrientation, let deviceOrientation = self.deviceOrientation else { return forCamera == .rear ? .right : .leftMirrored }
        switch deviceOrientation {
        case .landscapeLeft: return forCamera == .rear ? .up : .downMirrored
        case .landscapeRight: return forCamera == .rear ? .down : .upMirrored
        case .portraitUpsideDown: return forCamera == .rear ? .left : .rightMirrored
        default: return forCamera == .rear ? .right : .leftMirrored
        }
    }
    
    func getPreviewLayerOrientation() -> AVCaptureVideoOrientation {
        switch UIApplication.shared.statusBarOrientation {
        case .portrait, .unknown: return AVCaptureVideoOrientation.portrait
        case .landscapeLeft: return AVCaptureVideoOrientation.landscapeLeft
        case .landscapeRight: return AVCaptureVideoOrientation.landscapeRight
        case .portraitUpsideDown: return AVCaptureVideoOrientation.portraitUpsideDown
        @unknown default: return AVCaptureVideoOrientation.portrait
        }
    }
    
    func getVideoOrientation() -> AVCaptureVideoOrientation? {
        guard shouldUseDeviceOrientation, let deviceOrientation = self.deviceOrientation else { return nil }
        switch deviceOrientation {
        case .landscapeLeft: return .landscapeRight
        case .landscapeRight: return .landscapeLeft
        case .portraitUpsideDown: return .portraitUpsideDown
        default: return .portrait
        }
    }
    
    private func handleAccelerometerUpdate(data: CMAccelerometerData){
        if(abs(data.acceleration.y) < abs(data.acceleration.x)){
            if(data.acceleration.x > 0){ deviceOrientation = UIDeviceOrientation.landscapeRight }
            else { deviceOrientation = UIDeviceOrientation.landscapeLeft }
        } else{
            if(data.acceleration.y > 0){ deviceOrientation = UIDeviceOrientation.portraitUpsideDown }
            else { deviceOrientation = UIDeviceOrientation.portrait }
        }
    }
}

public enum SwiftyCamVideoGravity {
    case resize, resizeAspect, resizeAspectFill
}

class PreviewView: UIView {
    private var gravity: SwiftyCamVideoGravity = .resizeAspect
    init(frame: CGRect, videoGravity: SwiftyCamVideoGravity) {
        gravity = videoGravity
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
    }
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        let previewlayer = layer as! AVCaptureVideoPreviewLayer
        switch gravity {
        case .resize: previewlayer.videoGravity = AVLayerVideoGravity.resize
        case .resizeAspect: previewlayer.videoGravity = AVLayerVideoGravity.resizeAspect
        case .resizeAspectFill: previewlayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        }
        return previewlayer
    }
    var session: AVCaptureSession? {
        get { return videoPreviewLayer.session }
        set { videoPreviewLayer.session = newValue }
    }
    override class var layerClass : AnyClass { return AVCaptureVideoPreviewLayer.self }
}
