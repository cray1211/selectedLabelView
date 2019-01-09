//
//  ViewController.swift
//  tagLabel
//
//  Created by sxf_pro on 2019/1/9.
//  Copyright © 2019年 sxf_pro. All rights reserved.
//

import UIKit
import SnapKit
let SCREEN_WIDTH = UIScreen.main.bounds.width
class ViewController: UIViewController {

    @IBOutlet weak var titleLb: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //需要设定宽度
        let rulerV = rulerView(frame: CGRect(x: 80, y: 100, width: SCREEN_WIDTH - 40, height: 30))
        rulerV.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        rulerV.isSingle = false //多选还是单选
        rulerV.maxSelectedCount = 7//最大选择4个 不设置默认最大
        view.addSubview(rulerV)
        
        rulerV.frameUpDate = {(viewHeight : CGFloat) -> Void in
            print("约束高度\(viewHeight)")
            //更改rulerV的约束
            rulerV.frame = CGRect(x: 20, y: 100, width: SCREEN_WIDTH - 40, height: viewHeight)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            rulerV.setDataForView(data: ["qwewq", "针的是很烦", "针的是很烦针的是很烦", "针的", "针的是", "哈哈哈我去额", "哈", "哈哈", "ewoiqeuwqo", "wqeoqweiqwopp[dkklj", "qewoied", "撒谎大会开始打时空大胜靠德"])
        }
        
        
        //选择的状态回调
        rulerV.selectedItemCallBack = {(itemArr : [UIButton],  itemSelectedArr : [Bool] , sender :  UIButton) -> Void in
            print("点击的是\(sender.tag)")
            print(itemSelectedArr)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

