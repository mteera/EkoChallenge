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
    var perPage = 20
    var usersSince = 0
    var loaded = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(activityIndicatorView)
        activityIndicatorView.centerInSuperview()

        tableView.separatorColor = .clear

        registerCells()
            
            Service.shared.getUsers(usersSince: self.users.count, perPage: perPage) { (users, lastUserId, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }

                guard let users = users, let lastUserId = lastUserId else { return }

                self.users = users
                self.usersSince = lastUserId

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
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
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


            self.tableView.tableFooterView = spinner
            self.tableView.tableFooterView?.isHidden = isDonePaginating ? true : false

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
        let user = self.users[indexPath.row]
        cell.user = user

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }


}

extension TableViewController: CustomTableViewCellDelegate {

    
    func handleFavourite(_ user: User, indexPath: IndexPath) {

        let isFavourite = user.isFavourite
        self.users[indexPath.item].isFavourite = !isFavourite
        self.tableView.reloadData()

    }
    

}







