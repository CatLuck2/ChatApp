//
//  SettingViewController.swift
//  RealTimeChat
//
//  Created by 藤澤洋佑 on 2018/11/06.
//  Copyright © 2018年 Fujisawa-Yousuke. All rights reserved.
//

/*
 Strage:gs://realtimechat-e6e96.appspot.com
 */

import UIKit
import Photos
import Firebase
import FirebaseUI

class SettingViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //カメラ、アルバムの起動を許可云々
        PHPhotoLibrary.requestAuthorization { (status) in
            switch(status){
            case .authorized: break
            case .denied: break
            case .notDetermined: break
            case .restricted: break
            }
        }
        
        let storageRef = Storage.storage().reference()
        imageView.sd_setImage(with: storageRef.child("userImage").child(UserDefaults.standard.object(forKey: "userName") as! String))
    }
    
    @IBAction func changeImage(_ sender: Any) {
        //アルバムを指定
        //SourceType.camera：カメラを指定
        let sourceType:UIImagePickerController.SourceType
            = UIImagePickerController.SourceType.photoLibrary
        //アルバムを立ち上げる
        if UIImagePickerController.
        isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            // インスタンスの作成
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            //アルバム画面を開く
            self.present(cameraPicker, animated: true, completion: nil)
        }
    }
    
    //アルバム画面で写真を選択した時
    @objc func imagePickerController
        (_ picker: UIImagePickerController,
         didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //imageにアルバムで選択した画像が格納される
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //ImageViewに表示
            self.imageView.image = image
            //アルバム画面を閉じる
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func decide(_ sender: Any) {
        if let image = self.imageView.image {
            let storageRef = Storage.storage().reference(forURL: "gs://realtimechat-e6e96.appspot.com")
            //画像をNSDataに変換する
            // UIImageJPEGRepresentation
            let data = image.jpegData(compressionQuality: 0.1)! as Data
            storageRef.child("userImage").child(UserDefaults.standard.object(forKey: "userName") as! String).delete { (error) in
                if error != nil {
                    print("error!?")
                } else {
                    
                }
            }
            storageRef.child("userImage").child(UserDefaults.standard.object(forKey: "userName") as! String)
                .putData(data, metadata: nil) { metadata,error in
                    if error != nil {
                        print("error!")
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
            }
        } else {
            return
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
