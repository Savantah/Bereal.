import UIKit
import ParseSwift

class FeedViewController: UITableViewController {
    
    private var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPosts()
    }
    
    private func setupUI() {
        navigationItem.title = "BeReal."
        
       
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "PostCell")
        
       
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(fetchPosts), for: .valueChanged)
        
       
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "New Post",
                                                         style: .plain,
                                                         target: self,
                                                         action: #selector(newPostTapped))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout",
                                                          style: .plain,
                                                          target: self,
                                                          action: #selector(logoutTapped))
    }
    
    @objc private func fetchPosts() {
        let query = Post.query()
            .include("user")
            .order([.descending("createdAt")])
        
        query.find { [weak self] result in
            DispatchQueue.main.async {
                self?.refreshControl?.endRefreshing()
                
                switch result {
                case .success(let posts):
                    print("✅ Fetched \(posts.count) posts")
                    self?.posts = posts
                    self?.tableView.reloadData()
                    
                case .failure(let error):
                    print("❌ Error fetching posts: \(error)")
                }
            }
        }
    }
    
    @objc private func newPostTapped() {
        let postVC = PostViewController()
        navigationController?.pushViewController(postVC, animated: true)
    }
    
    @objc private func logoutTapped() {
        User.logout { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    let loginVC = LoginViewController()
                    self?.view.window?.rootViewController = loginVC
                case .failure(let error):
                    print("❌ Error logging out: \(error)")
                }
            }
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostTableViewCell else {
            return UITableViewCell()
        }
        
        let post = posts[indexPath.row]
        cell.configure(with: post)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
}
