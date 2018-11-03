//
//  ChatViewController.swift
//  RealTimeChat
//
//  Created by 藤澤洋佑 on 2018/11/03.
//  Copyright © 2018年 Fujisawa-Yousuke. All rights reserved.
//

/*
 
 DatabaseURl:https://realtimechat-e6e96.firebaseio.com/
 
 */

import UIKit

class ChatViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    //投稿者と文字列を保持
    var messageArray: Array<(Bool, String)> = []
    
    //messageArrayに代入するBool値
    var messageBool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "customcell")
        
    }
    
    @IBAction func me(_ sender: Any) {
        messageBool = true
    }
    
    @IBAction func other(_ sender: Any) {
        messageBool = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "customcell", for: indexPath) as? TableViewCell else { return UITableViewCell() }
        
        //TableViewCellのtalk関数にBool値とテキストを渡す
        cell.talk(messageArray[indexPath.row].0, messageArray[indexPath.row].1)
        
        return cell
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //もし入力値があるなら、代入
        if let _ = textField.text {
            messageArray.append((messageBool,textField.text!))
        }
        
        //リロード
        tableView.reloadData()
        
        //セルが追加される度に自動スクロール
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tableView.scrollToRow(at: IndexPath(row: self.messageArray.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
        }
        
        return true
        
    }

}
