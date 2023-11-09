//
//  ProfileViewController.swift
//  ChatSwift
//
//  Created by Yogesh Lamba on 25/10/23.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    let data=["Log out"]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate=self
        tableView.dataSource=self
        tableView.tableHeaderView=createTableHeader()
    }
    func createTableHeader()->UIView?{
        
        //First we are finding the path by using safeurl,then we are downloading the url of image from firebase storage then we are using that url to actually download image and insert into image view
        
        guard let email=UserDefaults.standard.value(forKey: "email") else{
            return nil
        }
        print(email)
        let safeEmail=DatabaseManager.safeEmail(emailAddress: email as! String)
        print(safeEmail)
        let fileName=safeEmail+"_profile_picture.png"
        print(fileName)
        let path="images/"+fileName
        
        let headerView=UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 300))
        headerView.backgroundColor = .link
        let imageView=UIImageView(frame: CGRect(x: (headerView.width-150)/2, y: 75, width: 150, height: 150))
        
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.borderColor=UIColor.white.cgColor
        imageView.layer.borderWidth=3
        imageView.layer.masksToBounds=true
        imageView.layer.cornerRadius=imageView.width/2
        headerView.addSubview(imageView)
        
        StorageManager.shared.downloadURL(for: path) {[weak self] result in
            switch result{
            case .success(let url):
                self?.downloadImage(imageView: imageView, url: url)
            case .failure(let error):
                print(error)
            }
        }
        
        return headerView
    }
    
    func downloadImage(imageView:UIImageView,url:URL){
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data=data,error==nil else{
                return
            }
            DispatchQueue.main.async {
                let image=UIImage(data: data)
                imageView.image=image
            }
        }.resume()
    }
}

extension ProfileViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let actionSheet=UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: {[weak self] _ in
            
            do{
                try FirebaseAuth.Auth.auth().signOut()
                
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen  //Don't want card style such that user can't swipe down.
                self?.present(nav, animated: true)
            }
            catch{
                print("Failed to log out")
            }
             
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet, animated: true)
        
        
    }
    
}
