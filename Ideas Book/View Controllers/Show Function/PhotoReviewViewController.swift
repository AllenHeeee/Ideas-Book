//
//  PhotoReviewViewController.swift
//  Ideas Book
//
//  Created by Junjie He on 2019/8/10.
//  Copyright © 2019 AllenHe. All rights reserved.
//

import UIKit

class PhotoReviewViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var image:UIImage?;
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image;
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
