import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let tabBarController = UITabBarController()
        
        let newsPage = NewsController(viewModel: NewsViewModel(newsService: NewsServiceImpl()))
        let sportsPage = SportsController()
        newsPage.tabBarItem = UITabBarItem(title: "News+", image: UIImage(systemName: "newspaper.fill"), tag: 0)
        sportsPage.tabBarItem = UITabBarItem(title: "Sports", image: UIImage(systemName: "sportscourt.fill"), tag: 1)
        
        tabBarController.viewControllers = [newsPage, sportsPage]
        // Set the background color of the tab bar
        tabBarController.tabBar.barTintColor = .white

        // Set the color of the selected tab item
        tabBarController.tabBar.tintColor = .systemPink

        // Set the color of unselected tab items
        tabBarController.tabBar.unselectedItemTintColor = .gray
        window?.rootViewController = UINavigationController(rootViewController: tabBarController)
        window?.makeKeyAndVisible()
    }
}
