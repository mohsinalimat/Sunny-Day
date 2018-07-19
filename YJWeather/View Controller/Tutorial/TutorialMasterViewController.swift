//
//  TutorialMasterViewController.swift
//  YJWeather
//
//  Created by 최영준 on 2018. 5. 15..
//  Copyright © 2018년 최영준. All rights reserved.
//

import UIKit

class TutorialMasterViewController: UIViewController, UIPageViewControllerDataSource {

    private var pageViewController: UIPageViewController!
    private let contentCount = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pageViewController = UIStoryboard(name: "Tutorial", bundle: Bundle.main).instantiateViewController(withIdentifier: "PageVC") as! UIPageViewController
        pageViewController.dataSource = self
        
        // 페이지 뷰 컨트롤러의 기본 페이지 지정
        let startContentVC = getContentVC(atIndex: 0)! // 최초 노출될 콘텐츠 뷰 컨트롤러
        pageViewController.setViewControllers([startContentVC], direction: .forward, animated: true, completion: nil)
        
        // 페이지 뷰 컨트롤러의 출력 영역 지정
        if AppDelegate.isIPhoneX() {
            pageViewController.view.frame.origin = CGPoint(x: 0, y: 120)
            pageViewController.view.frame.size.width = UIScreen.main.bounds.width
            pageViewController.view.frame.size.height = UIScreen.main.bounds.height - 200
        } else {
            let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
            
            // 전화 상태일 경우
            if statusBarHeight == 40 {
                pageViewController.view.frame.origin = CGPoint(x: 0, y: 0)
                pageViewController.view.frame.size.width = UIScreen.main.bounds.width
                pageViewController.view.frame.size.height = UIScreen.main.bounds.height - 60
                
            } else {
                pageViewController.view.frame.origin = CGPoint(x: 0, y: 0)
                pageViewController.view.frame.size.width = UIScreen.main.bounds.width
                pageViewController.view.frame.size.height = UIScreen.main.bounds.height - 40
            }
        }
        
        
        // 페이지 뷰 컨트롤러를 마스터 뷰 컨트롤러의 자식 뷰 컨트롤러로 설정
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
        
        
        let pageControl = UIPageControl.appearance()
        pageControl.currentPageIndicatorTintColor = UIColor.black
        pageControl.pageIndicatorTintColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    }
    
    private func getContentVC(atIndex idx: Int) -> UIViewController? {
        // 인덱스가 범위를 벗어나면 nil을 반환
        guard contentCount >= idx && contentCount > 0 else {
            return nil
        }
        
        guard let cvc = UIStoryboard(name: "Tutorial", bundle: Bundle.main).instantiateViewController(withIdentifier: "ContentsVC") as? TutorialContentsViewController else {
            return nil
        }
        
        cvc.pageIndex = idx
        
        if idx == 0 {
            cvc.imageFile = "tutorial1"
        } else if idx == 1 {
            cvc.imageFile = "tutorial2"
        }
        
        return cvc
    }
    
    @IBAction func close(_ sender: Any) {
        let ud = UserDefaults.standard
        
        if ud.bool(forKey: "TUTORIAL") == false {
            ud.set(true, forKey: "TUTORIAL")
            ud.synchronize()
        }
        
        dismiss(animated: true, completion: nil)
        //presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: PageViewController data source methods
    
    // 현재의 콘텐츠 뷰 컨트롤러보다 앞쪽에 올 콘텐츠 뷰 컨트롤러 객체
    // 즉, 현재의 상태에서 앞쪽으로 스와이프했을 때 보여줄 콘텐츠 뷰 컨트롤러 객체
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        // 현재 페이지 인덱스
        guard var index = (viewController as! TutorialContentsViewController).pageIndex else {
            return nil
        }
        
        // 현재 인덱스가 맨 앞이라면 nil을 반환하고 종료
        guard index > 0 else {
            return nil
        }
        
        index -= 1 // 현재의 인덱스에서 하나 뺌(즉, 이전 페이지 인덱스)
        return self.getContentVC(atIndex: index)
    }
    
    // 현재의 콘텐츠 뷰 컨트롤러보다 뒤쪽에 올 콘텐츠 뷰 컨트롤러 객체
    // 즉, 현재의 상태에서 뒤쪽으로 스와이프했을 때 보여줄 콘텐츠 뷰 컨트롤러 객체
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        // 현재의 페이지 인덱스
        guard var index = (viewController as! TutorialContentsViewController).pageIndex else {
            return nil
        }
        
        index += 1 // 현재의 인덱스에 하나를 더함(즉, 다음 페이지 인덱스)
        
        // 인덱스는 항상 배열 데이터의 크기보다 작아야 한다.
        guard index < contentCount else {
            return nil
        }
        
        return self.getContentVC(atIndex: index)
    }
    
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return contentCount
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

