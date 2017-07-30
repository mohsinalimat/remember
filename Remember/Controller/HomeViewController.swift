//
//  ViewController.swift
//  Remember
//
//  Created by Songbai Yan on 14/11/2016.
//  Copyright © 2016 Songbai Yan. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import SCLAlertView

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let inputViewHeight:CGFloat = 60
    
    fileprivate var shouldInputViewDisplay = true
    fileprivate var service = HomeService()
    fileprivate var tableView:UITableView!
    fileprivate var snapshotView:UIView?
    fileprivate var tableHeaderView:UIView!
    fileprivate let pasteboardViewTag = 1234
    fileprivate var sourceIndexPath:IndexPath?
    fileprivate var pasteContent:String?
    fileprivate var inputThingView:InputThingView!
    
    fileprivate var things = [ThingModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        initUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.updatePasteboardView(_:)), name: NSNotification.Name(rawValue: "updatePasteboardView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.tagRemoved(_:)), name: NSNotification.Name(rawValue: "tagRemovedNotification"), object: nil)
    }
    
    private func initUI(){
        self.title = "丁丁记事"
        self.view.backgroundColor = UIColor.background()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.remember()];
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "setting"), style: .plain, target: self, action: #selector(HomeViewController.pushToAboutPage(_:)))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.remember()
        
        initTableView()
        initInputView()
        initTableHeaderView()
        initLongPressForTableView()
        setKeyboardNotification()
        
        initData()
    }
    
    func beginCreateThing(){
        inputThingView.beginEditing()
    }
    
    func updatePasteboardView(_ notification: Notification){
        addPasteboardViewIfNeeded()
    }
    
    func tagRemoved(_ notification: Notification){
        self.tableView.reloadData()
    }
    
    private func initData(){
        things = service.things
    }
    
    private func setKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func initInputView(){
        inputThingView = InputThingView(frame: CGRect(x: 0, y: self.view.frame.height - inputViewHeight, width: self.view.frame.width, height: inputViewHeight))
        inputThingView.delegate = self
        inputThingView.voiceInputAction = {(inputView) -> Void in
            let voiceInputController = VoiceInputController()
            voiceInputController.delegate = self
            voiceInputController.modalPresentationStyle = .custom
            voiceInputController.modalTransitionStyle = .crossDissolve
            self.present(voiceInputController, animated: false, completion:{ Void in
                voiceInputController.show()
            })
        }
        self.view.addSubview(inputThingView)
    }
    
    private func initTableHeaderView(){
        tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60))
        tableHeaderView.addSubview(getSearchButton())
        
        addPasteboardViewIfNeeded()
        
        tableView.tableHeaderView = tableHeaderView
    }
    
    private func addPasteboardViewIfNeeded(){
        //如果已经有粘贴板提示了就返回
        if self.tableHeaderView.viewWithTag(self.pasteboardViewTag) != nil{
            return
        }
        if let tempPasteContent = HomeService.getPasteboardContent(){
            //add timer
            addPasteDisappearTimer()
            
            pasteContent = tempPasteContent
            self.tableView.beginUpdates()
            tableHeaderView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 130)
            tableHeaderView.addSubview(getPasteBoardView(tempPasteContent))
            self.tableView.endUpdates()
        }
    }
    
    private func addPasteDisappearTimer(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            // 移除粘贴板提示
            if self.pasteContent != nil{
                self.removePasteboardView()
            }
        }
    }
    
    private func getSearchButton() -> UIView{
        let searchButton = UIButton(type: UIButtonType.system)
        searchButton.setTitle(" 搜索你忘记的小事", for: UIControlState.normal)
        searchButton.setImage(UIImage(named: "Search"), for: UIControlState.normal)
        searchButton.frame = CGRect(x: 10, y: 10, width: self.view.frame.width - 20, height: 40)
        searchButton.layer.borderColor = UIColor.inputGray().cgColor
        searchButton.layer.borderWidth = 1
        searchButton.layer.cornerRadius = 20
        searchButton.backgroundColor = UIColor.inputGray()
        searchButton.setTitleColor(UIColor.remember(), for: UIControlState.normal)
        searchButton.tintColor = UIColor.remember()
        searchButton.addTarget(self, action: #selector(HomeViewController.searchClick(_:)), for: UIControlEvents.touchUpInside)
        return searchButton
    }
    
    private func getPasteBoardView(_ content:String) -> UIView{
        let pasteboardView = UIView(frame: CGRect(x: 10, y: 60, width: self.view.frame.width - 20, height: 55))
        pasteboardView.layer.cornerRadius = 10
        pasteboardView.backgroundColor = UIColor.white
        let tipTextLabel = UILabel(frame: CGRect(x: 10, y: 5, width: pasteboardView.frame.width, height: 20))
        tipTextLabel.textColor = UIColor.remember()
        tipTextLabel.text = "是否要添加粘贴板的内容："
        tipTextLabel.font = UIFont.systemFont(ofSize: 12)
        pasteboardView.addSubview(tipTextLabel)
        tipTextLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(pasteboardView).offset(10)
            maker.top.equalTo(pasteboardView).offset(5)
            maker.right.equalTo(pasteboardView).offset(-10)
        }
        
        let okButton = UIButton(type: UIButtonType.custom)
        okButton.setImage(UIImage(named: "Checked"), for: .normal)
        okButton.addTarget(self, action: #selector(HomeViewController.pasteOkButtonClick(_:)), for: .touchUpInside)
        okButton.sizeToFit()
        pasteboardView.addSubview(okButton)
        okButton.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(pasteboardView)
            maker.right.equalTo(pasteboardView.snp.right).offset(-10)
        }
        
        let pasteContentLabel = UILabel()
        pasteContentLabel.textColor = UIColor.text()
        pasteContentLabel.text = content
        pasteboardView.addSubview(pasteContentLabel)
        pasteContentLabel.snp.makeConstraints { (maker) in
            maker.top.equalTo(tipTextLabel.snp.bottom).offset(5)
            maker.left.equalTo(tipTextLabel)
            maker.right.lessThanOrEqualTo(okButton.snp.left).offset(-5)
            maker.height.equalTo(20)
        }
        
        addPasteContentToSettings(content)
        
        pasteboardView.tag = pasteboardViewTag
        return pasteboardView
    }
    
    private func addPasteContentToSettings(_ content:String){
        UserDefaults.standard.set(content, forKey: "pasteboardContent")
        UserDefaults.standard.synchronize()
    }
    
    func pasteOkButtonClick(_ sender:UIButton){
        if let content = pasteContent{
            let thing = ThingModel(content: content)
            thing.isNew = true
            service.create(thing)
            self.things.insert(thing, at: 0)
            self.sortAndSaveThings()
            pasteContent = nil
            tableView.reloadData()
        }
        
        removePasteboardView()
    }
    
    private func removePasteboardView(){
        //remove pasteboard

        self.tableView.beginUpdates()
        self.tableHeaderView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60)
        if let pasteboardView = self.tableHeaderView.viewWithTag(self.pasteboardViewTag){
            pasteboardView.removeFromSuperview()
        }
        self.tableView.tableHeaderView = self.tableHeaderView
        self.tableView.endUpdates()
    }
    
    func searchClick(_ sender:UIButton) {
        inputThingView.endEditing()
        
        let searchController = SearchViewController()
        searchController.homeController = self
        self.present(UINavigationController.init(rootViewController: searchController), animated: false, completion: nil)
    }
    
    private func initTableView(){
        var statusHeight = UIApplication.shared.statusBarFrame.height
        if let navBarHeight = self.navigationController?.navigationBar.frame.height{
            statusHeight += navBarHeight
        }
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - inputViewHeight), style: UITableViewStyle.plain)
        tableView.backgroundColor = UIColor.background()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(ThingTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView(frame:CGRect.zero)
        self.view.addSubview(tableView)
        
        // EmptyDataSet SDK
        self.tableView.emptyDataSetSource = self;
        self.tableView.emptyDataSetDelegate = self;
    }
    
    private func initLongPressForTableView(){
        let longPress = UILongPressGestureRecognizer(target: self, action:#selector(HomeViewController.longPressGestureRecognized(_:)))
        self.tableView.addGestureRecognizer(longPress)
    }
    
    func longPressGestureRecognized(_ sender:AnyObject) {
        let longPress = sender as! UILongPressGestureRecognizer
        let state = longPress.state
        let location = longPress.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: location)
        
        switch state {
        case .began:
            if indexPath != nil {
                sourceIndexPath = indexPath
                let cell = self.tableView.cellForRow(at: indexPath!)
                snapshotView = self.customSnapshotFromView(cell!)
                
                var center = cell?.center
                snapshotView?.center = center!
                snapshotView?.alpha = 0.0
                self.tableView.addSubview(snapshotView!)
                
                UIView.animate(withDuration: 0.25, animations: {
                    center?.y = location.y
                    self.snapshotView?.center = center!
                    self.snapshotView?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    self.snapshotView?.alpha = 0.98
                    cell?.alpha = 0.0
                },completion: { (finished) in
                    cell?.isHidden = true
                })
            }
            break
        case .changed:
            var  center = snapshotView?.center
            center?.y = location.y
            snapshotView?.center = center!
            
            if indexPath != nil && !(indexPath == sourceIndexPath) {
                if let tempIndexPath = sourceIndexPath{
                    let index = self.things[indexPath!.row].index
                    self.things[indexPath!.row].index = self.things[tempIndexPath.row].index
                    self.things[tempIndexPath.row].index = index
                    swap(&self.things[indexPath!.row], &self.things[tempIndexPath.row])
                    self.tableView.moveRow(at: tempIndexPath, to: indexPath!)
                    sourceIndexPath = indexPath
                }
            }
            break
        default:
            if let tempIndexPath = sourceIndexPath{
                let cell = self.tableView.cellForRow(at: tempIndexPath)
                cell?.alpha = 0.0
                
                UIView.animate(withDuration: 0.25, animations: {
                    self.snapshotView?.center = cell!.center
                    self.snapshotView?.transform = CGAffineTransform.identity
                    self.snapshotView?.alpha = 0.0
                    cell?.alpha = 1.0
                    self.sortAndSaveThings()
                    self.tableView.reloadData()
                }, completion: { (finished) in
                    cell?.isHidden = false
                    self.sourceIndexPath = nil
                    self.snapshotView?.removeFromSuperview()
                    self.snapshotView = nil
                })
            }
            break
        }
    }
    
    fileprivate func sortAndSaveThings(){
        var set = Set<Int>()
        self.things.forEach { set.insert($0.index) }
        if set.count < self.things.count || self.things[0].index != 0{
            var index = 0
            self.things.forEach({ (thing) in
                thing.index = index
                index += 1
            })
        }
        
        self.service.save(sorted: self.things)
    }
    
    func customSnapshotFromView(_ inputView:UIView) ->UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let snapshot = UIImageView(image: image)
        snapshot.layer.masksToBounds = false
        snapshot.layer.cornerRadius = 0.0
        snapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        snapshot.layer.shadowOpacity = 0.4
        return snapshot
    }
    
    func keyboardWillHide(_ notice:Notification){
        if shouldInputViewDisplay{
            inputThingView.frame = CGRect(x: 0, y: self.view.frame.height - inputViewHeight, width: self.view.frame.width, height: inputViewHeight)
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func keyboardWillShow(_ notice:Notification){
        if shouldInputViewDisplay && inputThingView.isEditing(){
            let userInfo:NSDictionary = (notice as NSNotification).userInfo! as NSDictionary
            let endFrameValue: NSValue = userInfo.object(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
            let endFrame = endFrameValue.cgRectValue
            inputThingView.frame = CGRect(x: 0, y: self.view.bounds.height - inputViewHeight - endFrame.height, width: self.view.bounds.width, height: inputViewHeight)
        }
    }
    
    func pushToAboutPage(_ sender:UIBarButtonItem){
        inputThingView.endEditing()
        let settingsController = SettingsViewController()
        self.navigationController?.pushViewController(settingsController, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension HomeViewController{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.things.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ThingTableViewCell
        let thing = self.things[indexPath.row]
        cell.textLabel?.text = thing.content
        cell.showTags(for: thing)
        cell.addTagAction = { () in
            self.editThing(thing, isTag: true)
        }
        cell.setBackground(style: getCellBackgroundStyle(indexPath.row))
        if thing.isNew{
            cell.showAddTagButton()
            thing.isNew = false
        }
        return cell
    }
    
    private func getCellBackgroundStyle(_ index:Int) -> ThingCellBackgroundStyle{
        var style = ThingCellBackgroundStyle.normal
        let lastNumber = things.count - 1
        switch index {
        case 0:
            style = ThingCellBackgroundStyle.first
        case lastNumber:
            style = ThingCellBackgroundStyle.last
        default:
            style = ThingCellBackgroundStyle.normal
        }
        
        if things.count == 1{
            style = ThingCellBackgroundStyle.one
        }
        
        return style
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let thing = things[indexPath.row]
        let content:NSString = thing.content! as NSString
        let size = content.boundingRect(with: CGSize(width: self.view.frame.width - 60, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 17)], context: nil)
        var height = size.height + 40
        let hasTag = service.hasTag(for: thing)
        if hasTag{
            height = size.height + 50
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "标签") { (action, index) -> Void in
            let index = indexPath.row
            let thing = self.things[index]
            self.editThing(thing, isTag: true)
            tableView.isEditing = false
        }
        
        let shareAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "分享") { (action, index) -> Void in
            let index=(indexPath as NSIndexPath).row as Int
            let thing = self.things[index]
            let activityController = HomeService.getActivityViewController(content: thing.content!)
            self.present(activityController, animated: true, completion: nil)
        }
        shareAction.backgroundColor = UIColor.remember()
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "删除") { (action, index) -> Void in
            
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            alertView.addButton("确认删除", backgroundColor: UIColor(red: 251/255, green: 103/255, blue: 83/255, alpha: 1), textColor: UIColor.white, showTimeout: nil, action: {
                let index=(indexPath as NSIndexPath).row as Int
                let thing = self.things[index]
                self.things.remove(at: index)
                self.service.delete(thing)
                tableView.reloadData()
            })
            alertView.addButton("取消", backgroundColor: UIColor(red: 254/255, green: 208/255, blue: 52/255, alpha: 1), textColor: UIColor.white, showTimeout: nil, action: {
                tableView.setEditing(false, animated: true)
            })
            alertView.showWarning("确定要删除吗？", subTitle: "删除后就找不回来啦。")
        }
        return [deleteAction, shareAction,editAction]
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        inputThingView.endEditing()
        tableView.deselectRow(at: indexPath, animated: true)
        
        let thing = self.things[indexPath.row]
        openThingViewController(with: thing)
    }
    
    func openThingViewController(with thing:ThingModel){
        let editController = EditThingViewController()
        editController.delegate = self
        editController.thing = thing
        self.navigationController?.pushViewController(editController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        inputThingView.endEditing()
    }
    
    private func editThing(_ thing: ThingModel, isTag: Bool = false){
        self.shouldInputViewDisplay = true
        
        let editController = EditThingViewController()
        editController.delegate = self
        editController.thing = thing
        editController.isEditTag = isTag
        self.navigationController?.pushViewController(editController, animated: true)
    }
}

extension HomeViewController : DZNEmptyDataSetSource,DZNEmptyDataSetDelegate{
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "EmptyBox")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "添加一个小事吧", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 16)])
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: Constants.sampleThing, attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 12)])
    }
}

extension HomeViewController : UISearchControllerDelegate{
    func willDismissSearchController(_ searchController: UISearchController) {
        self.shouldInputViewDisplay = true
    }
}

extension HomeViewController : ThingInputDelegate{
    func input(inputView: InputThingView, thing: ThingModel) {
        self.things.insert(thing, at: 0)
        self.sortAndSaveThings()
        tableView.reloadData()
    }
}

extension HomeViewController : VoiceInputDelegate{
    func voiceInput(voiceInputView:VoiceInputController, thing:ThingModel){
        self.things.insert(thing, at: 0)
        self.sortAndSaveThings()
        tableView.reloadData()
    }
}

extension HomeViewController : EditThingDelegate{
    func editThing(isDeleted: Bool, thing: ThingModel) {
        if isDeleted{
            if let index = self.things.index(where: {$0.id == thing.id}){
                self.things.remove(at: index)
            }
        }
        tableView.reloadData()
    }
}

extension HomeViewController : SearchResultTableDelegate{
    func searchResultTable(view: SearchResultTableViewController, thing: ThingModel) {
        openThingViewController(with: thing)
    }
}

