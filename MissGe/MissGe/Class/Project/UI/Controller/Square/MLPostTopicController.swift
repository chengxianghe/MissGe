//
//  MLPostTopicController.swift
//  MissLi
//
//  Created by chengxianghe on 16/7/20.
//  Copyright © 2016年 cn. All rights reserved.
//

import UIKit
import Photos
import TZImagePickerController
import YYImage
import RxSwift
import RxCocoa
import Moya

typealias PublishDismissClosure = (_ isActionSucceed: Bool) -> Void

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

    let viewModel = MLHomeViewModel()
    var bag: DisposeBag = DisposeBag()
    let provider = MoyaProvider<APIManager>(endpointClosure: kAPIManagerEndpointClosure, requestClosure: kAPIManagerRequestClosure)

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var publishButton: UIButton!
    @IBOutlet weak var wordNumberLabel: UILabel!

    @IBOutlet weak var publishViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var userAllowProtocolButton: UIButton!
    @IBOutlet weak var hiddenNameSwitch: UISwitch!

//    let publishRequest = MLPostTopicRequest()
//    let commentArticleRequest = MLHomeCommentRequest()
//    let commentTopicRequest = MLTopicCommentRequest()

    // 相册
    lazy var imagePickerVc: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        // set appearance / 改变相册选择页的导航栏外观
        picker.navigationBar.barTintColor = self.navigationController!.navigationBar.barTintColor
        picker.navigationBar.tintColor = self.navigationController!.navigationBar.tintColor
        picker.navigationBar.titleTextAttributes = self.navigationController!.navigationBar.titleTextAttributes
        return picker
    }()

    var selectedPhotos = NSMutableArray()
    var selectedAssets = NSMutableArray()
    var selectedModels = NSMutableArray()
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

        self.textView.placeholder = "说点什么吧"
        self.wordNumberLabel.text = "剩余\(140 - self.textView.text.length)字"

