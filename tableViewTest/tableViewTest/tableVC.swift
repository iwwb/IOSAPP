//
//  tableVC.swift
//  tableViewTest
//
//  Created by IW on 2017/6/7.
//  Copyright © 2017年 wb. All rights reserved.
//

import UIKit

class tableVC: UITableViewController,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource
{
    //还款期数
    var cellCount = 0
    //TableView数据源
    var ds = Dictionary<String, Double>()
    //缓存输入后未刷至数据源的TextField
    var toResignTextField:UITextField? = nil
    //计算值显示格式
    let doubleFormat = "%.3f"
    //初始化pickerView datasource
    var pickerPhases:[Int] = [1,3,6,12,24,36,60,120,240,360]
    //定义pickerView
    var pickerV:UIPickerView? = nil
    
    /*公共提示方法*/
    func AlertView(message:String) {
        let alert = UIAlertController.init(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true) {
            
        }
    }
    
    /*检查字符是否为整数*/
    func isPurnInt(string: String) -> Bool
    {
        let scan: Scanner = Scanner(string: string)
        var val:Int = 0
        return scan.scanInt(&val) && scan.isAtEnd
    }
    
    /*检查字符是否为Double*/
    func isPurnDouble(string: String) -> Bool
    {
        let scan: Scanner = Scanner(string: string)
        var val:Double = 0.0
        return scan.scanDouble(&val) && scan.isAtEnd
    }
    
    @IBOutlet var tv: UITableView!
    @IBOutlet weak var loanV: UITextField!
    @IBOutlet weak var monthFeeV: UITextField!
    @IBOutlet weak var yearInterestV: UITextField!
    @IBOutlet weak var loanPhaseCountValue: UITextField!
    @IBOutlet weak var topTabV: UIView!
    @IBOutlet weak var genBtn: UIButton!
    @IBOutlet weak var copyBtn: UIButton!
    @IBOutlet weak var calculateBtn: UIButton!
    @IBOutlet weak var clearBtn: UIButton!
    
    /*拷贝第1期额度*/
    @IBAction func copyPhase1(_ sender: Any)
    {
        if(self.toResignTextField != nil)
        {
            self.toResignTextField!.resignFirstResponder()
            self.toResignTextField = nil
        }
        let phase1V = self.ds["1"]
        for i in 2...self.cellCount {
            self.ds["\(i)"] = phase1V
        }
        self.tv.reloadData()
    }
    
    /*清理输入项*/
    @IBAction func ClearAll(_ sender: Any) {
        if(self.toResignTextField != nil)
        {
            self.toResignTextField!.resignFirstResponder()
            self.toResignTextField = nil
        }
        loanV.text = ""
        monthFeeV.text = ""
        yearInterestV.text = ""
        for i in 1...self.cellCount {
            self.ds["\(i)"] = 0
        }
        self.tv.reloadData()
    }
    
    /*计算年利率*/
    @IBAction func calculate(_ sender: Any)
    {
        let loanStr = loanV.text!
        if(loanStr=="")
        {
            AlertView(message: "需要输入贷款数额!")
            return
        }
        if(self.toResignTextField != nil)
        {
            self.toResignTextField!.resignFirstResponder()
            self.toResignTextField = nil
        }
        
        let loanDouble = (loanStr as NSString).doubleValue
        var sumAll = -loanDouble
        for (_,value) in self.ds {
            sumAll += value
        }
        let monthFeeDouble = sumAll/Double(self.cellCount)/abs(loanDouble)
        monthFeeV.text = String(format: self.doubleFormat,monthFeeDouble)
        let yearIRRDouble = monthFeeDouble*Double(self.cellCount)*24/13
        let monthIRRDouble = yearIRRDouble/12
        let yearInterestDouble = pow(1+monthIRRDouble, 12)-1
        yearInterestV.text = String(format: self.doubleFormat,yearInterestDouble)
    }
    
    /*根据还款期数生成相应TableViewCells*/
    @IBAction func genCells(_ sender: Any) {
        if(self.toResignTextField != nil)
        {
            self.toResignTextField!.resignFirstResponder()
            self.toResignTextField = nil
        }
        let loanpcv = loanPhaseCountValue.text!
        if(loanpcv=="")
        {
            return
        }
        if(!isPurnInt(string: loanpcv))
        {
            AlertView(message: "贷款期数只能为整数!")
            return
        }
        let loanpcvInt = (loanpcv as NSString).integerValue
        if(loanpcvInt<1)
        {
            AlertView(message: "贷款期数须大于1!")
            return
        }
        self.cellCount = loanpcvInt
        self.ds.removeAll()
        for i in 1...self.cellCount {
            self.ds["\(i)"] = 0
        }
        tv.reloadData()
    }

