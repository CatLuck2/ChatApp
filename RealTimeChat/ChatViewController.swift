//
//  ChatViewController.swift
//  RealTimeChat
//
//  Created by 藤澤洋佑 on 2018/11/03.
//  Copyright © 2018年 Fujisawa-Yousuke. All rights reserved.
//

/*
 
 DatabaseURl:
 
 */

import UIKit
import Firebase

class ChatViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    //Firebase関連
    //Firebaseに保存する変数を持つクラスインスタンス
    var Post = Object()
    //Objectクラスのインスタンスを持つ配列
    var Posts = [Object]()
    
    //UDからユーザーネームを取得
    let username = UserDefaults.standard.object(forKey: "userName") as! String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //デリゲート
        textField.delegate = self
        //カスタムセルを登録
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "customcell")
        //リロード
        tableView.reloadData()
        
    }
    
    //セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Posts.count
    }
    
    //セルを読み込む
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "customcell", for: indexPath) as? TableViewCell else { return UITableViewCell() }
        
        //TableViewCellのtalk関数にユーザー名とメッセを渡す
        cell.talk(Posts[indexPath.row].username, Posts[indexPath.row].message)
        
        return cell
    }
    
    //メッセを投稿
    @IBAction func send(_ sender: Any) {
        
        //メッセが入力されてれば
        if let _ = textField.text {
            //Firebaseに[ユーザー名：本文]を保存
            saveData_Firebase(username, textField.text!)
            loadData_Firebase()
        } else {return}
        
    }
    
    //Enterを押したとき
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //メッセが入力されてれば
        if let _ = textField.text {
            //Firebaseに[ユーザー名：本文]を保存
            saveData_Firebase(username, textField.text!)
            loadData_Firebase()
        } else {return true}
        
        return true
        
    }
    
    //Firebaseにデータを保存する関数
    func saveData_Firebase(_ username:String, _ message:String) {
        
        //TextFieldの値をnil
        textField.text = ""
    
        //データベースの階層URL
        let ref = Database.database().reference(fromURL: "https://realtimechat-e6e96.firebaseio.com/").child("post").childByAutoId()
        
        //データを保存するときの辞書
        let data = ["username":username, "message": message]
        
        //データベースにデータを保存
        ref.setValue(data)
        
        //tableViewをリロード
//        tableView.reloadData()
        
        //セルが追加される度に自動スクロール
        if Posts.count > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.tableView.scrollToRow(at: IndexPath(row: self.Posts.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
            }
        } else {}
        
    }
    
    
    //Firebaseからデータを取得する関数
    func loadData_Firebase() {
        
        //データベースの参照URL
        let ref = Database.database().reference()
        
        //データを初期化
        self.Post = Object()
        self.Posts = [Object]()
        
        ref.child("post").observeSingleEvent(of: .value) { (snap,error) in
            
            let snapdata = snap.value as? [String:NSDictionary]
            
            if snapdata == nil {
                return
            }
            
            for (_, snap) in snapdata! {
                self.Post = Object()
                if let username = snap["username"] as? String, let message = snap["message"] as? String {
                    self.Post.username = username
                    self.Post.message = message
                }
                self.Posts.append(self.Post)
            }
            
            self.tableView.reloadData()
            
        }
        
    }
    
    
    

}
