import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    lazy var pages = [UIViewController]()
    var pageControl = UIPageControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        guard
            let ipv4Page = storyboard?.instantiateViewController(withIdentifier: "IPv4ViewController"),
            let ipTrackingPage = storyboard?.instantiateViewController(withIdentifier: "IPTrackingViewController")
            else {
                return
        }
        
        pages.append(ipv4Page)
        pages.append(ipTrackingPage)
        
        setViewControllers([ipv4Page], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
        
        self.delegate = self
        self.dataSource = self
        
        pageControl = UIPageControl(frame: CGRect(x: 0,
                                                  y: UIScreen.main.bounds.maxY - 50,
                                                  width: UIScreen.main.bounds.width,
                                                  height: 50))
        
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.darkGray
        self.view.addSubview(pageControl)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard
            let currentIndex = pages.index(of: viewController)
        else {
                return nil
        }
        
        if currentIndex == 0 {
            return nil
        }
        
        let previousIndex = abs((currentIndex - 1) % pages.count)
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard
            let currentIndex = pages.index(of: viewController)
        else {
            return nil
        }
        
        if currentIndex == pages.count - 1 {
            return nil
        }
        
        let nextIndex = abs((currentIndex + 1) % pages.count)
        
        return pages[nextIndex]
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard
            let controllers = pageViewController.viewControllers,
            let currentPageIndex = pages.index(of: controllers[0])
        else {
            return
        }
        self.pageControl.currentPage = currentPageIndex
    }
}