    /*初始化加载*/
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.cellCount = 12
        for i in 1...self.cellCount {
            self.ds["\(i)"] = 0
        }
        
        let img1 = UIImage(named:"button1")
        self.genBtn.setBackgroundImage(img1, for: UIControlState.normal)
        self.copyBtn.setBackgroundImage(img1, for: UIControlState.normal)
        self.calculateBtn.setBackgroundImage(img1, for: UIControlState.normal)
        self.clearBtn.setBackgroundImage(img1, for: UIControlState.normal)
        let img2 = UIImage(named:"button2")
        self.genBtn.setBackgroundImage(img2, for: UIControlState.highlighted)
        self.copyBtn.setBackgroundImage(img2, for: UIControlState.highlighted)
        self.calculateBtn.setBackgroundImage(img2, for: UIControlState.highlighted)
        self.clearBtn.setBackgroundImage(img2, for: UIControlState.highlighted)
        
        monthFeeV.isUserInteractionEnabled = false
        yearInterestV.isUserInteractionEnabled = false
        loanV.delegate = self
        loanPhaseCountValue.delegate = self
        pickerV = UIPickerView()
        pickerV!.delegate = self
        pickerV!.dataSource = self
        pickerV!.selectRow(3,inComponent:0,animated:true)
        loanPhaseCountValue.inputView = pickerV!
        loanV.keyboardType = UIKeyboardType.numberPad
        tv.backgroundColor = Color.babyBlueColor()
        topTabV.backgroundColor = Color.siennaColor()
        
//        let background = turquoiseColor()
//        background.frame = self.topTabV.bounds
//        self.topTabV.layer.insertSublayer(background, at: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellCount
    }

    /*重用TableViewCell构建TableView*/
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ri", for: indexPath)
        cell.backgroundColor = Color.babyBlueColor()
        let label = cell.viewWithTag(1001) as! UILabel
        let key = indexPath.row+1
        label.text = "第\(key)期还"
        let textField = cell.viewWithTag(1002) as! UITextField
        textField.delegate = self
        textField.keyboardType = UIKeyboardType.numberPad
        let value = self.ds["\(key)"]
        if(value==nil)
        {
            textField.text = ""
        }
        else if(value==0)
        {
            textField.text = "0"
        }
        else
        {
            textField.text = "\(value!)"
        }
        return cell
    }
    

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    /*TextField代理方法，捕获结束编辑事件*/
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        let temp = textField.tag
        if(temp<=1000)
        {
            return
        }
        let textV = textField.text!
        if(textV=="")
        {
            AlertView(message: "需要输入还款数额!")
            return
        }
        if(!isPurnDouble(string: textV))
        {
            AlertView(message: "需要输入合法数额!不能包含字母符号等")
            return
        }
        let textVDouble = (textV as NSString).doubleValue
        if(textVDouble<0)
        {
            AlertView(message: "需要输入不小于0的数!")
            return
        }
        let cell = textField.superview!.superview as! UITableViewCell
        let indexpath = self.tv.indexPath(for: cell)
        let key = "\(indexpath!.row+1)"
        self.ds[key] = Double(textField.text!)
        if(self.toResignTextField==textField)
        {
            self.toResignTextField = nil
        }
    }
    
    /*TextField代理方法，捕获开始编辑事件*/
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        self.toResignTextField = textField
    }

    //点击return 收回键盘
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if(self.toResignTextField==textField)
        {
            self.toResignTextField = nil
        }
        return true
    }
    //点击其他地方  收回键盘
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(self.toResignTextField != nil)
        {
            self.toResignTextField!.resignFirstResponder()
            self.toResignTextField = nil
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int)->Int {
        return pickerPhases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(pickerPhases[row])"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        loanPhaseCountValue.text = "\(self.pickerPhases[row])"
    }
    
    func turquoiseColor() -> CAGradientLayer {
        let topColor = Color.coolPurpleColor()
        let bottomColor = Color.periwinkleColor()
        let middleTopColor = Color.skyBlueColor()
        let middleBottomColor = Color.indigoColor()
        let gradientColors: Array <AnyObject> = [topColor.cgColor,middleTopColor.cgColor,middleBottomColor.cgColor,bottomColor.cgColor]
        let gradientLocations:Array = [0 as NSNumber,0.45 as NSNumber,0.65 as NSNumber,1 as NSNumber]
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        return gradientLayer
    }
}
