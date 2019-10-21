//
//  PreviewViewController.swift
//  Ideas Book
//
//  Created by Junjie He on 2019/8/6.
//  Copyright © 2019 AllenHe. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
    var image:UIImage!;
    @IBOutlet weak var photo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photo.image = image;
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "shoePhotoEdit"{
            let editVC = segue.destination as! PhotoEditViewController;
            editVC.image = self.image
        }
    }


}
