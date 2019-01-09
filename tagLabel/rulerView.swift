//
//  rulerView.swift
//  DoLifeApp
//
//  Created by sxf_pro on 2019/1/8.
//  Copyright © 2019年 张志超. All rights reserved.
//

import UIKit

class rulerView: UIView {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private var viewOffset : UIEdgeInsets?//内边距
    private var lineSpace : CGFloat?//行间距
    private var listSpace : CGFloat?//列间距
    private var titleInset : CGFloat? //标题item内边距
    private var itemHeight : CGFloat? //item的高度
    private var viewHeight : CGFloat? //布局后获取的高度
    private var itemContentView = UIView()//存放元素的item
    private var itemArr = [UIButton]()
    private var lastBtn : UIButton?//存储上一个按钮
    private var itemTitleNormalColor : UIColor? //titlecolor
    private var itemTitleSelectedColor : UIColor? //选种颜色
    private var itemBoardNoramlColor : UIColor?//边框颜色
    private var itemBoardSelectedColor : UIColor?//边框选中颜色
    private var itemNormalBackgroundColor : UIColor? //默认背景色
    private var itemSelectedBackgroundColor : UIColor?//选中背景色
    
    var isSingle : Bool? //是否是单选  true 为单选
    var maxSelectedCount : Int?//选择的最大个数， 在单选状态下失效
    
    private var itemSelectedStatus = [Bool]()
    //回调frame
    var frameUpDate : ((_ viewHeight : CGFloat)->Void)?
    //回调选好的item
    var selectedItemCallBack :((_ itemArr : [UIButton], _ itemSelectedArr : [Bool] , _ sender :  UIButton) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isSingle = true //默认单选
        viewOffset = UIEdgeInsetsMake(0, 0, 0, 0)//默认值
        lineSpace = 10
        listSpace = 10
        itemHeight = 30
        viewHeight = itemHeight//默认一行的高度
        titleInset = 10
        itemContentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        itemTitleNormalColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        itemTitleSelectedColor =  #colorLiteral(red: 0, green: 0.6745098039, blue: 0.5921568627, alpha: 1)
        
        itemBoardNoramlColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        itemBoardSelectedColor = #colorLiteral(red: 0, green: 0.6745098039, blue: 0.5921568627, alpha: 1)
        
        itemNormalBackgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        itemSelectedBackgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        maxSelectedCount = 10000//默认值最大全选
        
        addChildrenViews()
    }
    
    
    
