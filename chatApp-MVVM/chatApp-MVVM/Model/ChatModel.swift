//
//  ChatModel.swift
//  chatApp-MVVM
//
//  Created by 木元健太郎 on 2021/09/23.
//

import RxSwift
import RxCocoa

//チャット データソースとなるstruct
struct Message {
    let message: String
    
    init(message:String) {
        self.message = message
    }
}


class MessageModel {
    
    var dataMessageRx = RxCocoa.BehaviorRelay<[Message]>(value: [])  //TableViewのデータソース。Variableがdeprecateになったので　BehaviorRelayを使用
    var data:[Message]? = []    //dataMessageRxを更新する為のデータを格納するオブジェクト
    var currentPage = 1         //現在のページ数
    
    var dataDB:[Message]? = []    //チャットメッセージのテストデータ。これは本来FirebaseなどのDB
    
    init() {
        
        //テストデータを作成
        for index in 1...208 {
            let messageStr = "message:\(index)"
            dataDB?.append(Message(message: messageStr))
        }
    }
    
    //ページ数に応じてデータを取得
    // 取得後、dataMessageRx のValueを変更する(=subscribeしている箇所を実行)
    func messagesGet() {
        
        //**** 表示するデータを取得してデータソースを更新(すると自動的にobserveしているプログラムが実行される)
        //      今回は配列だが、本来はFirebaseなどのDBからデータを取得する部分。
        //ページ数を考慮してデータを取得
        self.data = (dataDB?.suffix(20 * currentPage).map { $0 })!

        //取得したデータでobservableを変更
        self.dataMessageRx.accept(self.data!)
    }
    
    func messagesRx() -> RxCocoa.BehaviorRelay<[Message]> {
        //データ取得前に現カウントと取得しておいてから初期化
        self.data = []
        
        self.messagesGet()
        return self.dataMessageRx
    }
    
    func add(msg:String){
        //データソースを更新
        self.dataDB?.append(Message(message: msg))
        //self.data?.append(Message(message: msg))
        self.messagesGet()
        self.dataMessageRx.accept(self.data!)
    }
}
