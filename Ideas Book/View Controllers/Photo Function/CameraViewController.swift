//
//  CameraViewController.swift
//  Ideas Book
//
//  Created by Junjie He on 2019/8/6.
//  Copyright © 2019 AllenHe. All rights reserved.
//

import UIKit
import AVFoundation
class CameraViewController: UIViewController{

    var backCamera:AVCaptureDevice?;
    var frontCamera:AVCaptureDevice?;
    var captureSession = AVCaptureSession();
    var currentCamera:AVCaptureDevice?;
    var photoOutput:AVCapturePhotoOutput?;
    var cameraPreviewLayer:AVCaptureVideoPreviewLayer?;
    var image:UIImage?;
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession();
        setupDevice();
        setupInputOutput();
        setupPreviewLayer();
        startRunningCaptureSession();
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if let imagee = image{
            let previewVC = self.storyboard?.instantiateViewController(withIdentifier: "PreviewViewController") as? PreviewViewController;
            if let previewVC = previewVC{
                previewVC.image = imagee
                self.image = nil;
                self.present(previewVC, animated: true, completion: nil);
            }
        }
    }
    func setupCaptureSession(){
        captureSession.sessionPreset = AVCaptureSession.Preset.photo;
    }
    
    func setupDevice(){
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:[AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified);
        let devices = deviceDiscoverySession.devices;
        for device in devices {
            if device.position == AVCaptureDevice.Position.back{
                backCamera = device;
            }else if device.position == AVCaptureDevice.Position.front{
                frontCamera = device;
            }
        }
        currentCamera = backCamera;
        
    }
    
    func setupInputOutput(){
        do{
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!);
            captureSession.addInput(captureDeviceInput);
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
        }catch{
            print(error);
        }
    }
    
    func setupPreviewLayer(){
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill;
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame;
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0);
    }
    
    func startRunningCaptureSession(){
        captureSession.startRunning();
    }
    
    @IBAction func takePhotoTapped(_ sender: Any) {
        let settings = AVCapturePhotoSettings();
        photoOutput?.capturePhoto(with: settings, delegate: self);
       
    }
    @IBAction func libraryTapped(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary;
        imagePicker.delegate=self;
        
        // Present it
        present(imagePicker, animated: true, completion: nil);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhoto"{
            let previewVC = segue.destination as! PreviewViewController;
            previewVC.image = self.image
            self.image = nil;
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil);
    }
    
}
extension CameraViewController: AVCapturePhotoCaptureDelegate{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(){
            image = UIImage(data: imageData);
            performSegue(withIdentifier: "showPhoto", sender: nil)
        }
    }
}
extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            
            // Successfully got the image, now upload it
            image = selectedImage;
        }
        
        // Dismiss the picker
        picker.dismiss(animated: true, completion: nil);
    }
}
