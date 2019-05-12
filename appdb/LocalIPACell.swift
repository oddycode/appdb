//
//  LocalIPACell.swift
//  appdb
//
//  Created by ned on 28/04/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit
import Cartography
import Alamofire

class LocalIPACell: UICollectionViewCell {
    
    fileprivate var filename: UILabel!
    fileprivate var size: UILabel!
    fileprivate var moreImageButton: UIImageView!
    fileprivate var dummy: UIView!
    fileprivate var semaphore: Bool = false
    fileprivate var progressView: UIProgressView!
    
    func updateText(_ text: String) {
        size.text = text
    }
    
    func configure(with ipa: LocalIPAFile) {
        filename.text = ipa.filename
        size.text = ipa.size
        progressView.isHidden = true
    }
    
    func configureForUpload(with ipa: LocalIPAFile, util: LocalIPAUploadUtil) {
        filename.text = ipa.filename
        progressView.isHidden = false
        semaphore = false
        
        size.text = util.lastCachedProgress
        progressView.progress = util.lastCachedFraction
        
        util.onProgress = { fraction, text in
            if !self.semaphore, !util.isPaused { // prevent wrong cell text update after reuse
                self.size.text = text
                self.progressView.setProgress(fraction, animated: true)
            }
        }
        
        util.onPause = {
            if let partial = util.lastCachedProgress.components(separatedBy: "Uploading".localized() + " ").last {
                self.size.text = "Paused".localized() + " - \(partial)"
            } else {
                self.size.text = "Paused"
            }
        }
        
        util.onCompletion = {
            self.filename.text = ipa.filename
            self.size.text = ipa.size
            delay(0.1) {
                self.progressView.isHidden = true
                self.progressView.progress = 0.0
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        semaphore = true
        filename.text = ""
        size.text = ""
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    func setup() {
        theme_backgroundColor = Color.veryVeryLightGray
        contentView.theme_backgroundColor = Color.veryVeryLightGray
        
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 6
        contentView.layer.borderWidth = 1 / UIScreen.main.scale
        contentView.layer.theme_borderColor = Color.borderCgColor
        layer.backgroundColor = UIColor.clear.cgColor
        
        // Filename
        filename = UILabel()
        filename.theme_textColor = Color.title
        filename.font = .systemFont(ofSize: 17~~16)
        filename.numberOfLines = 1
        filename.makeDynamicFont()
        
        // Info
        size = UILabel()
        size.theme_textColor = Color.darkGray
        size.font = .systemFont(ofSize: 13~~12)
        size.numberOfLines = 1
        size.makeDynamicFont()
        
        // Progress view
        progressView = UIProgressView()
        progressView.trackTintColor = .clear
        progressView.theme_progressTintColor = Color.mainTint
        progressView.progress = 0
        progressView.isHidden = true
        
        // More image button
        moreImageButton = UIImageView(image: #imageLiteral(resourceName: "more"))
        moreImageButton.alpha = 0.9
        
        dummy = UIView()
        
        contentView.addSubview(filename)
        contentView.addSubview(size)
        contentView.addSubview(moreImageButton)
        contentView.addSubview(progressView)
        contentView.addSubview(dummy)
        
        constrain(filename, size, moreImageButton, progressView, dummy) { name, size, moreButton, progress, d in
            
            moreButton.centerY == moreButton.superview!.centerY
            moreButton.right == moreButton.superview!.right - Global.size.margin.value
            moreButton.width == (22~~20)
            moreButton.height == moreButton.width
            
            d.height == 1
            d.centerY == d.superview!.centerY
            
            name.left == name.superview!.left + Global.size.margin.value
            name.right == moreButton.left - Global.size.margin.value
            name.bottom == d.top + 2
            
            size.left == name.left
            size.right == name.right
            size.top == d.bottom + 3
            
            progress.bottom == progress.superview!.bottom
            progress.left == progress.superview!.left
            progress.right == progress.superview!.right
        }
    }
    
    // Hover animation
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIView.animate(withDuration: 0.1) {
                    self.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
                }
            } else {
                UIView.animate(withDuration: 0.1) {
                    self.transform = .identity
                }
            }
        }
    }
}
