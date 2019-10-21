//
//  HomeViewController.swift
//  Ideas Book
//
//  Created by Junjie He on 2019/8/3.
//  Copyright © 2019 AllenHe. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift
class HomeViewController: UIViewController {
    var user:User?;
    @IBOutlet weak var welcomeLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        user = Helper.loadCurrentUser();
        if user != nil{
             welcomeLabel.text = "\(user!.username!)'s Home!";
        }
        // Do any additional setup after loading the view.
    }
    func showSaveAlert() -> UIAlertController{
        let realm = try! Realm()
        let photos = realm.objects(SavedPhotos.self).first
        let alert = UIAlertController(title: "Would you like to recover your draft?", message: "If not recover, the draft will be deleted forever.", preferredStyle: .alert);
        let recoverAction = UIAlertAction(title: "Recover", style: .destructive) { (action) in
            let editVC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoEditViewController") as? PhotoEditViewController
            if let vc = editVC{
                vc.savedText = photos?.text;
                Helper.imageArr.removeAll();
                var data = photos?.image1
                Helper.imageArr.append(UIImage(data: data!)!)
                
                data = photos?.image2
                if data != nil{
                    Helper.imageArr.append(UIImage(data: data!)!)
                }
                data = photos?.image3
                
                if data != nil{
                    Helper.imageArr.append(UIImage(data: data!)!)
                }
                try! realm.write {
                    realm.deleteAll();
                }
                self.present(vc, animated: true, completion: nil)
            }
            
            
            
        }
        alert.addAction(recoverAction);
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            try! realm.write {
                realm.deleteAll();
            }
            
            let cameraVC = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewController") as? CameraViewController
            if let vc = cameraVC{
                self.present(vc, animated: true, completion: nil)
            }
            
        }
        alert.addAction(cancelAction);
        return alert;
    }
    @IBAction func photoTapped(_ sender: Any) {
        let realm = try! Realm()
        let photos = realm.objects(SavedPhotos.self).first
        if photos?.image1 != nil{
            present(showSaveAlert(), animated: true, completion: nil)

        }else{
            let cameraVC = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewController") as? CameraViewController
            if let vc = cameraVC{
                present(vc, animated: true, completion: nil)
            }
        }

    }
    
    @IBAction func videoTapped(_ sender: Any) {
        let cameraVC = self.storyboard?.instantiateViewController(withIdentifier: "VideoViewController") as? VideoViewController
        if let vc = cameraVC{
            present(vc, animated: true, completion: nil)
        }
    }
    
    

}
