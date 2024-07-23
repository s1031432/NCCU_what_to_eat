import UIKit
import QuartzCore

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CAAnimationDelegate {
    @IBOutlet weak var spinWheel: UIView!
    var restaurants = ["麥當勞", "摩斯漢堡", "八方雲集", "敏忠小吃店", "食鼎鵝肉", "提洛斯義式廚房", "福勝亭", "四川飯館"]
    var spinWheelLayer: CAShapeLayer!
    var pointerLayer: CAShapeLayer!
    var currentAngle: CGFloat = 0
    var tableView: UITableView!
    var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSpinWheel()
        createPointer()
        setupSpinButton()
        setupTableView()
        setupAddButton()
    }
    
    func createSpinWheel() {
        guard let wheelView = self.view.viewWithTag(1) else { return }
        
        // 清除之前的圖層
        spinWheelLayer?.removeFromSuperlayer()
        
        // 計算轉盤的半徑和中心
        let radius = wheelView.bounds.width / 2
        let center = CGPoint(x: wheelView.bounds.midX, y: wheelView.bounds.midY)
        
        // 創建轉盤圖層
        spinWheelLayer = CAShapeLayer()
        spinWheelLayer.frame = wheelView.bounds
        wheelView.layer.addSublayer(spinWheelLayer)
        
        // 繪製轉盤
        for (index, restaurant) in restaurants.enumerated() {
            let startAngle = CGFloat(index) * (2 * .pi / CGFloat(restaurants.count))
            let endAngle = startAngle + (2 * .pi / CGFloat(restaurants.count))
            let path = UIBezierPath()
            path.move(to: center)
            path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
            let segmentLayer = CAShapeLayer()
            segmentLayer.path = path.cgPath
            segmentLayer.fillColor = UIColor(hue: CGFloat(index) / CGFloat(restaurants.count), saturation: 0.5, brightness: 0.9, alpha: 1.0).cgColor
            spinWheelLayer.addSublayer(segmentLayer)
            
            let midAngle = (startAngle + endAngle) / 2
            let label = CATextLayer()
            label.string = restaurant
            label.fontSize = 14
            label.alignmentMode = .center
            label.foregroundColor = UIColor.black.cgColor
            label.position = CGPoint(x: center.x + radius * 0.7 * cos(midAngle), y: center.y + radius * 0.7 * sin(midAngle))
            label.transform = CATransform3DMakeRotation(midAngle + .pi / 2, 0, 0, 1)
            label.bounds = CGRect(x: 0, y: 0, width: 80, height: 20)
            spinWheelLayer.addSublayer(label)
        }
    }
    
    func createPointer() {
        guard let wheelView = self.view.viewWithTag(1) else { return }
        // 計算指針的位置
        let pointerWidth: CGFloat = 120
        let pointerHeight: CGFloat = 60
        let pointerPath = UIBezierPath()
        pointerPath.move(to: CGPoint(x: 0, y: 0))
        pointerPath.addLine(to: CGPoint(x: pointerWidth / 2, y: -pointerHeight))
        pointerPath.addLine(to: CGPoint(x: -pointerWidth / 2, y: -pointerHeight))
        pointerPath.close()
        
        // 建立指針圖層
        pointerLayer = CAShapeLayer()
        pointerLayer.path = pointerPath.cgPath
        pointerLayer.fillColor = UIColor.red.cgColor
        pointerLayer.position = CGPoint(x: wheelView.bounds.width , y: wheelView.bounds.height )
        wheelView.layer.addSublayer(pointerLayer)
        print( restaurants[Int(45/(360/restaurants.count))] )
    }
    func setupSpinButton() {
        let button = UIButton(type: .system)
        button.setTitle("抽", for: .normal)
        button.addTarget(self, action: #selector(spinButtonTapped), for: .touchUpInside)
        let buttonSize: CGFloat = 120
        button.frame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        button.center = CGPoint(x: spinWheel.bounds.midX, y: spinWheel.bounds.midY)
        button.layer.cornerRadius = buttonSize / 2
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5) // 半透明黑色
        button.setTitleColor(.white, for: .normal)
        spinWheel.addSubview(button)
    }
    func setupTableView() {
        tableView = UITableView(frame: CGRect(x: 0, y: view.center.y+50, width: view.bounds.width, height: 220))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
    }
    func setupAddButton() {
        addButton = UIButton(type: .system)
        addButton.setTitle("新增", for: .normal)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        addButton.frame = CGRect(x: 20, y: view.bounds.height - 100, width: 100, height: 50)
        addButton.backgroundColor = UIColor.systemBlue
        addButton.setTitleColor(.white, for: .normal)
        view.addSubview(addButton)
    }

    @objc func addButtonTapped() {
        let alertController = UIAlertController(title: "新增餐廳", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "輸入餐廳名稱"
        }
        let confirmAction = UIAlertAction(title: "確認", style: .default) { _ in
            if let textField = alertController.textFields?.first, let newRestaurant = textField.text, !newRestaurant.isEmpty {
                self.restaurants.append(newRestaurant)
                self.createSpinWheel()
                self.setupSpinButton()
                self.tableView.reloadData()
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func spinButtonTapped() {
        // 設置旋轉動畫
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        let randomRotation = CGFloat.random(in: CGFloat.pi * 2...CGFloat.pi * 20) // 隨機旋轉角度
        rotation.toValue = NSNumber(value: randomRotation + Double(currentAngle)) // 累計目前角度
        rotation.duration = 2.0
        rotation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        rotation.fillMode = .forwards
        rotation.isRemovedOnCompletion = false
        rotation.delegate = self
        spinWheelLayer.add(rotation, forKey: "rotationAnimation")
        
        // 更新角度
        currentAngle += randomRotation
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = restaurants[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            restaurants.remove(at: indexPath.row)
            createSpinWheel()
            setupSpinButton()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            // 計算選中的餐廳
            spinWheelLayer.transform = CATransform3DMakeRotation(currentAngle, 0, 0, 1)
            let angle = (currentAngle)/Double.pi * 180.0
            let normalizedAngle = 360 - fmod(angle, 360)
            let segmentAngle = 360 / CGFloat(restaurants.count)

            // 顯示選中的餐廳
            let pointerDegree = 45.0
            let index = Int( (pointerDegree + normalizedAngle) / segmentAngle) % restaurants.count
            showAlert(for: restaurants[index])
        }
    }
    
    func showAlert(for restaurant: String) {
        let alert = UIAlertController(title: "今天吃什麼", message: "今天吃 \(restaurant)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
