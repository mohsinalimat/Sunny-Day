//
//  AirPollutionCell.swift
//  YJWeather
//
//  Created by 최영준 on 2018. 5. 14..
//  Copyright © 2018년 최영준. All rights reserved.
//

import UIKit

class AirPollutionCell: UICollectionViewCell {
    // MARK: - Properties
    // MARK: -
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var gradeLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    
    // MARK: - Initializer
    // MARK: -
    override func awakeFromNib() {
        super.awakeFromNib()
        setTintColor((UIApplication.shared.delegate as? AppDelegate)?.tintColorType ?? .white)
    }
    
    // MARK: - Custom methods
    // MARK: -
    /// 이미지, 텍스트 색상을 설정한다
    private func setTintColor(_ type: TintColorType) {
        var color: UIColor
        switch type {
        case .white:
            color = .white
        case .black:
            color = .black
        }
        titleLabel.textColor = color
        gradeLabel.textColor = color
        valueLabel.textColor = color
    }
}

