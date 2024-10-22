import UIKit
import PhotosUI
import ParseSwift

class PostViewController: UIViewController {
    
    private var pickedImage: UIImage?
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray6
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let captionField: UITextField = {
        let field = UITextField()
        field.placeholder = "Write a caption..."
        field.borderStyle = .roundedRect
        field.backgroundColor = .systemBackground
        field.textColor = .label
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Share Post", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let pickPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Pick Photo", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "New Post"
        
        view.addSubview(imageView)
        view.addSubview(captionField)
        view.addSubview(pickPhotoButton)
        view.addSubview(shareButton)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            
            captionField.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            captionField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            captionField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            captionField.heightAnchor.constraint(equalToConstant: 44),
            
            pickPhotoButton.topAnchor.constraint(equalTo: captionField.bottomAnchor, constant: 16),
            pickPhotoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pickPhotoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            pickPhotoButton.heightAnchor.constraint(equalToConstant: 44),
            
            shareButton.topAnchor.constraint(equalTo: pickPhotoButton.bottomAnchor, constant: 16),
            shareButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            shareButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        pickPhotoButton.addTarget(self, action: #selector(pickPhotoTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
    }
    
    @objc private func shareTapped() {
        guard let image = pickedImage else {
            showAlert(title: "Error", message: "Please select an image first")
            return
        }
        
        // Disable buttons and show loading state
        shareButton.isEnabled = false
        pickPhotoButton.isEnabled = false
        
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.center = view.center
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)
        
        // Compress image
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            showAlert(title: "Error", message: "Failed to process image")
            return
        }
        
        print("📸 Image size: \(imageData.count) bytes")
        
        // Create Parse file
        let imageFile = ParseFile(name: "post_image.jpg", data: imageData)
        
        // First, save the image file
        imageFile.save { [weak self] result in
            switch result {
            case .success(let savedFile):
                print("✅ Image file saved successfully")
                print("📎 File URL: \(savedFile.url?.absoluteString ?? "no URL")")
                
                // Create and save post
                guard let user = User.current else {
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Error", message: "User not logged in")
                        loadingIndicator.removeFromSuperview()
                        self?.shareButton.isEnabled = true
                        self?.pickPhotoButton.isEnabled = true
                    }
                    return
                }
                
                var post = Post(caption: self?.captionField.text ?? "",
                              imageFile: savedFile,
                              user: user)
                
                
                post.save { result in
                    DispatchQueue.main.async {
                        loadingIndicator.removeFromSuperview()
                        self?.shareButton.isEnabled = true
                        self?.pickPhotoButton.isEnabled = true
                        
                        switch result {
                        case .success(let savedPost):
                            print("✅ Post saved successfully")
                            print("📝 Post ID: \(savedPost.objectId ?? "no ID")")
                            self?.navigationController?.popViewController(animated: true)
                            
                        case .failure(let error):
                            print("❌ Failed to save post: \(error)")
                            self?.showAlert(title: "Error",
                                          message: "Failed to save post: \(error.localizedDescription)")
                        }
                    }
                }
                
            case .failure(let error):
                print("❌ Failed to save image file: \(error)")
                DispatchQueue.main.async {
                    loadingIndicator.removeFromSuperview()
                    self?.shareButton.isEnabled = true
                    self?.pickPhotoButton.isEnabled = true
                    self?.showAlert(title: "Error",
                                  message: "Failed to upload image: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func pickPhotoTapped() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                    message: message,
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension PostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error",
                                  message: "Error selecting image: \(error.localizedDescription)")
                }
                return
            }
            
            guard let image = object as? UIImage else { return }
            
            DispatchQueue.main.async {
                self?.pickedImage = image
                self?.imageView.image = image
            }
        }
    }
}
