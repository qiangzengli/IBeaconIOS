//
//  ViewController.swift
//  IBeacon
//
//  Created by alan on 2023/11/24.
//

import UIKit
import CoreLocation
import SnapKit

class ViewController: UIViewController {
    let locationManager = CLLocationManager()

    let distance = UILabel()
    let rssi = UILabel()
    let major = UILabel()
    let minor = UILabel()
    let container =  UIStackView()
   let uuid = UUID.init(uuidString: "FDA50693-A4E2-4FB1-AFCF-C6EB07647825")!
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    
       
        // Do any additional setup after loading the view.
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        
//        let region = CLBeaconRegion(uuid:uuid,major: CLBeaconMajorValue(01),minor: CLBeaconMinorValue(02),identifier: "iBeacon Region");
//            
//                                    
//        locationManager.startMonitoring(for:region)
        print("搜索中")
        
        locationManager.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid:uuid,major: CLBeaconMajorValue(UInt16(01)),minor: CLBeaconMinorValue(UInt16(02))))
    }

    
    func initView(){
        distance.textColor = .black
        rssi.textColor = .black
        major.textColor = .black
        minor.textColor = .black
        container.axis = .vertical
        container.alignment = .top
        container.addArrangedSubview(distance)
        container.addArrangedSubview(rssi)
        container.addArrangedSubview(major)
        container.addArrangedSubview(minor)
        self.view.addSubview(container)
        
        container.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview().offset(10)
        
        }
      
        distance.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(40)
        }
        
        rssi.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(40)
        }
        
        major.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(40)
        }
        
        minor.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(40)
        }
      
    }

}

extension ViewController :CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager did fail: \(error.localizedDescription)")
    }
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Location Manager monitoring did fail:\(error.localizedDescription)")
    }
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("didStartMonitoringFor")
        // 開始偵測範圍之後，就先檢查目前的 state 是否在範圍內
        manager.requestState(for: region)
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("didEnterRegion")
        guard region is CLBeaconRegion else {return}
        guard CLLocationManager.isRangingAvailable() else{return}
        manager.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid:uuid,major: CLBeaconMajorValue(UInt16(01)),minor: CLBeaconMinorValue(UInt16(02))))
    
    }
    
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("didExitRegion")
        guard region is CLBeaconRegion else {return}
        guard CLLocationManager.isRangingAvailable() else {return}
        manager.stopRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid:uuid,major: CLBeaconMajorValue(UInt16(01)),minor: CLBeaconMinorValue(UInt16(02))))
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print("Location manager ranging beacons did fail: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print("didRangeBeacons\(beacons.count)")
        if let beacon = beacons.first{
            print("距离最近的beacon : \(beacon.`self`())")
            distance.text = "IBeacon 信标的距离是：\(beacon.rssi == 0 ? 0.0 : calculateDistance(rssi : Double(beacon.rssi))) m"
            major.text = "major:\(beacon.major)"
            minor.text = "minor:\(beacon.minor)"
            rssi.text = "rssi:\(beacon.rssi)"
        }
    }
    
    func rssi2Distance(rssi: Int) -> Double {
        let iRssi = abs(rssi)
          // 发射端和接收端 相隔1m的信号强度
        let s :Double = 60.0
          // 环境衰减因子
          let f = 5.67
        let power :Double = ( Double(iRssi) - s) / (10.0 * f)
        return pow(10.0,power)
      }
    
    func calculateDistance(rssi: Double, txPower: Double = -60.0, pathLossExponent: Double = 2.5) -> Double {
          // 路径损耗指数模型中的距离计算公式
        let ratio = (txPower - rssi) / (10.0 * pathLossExponent)
        return pow(10.0,ratio)
      }

}


