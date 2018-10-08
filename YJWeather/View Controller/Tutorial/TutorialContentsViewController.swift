//
//  TutorialContentsViewController.swift
//  YJWeather
//
//  Created by 최영준 on 08/10/2018.
//  Copyright © 2018 최영준. All rights reserved.
//

import UIKit

class TutorialContentsViewController: UIViewController {
    // MARK: - Properties
    // MARK: -
    var pageNum: Int?
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageViewWidth: NSLayoutConstraint!
    @IBOutlet var imageViewHeight: NSLayoutConstraint!
    @IBOutlet var descriptionView: UIView! {
        didSet {
            descriptionView.layer.cornerRadius = 10
        }
    }
    @IBOutlet var thermometerImageView: UIImageView! {
        didSet {
            thermometerImageView.image = thermometerImageView.image?.withRenderingMode(.alwaysTemplate)
            thermometerImageView.tintColor = UIColor.white
        }
    }
    @IBOutlet var umbrellaImageView: UIImageView! {
        didSet {
            umbrellaImageView.image = umbrellaImageView.image?.withRenderingMode(.alwaysTemplate)
            umbrellaImageView.tintColor = UIColor.white
        }
    }
    @IBOutlet var humidityImageView: UIImageView! {
        didSet {
            humidityImageView.image = humidityImageView.image?.withRenderingMode(.alwaysTemplate)
            humidityImageView.tintColor = UIColor.white
        }
    }
    @IBOutlet var windImageView: UIImageView! {
        didSet {
            windImageView.image = windImageView.image?.withRenderingMode(.alwaysTemplate)
            windImageView.tintColor = UIColor.white
        }
    }
    @IBOutlet var windDegImageView: UIImageView! {
        didSet {
            windDegImageView.image = windDegImageView.image?.withRenderingMode(.alwaysTemplate)
            windDegImageView.tintColor = UIColor.white
        }
    }
    
    // MARK: - View lifecycle
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        if pageNum == 0 {
            descriptionView.isHidden = true
        } else {
            imageView.isHidden = true
        }
        switch UIDevice.currentIPhone {
        case .iPhoneMax, .iPhonePlus:
            imageViewWidth.constant = 354
            imageViewHeight.constant = 601
        case .iPhoneX, .iPhone:
            imageViewWidth.constant = 315
            imageViewHeight.constant = 535
        case .iPhoneSE:
            imageViewWidth.constant = 260
            imageViewHeight.constant = 442
        case .otherDevice:
            ()
        }
    }
    
    // MARK: - IBAction methods
    // MARK: -
    @IBAction func startAction(_ sender: Any) {
        let ud = UserDefaults.standard
        // 튜토리얼 자동 실행은 최초 1회만
        if ud.bool(forKey: "TUTORIAL") == false {
            ud.set(true, forKey: "TUTORIAL")
            ud.synchronize()
        }
        dismiss(animated: true, completion: nil)
    }
}
