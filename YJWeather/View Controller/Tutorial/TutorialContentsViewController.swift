//
//  TutorialContentsViewController.swift
//  YJWeather
//
//  Created by 최영준 on 2018. 5. 15..
//  Copyright © 2018년 최영준. All rights reserved.
//

import UIKit

class TutorialContentsViewController: UIViewController {
    // MARK: - Properties
    // MARK: -
    var pageIndex: Int?
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var descriptionView: UIView!
    @IBOutlet var thermometerImageView: UIImageView!
    @IBOutlet var umbrellaImageView: UIImageView!
    @IBOutlet var humidityImageView: UIImageView!
    @IBOutlet var windImageView: UIImageView!
    @IBOutlet var windDegImageView: UIImageView!
    
    // MARK: - View lifecycle
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let pageIndex = pageIndex else {
            return
        }
        if pageIndex < 2 {
            // 전달받은 이미지 정보를 이미지 뷰에 대입한다.
            imageView.image = UIImage(named: "tutorial\(pageIndex+1)")
            imageView.isHidden = false
            descriptionView.isHidden = true
        } else {
            imageView.isHidden = true
            descriptionView.isHidden = false
            initializeDescriptionView()
        }
    }
    
    // MARK: - Custom methods
    // MARK: -
    func initializeDescriptionView() {
        descriptionView.layer.cornerRadius = 10
        view.bringSubview(toFront: descriptionView)
        thermometerImageView.image = thermometerImageView.image?.withRenderingMode(.alwaysTemplate)
        thermometerImageView.tintColor = UIColor.white
        umbrellaImageView.image = umbrellaImageView.image?.withRenderingMode(.alwaysTemplate)
        umbrellaImageView.tintColor = UIColor.white
        humidityImageView.image = humidityImageView.image?.withRenderingMode(.alwaysTemplate)
        humidityImageView.tintColor = UIColor.white
        windImageView.image = windImageView.image?.withRenderingMode(.alwaysTemplate)
        windImageView.tintColor = UIColor.white
        windDegImageView.image = windDegImageView.image?.withRenderingMode(.alwaysTemplate)
        windDegImageView.tintColor = UIColor.white
    }
}
