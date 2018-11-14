//
//  TableViewCell.swift
//  RealTimeChat
//
//  Created by 藤澤洋佑 on 2018/11/03.
//  Copyright © 2018年 Fujisawa-Yousuke. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var MyView: UIView!
    @IBOutlet weak var MyLabel: UILabel!
    @IBOutlet weak var MyDateLabel: UILabel!
    @IBOutlet weak var MyImageView: UIImageView!
    
    @IBOutlet weak var OtherView: UIView!
    @IBOutlet weak var OtherLabel: UILabel!
    @IBOutlet weak var OtherDateLabel: UILabel!
    @IBOutlet weak var OtherImageView: UIImageView!
    
    var isMe = Bool()
    

    //引数のusernameとUDのユーザー名が一致するかで、表示する吹き出しが変わる
    func talk(_ username:String, _ message:String, _ date:String, _ ref: StorageReference) {
        
        //UDに登録されてるユーザー名と同じ？
        if username == UserDefaults.standard.object(forKey: "userName") as! String {
            isMe = true
        } else {
            isMe = false
        }
        //meTalkViewが表示、partnerTalkViewが非表示
        MyView.isHidden = !isMe
        OtherView.isHidden = isMe
        //表示されるViewのラベルに設定を施す
        if isMe {
            //Labelに設定を施す
            settingLabel(label: MyLabel)
            //meTalkViewは文字を表示、partnerTalkViewは文字を表示しない
            MyLabel.text = isMe ? message : ""
            MyDateLabel.text = isMe ? date : ""
            MyImageView.sd_setImage(with: ref)
        } else {
            settingLabel(label: OtherLabel)
            OtherLabel.text = isMe ? "" : message
            OtherDateLabel.text = isMe ? "" : date
        }
        
    }
    
    //メッセのアイコンを設定
    func settingImage(_ ref: StorageReference) {
        MyImageView.sd_setImage(with: ref)
    }

    //指定されたLabelに設定をほどこす
    func settingLabel(label: UILabel) {
        label.font = UIFont(name: "HiraKakuProN-W3", size: 18)
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        label.layer.cornerRadius = 50
    }
    
}
