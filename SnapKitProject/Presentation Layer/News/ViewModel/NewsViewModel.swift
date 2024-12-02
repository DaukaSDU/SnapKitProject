import Foundation

final class NewsViewModel {
    // MARK: Properties
    private let newsService: NewsService
    var news: [New] = []
    
    // MARK: Callbacks
    var didLoadNews: (([New]) -> Void)?
    
    // MARK: Init
    init(newsService: NewsService) {
        self.newsService = newsService
    }
    
    func getTopHeadLines() {
        newsService.getTopHeadLines(
            success: { [weak self] news in
                self?.news = news
                self?.didLoadNews?(news)
            },
            failure: { error in
                print(error.localizedDescription.description)
            }
        )
    }
    
    func saveLikedArticles() {
        let likedArticles = news.filter { $0.isLiked ?? false }
        let likedIDs = likedArticles.compactMap { $0.url }
        UserDefaults.standard.set(likedIDs, forKey: "likedArticles")
    }
    
    func loadLikedArticles() {
        let likedArticles = UserDefaults.standard.array(forKey: "likedArticles") as? [String] ?? []
        
        news = news.map { article in
            var updatedArticle = article
            updatedArticle.isLiked = likedArticles.contains(article.url ?? "")
            return updatedArticle
        }
    }
}