    func setDataForView(data:[String]){
        layoutIfNeeded()
        //创建 并存储
        for title in data{
            let btn = UIButton(type: .custom)
            btn.setTitle(title, for: .normal)
            btn.tag = data.index(of: title)!
            btn.addTarget(self, action: #selector(clickBtn(sender :)), for: .touchUpInside)
            btn.setTitleColor(itemTitleSelectedColor, for: .selected)
            btn.setTitleColor(itemTitleNormalColor, for: .normal)
            
            btn.layer.borderWidth = 1
            btn.layer.borderColor = itemBoardNoramlColor?.cgColor
            
            btn.layer.cornerRadius = 4
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            
            btn.backgroundColor = itemNormalBackgroundColor
            
            itemArr.append(btn)
            addSubview(btn)
            itemSelectedStatus.append(false)//初始化为非选中
            
            if maxSelectedCount! > data.count{
                maxSelectedCount = data.count
            }
            
            print("str = \(title) \n长度 ： \(numberOfChars(title))   count = \(title.count)")
        }
        
        
        //布局按钮
        //计算x
        var orginX : CGFloat = 0
        
        //计算y
        var orginY : CGFloat = 0
        
        //计算宽度
        var btnW : CGFloat = 0
        
        //根据所占的字节位数 计算所占用的宽度
        var bytesCount : Int = 0

        
        for btn in itemArr{
            itemContentView.addSubview(btn)
            if lastBtn != nil{
                orginX = (lastBtn?.frame.origin.x)! + (lastBtn?.frame.width)! + listSpace!
                
                orginY = (lastBtn?.frame.origin.y)!
                
            }

            bytesCount = numberOfChars((btn.titleLabel?.text)!)
            btnW = CGFloat(bytesCount) * ((btn.titleLabel?.font.pointSize)! * 0.5) + (2 * titleInset! )
            
//            print("x = \(orginX)\ny = \(orginY)\nw = \(btnW)\nh = \(String(describing: itemHeight))\n")
            
            if (orginX + btnW + listSpace!) > itemContentView.frame.width{
                //换行
                orginX = 0
                orginY = (lastBtn?.frame.origin.y)! + (lastBtn?.frame.height)! + lineSpace!
            }
            btn.frame = CGRect(x: orginX, y: orginY, width: btnW, height: itemHeight!)
            lastBtn = btn
        }
        
        
        //布局完成 回调frame //并设置contentViewframe
        viewHeight = (itemArr.last?.frame.origin.y)! + (itemArr.last?.frame.height)!
        //移除以前的 重新添加
//        itemContentView.snp.remakeConstraints { (view) in
//            view.left.right.top.equalTo(self)
//            view.height.equalTo(viewHeight!)
//        }
        //更新约束
        itemContentView.snp.updateConstraints { (view) in
            view.height.equalTo(viewHeight!)
        }
        layoutSubviews()
        updateConstraints()
        if frameUpDate != nil {
            frameUpDate!(viewHeight!)
        }
        
    }
    
    //点击按钮
    @objc func clickBtn(sender :UIButton){
//        print("点击的是\(sender.tag)")
        sender.isSelected = !sender.isSelected
        //更改颜色
        changeBtnColor(sender: sender)
        //记录选择的状态
        itemSelectedStatus[sender.tag] = sender.isSelected
        if isSingle == false {
            
            var sameCount = 0
            for selected in itemSelectedStatus{
                if selected{
                    sameCount += 1
                }
            }
            //多选
            if maxSelectedCount! < sameCount{
                showAlertView()
                sender.isSelected = false
                //更改颜色
                changeBtnColor(sender: sender)
                //记录选择的状态
                itemSelectedStatus[sender.tag] = sender.isSelected
            }
        }else{
            //单选
            for btn in itemArr{
                if btn != sender{
                    itemSelectedStatus[btn.tag] = false
                    btn.isSelected = false
                    changeBtnColor(sender: btn)//默认为非选中
                }
            }
        }
        
        
        
        
//        print(itemSelectedStatus)
        
        //回调选择好的item
        if selectedItemCallBack != nil {
            selectedItemCallBack!(itemArr, itemSelectedStatus, sender)
        }

    }
    
    
    private func changeBtnColor(sender : UIButton){
        sender.layer.borderColor = sender.isSelected ? itemBoardSelectedColor?.cgColor : itemBoardNoramlColor?.cgColor
        sender.backgroundColor = sender.isSelected ? itemSelectedBackgroundColor : itemNormalBackgroundColor
    }
    
    
    
    private func showAlertView(){
        let alert = UIAlertController(title: "", message: "超出最大选择限制\(String(format: "%d", maxSelectedCount!))", preferredStyle: .alert)
        let kw = UIApplication.shared.keyWindow
        kw?.rootViewController?.present(alert, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            kw?.rootViewController?.dismiss(animated: true, completion: {
                print("弹窗消失")
            })
        }
    }
    

}

extension rulerView{
    private func addChildrenViews(){
        addSubview(itemContentView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        itemContentView.snp.makeConstraints({ (view) in
            view.left.right.top.equalTo(self)
            view.height.equalTo(viewHeight!)
        })
    }
}

extension rulerView{

    //根据中英文 判断字符的长度
    
    /*
     代码中的 0x4E00 是一个十六进制数,这是字符编码集中中文字符开始的地方,日文的编码边界是 0x0800。 所以我们根据这个边界值来判断字符应该占两位还是一位
     */
    func numberOfChars(_ str: String) -> Int {
        var number = 0
        guard str.count > 0 else {return 0}
        for i in 0...str.count - 1 {
            let c: unichar = (str as NSString).character(at: i)
            if (c >= 0x4E00) {
                number += 2
            }else {
                number += 1
            }
        }
        return number
    } 
    
    
}
