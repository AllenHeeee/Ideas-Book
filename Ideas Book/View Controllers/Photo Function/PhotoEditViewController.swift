//
//  PhotoEditViewController.swift
//  Ideas Book
//
//  Created by Junjie He on 2019/8/6.
//  Copyright © 2019 AllenHe. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift

class PhotoEditViewController: UIViewController {
    @IBOutlet weak var textField: UITextView!
    var image:UIImage!;
    @IBOutlet weak var collectionView: UICollectionView!
     var user:User?;
    var savedText:String?;
    @IBOutlet weak var postButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        if savedText != nil{
            self.textField.text = savedText!;
        }
        user = Helper.loadCurrentUser();
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        if Helper.imageArr.count<=3 && image != nil{
             Helper.imageArr.append(image);
        }
        postButton.isEnabled = true;
    }
    @IBAction func cancelTapped(_ sender: Any) {
        textField.resignFirstResponder();
        if textField.text.trimmingCharacters(in: .whitespacesAndNewlines) != "" || Helper.imageArr.isEmpty == false{
            present(showSaveMessage(), animated: true, completion: nil);
            return;
        }
        Helper.imageArr.removeAll();
        let defaults = UserDefaults.standard;
        defaults.set(nil, forKey: "savedTextForPhoto");
        dismiss(animated: true, completion: nil)
    }
    
    func showSaveMessage()->UIAlertController{
        let alert = UIAlertController(title: "Would you like to save the draft?", message: "If saved, the draft can be recovered in the future.", preferredStyle: .actionSheet);
        let saveAction = UIAlertAction(title: "Save", style: .destructive) { (action) in
            
            let myData = SavedPhotos();
            myData.text = self.textField.text;
            if Helper.imageArr.count == 1{
                myData.image1 = Helper.imageArr[0].jpegData(compressionQuality: 0.1);
            }else if Helper.imageArr.count == 2{
                 myData.image1 = Helper.imageArr[0].jpegData(compressionQuality: 0.1);
                myData.image2 = Helper.imageArr[1].jpegData(compressionQuality: 0.1);
            }else if Helper.imageArr.count == 3{
                 myData.image1 = Helper.imageArr[0].jpegData(compressionQuality: 0.1);
                myData.image2 = Helper.imageArr[1].jpegData(compressionQuality: 0.1);
                myData.image3 = Helper.imageArr[2].jpegData(compressionQuality: 0.1);
            }
            let realm = try! Realm()
            try! realm.write {
                realm.deleteAll();
                realm.add(myData)
            }
            let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
            if let vc = homeVC{
                self.present(vc, animated: false, completion: nil);
            }
            
        }
        alert.addAction(saveAction);
        let unSaveAction = UIAlertAction(title: "Discard", style: .default) { (action) in

            Helper.imageArr.removeAll();
            let realm = try! Realm()
            
            try! realm.write {
                realm.deleteAll();
            }
            
            let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
            if let vc = homeVC{
                self.present(vc, animated: false, completion: nil);
            }
        }
        alert.addAction(unSaveAction);
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil);
        alert.addAction(cancelAction);
        return alert;
    }
    @IBAction func postTapped(_ sender: Any) {
        textField.resignFirstResponder();
        postButton.isEnabled = false;
        
        if textField.text.count>240{
            present(Helper.showError("You cannot input more than 240 characters!"), animated: true) {
                self.textField.text = String(self.textField.text.prefix(240));
            }
            return;
        }
        
        let filename = UUID().uuidString;
        let time = Timestamp(date: Date());
        

        
        // Get a storage reference
        let userId = Auth.auth().currentUser!.uid;
        var urls = [String]();
        var imageNames = [String]();
        for _ in 0..<Helper.imageArr.count{
            urls.append("nil")
        }
        for i in 1...3{
            if Helper.imageArr.count<i{
                break;
            }
            let imageName:String = "image\(i)URL";
            imageNames.append(imageName);
            let ref = Storage.storage().reference().child("\(userId)/images/\(filename)/\(imageName).jpg");
            // Get data representation of the image
            let photoData = Helper.imageArr[i-1].jpegData(compressionQuality: 0.1);
            
            guard photoData != nil else{
                print("Couldn't turn the image to data!")
                return;
            }
            // Upload the photo
            ref.putData(photoData!, metadata: nil) { (metadata, error) in
                if error != nil {
                    print("An error during upload occurred")
                }else{
                    // Upload was successful, noe create a database entry
                    ref.downloadURL(completion: { (url, error) in
                        if error == nil{
                            print(i)
                            urls[i-1] = url!.absoluteString
//                            urls.append(url!.absoluteString)
                            if urls.count == Helper.imageArr.count{
                                let textContent = self.textField.text;
                                let db = Firestore.firestore()
                                var data = [String:Any]();
                                for j in 0..<imageNames.count{
                                    data[imageNames[j]] = urls[j];
                                }
                                data["text"] = textContent!;
                                data["time"] = time
                                db.collection("users").document(self.user!.userID!).collection("photo").document(filename).setData(data) { (error) in
                                    if error == nil{
                                        print("Good")
                                        db.collection("users").document(self.user!.userID!).collection("all").document(filename).setData(data, completion: { (error) in
                                            if error == nil{
                                                let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController;
                                                if let homeVC = homeVC{
                                                    self.present(homeVC, animated: true, completion: nil);
                                                }
                                            }
                                        })
                                    }
                                }
                            }
                        }else{
                            self.present(Helper.showError(error?.localizedDescription), animated: true, completion: nil)
                        }
                    })
                }
            }
        }
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        textField.becomeFirstResponder();
    }
    override func viewDidAppear(_ animated: Bool) {
        
        if Helper.imageArr.count == 0{
            let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController;
            if let homeVC = homeVC{
                self.present(homeVC, animated: true, completion: nil);
            }
        }
    }

}

extension PhotoEditViewController:UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath as IndexPath) as! PhotoCollectionViewCell
       
        if indexPath.row >= Helper.imageArr.count{
            if indexPath.row == Helper.imageArr.count{
                cell.imageView.image = UIImage(named: "plus");
            }else{
                cell.imageView.image = nil;
            }
        
        }else{
            cell.imageView.image = Helper.imageArr[indexPath.row]
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row >= Helper.imageArr.count{
            if indexPath.row == Helper.imageArr.count{
            let cameraVC = self.storyboard?.instantiateViewController(withIdentifier: "CameraViewController") as? CameraViewController;
            if let cameraVC = cameraVC{
                present(cameraVC, animated: true, completion: nil);
            }
            }
        }else{
            let reviewVC = self.storyboard?.instantiateViewController(withIdentifier: "ReviewPhotoViewController") as? ReviewPhotoViewController;
            if let reviewVC = reviewVC{
                let photo = Helper.imageArr[indexPath.row];
                reviewVC.photo = photo
                reviewVC.index = indexPath.row;
                reviewVC.modalTransitionStyle = .crossDissolve
                present(reviewVC, animated: true, completion: nil);
            }
        }
    }
    
    
}