//        self.textView.selectedRange = NSMakeRange(0, 0);

        self.textView.textDidChange = {[weak self] (text: String?) in
            guard let _self = self else {
                return
            }
            _self.wordNumberLabel.text = "剩余\(140 - _self.textView.text.length)字"
        }

        if postType != .postTopic {
            collectionView.isHidden = true
            publishViewHeightConstraint.constant = 190
        } else {
            publishViewHeightConstraint.constant = 190 + collectionViewH
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
        self.dismiss(animated: true) {[weak self] in
            guard let _self = self else {
                return
            }
            _self.dismissClosure?(isPostSuccess)
        }
    }

    @IBAction func onPublishBtnClick(_ sender: UIButton) {
        self.textView.resignFirstResponder()

        var checkRight = false
        if postType != .postTopic {
            checkRight = self.textView.text.length > 0 && self.textView.text.length < 140
        } else {
            checkRight = (self.textView.text.length > 0 && self.textView.text.length < 140) || selectedPhotos.count > 0
        }

        if self.textView.text.length <= 0 {
            self.showError("请输入内容")
            return
        }

        if (checkRight) {
            if postType == .postTopicComment {
                self.publishTopicComment()
            } else if (postType == .articleComment) {
                self.publishArticleComment()
            } else {
                uploadImages.removeAll()
                if selectedPhotos.count > 0 {
                    // selectedPhotos [UIImage]
                    self.showLoading("正在上传图片...")
                    var i: Int = 0
                    for tzModel in selectedModels {
                        let model = tzModel as! TZAssetModel
                        if model.type == TZAssetModelMediaTypePhotoGif {
                            XHImageGifHelper.getImageDataWithAsset(asset: model.asset as AnyObject, completion: {[weak self] (isGif, data, error) in
                                guard let _self = self else {
                                    return
                                }
                                if error == nil && data != nil {
                                    _self.uploadImages.append(_self.setuoUploadImageWithImageData(data, isGif: isGif))
                                }
                                i += 1
                                if i == _self.selectedModels.count {
                                    _self.realUpload()
                                }
                            })

                        } else {
                            self.uploadImages.append(self.setuoUploadImageWithImage((selectedPhotos[i] as! UIImage)))
                            i += 1
                            if i == self.selectedModels.count {
                                self.realUpload()
                            }
                        }
                    }
                } else {
                    self.publishTopic(nil)
                }
            }
        }
    }

    func realUpload() {
        XHUploadImagesHelper().uploadImages(images: uploadImages, uploadMode: .ignore, progress: { (totals, completions) in
            print("totals:\(totals) -- completions:\(completions)")
        }, completion: { (successImageModel: [XHUploadImageModel]?, failedImages: [XHUploadImageModel]?) in
            let ids = successImageModel!.map({ $0.resultImageId })

            self.publishTopic(ids as? [String])
        })
    }

    /**
     *  返回图片完整路径
     *  压缩图约为原图的 1/4
     */
    func setuoUploadImageWithImage(_ image: UIImage) -> String {
        var imageData: Data? = nil

        imageData = XHImageCompressHelper.getUpLoadImageData(originalImage: image, isOriginalPhoto: self.isSelectOriginalPhoto)

        if imageData == nil {
            return ""
        }

        let name = NSDate().millisecondTimeDescription().appendingFormat("-size-%d.jpg", imageData!.count)

        if let str = XHImageCompressHelper.save(imageData: imageData!, withName: name) {
            return str
        }

        return ""
    }

    /**
     *  返回gif图片完整路径
     */
    func setuoUploadImageWithImageData(_ imageData: Data?, isGif: Bool) -> String {
        if imageData == nil {
            return ""
        }
        var data: Data! = imageData!

        let name = NSDate().millisecondTimeDescription().appendingFormat("-size-%d.gif", data.count)

        if let str = XHImageCompressHelper.save(imageData: data, withName: name) {
            return str
        }
        return ""
    }

    func publishTopic(_ ids: [String]?) {

        self.showLoading("正在发表")
        self.provider
            .rx
            .request(.PostTopic(anonymous: self.hiddenNameSwitch.isOn ? 1 : 0, ids: ids, detail: self.textView.text.emojiEscapedString))
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .subscribe(onSuccess: { (res) in
                self.showSuccess("发表成功")
                self.dismissPost(true)
            }, onError: { ( error) in
                self.hideHud()
                print(error)
                self.showError("发表失败" + error.localizedDescription)
                print(error)
            }).disposed(by: self.bag)
    }

    func publishTopicComment() {
        self.showLoading("正在发表")
        self.provider
            .rx
            .request(.TopicComment(anonymous: self.hiddenNameSwitch.isOn ? 1 : 0, tid: tid, quote: quote, detail: self.textView.text.emojiEscapedString))
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .subscribe(onSuccess: { (res) in
                self.showSuccess("发表成功")
                self.dismissPost(true)
            }, onError: { ( error) in
                self.hideHud()
                print(error)
                self.showError("发表失败" + error.localizedDescription)
                print(error)
            }).disposed(by: self.bag)
    }

    func publishArticleComment() {
        self.showLoading("正在发表")
        self.provider
            .rx
            .request(.AddHomeComment(aid: aid, cid: cid, detail: self.textView.text.emojiEscapedString))
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .subscribe(onSuccess: { (res) in
                self.showSuccess("发表成功")
                self.dismissPost(true)
            }, onError: { ( error) in
                self.hideHud()
                print(error)
                self.showError("发表失败" + error.localizedDescription)
                print(error)
            }).disposed(by: self.bag)
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

    func deleteBtnClik(indexPath: IndexPath) {

        selectedPhotos.removeObject(at: indexPath.row)
        selectedAssets.removeObject(at: indexPath.row)
        selectedModels.removeObject(at: indexPath.row)
        //    _layout.itemCount = _selectedPhotos.count;

        collectionView.performBatchUpdates({
            self.collectionView.deleteItems(at: [indexPath])
        }) { (finished) in
            self.refreshCollectionViewHeight()
        }
    }

    func takePhoto() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if ((authStatus == AVAuthorizationStatus.restricted || authStatus == AVAuthorizationStatus.denied) && kiOS7Later()) {
            // 无权限 做一个友好的提示
            let actionSheet = UIAlertController(title: "无法使用相机", message: "请在iPhone的'设置-隐私-相机'中允许访问相机", preferredStyle: .alert)
            let actionSet = UIAlertAction.init(title: "设置", style: UIAlertActionStyle.default, handler: { (action) in
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            })
            let actionCancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
            actionSheet.addAction(actionSet)
            actionSheet.addAction(actionCancel)

            self.present(actionSheet, animated: true, completion: nil)
        } else if (PHPhotoLibrary.authorizationStatus().rawValue == 2) { // 已被拒绝，没有相册权限，将无法保存拍的照片
            let actionSheet = UIAlertController(title: "无法访问相册", message: "请在iPhone的'设置-隐私-相册'中允许访问相册", preferredStyle: .alert)
            let actionSet = UIAlertAction.init(title: "设置", style: UIAlertActionStyle.default, handler: { (action) in
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            })
            let actionCancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
            actionSheet.addAction(actionSet)
            actionSheet.addAction(actionCancel)

            self.present(actionSheet, animated: true, completion: nil)
        } else if (PHPhotoLibrary.authorizationStatus().rawValue == 0) { // 正在弹框询问用户是否允许访问相册，监听权限状态
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // .seconds(1)
                // your code here
                return self.takePhoto()
            }
        } else { // 调用相机
            let sourceType = UIImagePickerControllerSourceType.camera
            if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
                self.imagePickerVc.sourceType = sourceType
                imagePickerVc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                self.present(imagePickerVc, animated: true, completion: nil)
            } else {
                print("模拟器中无法打开照相机,请在真机中使用")
            }
        }
    }

    // MARK: - ImagePicker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {

        picker.dismiss(animated: true, completion: nil)

        let type = info["UIImagePickerControllerMediaType"] as! String
        if (type == "public.image") {
            let tzImagePickerVc = TZImagePickerController.init(maxImagesCount: 9, delegate: self)

            tzImagePickerVc?.showProgressHUD()

            let image = info["UIImagePickerControllerOriginalImage"] as! UIImage
            // save photo and get asset / 保存图片，获取到asset
            TZImageManager.default()?.savePhoto(with: image, completion: { (asset, error) in
                TZImageManager.default()?.getCameraRollAlbum(false, allowPickingImage: true, needFetchAssets: true, completion: { (albumModel) in
                    TZImageManager.default()?.getAssetsFrom(albumModel?.result, completion: {[weak self] (models) in
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
                        _self.selectedModels.add(assetModel!)
                        _self.refreshCollectionViewHeight()
                    })
                })
            })

        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    // MARK: - TZImagePickerController

    func pushImagePickerController() {
        let imagePickerVc = TZImagePickerController.init(maxImagesCount: 9, delegate: self)

        // MARK: - 四类个性化设置，这些参数都可以不传，此时会走默认设置
        imagePickerVc?.isSelectOriginalPhoto = isSelectOriginalPhoto

        // 1.如果你需要将拍照按钮放在外面，不要传这个参数 
        imagePickerVc?.selectedAssets = selectedAssets; // optional, 可选的
        imagePickerVc?.selectedModels = selectedModels; // optional, 可选的
        imagePickerVc?.allowTakePicture = false; // 在内部显示拍照按钮
        imagePickerVc?.allowPickingGif = true; // 可以选择gif

        // 2. Set the appearance
        // 2. 在这里设置imagePickerVc的外观
        // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
        // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
        // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];

        // 3. Set allow picking video & photo & originalPhoto or not
        // 3. 设置是否可以选择视频/图片/原图
        imagePickerVc?.allowPickingVideo = true
        imagePickerVc?.allowPickingImage = true
        imagePickerVc?.allowPickingOriginalPhoto = true

        // 4. 照片排列按修改时间升序
        imagePickerVc?.sortAscendingByModificationDate = false
        // MARK: - 到这里为止

        // You can get the photos by block, the same as by delegate.
        // 你可以通过block或者代理，来得到用户选择的照片.
        imagePickerVc?.didFinishPickingPhotosHandle = {[weak self] (photos: [UIImage]?, assets: [Any]?, isSelectOriginalPhoto: Bool) in
            guard let _self = self else {
                return
            }

            _self.selectedPhotos = NSMutableArray(array: photos!)
            _self.selectedAssets = NSMutableArray(array: assets!)
            _self.selectedModels = NSMutableArray(array: imagePickerVc?.selectedModels ?? [])
            _self.isSelectOriginalPhoto = isSelectOriginalPhoto
            _self.refreshCollectionViewHeight()
        }

        self.present(imagePickerVc!, animated: true, completion: nil)
    }

    func tz_imagePickerControllerDidCancel(_ picker: TZImagePickerController!) {

    }

}


