//
//  InputView.swift
//  testfortest
//
//  Created by Rex Peng on 2019/6/3.
//  Copyright © 2019 Rex Peng. All rights reserved.
//

import UIKit

private class InsetTextField: UITextField {
    var insets: UIEdgeInsets?
    
    var insetLeft: CGFloat?
    
    init(insets: UIEdgeInsets?) {
        self.insets = insets
        super.init(frame: .zero)
    }
    
    init(insetLeft: CGFloat?) {
        self.insetLeft = insetLeft
        super.init(frame: .zero)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("not intended for use from a NIB")
    }
    
    // placeholder position
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        if insets != nil {
            return super.textRect(forBounds: bounds.inset(by: insets!))
        } else if insetLeft != nil {
            return super.textRect(forBounds: bounds.insetBy(dx: insetLeft!, dy: 0))
        }
        return super.textRect(forBounds: bounds)
    }
    
    // text position
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        if insets != nil {
            return super.editingRect(forBounds: bounds.inset(by: insets!))
        } else if insetLeft != nil {
            return super.editingRect(forBounds: bounds.insetBy(dx: insetLeft!, dy: 0))
        }
        return super.editingRect(forBounds: bounds)
    }
    

}

extension UITextField {
    
    class func textFieldWithInsets(insets: UIEdgeInsets) -> UITextField {
        return InsetTextField(insets: insets)
    }

    class func textFieldWithInsetLeft(insetLeft: CGFloat) -> UITextField {
        return InsetTextField(insetLeft: insetLeft)
    }

}

enum InputType {
    case normal, pickdate, pickdata, pickyearmonth
}

@IBDesignable
class InputView: UIView {
    
    var mTitle: UILabel = {
        let title = UILabel(frame: .zero)
        title.font = UIFont.systemFont(ofSize: 14)
        title.textColor = UIColor(red: 14/255, green: 57/255, blue: 78/255, alpha: 1)
        title.text = "Label"
        title.sizeToFit()
        return title
    }()
    
    var mTextField: UITextField = {
        let field = UITextField.textFieldWithInsetLeft(insetLeft: 15)
        field.backgroundColor = UIColor.white
        return field
    }()
    
    
    @IBInspectable
    var Title: String {
        set {
            mTitle.text = newValue
        }
        get {
            return mTitle.text ?? "Label"
        }
    }
    
    @IBInspectable
    var titleColor: UIColor {
        set {
            mTitle.textColor = newValue
        }
        get {
            return mTitle.textColor
        }
    }

    @IBInspectable
    var Placeholder: String {
        set {
            mTextField.placeholder = newValue
        }
        get {
            return mTextField.placeholder ?? ""
        }
    }
    

    @IBInspectable
    var cornerRadius: CGFloat {
        set {
            mTextField.layer.cornerRadius = newValue
            mTextField.layer.masksToBounds = newValue > 0
        }
        get {
            return mTextField.layer.cornerRadius
        }
    }
    
    @IBInspectable
    var borderColor: UIColor {
        set {
            mTextField.layer.borderColor = newValue.cgColor
        }
        get {
            return UIColor(cgColor: mTextField.layer.borderColor ?? UIColor(red: 222/255, green: 169/255, blue: 47/255, alpha: 1.0).cgColor)
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        set {
            mTextField.layer.borderWidth = newValue
        }
        get {
            return mTextField.layer.borderWidth
        }
    }
    
    var inputType: InputType = .normal {
        didSet {
            configureInputType()
        }
    }
    
    private var isMultiData: Bool = false
    private var pickView: UIPickerView?
    private var datePick: UIDatePicker?
    var pickData: [Any] = [] {
        didSet {
            tmpPickData.removeAll()
            if let data = pickData.first, data is Array<Any> {
                isMultiData = true
                for i in 0..<pickData.count {
                    if let item:[Any] = pickData[i] as? Array {
                        if let string = item[0] as? String {
                            tmpPickData.append(string)
                        }
                    }
                }
            } else {
                if let data = pickData.first as? String {
                    tmpPickData.append(data)
                }
            }
        }
    }
    private var tmpPickData: [String] = []
    private var nowYear: Int = 2019
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        
        configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        mTitle.sizeToFit()
        
        mTitle.frame = CGRect(x: 5, y: 5, width: mTitle.bounds.width, height: mTitle.bounds.height)
        
        mTextField.frame = CGRect(x: 5, y: mTitle.bounds.height+5, width: bounds.width-10, height: bounds.height-5-mTitle.bounds.height-5)
        
    }
    
    
    private func configure() {
        self.backgroundColor = .clear
        self.addSubview(mTitle)
        cornerRadius = 5
        borderColor = UIColor(red: 222/255, green: 169/255, blue: 47/255, alpha: 1.0)
        borderWidth = 1
        mTextField.delegate = self
        self.addSubview(mTextField)
        
    }
    
    private func configureInputType() {
        switch inputType {
        case .pickdate:
            datePick = UIDatePicker()
            datePick?.datePickerMode = .date
            datePick?.addTarget(self, action: #selector(datePickChanged), for: .valueChanged)
            mTextField.inputView = datePick
        case .pickdata:
            pickView = UIPickerView()
            pickView?.delegate = self
            pickView?.dataSource = self
            mTextField.inputView = pickView
        case .pickyearmonth:
            pickView = UIPickerView()
            nowYear = Calendar.current.component(.year, from: Date())
            pickView?.delegate = self
            pickView?.dataSource = self
            mTextField.inputView = pickView
            tmpPickData.append("\(nowYear)")
            tmpPickData.append("1")
            pickView?.selectRow(99, inComponent: 0, animated: false)
        case .normal:
            break
        }
    }
    
    @objc func datePickChanged() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        mTextField.text = formatter.string(from: datePick!.date)
    }
    
    func dismissPickView() {
        self.endEditing(true)
    }
    
    func setTextField() {
        switch inputType {
        case .normal:
            break
        case .pickdata:
            var result = ""
            for string in tmpPickData {
                if !result.isEmpty {
                    result += " "
                }
                result += string
            }
            mTextField.text = result
        case .pickyearmonth:
            mTextField.text = "\(tmpPickData[0])-\(tmpPickData[1])"
        case .pickdate:
            datePickChanged()
        }
    }
}

extension InputView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setTextField()
    }
}

extension InputView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if isMultiData {
            return pickData.count
        } else if inputType == .pickyearmonth {
            return 2
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if isMultiData {
            if let data:[Any] = pickData[component] as? Array {
                return data.count
            }
        } else if inputType == .pickyearmonth {
            if component == 0 {
                return 100
            } else {
                return 12
            }
        }
        return pickData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if isMultiData {
            if let data:[Any] = pickData[component] as? Array, let title = data[row] as? String {
                return title
            }
        } else if inputType == .pickyearmonth {
            if component == 0 {
                
                return "\(nowYear-99+row)"
            } else {
                return DateFormatter().monthSymbols[row]  //"\(row+1)"
            }
        } else if let title = pickData[row] as? String {
            return title
        }
        
        
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if isMultiData {
              if let data:[Any] = pickData[component] as? Array, let title = data[row] as? String {
                tmpPickData[component] = title
            }
            setTextField()
        } else if inputType == .pickyearmonth {
            if component == 0 {
                tmpPickData[0] = "\(nowYear-100+row)"
            } else {
                tmpPickData[1] = "\(row+1)"
            }
            setTextField()
        } else if let title = pickData[row] as? String {
            mTextField.text = title
        }
        //dismissPickView()
    }
}
