//
//  ChatViewController.swift
//  ChatSwift
//
//  Created by Yogesh Lamba on 01/11/23.
//

import UIKit
import MessageKit

struct Message:MessageType{
    var sender: MessageKit.SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKit.MessageKind
}

struct Sender:SenderType{
    var photoURL:String
    var senderId: String
    var displayName: String
}

class ChatViewController: MessagesViewController {

    private var messages=[Message]()
    private let selfSender=Sender(photoURL: "", senderId:"1", displayName: "test1")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind:.text("First Message.")))
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind:.text("First Message.First Message.First Message.First Message.First Message.First Message.")))
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind:.text("First Message.")))
        
        
        view.backgroundColor = .red
        
        messagesCollectionView.messagesDataSource=self
        messagesCollectionView.messagesLayoutDelegate=self
        messagesCollectionView.messagesDisplayDelegate=self
        
        messagesCollectionView.reloadData()
    }


}

extension ChatViewController:MessagesDataSource,MessagesLayoutDelegate,MessagesDisplayDelegate{
    var currentSender: MessageKit.SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
