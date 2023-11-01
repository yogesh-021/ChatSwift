//
//  NewConversationViewController.swift
//  ChatSwift
//
//  Created by Yogesh Lamba on 25/10/23.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    private let spinner=JGProgressHUD()
    
    private let searchBar:UISearchBar={
        let searchBar=UISearchBar()
        searchBar.placeholder="Search for Users..."
        return searchBar
    }()
    
    private let noResultsLabel:UILabel={
        let label=UILabel()
        label.text="No Results!"
        label.textColor = .gray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 21, weight: .medium )
        label.isHidden=true
        return label
    }()
    
    private let tableView:UITableView={
        let table=UITableView()
        table.isHidden=true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate=self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView=searchBar
        navigationItem.rightBarButtonItem=UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        
        searchBar.becomeFirstResponder()
    }
    @objc private func dismissSelf(){
        dismiss(animated: true)
    }
}

extension NewConversationViewController:UISearchBarDelegate{
    
}
