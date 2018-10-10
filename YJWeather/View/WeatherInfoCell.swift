//
//  WeatherInfoCell.swift
//  YJWeather
//
//  Created by 최영준 on 2018. 5. 14..
//  Copyright © 2018년 최영준. All rights reserved.
//

import UIKit

class ExpandingTableViewCellContent {
    var totalData: TotalData
    var expanded: Bool
    var isEditing: Bool
    init(data: TotalData) {
        totalData = data
        self.expanded = false
        self.isEditing = false
    }
}

enum TintColorType {
    case white, black
}

class WeatherInfoCell: UITableViewCell {
    // MARK: - Custom enumerations
    // MARK: -
    private enum AirPollutionIndex: Int {
        case khai, pm10, pm25, co, no2, o3, so2
    }
    
    enum BackgroundColorType {
        case sky, air
    }
    
    // MARK: - Properties
    // MARK: -
    private var weatherRealtime: WeatherRealtimeData?
    private var weatherLocals: [WeatherLocalData]?
    private var airPollution : AirPollutionData?
    private var airPollutionCount = 7
    @IBOutlet var deleteButton: UIButton! {
        didSet {
            deleteButton.layer.cornerRadius = deleteButton.frame.width / 2
        }
    }
    @IBOutlet private var bgView: UIView! {
        didSet {
            bgView.layer.cornerRadius = 10
        }
    }
    @IBOutlet private var summaryView: UIView!
    @IBOutlet private var locationLabel: UILabel!
    @IBOutlet private var skyStatusImageView: UIImageView!
    @IBOutlet private var popView: UIView!
    @IBOutlet private var popImageView: UIImageView!
    @IBOutlet private var popLabel: UILabel!
    @IBOutlet private var rn1Label: UILabel!
    @IBOutlet private var skyStatusLabel: UILabel!
    @IBOutlet private var rehImageView: UIImageView!
    @IBOutlet private var rehLabel: UILabel!
    @IBOutlet private var windImageView: UIImageView!
    @IBOutlet private var vecImageView: UIImageView!
    @IBOutlet private var wsdLabel: UILabel!
    @IBOutlet private var pm10Label: UILabel!
    @IBOutlet private var currentTempLabel: UILabel!
    @IBOutlet private var maxMinTempLabel: UILabel!
    @IBOutlet private var arrowImageView: UIImageView!
    @IBOutlet private var detailView: UIView!
    @IBOutlet private var airPollutionCollectionView: UICollectionView!
    @IBOutlet private var weatherForecastCollectionView: UICollectionView!
    @IBOutlet private var weatherLocalsTitleLabel: UILabel!
    @IBOutlet private var airPollutionTitleLabel: UILabel!
    