// MARK: - UICollectionViewDataSource
extension MLPostTopicController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedPhotos.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TZTestCell", for: indexPath) as? TZTestCell else {
            return UICollectionViewCell()
        }

        cell.videoImageView.isHidden = true
        if (indexPath.row == selectedPhotos.count) {
            cell.imageView.image = UIImage(named: "AlbumAddBtn")
            cell.deleteBtn.isHidden = true
            cell.gifLable.isHidden = true
        } else {
            cell.imageView.image = selectedPhotos[indexPath.row] as? UIImage
            cell.model = selectedModels[indexPath.row] as? TZAssetModel
            cell.deleteBtn.isHidden = false
        }
        cell.deleteClickClosure = {[weak self] (sender: AnyObject?) in
            self?.deleteBtnClik(indexPath: indexPath)
        }
        return cell

    }
}

// MARK: - UICollectionViewDelegate
extension MLPostTopicController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
            let assetModel = selectedModels[(indexPath as NSIndexPath).row] as? TZAssetModel
            if (assetModel?.type == TZAssetModelMediaTypeVideo) { // perview video / 预览视频
                let vc = TZVideoPlayerController()
                vc.model = assetModel
                self.present(vc, animated: true, completion: nil)
            } else { // preview photos / 预览照片
                let imagePickerVc = TZImagePickerController.init(selectedAssets: selectedAssets, selectedPhotos: selectedPhotos, index: (indexPath as NSIndexPath).row)
                imagePickerVc?.allowPickingOriginalPhoto = true
                imagePickerVc?.allowPickingGif = true
                imagePickerVc?.isSelectOriginalPhoto = isSelectOriginalPhoto
                imagePickerVc?.selectedModels = self.selectedModels
                imagePickerVc?.didFinishPickingPhotosHandle = ({ (photos: [UIImage]?, assets: [Any]?, isSelectOriginalPhoto: Bool) in
                    self.selectedPhotos = NSMutableArray.init(array: photos!)
                    self.selectedAssets = NSMutableArray.init(array: assets!)
                    self.selectedModels = NSMutableArray.init(array: imagePickerVc?.selectedModels ?? [])
                    self.isSelectOriginalPhoto = isSelectOriginalPhoto
                    self.refreshCollectionViewHeight()
                })

                self.present(imagePickerVc!, animated: true, completion: nil)
            }
        }

    }

}
