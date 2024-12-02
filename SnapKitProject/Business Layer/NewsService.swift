import Foundation
import Alamofire
import AlamofireImage

protocol NewsService {
    func getTopHeadLines(success: @escaping ([New]) -> Void, failure: @escaping (Error) -> Void)
    func getTopHeadLinesWithURLSession(success: @escaping ([New]) -> Void, failure: @escaping (Error) -> Void)

}

class NewsServiceImpl: NewsService {
    func getTopHeadLines(success: @escaping ([New]) -> Void, failure: @escaping (Error) -> Void) {
        let urlString = String(format: "%@top-headlines", NewsApi.baseUrl)
        guard let url = URL(string: urlString) else { return }
        
        let queryParams: Parameters = ["apiKey": NewsApi.apiKey, "country": NewsApi.country]
        
        AF.request(url, method: .get, parameters: queryParams).responseDecodable { (response: DataResponse<NewsWrapper, AFError>) in
            switch response.result {
            case .success(let newsData):
                success(newsData.articles)
            case .failure(let error):
                failure(error)
            }
        }
    }
    
    // service Detail News
    
    // search
    
    
    func getTopHeadLinesWithURLSession(success: @escaping ([New]) -> Void, failure: @escaping (Error) -> Void) {
        let urlString = String(format: "%@top-headlines", NewsApi.baseUrl)
        guard var urlComponents = URLComponents(string: urlString) else {
            failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil))
            return
        }

        // Set query parameters
        urlComponents.queryItems = [
            URLQueryItem(name: "apiKey", value: NewsApi.apiKey),
            URLQueryItem(name: "country", value: NewsApi.country)
        ]
        
        // Ensure the URL is valid after adding query parameters
        guard let url = urlComponents.url else {
            failure(NSError(domain: "Invalid URL components", code: -1, userInfo: nil))
            return
        }

        // Create the URLSession data task
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Check if there was an error
            if let error = error {
                failure(error)
                return
            }

            // Check if the response is valid and if we have data
            guard let data = data else {
                failure(NSError(domain: "No data received", code: -1, userInfo: nil))
                return
            }

            do {
                // Decode the data into your NewsWrapper model
                let decoder = JSONDecoder()
                let newsData = try decoder.decode(NewsWrapper.self, from: data)

                // Call success handler with the articles
                success(newsData.articles)
            } catch {
                // Handle decoding errors
                failure(error)
            }
        }
        
        // Start the task
        task.resume()
    }

}
