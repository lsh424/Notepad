//
//  MemoViewController.swift
//  NotePad
//
//  Created by seunghwan Lee on 2020/02/16.
//  Copyright © 2020 seunghwan Lee. All rights reserved.
//

// 라이브러리 사용 - https://github.com/DragonCherry/AssetsPickerViewController
import UIKit
import AssetsPickerViewController
import Photos

enum Mode{
    case write
    case read
    case modify
}

class MemoViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet var titleLabel: UITextField!
    @IBOutlet var contents: UITextView!
    @IBOutlet var imgCollectionView: UICollectionView!
    @IBOutlet var aboutImgLabel: UILabel!
    @IBOutlet var textViewtBotConst: NSLayoutConstraint!
    
    var memoMode = Mode.write
    var readData: MemoData?
    
    lazy var dao = MemoDAO()
    lazy var imageManager = ImageManager()
    
    var imgList: [UIImage] = []
    var imgIDs: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toolbarSetup()
        
        imgCollectionView.collectionViewLayout = CollectionViewGridLayout(numberofColumns: 3)

        contents.delegate = self
        titleLabel.delegate = self
        imgCollectionView.delegate = self
        imgCollectionView.dataSource = self
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(longPressGestureRecognizer:)))
        self.view.addGestureRecognizer(longPressRecognizer)
 
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
                
        if memoMode == .read {

            imgIDs = readData?.imgIDs ?? []
            imgList = imageManager.fetchImageFromDocumentDitectory(imgIDs)
            titleLabel.text = readData?.title
            contents.text = readData?.contents
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: titleLabel.frame.height - 1, width: titleLabel.frame.width, height: 1)
        bottomLine.backgroundColor = UIColor.black.cgColor
        titleLabel.layer.addSublayer(bottomLine)
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
        if memoMode == .write {
            if contents.text.isEmpty == false || titleLabel.text?.isEmpty == false || imgList.count > 0 {
                save()
            }
        } else if memoMode == .modify {
            modify()
          }
        }
    }
    
    func toolbarSetup() {
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: 0, height: 38)
        toolbar.barTintColor = UIColor.lightGray
                
        let imgPicker = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.camera, target: self  , action: #selector(selectImageSource))
                
        let btnImg = UIImage(named: "down")
        let hideKeybrd = UIBarButtonItem(image: btnImg, style: .done, target: self, action: #selector(hideKeyboard))
                
            toolbar.setItems([imgPicker, hideKeybrd], animated: true)
            contents.inputAccessoryView = toolbar
            titleLabel.inputAccessoryView = toolbar
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        changeModeReadToModify()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        changeModeReadToModify()
    }
    
    func save() {
        let data = getData()
        self.dao.insert(data)
        return
    }
        
    func modify() {
        let data = getData()
        self.dao.update(data, self.readData!.objectID! )
        return
    }
    
    func getData() -> MemoData {
        
        let data = MemoData()
        data.contents = contents.text
        data.date = Date()
        data.title = titleLabel.text
        data.imgIDs = imgIDs
        
        if imgList.count > 0 {
        data.thumbnail = imgList[0]
        }

        return data
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            textViewtBotConst.constant = keyboardHeight
        }
    }
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = longPressGestureRecognizer.location(in: self.imgCollectionView)
            if let indexPath = imgCollectionView.indexPathForItem(at: touchPoint){
                
                imageManager.deleteImage(imgNames: imgIDs, index: indexPath.row)
                
                imgList.remove(at: indexPath.row)
                imgIDs.remove(at: indexPath.row)
                
                self.imgCollectionView.reloadData()
                changeModeReadToModify()
            }
        }
    }
    
    @objc func hideKeyboard(_ sender: Any){
        self.view.endEditing(true)
       }
    
    @objc func selectImageSource(_ sender: Any) {
        self.view.endEditing(true)
        
        let source = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        source.addAction(UIAlertAction(title: "카메라", style: .default, handler: { (_) in
            self.presentPicker(source: .camera)
        }))
        
        source.addAction(UIAlertAction(title: "사진 라이브러리", style: .default, handler: { (_) in
            self.presentPicker(source: .photoLibrary)
               }))
        
        source.addAction(UIAlertAction(title: "외부 이미지", style: .default, handler: { (_) in
            let alert = UIAlertController(title: nil, message: "외부 이미지 링크를 입력해 주세요.", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "이미지 링크"
            }
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { (_) in
                let link = alert.textFields?[0].text
                self.getLinkImage(link)
            }))

            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            self.present(alert, animated: false)
           }))
    
        source.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        self.present(source, animated: true)
    }
    
    func changeModeReadToModify() {
        // 만약 읽기모드라면 수정모드로 변경
        if memoMode == .read {
            memoMode = .modify
        }
    }
}

