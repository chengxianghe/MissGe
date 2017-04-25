//
//  MLPostTopicController.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/20.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit
import Photos
import AssetsLibrary
import TZImagePickerController

typealias PublishDismissClosure = (_ isActionSucceed: Bool) -> Void;

enum PostTopicType {
    /// 发送圈儿动态 不需要参数
    case postTopic
    
    /// 发送动态评论 需要cid,tid,quote
    case postTopicComment
    
    /// 发送文章评论 需要cid,aip
    case articleComment
}

class MLPostTopicController: BaseViewController {

    // 文章评论
    var aid = ""
    var cid = ""

    // 动态评论
    var quote = ""
    var tid = ""

    var postType = PostTopicType.postTopic
    
    var dismissClosure: PublishDismissClosure?
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var publishButton: UIButton!
    @IBOutlet weak var wordNumberLabel: UILabel!
    
    @IBOutlet weak var publishViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var userAllowProtocolButton: UIButton!
    @IBOutlet weak var hiddenNameSwitch: UISwitch!
    
    let publishRequest = MLPostTopicRequest()
    let commentArticleRequest = MLHomeCommentRequest()
    let commentTopicRequest = MLTopicCommentRequest()

    // 相册
    lazy var imagePickerVc: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        // set appearance / 改变相册选择页的导航栏外观
        picker.navigationBar.barTintColor = self.navigationController!.navigationBar.barTintColor;
        picker.navigationBar.tintColor = self.navigationController!.navigationBar.tintColor;
        picker.navigationBar.titleTextAttributes = self.navigationController!.navigationBar.titleTextAttributes;
        return picker
    }()
    
    var selectedPhotos = NSMutableArray()
    var selectedAssets = NSMutableArray()
    var uploadImages = [String]()
    var isSelectOriginalPhoto = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let collectionViewLineSpace = collectionViewLayout.minimumLineSpacing
        let collectionViewItemSpace = collectionViewLayout.minimumInteritemSpacing
        let headerCellWidth: CGFloat = (kScreenWidth - 20 - 3 * collectionViewLineSpace) / 4.0
        self.collectionViewLayout.itemSize = CGSize(width: headerCellWidth, height: headerCellWidth)
        
        collectionView.register(TZTestCell.classForCoder(), forCellWithReuseIdentifier: "TZTestCell")
        print("collectionViewLineSpace:\(collectionViewLineSpace) -- collectionViewItemSpace:\(collectionViewItemSpace)")
        let collectionViewH = headerCellWidth
        
        publishViewHeightConstraint.constant = 190 + collectionViewH
        
        self.textView.placeholder = "说点什么吧"
        self.wordNumberLabel.text = "剩余\(140 - self.textView.text.length)字"
        