    // MARK: - Initializer
    // MARK: -
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        bringSubview(toFront: deleteButton)
        weatherForecastCollectionView.delegate = self
        weatherForecastCollectionView.dataSource = self
        airPollutionCollectionView.delegate = self
        airPollutionCollectionView.dataSource = self
        setTintColor((UIApplication.shared.delegate as? AppDelegate)?.tintColorType ?? .white)
    }
    
    // MARK: - Custom methods
    // MARK: -
    func show(_ content: ExpandingTableViewCellContent) {
        // 셀 확장 처리
        if content.expanded {
            arrowImageView.image = UIImage(named: "up-arrow")
            detailView.isHidden = true
        } else {
            arrowImageView.image = UIImage(named: "down-arrow")
            detailView.isHidden = false
        }
        detailView.isHidden = content.expanded ? false : true
        // 셀 애니메이션 처리
        if content.isEditing {
            startShakeAnimation()
            deleteButton.isHidden = false
        } else {
            stopShakeAnimation()
            deleteButton.isHidden = true
        }
        // 데이터 초기화 작업
        locationLabel.text = content.totalData.location
        weatherRealtime = content.totalData.weatherRealtime
        weatherLocals = content.totalData.weatherLocals
        airPollution = content.totalData.airPollution
        prepareCell()
    }
    /// 셀을 준비한다
    private func prepareCell() {
        prepareSummaryView()
        airPollutionCollectionView.reloadData()
        weatherForecastCollectionView.reloadData()
        setBackgroundColor(.sky)
    }
    /// summaryView를 초기화한다
    private func prepareSummaryView() {
        guard let weatherRealtime = weatherRealtime,
            let weatherLocals = weatherLocals else {
                return
        }
        var tmx = "", tmn = "", pop = "", s06 = ""
        for weatherLocal in weatherLocals {
            if let tmxValue = weatherLocal.tmx, tmx.isEmpty {
                tmx = tmxValue
            }
            if let tmnValue = weatherLocal.tmn, tmn.isEmpty {
                tmn = tmnValue
            }
            if let popValue = weatherLocal.pop, pop.isEmpty {
                pop = popValue
            }
            if let s06Value = weatherLocal.s06, s06.isEmpty {
                s06 = s06Value
            }
        }
        let t1h = weatherRealtime.t1h ?? "-°"       // 현재온도
        let sky = weatherRealtime.sky ?? "정보없음"   // 하늘상태
        let pty = weatherRealtime.pty ?? "없음"      // 강수형태
        let rn1 = weatherRealtime.rn1 ?? "-"        // 강수량
        let reh = weatherRealtime.reh ?? "-%"       // 습도
        let vec = weatherRealtime.vec ?? "-"        // 풍향
        let wsd = weatherRealtime.wsd ?? "-m/s"     // 풍속
        setSkyImageView(sky, pty: pty)
        setVecImageView(vec)
        switch pty {
        case "없음":
            // "맑음", "구름조금", "구름많음", "흐림"
            skyStatusLabel.text = sky
            popView.isHidden = false
            rn1Label.isHidden = true
            // "맑음", "구름조금", "구름많음", "흐림" 일 때는 강수확률
            popLabel.text = pop
        default:
            // "비", "비/눈", "눈"
            skyStatusLabel.text = sky
            popView.isHidden = true
            rn1Label.isHidden = false
            // "비", "비/눈", "눈" 일 때는 강수량, 적설량으로 변경
            if pty == "비" || pty == "비/눈" {
                rn1Label.text = rn1
            } else if pty == "눈" {
                rn1Label.text = s06
            }
        }
        rehLabel.text = reh
        wsdLabel.text = wsd
        currentTempLabel.text = t1h
        maxMinTempLabel.text = "\(tmx)/\(tmn)"
        if let pm10Grade1h = airPollution?.pm10Grade1h {
            pm10Label.text = "미세먼지 \(pm10Grade1h)"
        }
    }
    /// sky, pty 값에 따른 skyImageView 설정
    private func setSkyImageView(_ sky: String, pty: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let time = Int(dateFormatter.string(from: Date())) ?? 0
        if pty == "없음" {
            if sky == "맑음" {
                if time >= 06 && time < 20 {
                    skyStatusImageView.image = UIImage(named: "day-sunny")
                } else {
                    skyStatusImageView.image = UIImage(named: "night-clear")
                }
            } else if sky == "구름조금" {
                if time >= 06 && time < 20 {
                    skyStatusImageView.image = UIImage(named: "day-sunny-overcast")
                } else {
                    skyStatusImageView.image = UIImage(named: "night-partly-cloudy")
                }
            } else if sky == "구름많음" {
                if time >= 06 && time < 20 {
                    skyStatusImageView.image = UIImage(named: "day-cloudy")
                } else {
                    skyStatusImageView.image = UIImage(named: "night-cloudy")
                }
            } else if sky == "흐림" {
                skyStatusImageView.image = UIImage(named: "cloud")
            } else if sky == "정보없음" {
                skyStatusImageView.image = nil
            }
        } else {
            if pty == "비" || pty == "비/눈" {
                skyStatusImageView.image = UIImage(named: "rain")
            } else if pty == "눈" {
                skyStatusImageView.image = UIImage(named: "snow")
            }
        }
        setTintColor((UIApplication.shared.delegate as? AppDelegate)?.tintColorType ?? .white)
    }
    /// vec 값에 따른 vecImageView 설정
    private func setVecImageView(_ vec: String) {
        if vec == "북" {
            vecImageView.transform = CGAffineTransform(rotationAngle: CGFloat((180 * Double.pi) / 180))
        } else if vec == "북동" {
            vecImageView.transform = CGAffineTransform(rotationAngle: CGFloat((225 * Double.pi) / 180))
        } else if vec == "동" {
            vecImageView.transform = CGAffineTransform(rotationAngle: CGFloat((270 * Double.pi) / 180))
        } else if vec == "동남" {
            vecImageView.transform = CGAffineTransform(rotationAngle: CGFloat((315 * Double.pi) / 180))
        } else if vec == "남" {
            vecImageView.transform = CGAffineTransform(rotationAngle: CGFloat((0 * Double.pi) / 180))
        } else if vec == "남서" {
            vecImageView.transform = CGAffineTransform(rotationAngle: CGFloat((45 * Double.pi) / 180))
        } else if vec == "서" {
            vecImageView.transform = CGAffineTransform(rotationAngle: CGFloat((90 * Double.pi) / 180))
        } else if vec == "서북" {
            vecImageView.transform = CGAffineTransform(rotationAngle: CGFloat((135 * Double.pi) / 180))
        } else {
            vecImageView.image = nil
        }
    }
    /// 이미지, 텍스트 색상을 설정한다
    private func setTintColor(_ type: TintColorType) {
        var color: UIColor
        switch type {
        case .white:
            color = .white
        case .black:
            color = .black
        }
        skyStatusImageView.image = skyStatusImageView.image?.withRenderingMode(.alwaysTemplate)
        skyStatusImageView.tintColor = color
        popImageView.image = popImageView.image?.withRenderingMode(.alwaysTemplate)
        popImageView.tintColor = color
        rehImageView.image = rehImageView.image?.withRenderingMode(.alwaysTemplate)
        rehImageView.tintColor = color
        windImageView.image = windImageView.image?.withRenderingMode(.alwaysTemplate)
        windImageView.tintColor = color
        vecImageView.image = vecImageView.image?.withRenderingMode(.alwaysTemplate)
        arrowImageView.image = arrowImageView.image?.withRenderingMode(.alwaysTemplate)
        arrowImageView.tintColor = color
        vecImageView.tintColor = color
        locationLabel.textColor = color
        popLabel.textColor = color
        rn1Label.textColor = color
        rehLabel.textColor = color
        skyStatusLabel.textColor = color
        wsdLabel.textColor = color
        pm10Label.textColor = color
        currentTempLabel.textColor = color
        maxMinTempLabel.textColor = color
        weatherLocalsTitleLabel.textColor = color
        airPollutionTitleLabel.textColor = color
    }
    /// 하늘 상태, 공기오염 상태에 따른 백그라운 색상을 설정한다
    private func setBackgroundColor(_ type: BackgroundColorType) {
        switch type {
        case .sky:
            // 하늘 상태에 따른 셀 배경 색상 설정
            if let sky = weatherRealtime?.sky {
                setBackGroundColorWithSkyState(sky)
            }
        case .air:
            // 공기오염 상태에 따른 셀 배경 색상 설정
            if let pm10Grade = airPollution?.pm10Grade,
                let pm25Grade = airPollution?.pm25Grade,
                let khaiGrade = airPollution?.khaiGrade {
                if pm10Grade != "정보없음" {
                    setBackGroundColorWithAirState(pm10Grade)
                } else if pm25Grade != "정보없음" {
                    setBackGroundColorWithAirState(pm25Grade)
                } else if khaiGrade != "정보없음" {
                    setBackGroundColorWithAirState(khaiGrade)
                } else {
                    setBackGroundColorWithAirState("정보없음")
                }
            }
        }
    }
    // 하늘 상태에 따른 백그라운드 색상 설정
    private func setBackGroundColorWithSkyState(_ state: String) {
        switch state {
        case "맑음":
            bgView.backgroundColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        case "구름조금":
            bgView.backgroundColor = UIColor(red: 255/255, green: 204/255, blue: 0/255, alpha: 1)
        case "구름많음":
            bgView.backgroundColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
        case "흐림":
            bgView.backgroundColor = UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 1)
        case "비", "비/눈":
            bgView.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        case "눈":
            bgView.backgroundColor = UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 1)
        default:
            bgView.backgroundColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        }
    }
    // 공기오염 상태에 따른 백그라운드 색상 설정
    private func setBackGroundColorWithAirState(_ state: String) {
        switch state {
        case "좋음":  // 파랑
            bgView.backgroundColor = UIColor(red: 97/255, green: 168/255, blue: 255/255, alpha: 1)
        case "보통":  // 녹색
            bgView.backgroundColor = UIColor(red: 119/255, green: 221/255, blue: 119/255, alpha: 1)
        case "나쁨":  // 노랑
            bgView.backgroundColor = UIColor(red: 255/255, green: 179/255, blue: 71/255, alpha: 1)
        case "매우나쁨":    // 빨강
            bgView.backgroundColor = UIColor(red: 255/255, green: 105/255, blue: 97/255, alpha: 1)
        default:    // 정보없음
            bgView.backgroundColor = UIColor(red: 207/255, green: 207/255, blue: 196/255, alpha: 1)
        }
    }
}

