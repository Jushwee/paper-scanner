//
//  ViewController.swift
//  PhotoScanner
//
//  Created by Joshua on 10/14/19.
//  Copyright © 2019 Joshua. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    var imagePicker: ImagePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
    }
    
    @IBAction func SelectPhotoClick(_ sender: Any) {
        // self.showAlert();
        self.imagePicker.present(from: sender as! UIView)
    }
    
     //Show alert
    func showAlert() {

        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Photo Album", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    //get image from source type
    func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {

        
        //Check is source type available
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {

            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePickerController.sourceType = sourceType
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
}


extension ViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        // self.imageView.image = image
    }
}
