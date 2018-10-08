//
//  MainViewController.swift
//  YJWeather
//
//  Created by 최영준 on 2018. 5. 14..
//  Copyright © 2018년 최영준. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController {
    // MARK: - Properties
    // MARK: -
    static var dataAddCompletion = false
    private let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    private var locations = (UIApplication.shared.delegate as! AppDelegate).locations
    private let locationDAO = LocationDAO()
    private var dataSource = [ExpandingTableViewCellContent]()
    private let manager = CLLocationManager()
    private var refresher = UIRefreshControl()
    private var locationRequestCompletion = false
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.allowsSelection = true   // 셀 선택o
            tableView.separatorStyle = .none    // 셀 사이 간격x
        }
    }
    @IBOutlet var addButton: UIButton! {
        didSet {
            addButton.layer.cornerRadius = addButton.frame.width / 2
            let color = (appDelegate.tintColorType == .white) ? UIColor.white : UIColor.black
            let addImage = UIImage(named: "add")?.withRenderingMode(.alwaysTemplate)
            addButton.setImage(addImage, for: .normal)
            addButton.imageView?.tintColor = color
        }
    }
    @IBOutlet var removeButton: UIButton! {
        didSet {
            removeButton.layer.cornerRadius = removeButton.frame.width / 2
            let color = (appDelegate.tintColorType == .white) ? UIColor.white : UIColor.black
            let minusImage = UIImage(named: "minus")?.withRenderingMode(.alwaysTemplate)
            let cancelImage = UIImage(named: "cancel")?.withRenderingMode(.alwaysTemplate)
            removeButton.setImage(minusImage, for: .normal)
            removeButton.setImage(cancelImage, for: .selected)
            removeButton.imageView?.tintColor = color
        }
    }
    @IBOutlet var coverView: UIView! {
        didSet {
            coverView.isHidden = true
        }
    }
    @IBOutlet var indicatorView: UIActivityIndicatorView!
    
    // MARK: - View lifecycle
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        // manager: CLLocationManager 초기화
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        manager.requestWhenInUseAuthorization()
        // refresher: UIRefreshControl 초기화
        refresher.tintColor = UIColor.black
        refresher.addTarget(self, action: #selector(reloadData), for: UIControlEvents.valueChanged)
        // addButton: UIButton 초기화
        addButton.addTarget(self, action: #selector(displaySearchView(_:)), for: .touchUpInside)
        // removeButton: UIButton 초기화
        removeButton.addTarget(self, action: #selector(startEditing), for: .touchUpInside)
        // tableView: UITableView 초기화
        tableView.addSubview(refresher)
        // view: UIView 초기화
        view.bringSubview(toFront: coverView)
        // totalDataList가 비어있지 않다면, totalData로 ExpandingTableViewCellContent를 초기화, dataSource에 추가한다
        // 비었다면 데이터를 로드하기 위한 설정을한다
        if appDelegate.totalDataList.isEmpty {
            MainViewController.dataAddCompletion = true
        } else {
            for totalData in appDelegate.totalDataList {
                dataSource.append(ExpandingTableViewCellContent(data: totalData))
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 첫 시작시, 튜토리얼 뷰 컨트롤러로 전환
        if !UserDefaults.standard.bool(forKey: "TUTORIAL"),
            let tutorialVC = UIStoryboard(name: "Tutorial", bundle: Bundle.main).instantiateViewController(withIdentifier: "TutorialVC") as? TutorialViewController {
            present(tutorialVC, animated: true, completion: nil)
        }
        // 데이터가 추가되었거나 totalDataList가 비었다면 데이터를 리로드한다
        if MainViewController.dataAddCompletion {
            reloadData()
        }
    }
    
    // MARK: - Custom methods
    // MARK: -
    /// 데이터 로드 작업
    @objc private func reloadData() {
        // 인디케이터 로딩 시작
        if MainViewController.dataAddCompletion {
            coverView.isHidden = false
            indicatorView.startAnimating()
        }
        // locationRequestCompletion = false로 변경 후 요청한다
        locationRequestCompletion = false
        manager.requestLocation()
    }
    /// 검색 뷰 컨트롤러를 호출
    @objc private func displaySearchView(_ sender: Any) {
        // removeButton 선택된 상태라면 편집 작업을 중단한다
        if removeButton.isSelected {
            startEditing()
        }
        if let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchVC") as? SearchViewController {
            present(searchVC, animated: true, completion: nil)
        }
    }
    /// 편집(삭제) 작업을 시작
    @objc private func startEditing() {
        // dataSource == 1은 현재 위치 데이터만 존재, 더이상 삭제 불가
        removeButton.isSelected = (dataSource.count == 1) ? false : !removeButton.isSelected
        tableView.allowsSelection = !tableView.allowsSelection
        // removeButton이 선택된 상태라면 편집 작업을 시작하고 tableView 클릭을 비활성화 한다
        // 선택된 상태가 아니라면 편집 작업을 종료하고 tableView 클릭을 활성화 한다
        if removeButton.isSelected {
            dataSource.forEach { (content) in
                // 현재 위치 데이터 객체를 제외하고 편집 가능
                if content !== dataSource.first {
                    content.isEditing = true
                }
                // 확장된 tableViewCell을 닫는다
                content.expanded = false
            }
        } else {
            dataSource.forEach { (content) in
                content.isEditing = false
            }
        }
        tableView.reloadData()
    }
    /// 데이터를 삭제 작업(tableViewCell에 deleteButton에 전달)
    @objc private func deleteData(_ sender: UIButton) {
        let index = sender.tag
        let location = dataSource[index].totalData.location
        alertWithOkCancel("\(location)을 지우시겠습니까?") {
            self.locations = self.locationDAO.fetch()
            // 영구 저장소에서 index에 해당하는 LocationData를 제거한다
            // 첫 번째 데이터(현재 위치 데이터)는 고정 데이터가 아니기 때문에 index-1로 접근한다
            let data = self.locations[index-1]
            if self.locationDAO.delete(data) {
                self.dataSource.remove(at: index)
                self.tableView.reloadData()
            }
            // 데이터가 하나만 남았을 경우 편집 작업을 중단
            if self.dataSource.count == 1 {
                self.startEditing()
            }
        }
    }
}

extension MainViewController: CLLocationManagerDelegate {
    // MARK: - CLLocationManagerDelegate
    // MARK: -
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        if let location = locations.first, !locationRequestCompletion {
            locationRequestCompletion = true
            // 현재 위치 LocationData를 받는다
            getCurrentLocationData(location) { (isSuccess, data) in
                if isSuccess, let currentLocationData = data {
                    // Request 작업을 실행
                    Request().getTotalDataList(currentLocationData) { (isSuccess, data, error) in
                        if isSuccess, let totalDataList = data as? [TotalData] {
                            // 최종 데이터를 AppDelegate.totalDataList에 할당
                            self.appDelegate.totalDataList = totalDataList
                            // dataSource를 전부 제거 후 새로운 데이터로 초기화, tableView 리로드
                            self.dataSource.removeAll()
                            for totalData in totalDataList {
                                self.dataSource.append(ExpandingTableViewCellContent(data:totalData))
                            }
                            self.tableView.reloadData()
                            MainViewController.dataAddCompletion = false
                        } else {
                            if let errorDescription = error?.errorDescription {
                                self.alert(errorDescription, completion: nil)
                            }
                        }
                        // refresher, indicatorView 로딩 중단
                        self.refresher.perform(#selector(self.refresher.endRefreshing), with: nil, afterDelay: 0.05)
                        self.indicatorView.stopAnimating()
                        // coverView를 숨긴다
                        self.coverView.isHidden = true
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        alert("오류가 발생하였습니다.", completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            alert("위치 접근 허용이 필요합니다.", completion: nil)
        default:
            ()
        }
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDelegate, UITableViewDataSoruce
    // MARK: -
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let content = dataSource[indexPath.row]
        if content.expanded {
            return 450
        }
        return 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherInfoCell") as? WeatherInfoCell else {
            return UITableViewCell()
        }
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(deleteData(_:)), for: .touchUpInside)
        cell.show(dataSource[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let content = dataSource[indexPath.row]
        content.expanded = !content.expanded
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