//        self.textView.selectedRange = NSMakeRange(0, 0);
        
        self.textView.textDidChange = { (text: String?) in
            self.wordNumberLabel.text = "剩余\(140 - self.textView.text.length)字"
        }
        
    }
    
    @IBAction func onUserProtocolBtnClick(_ sender: UIButton) {
        self.navigationController?.pushViewController(UIViewController(), animated: true)
    }
    
    @IBAction func onUserAllowProtocolBtnClick(_ sender: UIButton) {
        
    }
    @IBAction func onHiddenNameSwitch(_ sender: UISwitch) {
        
    }
    
    @IBAction func onBackBtnClick(_ sender: UIButton) {
        self.dismissPost(false)
    }
    
    func dismissPost(_ isPostSuccess: Bool) {
        self.view.endEditing(true)
        self.dismiss(animated: true) {
            self.dismissClosure?(isPostSuccess);
        }
    }
    
    @IBAction func onPublishBtnClick(_ sender: UIButton) {
        if (self.textView.text.length > 0 && self.textView.text.length < 140) {

            if postType == .postTopicComment {
                self.publishTopicComment()
            } else if (postType == .articleComment) {
                self.publishArticleComment()
            } else {
                uploadImages.removeAll()
                if selectedPhotos.count > 0 {
                    // selectedPhotos [UIImage]
                    self.showLoading("正在上传图片...")
                    for image in selectedPhotos {
                        uploadImages.append(self.setuoUploadImageWithImage(image as! UIImage))
                    }
                    
                    XHUploadImagesHelper().uploadImages(images: uploadImages, uploadMode: .ignore, progress: { (totals, completions) in
                        print("totals:\(totals) -- completions:\(completions)")
                        }, completion: { (successImageModel: [XHUploadImageModel]?, failedImages: [String]?) in
                            let ids = successImageModel!.map( { $0.resultImageId } )
                            
                            self.publishTopic(ids as? [String])
                    })
                    
                } else {
                    self.publishTopic(nil);
                }
            }
            
        }
        
    }

    
    /**
     *  返回图片完整路径
     *  压缩图约为原图的 1/4
     */
    func setuoUploadImageWithImage(_ image: UIImage) -> String {
        
        var imageData: Data? = nil
        
        if (self.isSelectOriginalPhoto) {
            // 原图
            imageData = UIImageJPEGRepresentation(image, 1.0);
        } else {
            // 压缩的
            imageData = XHImageCompressHelper.getUpLoadImageData(originalImage: image)
        }
        if imageData == nil {
            return ""
        }
        
        let name = NSDate().millisecondTimeDescription().appendingFormat("-size-%d", imageData!.count)
        
        return XHImageCompressHelper.save(imageData: imageData!, withName: name)!;
    }
    
    func publishTopic(_ ids: [String]?) {
        if ids == nil {
            return
        }
        self.showLoading("正在发表")
        
        publishRequest.detail = self.textView.text
        publishRequest.anonymous = self.hiddenNameSwitch.isOn ? 1 : 0;
        publishRequest.ids = ids
        
        publishRequest.send(success: {[unowned self] (baseRequest, responseObject) in
            self.showSuccess("发表成功")
            self.dismissPost(true)
        }) { (baseRequest, error) in
            self.showError("发表失败" + error.localizedDescription)
            print(error)
        }
    }
    
    func publishTopicComment() {
        self.showLoading("正在发表")
        
        commentTopicRequest.detail = self.textView.text
        commentTopicRequest.anonymous = self.hiddenNameSwitch.isOn ? 1 : 0;
        commentTopicRequest.tid = tid
        commentTopicRequest.quote = quote
        
        commentTopicRequest.send(success: {[unowned self] (baseRequest, responseObject) in
            self.showSuccess("发表成功")
            self.dismissPost(true)
        }) { (baseRequest, error) in
            self.showError("发表失败" + error.localizedDescription)
            print(error)
        }
    }

    func publishArticleComment() {
        self.showLoading("正在发表")
        
        commentArticleRequest.detail = self.textView.text
        commentArticleRequest.aid = aid
        commentArticleRequest.cid = cid

        commentArticleRequest.send(success: {[unowned self] (baseRequest, responseObject) in
            self.showSuccess("发表成功")
            self.dismissPost(true)
        }) { (baseRequest, error) in
            self.showError("发表失败" + error.localizedDescription)
            print(error)
        }
    }

    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedPhotos.count + 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TZTestCell", for: indexPath) as? TZTestCell else {
            return UICollectionViewCell()
        }
        
        
        cell.videoImageView.isHidden = true;
        if ((indexPath as NSIndexPath).row == selectedPhotos.count) {
            cell.imageView.image = UIImage(named: "AlbumAddBtn");
            cell.deleteBtn.isHidden = true;
        } else {
            cell.imageView.image = selectedPhotos[(indexPath as NSIndexPath).row] as? UIImage;
            cell.asset = selectedAssets[(indexPath as NSIndexPath).row] as AnyObject;
            cell.deleteBtn.isHidden = false;
        }
        cell.deleteBtn.tag = (indexPath as NSIndexPath).row;
        cell.deleteBtn.addTarget(self, action: #selector(MLPostTopicController.deleteBtnClik(_:)), for: UIControlEvents.touchUpInside)
        return cell;
        
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        if ((indexPath as NSIndexPath).row == selectedPhotos.count) {
            self.view.endEditing(true)
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let actionTakePhoto = UIAlertAction.init(title: "拍照", style: UIAlertActionStyle.default, handler: { (action) in
                self.takePhoto()
            })
            
            let actionSelect = UIAlertAction(title: "去相册选择", style: UIAlertActionStyle.default, handler: { (action) in
                self.pushImagePickerController()
            })
            
            let actionCancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
            
            actionSheet.addAction(actionTakePhoto)
            actionSheet.addAction(actionSelect)
            actionSheet.addAction(actionCancel)
            
            // support iPad
            if (kisIPad()) {
                actionSheet.popoverPresentationController?.sourceView = collectionView
                actionSheet.popoverPresentationController?.sourceRect = (collectionView.cellForItem(at: indexPath)?.frame)!
                //或者
                //            actionSheet.popoverPresentationController?.barButtonItem = self.saveBarButtomItem
            }
            
            self.present(actionSheet, animated: true, completion: nil)
            
        } else { // preview photos or video / 预览照片或者视频
            let asset = selectedAssets[(indexPath as NSIndexPath).row];
            var isVideo = false;
            if ((asset as AnyObject).isKind(of: PHAsset.classForCoder())) {
                let phAsset = asset as! PHAsset;
                isVideo = phAsset.mediaType == PHAssetMediaType.video;
            } else if ((asset as AnyObject).isKind(of: ALAsset.classForCoder())) {
                let alAsset = asset as! ALAsset;
                isVideo = alAsset.value(forProperty: ALAssetPropertyType) as! String == ALAssetTypeVideo
            }
            if (isVideo) { // perview video / 预览视频
                let vc = TZVideoPlayerController()
                
                let model = TZAssetModel.init(asset: asset, type: TZAssetModelMediaTypeVideo, timeLength: "")
                vc.model = model;
                self.present(vc, animated: true, completion: nil)
            } else { // preview photos / 预览照片
                let imagePickerVc = TZImagePickerController.init(selectedAssets: selectedAssets, selectedPhotos: selectedPhotos, index: (indexPath as NSIndexPath).row)
                imagePickerVc?.allowPickingOriginalPhoto = true;
                imagePickerVc?.isSelectOriginalPhoto = isSelectOriginalPhoto;
                imagePickerVc?.didFinishPickingPhotosHandle = ({ (photos: [UIImage]?, assets: [Any]?, isSelectOriginalPhoto: Bool) in
                    self.selectedPhotos = NSMutableArray.init(array: photos!)
                    self.selectedAssets = NSMutableArray.init(array: assets!)
                    self.isSelectOriginalPhoto = isSelectOriginalPhoto;
                    //                    self.collectionViewLayout.itemCount = self.selectedPhotos.count;
                    self.collectionView.reloadData()
                    //                    self.collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
                    
                    self.refreshCollectionViewHeight()
                    
                })
                
                self.present(imagePickerVc!, animated: true, completion: nil)
            }
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension MLPostTopicController: TZImagePickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func refreshCollectionViewHeight() {
        let lines = CGFloat((self.selectedPhotos.count + 4)/4)
        let collectionViewLineSpace = self.collectionViewLayout.minimumLineSpacing
        let collectionViewH = (lines - 1) * collectionViewLineSpace + lines * self.collectionViewLayout.itemSize.height

        if self.publishViewHeightConstraint.constant != 190 + collectionViewH {
            self.publishViewHeightConstraint.constant = 190 + collectionViewH
            UIView.animate(withDuration: 0.3, animations: { 
                self.view.layoutIfNeeded()
                }, completion: { (finished) in
                    self.collectionView.reloadData()

            })
        } else {
            self.collectionView.reloadData()
        }
    }
    
    func deleteBtnClik(_ sender: UIButton) {
        
        selectedPhotos.removeObject(at: sender.tag)
        selectedAssets.removeObject(at: sender.tag)
        //    _layout.itemCount = _selectedPhotos.count;
        
        collectionView.performBatchUpdates({
            let indexPath = IndexPath.init(item: sender.tag, section: 0)
            self.collectionView.deleteItems(at: [indexPath])
        }) { (finished) in
            self.refreshCollectionViewHeight()
        }
    }
    
    func takePhoto() {
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if ((authStatus == AVAuthorizationStatus.restricted || authStatus == AVAuthorizationStatus.denied) && kiOS8Later()) {
            // 无权限 做一个友好的提示
            let actionSheet = UIAlertController(title: "无法使用相机", message: "请在iPhone的'设置-隐私-相机'中允许访问相机", preferredStyle: .alert)
            let actionSet = UIAlertAction.init(title: "设置", style: UIAlertActionStyle.default, handler: { (action) in
                if (kiOS8Later()) {
                    UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
                } else {
                    // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy&path=Photos"]];
                }
            })
            let actionCancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
            actionSheet.addAction(actionSet)
            actionSheet.addAction(actionCancel)
            
            self.present(actionSheet, animated: true, completion: nil)
            
            //            let alert = UIAlertView(title: "无法使用相机", message:, delegate:self, cancelButtonTitle:"取消", otherButtonTitles:"设置", nil);
            //            alert.show()
        } else { // 调用相机
            let sourceType = UIImagePickerControllerSourceType.camera;
            if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
                self.imagePickerVc.sourceType = sourceType;
                if(kiOS8Later()) {
                    imagePickerVc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext;
                }
                self.present(imagePickerVc, animated: true, completion: nil)
            } else {
                print("模拟器中无法打开照相机,请在真机中使用");
            }
        }
    }
    
    // MARK: - ImagePicker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion:nil)
        
        let type = info["UIImagePickerControllerMediaType"] as! String;
        if (type == "public.image") {
            let tzImagePickerVc = TZImagePickerController.init(maxImagesCount: 9, delegate: self)
            
            tzImagePickerVc?.showProgressHUD()
            
            let image = info["UIImagePickerControllerOriginalImage"] as! UIImage
            // save photo and get asset / 保存图片，获取到asset
            TZImageManager.default().savePhoto(with: image, completion: { (error) in
                TZImageManager.default().getCameraRollAlbum(false, allowPickingImage: true, completion: { (model) in
                    TZImageManager.default().getAssetsFromFetchResult(model?.result, allowPickingVideo: false, allowPickingImage: true, completion: {[weak self] (models) in
                        guard let _self = self else {
                            return
                        }
                        tzImagePickerVc?.hideProgressHUD()
                        var assetModel = models?.first
                        if (tzImagePickerVc?.sortAscendingByModificationDate)! {
                            assetModel = models?.last
                        }
                        
                        guard assetModel?.asset != nil else {
                            return
                        }
                        
                        _self.selectedAssets.add((assetModel?.asset)!)
                        _self.selectedPhotos.add(image)
                        _self.collectionView.reloadData()
                    })
                })
            })
    
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
    
    //MARK: - TZImagePickerController
    
    func pushImagePickerController() {
        let imagePickerVc = TZImagePickerController.init(maxImagesCount: 9, delegate: self)
        
        // MARK: - 四类个性化设置，这些参数都可以不传，此时会走默认设置
        imagePickerVc?.isSelectOriginalPhoto = isSelectOriginalPhoto;
        
        // 1.如果你需要将拍照按钮放在外面，不要传这个参数
        imagePickerVc?.selectedAssets = selectedAssets; // optional, 可选的
        imagePickerVc?.allowTakePicture = false; // 在内部显示拍照按钮
        
        // 2. Set the appearance
        // 2. 在这里设置imagePickerVc的外观
        // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
        // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
        // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
        
        // 3. Set allow picking video & photo & originalPhoto or not
        // 3. 设置是否可以选择视频/图片/原图
        imagePickerVc?.allowPickingVideo = false;
        imagePickerVc?.allowPickingImage = true;
        imagePickerVc?.allowPickingOriginalPhoto = true;
        
        // 4. 照片排列按修改时间升序
        imagePickerVc?.sortAscendingByModificationDate = false;
        // MARK: - 到这里为止
        
        // You can get the photos by block, the same as by delegate.
        // 你可以通过block或者代理，来得到用户选择的照片.
        //        imagePickerVc.didFinishPickingPhotosHandle
        
        
        imagePickerVc?.didFinishPickingPhotosHandle = {[weak self] (photos: [UIImage]?, assets: [Any]?, isSelectOriginalPhoto: Bool) in
            guard let _self = self else {
                return
            }
            _self.selectedPhotos = NSMutableArray(array: photos!)
            _self.selectedAssets = NSMutableArray(array: assets!)
            _self.isSelectOriginalPhoto = isSelectOriginalPhoto;
            //    _layout.itemCount = _selectedPhotos.count;
            _self.collectionView.reloadData()
            _self.refreshCollectionViewHeight()
        }
        
        self.present(imagePickerVc!, animated: true, completion: nil)
    }
    
    func tz_imagePickerControllerDidCancel(_ picker: TZImagePickerController!) {
        
    }
    
}
