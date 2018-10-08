//
//  TutorialViewController.swift
//  YJWeather
//
//  Created by 최영준 on 08/10/2018.
//  Copyright © 2018 최영준. All rights reserved.
//

import UIKit

class TutorialViewController: UIPageViewController {
    // MARK: - Properties
    // MARK: -
    let contentsCount = 2
    
    // MARK: - Initializer
    // MARK: -
    required init?(coder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    // MARK: - View lifecycle
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        let ud = UserDefaults.standard
        // 튜토리얼 자동 실행은 최초 1회만
        if ud.bool(forKey: "TUTORIAL") == true {
            dismiss(animated: true, completion: nil)
        }
        guard let startVC = getContentsVC(0) else {
            return
        }
        setViewControllers([startVC], direction: .forward, animated: true, completion: nil)
        dataSource = self
        // pageControl 생성
        let pageControl = UIPageControl.appearance()
        pageControl.currentPageIndicatorTintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        pageControl.pageIndicatorTintColor = UIColor.white
    }
    
    // MARK: - Custom methods
    // MARK: -
    private func getContentsVC(_ index: Int) -> UIViewController? {
        // 인덱스가 범위를 벗어나면 nil을 반환
        guard contentsCount >= index, contentsCount > 0 else {
            return nil
        }
        guard let contenstsVC = UIStoryboard(name: "Tutorial", bundle: Bundle.main).instantiateViewController(withIdentifier: "TutorialContentsVC") as? TutorialContentsViewController else {
            return nil
        }
        contenstsVC.pageNum = index
        return contenstsVC
    }
}

extension TutorialViewController: UIPageViewControllerDataSource {
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
        guard var index = contentsVC.pageNum, index > 0 else {
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
        guard var index = contentsVC.pageNum, index + 1 < contentsCount else {
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


