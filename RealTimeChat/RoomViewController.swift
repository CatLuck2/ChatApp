//
//  RoomViewController.swift
//  RealTimeChat
//
//  Created by 藤澤洋佑 on 2018/11/05.
//  Copyright © 2018年 Fujisawa-Yousuke. All rights reserved.
//

import UIKit
import Firebase

class RoomViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    //ルーム名を保持する配列
    var roomArray = [String]()
    
    //Firebaseに保存する配列
    var roomArray_Firebase = [String:String]()
    
    //refleshコントーラー
    let reflesh = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //インジケーターの色
        reflesh.tintColor = UIColor.blue
        //インジケーターの下に表示するテキスト
        reflesh.attributedTitle = NSAttributedString(string: "更新")
        //実行する処理を追加
        reflesh.addTarget(self, action: #selector(RoomViewController.loadData_Firebase_Indicator), for: .valueChanged)
        tableView.refreshControl = reflesh
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData_Firebase()
        tableView.tableFooterView = UIView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let label = cell.viewWithTag(1) as! UILabel
        print("indexPath.row = ", indexPath.row)
        print(roomArray[indexPath.row])
        label.text = roomArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //タップ時の色をなくす
        tableView.deselectRow(at: indexPath, animated: true)
        //遷移先のインスタンス
        let cvc = storyboard?.instantiateViewController(withIdentifier: "goRoom") as! ChatViewController
        //ChatViewControllerにパスを渡す
        cvc.roomPath = roomArray[indexPath.row]
        //遷移
        self.navigationController?.pushViewController(cvc, animated: true)
    }
    
    //アイコンを変える
    
    
    //ルームを新規追加
    @IBAction func AddRoom(_ sender: Any) {
        //アラートを表示
        alert()
    }
    
    //Firebaseにルームを保存する
    func saveData_Firebase(_ saveData: [String:String]) {
        //post - RoomList - ID
        let ref = Database.database().reference(fromURL: "https://realtimechat-e6e96.firebaseio.com/").child("post").child("RoomList").childByAutoId()
        ref.setValue(saveData)
    }
    
    //Firebaseからルーム一覧を取得する
    func loadData_Firebase() {
        //Databaseの参照URLを取得
        let ref = Database.database().reference()
        //データ取得開始
        ref.child("post").child("RoomList").observeSingleEvent(of: .value) { (snap, error) in
            //RoomList下の階層をまとめて取得
            let snapdata = snap.value as? [String:NSDictionary]
            //データを取得する配列
            self.roomArray = [String]()
            //もしデータがなければ無反応
            if snapdata == nil {
                return
            }
            //snapdata!.keys : 階層
            //key : 階層
            for key in snapdata!.keys.sorted() {
                //snap : 階層下のデータを書くのすいた辞書
                //今回なら、snap = ["RoomName":"はわはわ"]
                let snap = snapdata![key]
                if let roomname = snap!["RoomName"] as? String {
                    self.roomArray.append(roomname)
                }
            }
        }
    }
    
    @objc func loadData_Firebase_Indicator() {
        loadData_Firebase()
        //インジケーターを終了
        self.reflesh.endRefreshing()
    }
    
    //アラートを表示する
    func alert() {
        //アラート関連
        //アラートコントローラー
        let alertController = UIAlertController(title: "新規ルームを作成", message: "", preferredStyle: .alert)
        //OK
        let okAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            //アラートのtextFieldを生成([textField])
            guard let textField:[UITextField] = alertController.textFields else { return }
            //textFieldに入力したテキストを取得
            for text in textField {
                guard text.text != nil && text.text != "" else {return}
                self.roomArray.append(text.text!)
                self.roomArray_Firebase = ["RoomName":text.text!]
            }
            //リロード
            self.tableView.reloadData()
            print(1)
            print(self.roomArray)
            //Firebaseに保存
            
            self.saveData_Firebase(self.roomArray_Firebase)
            print(2)
            print(self.roomArray)
            //Firebaseから取得
            self.loadData_Firebase()
            print(3)
            print(self.roomArray)
            //roomArray_Firebaseを初期化
            self.roomArray_Firebase = ["":""]
            print(4)
            print(self.roomArray)
        }
        //Cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        //追加
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        //TextFieldを追加
        alertController.addTextField { (text:UITextField!) in
            text.placeholder = "ルーム名を入力してください"
        }
        //バグ対策(iPhone6以前の機種で起こるエラー対策)
        alertController.view.setNeedsLayout()
        //表示
        present(alertController, animated: true, completion: nil)
    }

}
