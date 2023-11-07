//
//  ViewController.swift
//  ChatSwift
//
//  Created by Yogesh Lamba on 25/10/23.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class ConversationsViewController: UIViewController {
    
    let spinner=JGProgressHUD(style: .dark)

    private let  tableView:UITableView = {
        let table=UITableView()
        table.isHidden=true //to only show when they had conversations
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let noConversationsLabel:UILabel={
        let label=UILabel()
        label.text="No Conversations!"
        label.textColor = .gray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 21, weight: .medium )
        label.isHidden=true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = false
        navigationItem.rightBarButtonItem=UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
        
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
        setUpTableView()
        fetchConversations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Check if user is already logged in
        validateAuth()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame=view.bounds
    }
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil{
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen  //Don't want card style such that user can't swipe down.
            self.present(nav, animated: false)
        }
    }

    private func setUpTableView(){
        tableView.delegate=self
        tableView.dataSource=self
    }
    
    private func fetchConversations(){
        tableView.isHidden=false
    }
    
    @objc private func didTapComposeButton(){
        let vc=NewConversationViewController()
        let navVC=UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
}


extension ConversationsViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
        cell.textLabel?.text="Hello World!"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc=ChatViewController()
        vc.title="Mohan"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
