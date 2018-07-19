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
    @IBOutlet var tableView: UITableView!
    @IBOutlet var footerView: UIView!
    @IBOutlet var informationButton: UIButton!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var removeButton: UIButton!
    @IBOutlet var coverView: UIView!
    @IBOutlet var indicatorView: UIActivityIndicatorView!
    
    static var dataAddCompletion = false
    
    var allData = [[String: Any]]()
    
    private var locationList = (UIApplication.shared.delegate as! AppDelegate).locationList
    private let dao = LocationDAO()
    private var datasource = [ExpandingTableViewCellContent]()
    private let manager = CLLocationManager()
    private var refresher = UIRefreshControl()
    private var isFirstLocRequest = false
    
    // MARK: - Initializers
    class func instantiate(_ allData: [[String: Any]]?) -> MainViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyBoard.instantiateViewController(withIdentifier: "MainVC") as! MainViewController
        if allData != nil {
            mainVC.allData = allData!
        }
        return mainVC
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true   // 셀 선택o
        tableView.separatorStyle = .none    // 셀 사이 간격x
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        manager.requestWhenInUseAuthorization()
        
        addButton.addTarget(self, action: #selector(displaySearchView(_:)), for: .touchUpInside)
        removeButton.addTarget(self, action: #selector(startEditing), for: .touchUpInside)
        informationButton.addTarget(self, action: #selector(displayTutorialView(_:)), for: .touchUpInside)
        
        coverView.isHidden = true
        view.bringSubview(toFront: coverView)
        
        refresher.tintColor = UIColor.black
        refresher.addTarget(self, action: #selector(reloadData), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        if allData.isEmpty {
            MainViewController.dataAddCompletion = true
        } else {
            for data in allData {
                datasource.append(ExpandingTableViewCellContent(data: data))
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let ud = UserDefaults.standard
        
        if ud.bool(forKey: "TUTORIAL") == false {
            let tutorialVC = UIStoryboard(name: "Tutorial", bundle: nil).instantiateViewController(withIdentifier: "MasterVC")
            present(tutorialVC, animated: true, completion: nil)
        }
        
        if MainViewController.dataAddCompletion {
            reloadData()
        }
    }
    
    
    // MARK: - Custom Methods
    @objc func reloadData() {
        // 인디케이터 로딩 시작
        if MainViewController.dataAddCompletion {
            coverView.isHidden = false
            indicatorView.startAnimating()
        }
        isFirstLocRequest = true
        manager.requestLocation()
    }
    
    @objc func displayTutorialView(_ sender: Any) {
        
        let tutorialVC = UIStoryboard(name: "Tutorial", bundle: nil).instantiateViewController(withIdentifier: "MasterVC")
        present(tutorialVC, animated: true, completion: nil)
    }
    
    @objc func displaySearchView(_ sender: Any) {
        if removeButton.isSelected {
            startEditing()
        }
        let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchVC") as! SearchViewController
        present(searchVC, animated: true, completion: nil)
    }
    
    @objc func startEditing() {
        
        if datasource.count == 1 {
            removeButton.isSelected = false
        } else {
            removeButton.isSelected = !removeButton.isSelected
        }
        
        if !removeButton.isSelected {
            datasource.forEach { (content) in
                content.expanded = false
                content.isEditing = false
            }
            tableView.allowsSelection = true
        } else {
            datasource.forEach { (content) in
                content.expanded = false
                if content !== datasource.first {
                    content.isEditing = true
                }
            }
            tableView.allowsSelection = false
        }
        tableView.reloadData()
    }
    
    @objc func deleteData(_ sender: UIButton) {
        let index = sender.tag
        let loc = datasource[index].data["location"] as! String
        
        alertWithOkCancel("\(loc)을 지우시겠습니까?") {
            self.locationList = self.dao.fetch()
            let data = self.locationList[index - 1]
            self.dao.delete(data)
            
            self.datasource.remove(at: index)
            self.tableView.reloadData()
            
            if self.datasource.count == 1 {
                self.startEditing()
            }
        }
    }
}

extension MainViewController: CLLocationManagerDelegate {
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        if let location = locations.first, isFirstLocRequest {
            isFirstLocRequest = false
            
            getCurrentLocation(location) { (isSuccess, locationName) in
                
                self.getAllData(location: location, name: locationName, completion: { (isSuccess, allData) in
                    if isSuccess {
                        if let allData = allData {
                            self.datasource.removeAll()
                            for data in allData {
                                self.datasource.append(ExpandingTableViewCellContent(data: data))
                            }
                            self.tableView.reloadData()
                            MainViewController.dataAddCompletion = false
                        }
                        
                        self.refresher.perform(#selector(self.refresher.endRefreshing), with: nil, afterDelay: 0.05)
                        // 인디케이터 로딩 종료
                        self.indicatorView.stopAnimating()
                        self.coverView.isHidden = true
                    }
                })
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        alert("오류가 발생하였습니다.") {
            exit(0)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            alert("위치 접근 허용이 필요합니다.") {
                exit(0)
            }
        default:
            ()
        }
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableView Delegate, DataSoruce
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let content = datasource[indexPath.row]
        if content.expanded {
            return 450
        }
        return 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherInfoCell", for: indexPath) as! WeatherInfoCell
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(deleteData(_:)), for: .touchUpInside)
        cell.show(datasource[indexPath.row])
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let content = datasource[indexPath.row]
        content.expanded = !content.expanded
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
    }
}
