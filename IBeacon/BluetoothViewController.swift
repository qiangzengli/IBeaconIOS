//
//  BluetoothViewController.swift
//  IBeacon
//
//  Created by alan on 2023/11/28.
//

import UIKit
import CoreBluetooth
import SnapKit

class BluetoothViewController: UIViewController {
    var centralManager: CBCentralManager!
    var discoveredPeripherals: [CBPeripheral] = []
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "BluetoothCell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        setupConstraints()
        
        // 初始化 central manager
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension BluetoothViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveredPeripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BluetoothCell", for: indexPath)
        let peripheral = discoveredPeripherals[indexPath.row]
        print( "设备名称\(peripheral.name),设备rssi:\(peripheral.readRSSI()) 设备: identifier :\(peripheral.identifier)")
        cell.textLabel?.text = peripheral.name ?? "Unknown"
        cell.detailTextLabel?.text = peripheral.identifier.uuidString
        return cell
    }
}

extension BluetoothViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // 蓝牙已打开，开始搜索
            central.scanForPeripherals(withServices: nil, options: nil)
        } else {
            // 其他状态处理
            print("蓝牙不可用")
        }
    }
//    93DCE735-2263-EDDA-5DD5-44D0555CB711
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // 发现蓝牙设备
//        print("发现设备: \(peripheral)")
        
        print("RSSI: \(RSSI)")
        print("计算距离：\(calculateDistance(rssi: Double.init(truncating: RSSI)))")
        
        if peripheral.name == nil || peripheral.name != "R23060287"{return}
        
        // 将发现的设备添加到数组中
        if !discoveredPeripherals.contains(peripheral) {
            discoveredPeripherals.append(peripheral)
        }else{
            discoveredPeripherals[discoveredPeripherals.firstIndex(of: peripheral)!] = peripheral
        }
        
        // 刷新 table view 来显示新设备
        tableView.reloadData()
    }
    
    func calculateDistance(rssi: Double, txPower: Double = -60.0, pathLossExponent: Double = 2.5) -> Double {
          // 路径损耗指数模型中的距离计算公式
        let ratio = (txPower - rssi) / (10.0 * pathLossExponent)
        return pow(10.0,ratio)
      }
}
