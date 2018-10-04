//
//  TutorialMasterViewController.swift
//  YJWeather
//
//  Created by 최영준 on 2018. 5. 15..
//  Copyright © 2018년 최영준. All rights reserved.
//

import UIKit

class TutorialMasterViewController: UIViewController {
    // MARK: - Properties
    // MARK: -
    private let contentsCount = 3
    
    // MARK: - View lifecycle
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let pageViewController = UIStoryboard(name: "Tutorial", bundle: Bundle.main).instantiateViewController(withIdentifier: "PageVC") as? UIPageViewController else {
            return
        }
        pageViewController.dataSource = self
        // 최초 노출될 콘텐츠 뷰 컨트롤러
        guard let startContentsVC = getContentsVC(0) else {
            return
        }
        // pageViewController의 기본 페이지 지정
        pageViewController.setViewControllers([startContentsVC], direction: .forward, animated: true, completion: nil)
        /* To do */
        // pageViewController의 출력 영역 지정
        if UIDevice.currentIPhone == .iPhoneX {
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
        /* End to do */
        // pageViewController TutorialMasterViewController의 자식 뷰 컨트롤러로 설정
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
        // pageControl 생성
        let pageControl = UIPageControl.appearance()
        pageControl.currentPageIndicatorTintColor = UIColor.black
        pageControl.pageIndicatorTintColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    }
    
    // MARK: - Custom methods
    // MARK: -
    private func getContentsVC(_ index: Int) -> UIViewController? {
        // 인덱스가 범위를 벗어나면 nil을 반환
        guard contentsCount >= index, contentsCount > 0 else {
            return nil
        }
        guard let contentsVC = UIStoryboard(name: "Tutorial", bundle: Bundle.main).instantiateViewController(withIdentifier: "ContentsVC") as? TutorialContentsViewController else {
            return nil
        }
        contentsVC.pageIndex = index
        return contentsVC
    }
    
    // MARK: - IBAction methods
    // MARk: -
    @IBAction func close(_ sender: Any) {
        let ud = UserDefaults.standard
        // 튜토리얼 자동 실행은 최초 1회만
        if ud.bool(forKey: "TUTORIAL") == false {
            ud.set(true, forKey: "TUTORIAL")
            ud.synchronize()
        }
        dismiss(animated: true, completion: nil)
    }
}

extension TutorialMasterViewController: UIPageViewControllerDataSource {
    // MARK: - UIPageViewControllerDataSource
    // MARK: -
    // 현재의 콘텐츠 뷰 컨트롤러보다 앞쪽에 올 콘텐츠 뷰 컨트롤러 객체
    // 즉, 현재의 상태에서 앞쪽으로 스와이프했을 때 보여줄 콘텐츠 뷰 컨트롤러 객체
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // 현재 페이지 인덱스
        guard let contentsVC = viewController as? TutorialContentsViewController else {
            return nil
        }
        // 현재 인덱스가 맨 앞이라면 nil을 반환하고 종료
        guard var index = contentsVC.pageIndex, index > 0 else {
            return nil
        }
        // 현재의 인덱스에서 하나 뺌(즉, 이전 페이지 인덱스)
        index -= 1
        return getContentsVC(index)
    }
    // 현재의 콘텐츠 뷰 컨트롤러보다 뒤쪽에 올 콘텐츠 뷰 컨트롤러 객체
    // 즉, 현재의 상태에서 뒤쪽으로 스와이프했을 때 보여줄 콘텐츠 뷰 컨트롤러 객체
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        // 현재 페이지 인덱스
        guard let contentsVC = viewController as? TutorialContentsViewController else {
            return nil
        }
        // 인덱스는 항상 배열 데이터의 크기보다 작아야 한다.
        guard var index = contentsVC.pageIndex, index + 1 < contentsCount else {
            return nil
        }
        // 현재의 인덱스에 하나를 더함(즉, 다음 페이지 인덱스)
        index += 1
        return getContentsVC(index)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return contentsCount
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

