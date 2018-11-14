//
//  ChatViewController.swift
//  RealTimeChat
//
//  Created by 藤澤洋佑 on 2018/11/03.
//  Copyright © 2018年 Fujisawa-Yousuke. All rights reserved.
//

/*
 
 DatabaseURl:
 
 セルが追加される度に自動スクロール
         if Posts.count > 1 {
             print(8)
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                 self.tableView.scrollToRow(at: IndexPath(row: self.Posts.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
             }
         } else {}
 
 let ref = Database.database().reference()
 
 let ref = Database.database().reference().child("post")
 
 let ref = Database.database().reference().child("post").child("RoomList")
 
 let ref = Database.database().reference().child("post").child("RoomList").childByAutoId()
 
 let ref = Database.database().reference(fromURL: "https://realtimechat-e6e96.firebaseio.com/").child("post").child("messages").child(roomPath).childByAutoId()
 
 */

import UIKit
import Firebase
import FirebaseUI


class ChatViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var roomLabel: UILabel!
    
    //Firebase関連
    //Firebaseに保存する変数を持つクラスインスタンス
    var Post = Object()
    //Objectクラスのインスタンスを持つ配列
    var Posts = [Object]()
    
    //現在入室しているルームメイ
    var roomPath = String()
    
    //投稿日
    var dateFormat = DateFormatter()
    
    //セルに渡す用のUIImage
    var image = UIImage()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //リロード
        tableView.reloadData()
    }
    
    //UDからユーザーネームを取得
    let username = UserDefaults.standard.object(forKey: "userName") as! String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //dateFormat.dateFormatの設定
        dateFormat.timeStyle = .short
        dateFormat.dateStyle = .short
        dateFormat.locale = Locale(identifier: "ja-JP")
        
        //選択したルーム名を上部タイトルに代入
        self.navigationItem.title = roomPath
        
        //デリゲート
        textField.delegate = self
        //カスタムセルを登録
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "customcell")
        //データを取得
        loadData_Firebase()
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
        let storageRef = Storage.storage().reference().child("userImage").child(UserDefaults.standard.object(forKey: "userName") as! String)
        cell.talk(Posts[indexPath.row].username, Posts[indexPath.row].message, Posts[indexPath.row].date, storageRef)
        
        if Posts.count > 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.tableView.scrollToRow(at: IndexPath(row: self.Posts.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
            }
        } else {}
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //タップ時の色をなくす
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func reflesh(_ sender: Any) {
        loadData_Firebase()
    }
    
    //メッセを投稿
    @IBAction func send(_ sender: Any) {
        
        //メッセが入力されてれば
        if textField.text != nil && textField.text != "" {
            //Firebaseに[ユーザー名：本文]を保存
            saveData_Firebase(username, textField.text!)
            loadData_Firebase()
        } else {return}
        
    }
    
    //Enterを押したとき
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //メッセが入力されてれば
        if textField.text != nil && textField.text != "" {
            //Firebaseに[ユーザー名：本文]を保存
            saveData_Firebase(username, textField.text!)
            loadData_Firebase()
            textField.resignFirstResponder()
        } else {return true}
        
        return true
        
    }
    
    //Firebaseにデータを保存する関数
    func saveData_Firebase(_ username:String, _ message:String) {
        
        //日付を生成
        let date = Date()
        //TextFieldの値をnil
        textField.text = nil
        //データベースの階層URL
        let ref = Database.database().reference(fromURL: "https://realtimechat-e6e96.firebaseio.com/")
            .child("post")
            .child("messages")
            .child(roomPath).childByAutoId()
        //データを保存するときの辞書
        let data = ["username":username,
                    "message": message,
                    "date": dateFormat.string(from: date)]
        //データベースにデータを保存
        ref.setValue(data)
        
    }
    
    
    //Firebaseからデータを取得する関数
    func loadData_Firebase() {
        //データベースの参照URL
        let ref = Database.database().reference(fromURL: "https://realtimechat-e6e96.firebaseio.com/")
        //データを初期化
        self.Post = Object()
        self.Posts = [Object]()
        ref.child("post")
            .child("messages")
            .child(roomPath)
            .queryOrderedByKey()
            .observeSingleEvent(of: .value) { (snap,error) in
            let snapdata = snap.value as? [String:NSDictionary]
            if snapdata == nil {
                return
            }
            for key in snapdata!.keys.sorted() {
                self.Post = Object()
                let snap = snapdata![key]
                if let username = snap!["username"] as? String, let message = snap!["message"] as? String, let date = snap!["date"] as? String {
                    self.Post.username = username
                    self.Post.message = message
                    self.Post.date = date
                }
                self.Posts.append(self.Post)
            }
            
            self.tableView.reloadData()
        }
        
    }
    
    //画面をタップするとキーボードが閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.resignFirstResponder()
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
