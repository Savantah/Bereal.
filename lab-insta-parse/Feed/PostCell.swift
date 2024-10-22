import UIKit
import ParseSwift

class PostCell: UITableViewCell {
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    func configure(with post: Post) {
        captionLabel.text = post.caption
        
        if let date = post.createdAt {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            dateLabel.text = formatter.string(from: date)
        } else {
            dateLabel.text = "Unknown date"
        }
        
        if let userPointer = post.user {
            userPointer.fetch { [weak self] result in
                switch result {
                case .success(let user):
                    DispatchQueue.main.async {
                        self?.usernameLabel.text = user.username
                    }
                case .failure(let error):
                    print("Error fetching user: \(error)")
                    DispatchQueue.main.async {
                        self?.usernameLabel.text = "Unknown user"
                    }
                }
            }
        }
        
        if let imageFile = post.imageFile,
           let imageUrl = imageFile.url {
            URLSession.shared.dataTask(with: imageUrl) { [weak self] data, _, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.postImageView.image = image
                    }
                }
            }.resume()
        } else {
            postImageView.image = nil
        }
    }
}