extension MemoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if imgList.count > 0 {
        aboutImgLabel.isHidden = false
        } else {
        aboutImgLabel.isHidden = true
        }
        return imgList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
        cell.imgView.image = imgList[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ImageDetailVC") as? ImageDetailViewController else {
            return
        }
        
        vc.imgList = imgList
        vc.idxPath = indexPath
        self.present(vc, animated: true, completion: nil)
    }
}

// MARK: 이미지 관련
extension MemoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, AssetsPickerViewControllerDelegate {
    
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        let imgs = getAssetImage(assets: assets)
        imgList.append(contentsOf: imgs)
        imgCollectionView.reloadData()
        changeModeReadToModify()
    }
    
    func presentPicker(source: UIImagePickerController.SourceType) {
        if source == .camera {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = source
        self.present(picker, animated: false)
        } else {
        PresentPhotoLibrary()
        }
    }
    
    func PresentPhotoLibrary(){
        let picker = AssetsPickerViewController()
        picker.pickerDelegate = self
        present(picker, animated: true, completion: nil)
        AssetsPickerConfig.customStringConfig = [
            .cancel: "취소",
            .done: "완료",
            .titleAlbums: "앨범",
            .titleSelectedPhoto: "%@ 장의 사진 선택",
            .titleSelectedPhotos: "%@ 장의 사진 선택",
            .titleNoItems: "사진 및 비디오가 없습니다."
        ]
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let selectedImg = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imgList.append(selectedImg)
            
            let imgID = imageManager.saveImage(img: selectedImg)
            imgIDs.append(imgID)
            
            imgCollectionView.reloadData()
            changeModeReadToModify()
        }
        picker.dismiss(animated: false)
    }
    
    func getAssetImage(assets: [PHAsset]) -> [UIImage] {
        var arrayOfImages = [UIImage]()
        for asset in assets {
            
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            var image = UIImage()
            option.isSynchronous = true
            manager.requestImage(for: asset, targetSize: CGSize(width: 800, height: 800), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                    image = result!

                let imgID = self.imageManager.saveImage(img: image)
                arrayOfImages.append(image)
                self.imgIDs.append(imgID)
                })
            }
            return arrayOfImages
        }
        
    func getLinkImage(_ link: String? ) {
        let alert = UIAlertController(title: "오류", message: "입력값이 비었거나 잘못되었습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        
        guard let link = link,
            let url = URL(string: link) else {
                self.present(alert, animated: false, completion: nil)
                return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                  let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                  let data = data, error == nil,
                  let image = UIImage(data: data) else {
                  DispatchQueue.main.async {
                     self.present(alert, animated: false, completion: nil)
                    }
                  return
            }
            
                let imgID = self.imageManager.saveImage(img: image)
                self.imgList.append(image)
                self.imgIDs.append(imgID)
            
                DispatchQueue.main.async {
                    self.imgCollectionView.reloadData()
                    self.changeModeReadToModify()
                }
                }.resume()
    }
}



