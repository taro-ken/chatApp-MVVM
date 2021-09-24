//
//  ChatControllerView.swift
//  chatApp-MVVM
//
//  Created by 木元健太郎 on 2021/09/23.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxKeyboard
import RxGesture

class ChatViewController: UIViewController, UITableViewDelegate, UITextViewDelegate {
    
    //UI
    var messageTableView: UITableView!
    var inputText = UITextView()
    var inputUIView = UIView()
    var chatUIView = UIView()
    var sendButton = UIButton()
    
    //RxSwift
    private let disposeBag = DisposeBag()
    private let chatViewMoel = ChatViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //******** UI create
        self.createUI()
        
        //******** RxSwift 関連の設定
        self.setRxSwift()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createUI() {
        self.navigationController?.isNavigationBarHidden = true
        self.view.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.92, alpha: 1.0)
        
        //**チャット UIView
        let frameUIView = CGRect(x: 0, y : 0, width: self.view.frame.width, height: self.view.frame.height)
        self.chatUIView = UIView(frame: frameUIView)
        
        //TableView
        let frame = CGRect(x: 0, y : 0, width: self.view.frame.width, height: self.view.frame.height - 50)
        messageTableView = UITableView(frame: frame)
        messageTableView.register(MessageTableViewCell.self, forCellReuseIdentifier: "MessageCell")
        messageTableView.backgroundColor = UIColor.clear
        messageTableView.allowsSelection = false;
        messageTableView.separatorStyle = .none
        messageTableView.estimatedRowHeight = 100
        messageTableView.rowHeight = UITableView.automaticDimension
        chatUIView.addSubview(messageTableView!)
        
        //**入力 UIView
        let frameUIViewInput = CGRect(x: 0, y : chatUIView.frame.height - 50, width: self.view.frame.width, height: 50)
        inputUIView = UIView(frame: frameUIViewInput)
        inputUIView.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.92, alpha: 1.0)
        chatUIView.addSubview(inputUIView)
        
        //テキスト
        inputText = UITextView (frame: CGRect(x: 5, y: 5 , width: self.view.frame.width - 70, height: 40))
        inputText.font = UIFont.systemFont(ofSize: 18)
        inputText.autocorrectionType = UITextAutocorrectionType.no
        inputText.keyboardType = UIKeyboardType.default
        inputText.returnKeyType = UIReturnKeyType.done
        inputUIView.addSubview(inputText)
        
        //送信ボタン
        sendButton = UIButton(frame: CGRect(x: self.view.frame.width - 60,y: 5,width: 50,height:40))
        sendButton.setTitle("send", for: .normal)
        sendButton.backgroundColor = UIColor(hue: 0, saturation: 0.73, brightness: 0.88, alpha: 1.0)
        sendButton.layer.cornerRadius = 10
        inputUIView.addSubview(sendButton)
        
        self.view.addSubview(chatUIView)
        
    }
    
    func setRxSwift() {
        
        //******** チャットのTableView
        //**** Delegateを設定
        messageTableView.rx
            .setDelegate(self as UITableViewDelegate)
            .disposed(by: disposeBag)
        
        //**** RxSwiftを使ったTableViewへのデータバインド
        chatViewMoel.dataMessageRx
            .bind(to: messageTableView!.rx.items(cellIdentifier: "MessageCell", cellType: MessageTableViewCell.self))
            { (row, element, cell) in
                cell.messageLabel.text = element.message
                cell.backgroundColor = UIColor.clear
            }
            .disposed(by: disposeBag)
        
        //**** DBに変更があった場合 リアルタイムにここが実行される。(BehaviorRelyを使用)
        chatViewMoel.dataMessageRx.asDriver()
            .drive(onNext: { message in
                //                    print(message)
                if (message.count > 0) {
                    self.messageTableView.reloadData()
                    
                    if (message.count == 20) {
                        //1ページしか表示していない場合は始めの表示なので一番下までスクロールする
                        self.messageTableView.scrollToRow(at: IndexPath(row: message.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)

                    } else if(message.count % 20 == 0) {
                        //1ページ以上なら最新より１ページ前を表示(row:20だと上手く表示されないので調整した)
                        self.messageTableView.scrollToRow(at: IndexPath(row: 20, section: 0), at: UITableView.ScrollPosition.top, animated: false)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        
        //**** 上までスクロールしたら過去データをロード
        //      contentOffset を監視する。
        messageTableView
            .rx.contentOffset
            .asObservable()
            .map {
                //$0.y ・・・　現在表示しているロケーション
                $0.y < -10
            }
            .distinctUntilChanged()
            .bind(to:chatViewMoel.scrollEndComing)  //ViewModelとバインド
            .disposed(by:disposeBag)
        
        //**** 画面をタップした時
        messageTableView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                //react to taps
                
                if (self.inputText.isFirstResponder) {
                    //KeyBoardが開いているので閉じる
                    self.inputText.resignFirstResponder()
                }
            })
            .disposed(by: disposeBag)

        
        //******** テキスト入力 UITextView
        inputText.rx
            .setDelegate(self as UITextViewDelegate)
            .disposed(by: disposeBag)
        
        
        //**** キーボード制御
        RxKeyboard.instance.frame
            .drive(onNext: { frame in
                if (frame.height > 0) {
                    let frame = CGRect(x: 0, y : self.view.frame.height - frame.height - 50, width: self.view.frame.width - 70, height: 50)
                    self.inputUIView.frame = frame
                }
            })
            .disposed(by: disposeBag)
        
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { keyboardVisibleHeight in
                if (keyboardVisibleHeight == 0) {
                    let frame = CGRect(x: 0, y : self.chatUIView.frame.height - 50, width: self.view.frame.width, height: 50)
                    self.inputUIView.frame = frame
                }
            })
            .disposed(by: disposeBag)
        
        
        //**** 送信ボタン
        sendButton.rx.tap
            .subscribe { [weak self] _ in
                
                if ((self?.inputText.text) != nil) {
                    //メッセージ登録処理 @ToDo Firebase使うならここでSetValue
                    self?.chatViewMoel.addMessage(msg: (self?.inputText.text)!)
                    
                    //キーボードを閉じる
                    self?.inputText.resignFirstResponder()
                    
                    //テキストを空白にする
                    self?.inputText.text = ""
                    
                    //送信したメッセージが見えるように下までスクロールする
                    self?.messageTableView.scrollToRow(at: IndexPath(row: (self?.chatViewMoel.getDataCount())!, section: 0),
                                                       at: UITableView.ScrollPosition.bottom, animated: true)
                }
            }
            .disposed(by: disposeBag)
        
    }
    
    //テキストが入力された時のイベント
    func textViewDidChange(_ textView: UITextView) {
        var frame = textView.frame
        
        //textViewのheightを変更
        if (textView.contentSize.height > 80) { //heightの上限を設定
            frame.size.height = 80
        } else {
            frame.size.height = textView.contentSize.height
        }
        textView.frame = frame
        
        //UIViewのheightを変更
        let frameView = CGRect(x: 0, y : self.inputUIView.frame.maxY - frame.size.height, width: self.view.frame.width, height: frame.size.height)
        self.inputUIView.frame = frameView
        
        
    }
    
}