extension WeatherInfoCell: UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource
    // MARK: -
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === airPollutionCollectionView {
            return airPollutionCount
        }
        return weatherLocals?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === weatherForecastCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherForecastCell", for: indexPath) as? WeatherForecastCell else {
                return UICollectionViewCell()
            }
            if let time = weatherLocals?[indexPath.row].time,
                let sky = weatherLocals?[indexPath.row].sky,
                let pty = weatherLocals?[indexPath.row].pty {
                cell.timeLabel.text = "\(time)시"
                cell.setSkyImageView(sky, pty: pty)
            }
            if let t3h = weatherLocals?[indexPath.row].t3h,
                let pop = weatherLocals?[indexPath.row].pop,
                let reh = weatherLocals?[indexPath.row].reh {
                cell.tempLabel.text = t3h
                cell.popLabel.text = pop
                cell.rehLabel.text = reh
            }
            if let vec = weatherLocals?[indexPath.row].vec,
                let wsd = weatherLocals?[indexPath.row].wsd {
                cell.setVecImageView(vec)
                cell.windLabel.text = wsd
            }
            return cell
        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AirPollutionCell", for: indexPath) as? AirPollutionCell else {
            return UICollectionViewCell()
        }
        switch indexPath.row {
        case AirPollutionIndex.khai.rawValue:
            cell.titleLabel.text = "통합대기환경"
            cell.gradeLabel.text = airPollution?.khaiGrade ?? ""
            cell.valueLabel.text = airPollution?.khaiValue ?? ""
        case AirPollutionIndex.pm10.rawValue:
            cell.titleLabel.text = "미세먼지"
            cell.gradeLabel.text = airPollution?.pm10Grade ?? ""
            cell.valueLabel.text = airPollution?.pm10Value ?? ""
        case AirPollutionIndex.pm25.rawValue:
            cell.titleLabel.text = "초미세먼지"
            cell.gradeLabel.text = airPollution?.pm25Grade ?? ""
            cell.valueLabel.text = airPollution?.pm25Value ?? ""
        case AirPollutionIndex.co.rawValue:
            cell.titleLabel.text = "일산화탄소"
            cell.gradeLabel.text = airPollution?.coGrade ?? ""
            cell.valueLabel.text = airPollution?.coValue ?? ""
        case AirPollutionIndex.no2.rawValue:
            cell.titleLabel.text = "이산화탄소"
            cell.gradeLabel.text = airPollution?.no2Grade ?? ""
            cell.valueLabel.text = airPollution?.no2Value ?? ""
        case AirPollutionIndex.o3.rawValue:
            cell.titleLabel.text = "오존"
            cell.gradeLabel.text = airPollution?.o3Grade ?? ""
            cell.valueLabel.text = airPollution?.o3Value ?? ""
        case AirPollutionIndex.so2.rawValue:
            cell.titleLabel.text = "아황산가스"
            cell.gradeLabel.text = airPollution?.so2Grade ?? ""
            cell.valueLabel.text = airPollution?.so2Value ?? ""
        default:
            ()
        }
        return cell
    }
}


