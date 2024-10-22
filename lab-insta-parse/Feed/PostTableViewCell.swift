import UIKit
import ParseSwift

class PostTableViewCell: UITableViewCell {
    
    private let postImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray6
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    static var imageCache: [String: UIImage] = [:]
    private var currentDataTask: URLSessionDataTask?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .black
        contentView.backgroundColor = .black
        
        contentView.addSubview(postImageView)
        contentView.addSubview(captionLabel)
        contentView.addSubview(dateLabel)
        postImageView.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            postImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            postImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            postImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            postImageView.heightAnchor.constraint(equalToConstant: 300),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: postImageView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: postImageView.centerYAnchor),
            
            captionLabel.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 8),
            captionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            captionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            dateLabel.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with post: Post) {
        captionLabel.text = post.caption
        
        if let date = post.createdAt {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            dateLabel.text = formatter.string(from: date)
        }
        
        loadImage(from: post)
    }
    
    private func loadImage(from post: Post) {
        // Cancel any existing data task
        currentDataTask?.cancel()
        
        // Reset image and start loading indicator
        postImageView.image = nil
        loadingIndicator.startAnimating()
        
        // Check cache first
        if let objectId = post.objectId,
           let cachedImage = PostTableViewCell.imageCache[objectId] {
            postImageView.image = cachedImage
            loadingIndicator.stopAnimating()
            return
        }
        
        guard let imageFile = post.imageFile,
              let url = imageFile.url else {
            print("❌ No valid image URL found")
            loadingIndicator.stopAnimating()
            return
        }
        
        let request = URLRequest(url: url)
        
        currentDataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Failed to load image: \(error)")
                    self?.loadingIndicator.stopAnimating()
                    return
                }
                
                guard let data = data,
                      let image = UIImage(data: data) else {
                    print("❌ Failed to create image from data")
                    self?.loadingIndicator.stopAnimating()
                    return
                }
                
                // Cache the image
                if let objectId = post.objectId {
                    PostTableViewCell.imageCache[objectId] = image
                }
                
                // Update UI
                self?.postImageView.image = image
                self?.loadingIndicator.stopAnimating()
                print("✅ Successfully loaded image for post: \(post.objectId ?? "unknown")")
            }
        }
        
        currentDataTask?.resume()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        currentDataTask?.cancel()
        postImageView.image = nil
        captionLabel.text = nil
        dateLabel.text = nil
        loadingIndicator.stopAnimating()
    }
}
