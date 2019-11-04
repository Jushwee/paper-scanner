//
//  ViewController.swift
//  PhotoScanner
//
//  Created by Joshua on 10/14/19.
//  Copyright © 2019 Joshua. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var imagePicker: ImagePicker!
    
    lazy var resultImgView: UIImageView = {
        let v = UIImageView(frame: .zero)
        v.contentMode = .scaleAspectFit
        v.isOpaque = true
        v.backgroundColor = UIColor.white
        
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(resultImgView)
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
    }
    
    @IBAction func SelectPhotoClick(_ sender: Any) {
        // self.showAlert();
        self.imagePicker.present(from: sender as! UIView)
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let width = view.bounds.width
        let height = view.bounds.height
        
        resultImgView.frame = CGRect(x: ceil(width * 0.05 ), y: ceil(height * 0.07), width: (ceil(width * 0.9)) , height: ceil(height * 0.75))
    }
}


extension ViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        if (image != nil)
        {
            // draw contour
            resultImgView.image = OpenCVWrapper.selectArea(image!)
            
            // check with user to see if the image is okay
            let dialogMessage = UIAlertController(title: "Confirm", message: "Scan Selected Area?", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
                let outputImage = OpenCVWrapper.scanDocument(image!)
                self.resultImgView.image = outputImage
                UIImageWriteToSavedPhotosAlbum(outputImage, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            })
            
            let cancel = UIAlertAction(title: "No", style: .cancel) { (action) -> Void in
                self.resultImgView.image = nil
            }
            
            dialogMessage.addAction(ok)
            dialogMessage.addAction(cancel)
            self.present(dialogMessage, animated: true, completion: nil)
        }
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}
