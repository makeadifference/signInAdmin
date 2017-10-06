//
//  EditClassroomVC.swift
//  admin
//
//  Created by drf on 2017/10/4.
//  Copyright © 2017年 drf. All rights reserved.
//  暂时有个bug，修改布局数组需要重新重选

import UIKit
import Alamofire

class EditClassroomVC: UICollectionViewController {

    var layoutArray = Array<[Int]>(repeating: [], count: 10)
    var type = ""  // 根据类型设置视图内容
    var classroomInfo = [String:Any]() // 正向传值
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.allowsMultipleSelection = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Actions
    @IBAction func Post(_ sender: Any) {
        if self.type == "添加教室"{
            addClassroom()
        } else {
            updateClassroom()
        }
    }
    
    @IBAction func Cancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 10
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 18
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "siteCell" , for: indexPath) as! siteCell
        cell.layer.borderWidth = 0.5
        // 填充布局
        if classroomInfo["layout"] != nil {
            let layout = classroomInfo["layout"] as! [[Int]]
            // section
            // 循环计数
            var counter = 0
            for array in layout {
                if indexPath.section == counter {
                    // 循环计数 ， 如果是nsarray则无需
                    var counter2 = 0
                    for _ in array {
                        if indexPath.row == counter2 {
                            cell.isSelected = true
                            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition(rawValue: 0))
                        }
                        counter2 += 1
                    }
                }
                counter += 1
            }
        }
        return cell
    }

    // HeaderView and footerView
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let headerview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "classroomHeader", for: indexPath) as! ClassHeaderView
            if self.type != "添加教室" {
                headerview.classRoomText.text = classroomInfo["name"] as? String
                print("ID\(String(describing: classroomInfo["id"]!))")
                print(classroomInfo["layout"]!)
                // cells is selected // 进一步，居中显示
                
            }
            return headerview
        } else {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "classroomFooter", for: indexPath) as! ClassFooterView
            if self.type == "添加教室" {
                footerView.leftbutton.setTitle("添加", for: .normal)
            } else {
                footerView.leftbutton.setTitle("修改", for: .normal)
            }
            
            return footerView
        }
    }
    
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    // 多选
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let selectedItems = collectionView.indexPathsForSelectedItems {
            if selectedItems.contains(indexPath) {
                collectionView.deselectItem(at: indexPath, animated: true)
                return false
            }
        }
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        // 选择，想数组添加元素
        let cell = collectionView.cellForItem(at: indexPath) as! siteCell
        // 10
        for a in 0..<10 {
            if indexPath.section == a {
                for b in 0..<18 {
                    if indexPath.row == b {
                    if cell.isSelected {
                       layoutArray[a].append(b)
                    }
                }
            }
        }
    }
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        let cell = collectionView.cellForItem(at: indexPath) as! siteCell
        //
        if cell.isSelected {
            cell.isSelected = false
        }
        cell.layer.borderWidth = 0.5
        print("deselected")
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("deselected:\(indexPath)")
      
        // 取消选择，从数组中删除
        for a in 0..<10 {
            if indexPath.section == a {
                for b in 0..<18 {
                    if indexPath.row == b {
                        // remove
                        if layoutArray[a].contains(b){
                            // 创建一个布包好b的新数组
                            if let index = layoutArray[a].index(of: b) {
                                layoutArray[a].remove(at: index)
                            }
                            
                        }
                    }
                }
            }
        }
    }

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    // 修改教室
    func updateClassroom(){
        // 检验数据有效性
        let HeaderView = collectionView?.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: IndexPath(row: 0, section: 0)) as! ClassHeaderView
        if (HeaderView.classRoomText.text?.isEmpty)! {
            self.alert(error: "提示", message: "请输入教室名")
            return
        }
        let layoutArray = generateJSONArray()
        print("布局数组\(layoutArray)")
        let url = URL(string: admin.weteam.baseURL+admin.Method.addClassRoom)
        let parameter : Parameters = ["classroomName": HeaderView.classRoomText.text!,"classroomJsonLayout" :
            String(describing: layoutArray)]
        Alamofire.request(url!, method: .post, parameters: parameter).responseJSON{ [weak self] response in
            if let json = response.result.value as? [String:Any]{
                if json["errors"] == nil {
                    self?.alert(error: "提示", message: json["msg"] as! String)
                } else {
                    let errors = json["errors"] as! [String:String]
                    if let classroomnameError = errors["classroomName"]{
                        self?.alert(error: "修改失败", message: classroomnameError)
                    }
                    
                    if let layoutError = errors["classroomJsonLayout"]{
                        self?.alert(error: "修改失败", message: layoutError)
                    }
                }
            }
        }
        
    }
    
    // 添加教室
    func addClassroom(){
        // 检验数据有效性
        let HeaderView = collectionView?.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: IndexPath(row: 0, section: 0)) as! ClassHeaderView
        if (HeaderView.classRoomText.text?.isEmpty)! {
            self.alert(error: "提示", message: "请输入教室名")
            return
        }
        let layoutJSONArray = generateJSONArray()
        print("布局数组\(layoutJSONArray)")
        let url = URL(string: admin.weteam.baseURL+admin.Method.addClassRoom)
        let parameter : Parameters = ["classroomName": HeaderView.classRoomText.text!,"classroomJsonLayout" : String(describing: layoutJSONArray)]
        Alamofire.request(url!, method: .post, parameters: parameter).responseJSON{ [weak self] response in
            if let json = response.result.value as? [String:Any]{
                if json["errors"] == nil {
                    self?.alert(error: "提示", message: json["msg"] as! String)
                } else {
                    let errors = json["errors"] as! [String:String]
                    if let classroomnameError = errors["classroomName"]{
                        self?.alert(error: "添加失败", message: classroomnameError)
                    }
                    
                    if let layoutError = errors["classroomJsonLayout"]{
                        self?.alert(error: "添加失败", message: layoutError)
                    }
                }
            }
        }
        
        
    }
    
    func generateJSONArray() -> [[Int]]{
        // 构造json数组
        // 算法应该在提交action中实现
        // 算法思路,仅考虑每排座位是连续的
        // 每行18座位，共10行分次历遍，第一个非零标记为start，最后一个非零为end
        // 比较所有start，最小的为左边界，
        // 比较所有end，最大的为右边界
        // 比较所有start与end的间距，最大的为内层数组的容量
        // 其他的start减去最小的start得到offset，offset用零填充
        // 注意： 讲台只是用于标记方向的
        var layoutArray2 = Array<[Int]>(repeating: [], count: 10)
        for a in 0..<10 {
            let sorted = layoutArray[a].sorted()
            layoutArray2.append(sorted)
        }
        // 创建目标json数组
        // 行数
        let effectArray = layoutArray2.filter{$0 != []} // 有效的数组
        // 各个数组的大小,获取最大值，json内层数组的大小
        var sizeArray = [Int]()
        // 每行的第一个元素
        var firstArray = [Int]()
        // 每行最后一个元素
        var lastArray = [Int]()
        
        for array in effectArray {
            sizeArray.append(array.count)
            firstArray.append(array.first!)
            lastArray.append(array.last!)
        }
        // 列数
        let row = sizeArray.max()
        // 各行的偏移量，第一个减去最小值
        // 计算偏移量，利用最小值
        let min = firstArray.min()!
        var leftOffsetArray = [Int]()
        for array in effectArray {
            leftOffsetArray.append(array.first!-min)
        }
        // 同理
        let max = lastArray.max()!
        var rightOffsetArray = [Int]()
        for array in effectArray {
            rightOffsetArray.append(max-array.last!)
        }
        // 内层数组
        let innerArray = Array<Int>(repeating: 0, count: row!)
        var jsonArray = Array<[Int]>(repeating: innerArray, count: effectArray.count)
        // 范围数组
        var rangeArray = Array<CountableClosedRange<Int>>()
        
        // 循环计数
        var counter = 0
        for startIndex in leftOffsetArray {
            // let endIndex = rightOffsetArray[index!] ,这个方法不行，重复元素取第一个位置
            let endIndex = rightOffsetArray[counter]
            if startIndex == 0  && endIndex == 0{
                let temp = row!-1
                let range = 0...temp
                rangeArray.append(range)
            }
            if startIndex == 0 && endIndex != 0 {
                let right = row!-(endIndex+1)
                let range = 0...right
                rangeArray.append(range)
            }
            if startIndex != 0 && endIndex == 0 {
                var left = 0
                if startIndex == 1 {
                    left = 1
                } else {
                    left = startIndex
                }
                let right = row!-1
                let range = left...right
                rangeArray.append(range)
            }
            if startIndex != 0 && endIndex != 0{
                var left = 0
                if startIndex == 1{
                    left = 1
                } else {
                    //
                    left = startIndex
                }
                let right = row!-(endIndex+1)
                let range = left...right
                rangeArray.append(range)
            }
            counter += 1
            
        }
        // 填充json数组 , 值类型
        var counter2 = 0
        for var array in jsonArray {
            for index in rangeArray[counter2] {
                if array[index] == 0 {
                    array[index] = 1
                }
            }
            jsonArray[counter2] = array
            counter2 += 1
        }
        return jsonArray
        
    }
    
    // 在已有的基础上修改布局
    func regenerateJsonArray(){
        
    }
    // 提示错误信息
    func alert(error : String, message:String){
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }

}

extension EditClassroomVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width/18
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
        let width = self.view.frame.width
        let height : CGFloat = 100
        return CGSize(width: width, height: height)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == 9 {
        let width = self.view.frame.width
        let height :CGFloat = 50
        return CGSize(width: width, height: height)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
}
