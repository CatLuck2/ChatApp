//
//  ViewController.swift
//  RealTimeChat
//
//  Created by 藤澤洋佑 on 2018/11/02.
//  Copyright © 2018年 Fujisawa-Yousuke. All rights reserved.
//

import UIKit
import EMAlertController

class ViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var login: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //もしユーザー名が保存されてるなら
        if let _ = UserDefaults.standard.object(forKey: "userName") {
            //ボタンの文字を"ログイン"に変更
            login.setTitle("Sign in", for: .normal)
            //保存されてないなら
        } else {
            login.setTitle("Sign up", for: .normal)
        }
    }

    @IBAction func login(_ sender: Any) {
        
        //既にログインしてるなら
        if let _ = UserDefaults.standard.object(forKey: "userName") {
            
            //もし入力した値が保存したユーザー名と同じなら
            if textField.text ==  UserDefaults.standard.object(forKey: "userName") as? String {
                
                //遷移
                performSegue(withIdentifier: "goTimeLine", sender: nil)
                
            //違うなら
            } else {
                
                //アラート作成
                let alert = EMAlertController(title: "ユーザー名が正しくありません。", message: "")
                //アクション作成
                let action = EMAlertAction(title: "OK", style: .cancel)
                //アラートにアクションを追加する
                alert.addAction(action: action)
                //アラートを表示
                present(alert, animated: true, completion: nil)
                
            }
            
        //新規登録の場合
        } else {
            
            //もし入力されてるなら
            if textField.text != "" {
                
                //UserDefaultsの変数
                let ud = UserDefaults.standard
                //ユーザー名をUDに保存
                ud.set(textField.text, forKey: "userName")
                //画面遷移
                performSegue(withIdentifier: "goTimeLine", sender: nil)
                
            //もし入力されてないなら
            } else {
                
                //アラート
                let alert = EMAlertController(title: "ユーザー名を入力してください", message: "")
                //アクション
                let action = EMAlertAction(title: "OK", style: .cancel)
                //アラートにアクションを追加する
                alert.addAction(action: action)
                //アラートを表示
                present(alert, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    //画面をタップするとキーボードが閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.resignFirstResponder()
    }
    
}

