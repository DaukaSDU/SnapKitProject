import UIKit
import SnapKit
import AlamofireImage
import Alamofire

protocol NewCellDelegate: AnyObject {
    func didToggleLike(for id: String, isLiked: Bool)
}

class NewCell: UICollectionViewCell {
    weak var delegate: NewCellDelegate?
    private var id: String?
    
    private let newImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .lightGray
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .lightGray
        label.numberOfLines = 3
        return label
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .red
        return button
    }()

    private var isLiked: Bool = false {
        didSet {
            let imageName = isLiked ? "heart.fill" : "heart"
            likeButton.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        newImage.af.cancelImageRequest()
        newImage.image = nil
    }
    
    private func layoutUI() {
        layer.cornerRadius = 16
        layer.masksToBounds = true
        backgroundColor = .white
        
        [newImage, titleLabel, dateLabel, contentLabel].forEach {
            addSubview($0)
        }
        
        newImage.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(8)
            make.top.equalTo(newImage.snp.bottom).offset(8)
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(8)
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
        }
        
        contentLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(8)
            make.top.equalTo(dateLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview().inset(8)
        }
        
        addSubview(likeButton)
        likeButton.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(8)
            make.width.height.equalTo(24)
        }
    }
    
    func configure(data: New) {
        id = data.url ?? "LikedNew"
        guard
            let imageUrl = data.urlToImage,
            let url = URL(string: imageUrl)
        else { return }
        
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: url) else { return }
            DispatchQueue.main.async { [weak self] in
                self?.newImage.image = UIImage(data: imageData)
            }
        }
        titleLabel.text = data.title ?? ""
        if let publishedDate = data.publishedAt {
            dateLabel.text = formatDate(publishedDate: publishedDate)
        }
        isLiked = data.isLiked ?? false
        contentLabel.text = data.content ?? ""
    }
        
    private func formatDate(publishedDate: String) -> String {
        let dbDateFormatter = DateFormatter()
        dbDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        if let date = dbDateFormatter.date(from: publishedDate){
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            let todaysDate = dateFormatter.string(from: date)
            return  "Published : " + todaysDate
        }
        
        return publishedDate
    }
    
    private func setupActions() {
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
    }

    @objc private func didTapLike() {
        guard let id = id else { return }
        isLiked.toggle()
        
        var likedArticles = UserDefaults.standard.array(forKey: "likedArticles") as? [String] ?? []
        if isLiked {
            likedArticles.append(id)
        } else {
            likedArticles.removeAll { $0 == id }
        }
        UserDefaults.standard.set(likedArticles, forKey: "likedArticles")
        
        delegate?.didToggleLike(for: id, isLiked: isLiked)
    }
}
