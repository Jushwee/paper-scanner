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
        
        resultImgView.frame = CGRect(x: 0.0, y: 0.0, width: width, height: ceil(height * 0.8))
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
                self.resultImgView.image = OpenCVWrapper.scanDocument(image!)
            })
            
            let cancel = UIAlertAction(title: "No", style: .cancel) { (action) -> Void in
                self.resultImgView.image = nil
            }
            
            dialogMessage.addAction(ok)
            dialogMessage.addAction(cancel)
            self.present(dialogMessage, animated: true, completion: nil)
        }
    }
}
