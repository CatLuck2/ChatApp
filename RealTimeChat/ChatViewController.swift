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
    
    //階層名
    var childNumber = 0
    
    //UDからユーザーネームを取得
    let username = UserDefaults.standard.object(forKey: "userName") as! String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //デリゲート
        textField.delegate = self
        //カスタムセルを登録
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "customcell")
        //データを取得
        loadData_Firebase()
        //メッセの数を取得
        childNumber = Posts.count
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
        print(22)
        //TableViewCellのtalk関数にユーザー名とメッセを渡す
        cell.talk(Posts[indexPath.row].username, Posts[indexPath.row].message)
        print("-------------------------------")
        print("-------------------------------")
        print(indexPath.row)
        print("-------------------------------")
        print("-------------------------------")
        print(30)
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
        
        print(1)
        
        //メッセが入力されてれば
        if let _ = textField.text {
            print(1)
            //Firebaseに[ユーザー名：本文]を保存
            saveData_Firebase(username, textField.text!)
            print(10)
            loadData_Firebase()
            self.childNumber = self.Posts.count
            print(20)
        } else {return true}
        
        print(21)
        
        return true
        
    }
    
    //Firebaseにデータを保存する関数
    func saveData_Firebase(_ username:String, _ message:String) {
        print(2)
        //TextFieldの値をnil
        textField.text = ""
        print(3)
        //データベースの階層URL
        let ref = Database.database().reference(fromURL: "https://realtimechat-e6e96.firebaseio.com/").child("post").child("\(childNumber)")
        print(4)
        //データを保存するときの辞書
        let data = ["username":username, "message": message]
        print(5)
        //データベースにデータを保存
        ref.setValue(data)
        print(6)
        //tableViewをリロード
//        tableView.reloadData()
        print(7)
        //セルが追加される度に自動スクロール
//        if Posts.count > 1 {
//            print(8)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                self.tableView.scrollToRow(at: IndexPath(row: self.Posts.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
//            }
//        } else {}
        print(9)
    }
    
    
    //Firebaseからデータを取得する関数
    func loadData_Firebase() {
        print(11)
        //データベースの参照URL
        let ref = Database.database().reference(fromURL: "https://realtimechat-e6e96.firebaseio.com/")
        print(12)
        //データを初期化
        self.Post = Object()
        self.Posts = [Object]()
        print(13)
        ref.child("post").observeSingleEvent(of: .value) { (snap,error) in
            print(14)
            let snapdata = snap.value as? [String:NSDictionary]
            print(15)
            if snapdata == nil {
                return
            }
            print(16)
            for (_, snap) in snapdata! {
                self.Post = Object()
                if let username = snap["username"] as? String, let message = snap["message"] as? String {
                    self.Post.username = username
                    self.Post.message = message
                }
                self.Posts.append(self.Post)
            }
            print(17)
            
            print(18)
            self.tableView.reloadData()
            print(19)
        }
        
    }
    
    
    

}
