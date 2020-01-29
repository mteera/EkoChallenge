//
//  ViewController.swift
//  EkoChallenge
//
//  Created by Chace Teera on 18/01/2020.
//  Copyright © 2020 chaceteera. All rights reserved.
//


import UIKit



class TableViewController: UITableViewController {
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        aiv.color = .darkGray
        aiv.startAnimating()
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    


    
    fileprivate var cellId = "cell"
    var users = [User]()
    
    var isPaginating = false
    var isDonePaginating = false
    var perPage = 60
    var usersSince = 0
    var loaded = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // No-storyboard approch as it is easier to maintain, less time spent rendering and better control when developing interface.

        view.addSubview(activityIndicatorView)
        activityIndicatorView.centerInSuperview()

        tableView.separatorColor = .clear

        registerCells()
        
        //Using singletons reduces massive view controllers, less DRY code and easier to maintain
            
            Service.shared.getUsers(usersSince: self.users.count, perPage: perPage) { (users, lastUserId, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }

                guard let users = users, let lastUserId = lastUserId else { return }

                self.users = users
                self.usersSince = lastUserId

                // tableView must be reloaded on the main thread.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    self.tableView.separatorColor = .systemGray4

                    self.activityIndicatorView.stopAnimating()
                    
                    self.tableView.reloadData()
                    self.loaded = true

                }

            }
        }

    fileprivate func registerCells() {
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: cellId)
    }
    

    
    func beginBatchFetch() {
        
        isPaginating = true
      
        Service.shared.getUsers(usersSince: usersSince, perPage: perPage) { (users, lastUserId, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }

            guard let users = users, let lastUserId = lastUserId else { return }
            
            if self.users.count == 0 {
                self.isDonePaginating = true
            }
            

            self.users += users
            self.usersSince = lastUserId

            DispatchQueue.main.async {
                self.tableView.reloadData()

            }
            self.isPaginating = false
        }

       
    }
    
     override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 20
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
            let titleLabel = UILabel(text: "Loading more...", font: .systemFont(ofSize: 16))

            let stackView = UIStackView(arrangedSubviews: [spinner, titleLabel], customSpacing: 8)
            stackView.axis = .vertical
            stackView.translatesAutoresizingMaskIntoConstraints = false
    
    
            tableView.tableFooterView = stackView
    
            stackView.centerInSuperview()

            self.tableView.tableFooterView?.isHidden = isDonePaginating ? false : true

            beginBatchFetch()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? CustomTableViewCell else { fatalError("Failed to initialise CustomTableViewCell")}
        cell.delegate = self
        cell.indexPath = indexPath
        var user = self.users[indexPath.row]
        
        
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "savedFavourite\(user.id)") != nil {
            user.isFavourite = true
        }

        cell.user = user

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.users[indexPath.row]
        let url = URL(string: user.url)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }


}

extension TableViewController: CustomTableViewCellDelegate {

    // Using delegates and protocols to pass data between views
    func handleFavourite(_ user: User, indexPath: IndexPath) {
        
        // Using UserDefaults as a quick solution to store and read favouriting

        let defaults = UserDefaults.standard

        let isFavourite = user.isFavourite
        
        if !isFavourite {
            defaults.set(user.id, forKey: "savedFavourite\(user.id)")
        } else {
            defaults.removeObject(forKey: "savedFavourite\(user.id)")
        }
        self.users[indexPath.item].isFavourite = !isFavourite
        self.tableView.reloadData()

    }
    

}







