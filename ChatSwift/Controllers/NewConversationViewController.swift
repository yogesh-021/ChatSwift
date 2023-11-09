//
//  NewConversationViewController.swift
//  ChatSwift
//
//  Created by Yogesh Lamba on 25/10/23.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    public var completion:(([String:String])->(Void))?
    private let spinner=JGProgressHUD(style: .dark)
    private var users=[[String:String]]()
    private var results=[[String:String]]()
    private var hasFetched=false
    
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
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
        
        tableView.delegate=self
        tableView.dataSource=self
        searchBar.delegate=self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView=searchBar
        navigationItem.rightBarButtonItem=UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame=view.frame
        noResultsLabel.frame=CGRect(x: view.width/4, y: (view.height-200)/2, width: view.width/2, height: 200)
    }
    
    @objc private func dismissSelf(){
        dismiss(animated: true)
    }
}

extension NewConversationViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Start New Conversation
        let targetUserData=results[indexPath.row]
    }
    
}

extension NewConversationViewController:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text=searchBar.text,!text.replacingOccurrences(of: " ", with: "").isEmpty else{
            return
        }
        
        searchBar.resignFirstResponder()
        
        results.removeAll()
        spinner.show(in: view)
        
        self.searchUsers(query: text)
    }
    
    func searchUsers(query:String){
        //we dont want to retrieve from firebase every time so we create an array ,if it is not present in array then we retrieve otherwise use array
        
        //check if array has firebase results
        if hasFetched{
            //if it does:fiter
            filterUsers(with: query)
        }
        else{
            //if not,fetch and filter
            DatabaseManager.shared.getAllUsers { [weak self] result in
                switch result{
                case .success(let userCollection):
                    self?.hasFetched=true
                    self?.users=userCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get users \(error)")
                }
            }
        }
    }
        
    func filterUsers(with term:String){
        //update UI either showResults or show noresults
        guard hasFetched else{
            return
        }
        self.spinner.dismiss()
        let results:[[String:String]] = self.users.filter({
            guard let name=$0["name"]?.lowercased() else{
                return false
            }
            return name.hasPrefix(term.lowercased())
        })
        self.results=results
        updateUI()
    }
    
    func updateUI(){
        if results.isEmpty{
            noResultsLabel.isHidden=false
            tableView.isHidden=true
        }
        else{
            noResultsLabel.isHidden=true
            tableView.isHidden=false
            tableView.reloadData()
        }
    }
}
