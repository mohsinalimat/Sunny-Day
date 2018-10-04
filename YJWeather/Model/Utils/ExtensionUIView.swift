//
//  ExtensionUIView.swift
//  YJWeather
//
//  Created by 최영준 on 02/10/2018.
//  Copyright © 2018 최영준. All rights reserved.
//

import UIKit

extension UIView {
    // MARK: - Animation effect
    // MARK: -
    /* To do */
    func degreesToRadian(_ degrees: CGFloat) -> CGFloat {
        return (degrees * CGFloat(Double.pi)) / 180.0
    }
    
    func startShakeAnimation() {
        let degrees: CGFloat = 5
        let option = [
            [0.0, degreesToRadian(-degrees) * 0.2,
             0.0, degreesToRadian(degrees) * 0.2,
             0.0, degreesToRadian(-degrees) * 0.2,
             0.0, degreesToRadian(degrees) * 0.2,
             0.0],
            [0.0, degreesToRadian(degrees) * 0.2,
             0.0, degreesToRadian(-degrees) * 0.2,
             0.0, degreesToRadian(degrees) * 0.2,
             0.0, degreesToRadian(-degrees) * 0.2,
             0.0]
        ]
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        animation.duration = 0.5
        // isCumulative: true 인 경우 속성의 값은 이전 반복주기 끝에 값과 현재 반복주기의 값을 더한 값. false 인 경우, 프로퍼티의 값은 단순히 현재 반복 사이클에 대해 계산 된 값.
        animation.isCumulative = true
        animation.repeatCount = Float.infinity
        animation.values = option[Int(arc4random() % 2)]
        // fillMode: 이 상수는 활성 기간이 완료된 후 시간 지정 객체가 작동하는 방식을 결정, fillMode 속성과 함께 사용
        //animation.fillMode = kCAFillModeForwards
        
        // timingFunction: 애니메이션의 페이싱을 정의하는 선택적 타이밍 함수, 기본값은 선형 페이싱을 나타내는 nil.
        //animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        layer.add(animation, forKey: "shake")
    }
    
    func stopShakeAnimation() {
        layer.removeAllAnimations()
        transform = CGAffineTransform.identity
    }
    /* End to do */
}
