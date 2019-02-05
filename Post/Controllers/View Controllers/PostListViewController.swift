//
//  PostListViewController.swift
//  Post
//
//  Created by Chris Grayston on 2/4/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let postController = PostController()
    
    var refreshControl = UIRefreshControl()
    
        // MARK: - Life Cycle Methods
        override func viewDidLoad() {
            super.viewDidLoad()
            // Setting table view datasource and delegate
            tableView.delegate = self
            tableView.dataSource = self
    
            // Setting tableViewCells dynamic heights
            tableView.estimatedRowHeight = 45
            tableView.rowHeight = UITableView.automaticDimension
    
            // Setting up refresh control for tableView
            tableView.refreshControl = refreshControl
    
            // Setting refreshControl to call the refreshControlPulled function when user swipes down on the top of the tableView
            refreshControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
    
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            postController.fetchPosts {
                self.reloadTableView()
            }
        }
    
    
    // MARK: - Helper Methods
    @objc func refreshControlPulled() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        postController.fetchPosts {
            self.reloadTableView()
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    // Custom Reload Table View Function
    func reloadTableView() {
        DispatchQueue.main.async {
            // Add networkActivityIndiator to the reloadView function
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table View Delagate Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postController.posts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        
        let post = postController.posts[indexPath.row]
        
        cell.textLabel?.text = post.text
        if let date = post.date {
            cell.detailTextLabel?.text = "\(post.username) - \(date)"
        } else {
            cell.detailTextLabel?.text = "\(post.username) - \(Date(timeIntervalSince1970: post.timestamp))"
        }
        
        return cell
    }
    
    func presentNewPostAlert() {
        let newPostAlertController = UIAlertController(title: "New Post", message: nil, preferredStyle: .alert)
        
        var usernameTextField = UITextField()
        newPostAlertController.addTextField { (usernameTF) in
            usernameTF.placeholder = "Enter unsername..."
            usernameTextField = usernameTF
        }
        
        
        var messageTextField = UITextField()
        newPostAlertController.addTextField { (messageTF) in
            messageTF.placeholder = "Enter message here..."
            messageTextField = messageTF
        }
        
        let postAlertAction = UIAlertAction(title: "Save", style: .default) { (alert) in
            guard let username = usernameTextField.text, !username.isEmpty, let message = messageTextField.text, !message.isEmpty else {
                self.presentErrorAlert()
                return
                
            }
            
            self.postController.addNewPostWith(username: username, text: message, completion: {
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    //self.tableView.reloadData()
                    self.tableView.endUpdates()

                }
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        newPostAlertController.addAction(postAlertAction)
        newPostAlertController.addAction(cancelAction)
        
        self.present(newPostAlertController, animated: true)
    }
    
    func presentErrorAlert() {
        let alertController = UIAlertController(title: "Error", message: "You are missing information and should try again!", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
        
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        presentNewPostAlert()
    }
    
    
}

extension PostListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= postController.posts.count - 1 {
            postController.fetchPosts(reset: false) {
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
            }
        }
    }
}
