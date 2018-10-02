//
//  ExtensionUIAlertController.swift
//  YJWeather
//
//  Created by 최영준 on 02/10/2018.
//  Copyright © 2018 최영준. All rights reserved.
//

import UIKit

extension UIAlertController {
    /// ok 버튼이 있는 Alert 컨트롤러를 생성후 반환한다
    func createAlertWithOkAction(_ message: String, completion: (() -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { (_) in
            completion?()
        }
        alert.addAction(okAction)
        return alert
    }
    /// ok, cancel 버튼이 있는 Alert 컨트롤러를 생성후 반환한다
    func createAlertWithOkCancelAction(_ message: String, completion: (() -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { (_) in
            completion?()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        return alert
    }
}
