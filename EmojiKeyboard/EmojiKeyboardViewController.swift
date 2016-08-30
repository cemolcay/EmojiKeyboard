//
//  EmojiKeyboardViewController.swift
//  EmojiKeyboard
//
//  Created by Cem Olcay on 29/08/16.
//  Copyright © 2016 Mojilala. All rights reserved.
//

import UIKit
import HorizontalFloatingHeaderLayout

extension NSString {
  func getSizeWithFont (width: CGFloat = .max, height: CGFloat = .max, font: UIFont) -> CGSize {
    return boundingRectWithSize(
      CGSize(width: width, height: height),
      options: .UsesLineFragmentOrigin,
      attributes: [NSFontAttributeName: font],
      context: nil).size
  }
}

extension String {
  func getSizeWithFont (width: CGFloat = .max, height: CGFloat = .max, font: UIFont) -> CGSize {
    return (self as NSString).getSizeWithFont(
      width,
      height: height,
      font: font)
  }
}

class EmojiCollectionViewCell: UICollectionViewCell {
  static let cellReuseIdentifier = "EmojiCell"
  var emojiLabel: UILabel?

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  private func commonInit() {
    emojiLabel = UILabel(frame: frame)
    emojiLabel?.textColor = UIColor.blackColor()
    emojiLabel?.font = UIFont(name: "AppleColorEmoji", size: 15)!
    emojiLabel?.textAlignment = .Center
    contentView.addSubview(emojiLabel!)
    emojiLabel?.translatesAutoresizingMaskIntoConstraints = false
    emojiLabel?.leftAnchor.constraintEqualToAnchor(contentView.leftAnchor).active = true
    emojiLabel?.rightAnchor.constraintEqualToAnchor(contentView.rightAnchor).active = true
    emojiLabel?.topAnchor.constraintEqualToAnchor(contentView.topAnchor).active = true
    emojiLabel?.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor).active = true
  }
}

class EmojiCollectionViewHeader: UICollectionReusableView {
  static let headerReuseIdentifier = "EmojiHeader"
  var titleLabel: UILabel?

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  private func commonInit() {
    titleLabel = UILabel(frame: frame)
    titleLabel?.textColor = UIColor.blackColor()
    titleLabel?.font = UIFont.systemFontOfSize(15)
    titleLabel?.textAlignment = .Center
    addSubview(titleLabel!)
    titleLabel?.translatesAutoresizingMaskIntoConstraints = false
    titleLabel?.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
    titleLabel?.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
    titleLabel?.topAnchor.constraintEqualToAnchor(topAnchor).active = true
    titleLabel?.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
  }
}

protocol EmojiKeyboardViewControllerDelegate: class {
  func emojiKeyboardViewController(emojiKeyboardViewContorller: EmojiKeyboardViewController, didPress emoji: String)
}

class EmojiKeyboardViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, HorizontalFloatingHeaderLayoutDelegate, UICollectionViewDelegateFlowLayout {
  @IBOutlet weak var collectionView: UICollectionView?
  @IBOutlet weak var horizontalFloatingFlowLayout: HorizontalFloatingHeaderLayout?
  weak var delegate: EmojiKeyboardViewControllerDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()

    // Setup Collection View
    if collectionView == nil {
      collectionView  = UICollectionView(frame: view.frame)
      collectionView?.dataSource = self
      collectionView?.delegate = self
      view.addSubview(collectionView!)
      collectionView?.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
      collectionView?.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true
      collectionView?.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
      collectionView?.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
    }

    // Setup Flow Layout
    if horizontalFloatingFlowLayout == nil {
      horizontalFloatingFlowLayout = HorizontalFloatingHeaderLayout()
      collectionView?.collectionViewLayout = horizontalFloatingFlowLayout!
    }

    // Register Cell
    collectionView?.registerClass(
      EmojiCollectionViewCell.self,
      forCellWithReuseIdentifier: EmojiCollectionViewCell.cellReuseIdentifier)

    // Register Header
    collectionView?.registerClass(
      EmojiCollectionViewHeader.self,
      forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
      withReuseIdentifier: EmojiCollectionViewHeader.headerReuseIdentifier)
  }

  // MARK: UICollectionViewDataSource
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return EmojiCategories.all.count
  }

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return EmojiDataSource.shared[EmojiCategories.all[section]].count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
      EmojiCollectionViewCell.cellReuseIdentifier,
      forIndexPath: indexPath) as! EmojiCollectionViewCell

    let emoji = EmojiDataSource.shared[EmojiCategories.all[indexPath.section]][indexPath.item]
    cell.emojiLabel?.text = "\(emoji)"

    return cell
  }

  // MARK: UICollectionViewDelegate
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    collectionView.deselectItemAtIndexPath(indexPath, animated: true)

    let emoji = EmojiDataSource.shared[EmojiCategories.all[indexPath.section]][indexPath.item]
    delegate?.emojiKeyboardViewController(self, didPress: emoji)
  }

  func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    let header = collectionView.dequeueReusableSupplementaryViewOfKind(
      kind,
      withReuseIdentifier: EmojiCollectionViewHeader.headerReuseIdentifier,
      forIndexPath: indexPath) as! EmojiCollectionViewHeader

    let category = EmojiCategories.all[indexPath.section].rawValue
    header.titleLabel?.text = category

    return header
  }

  // MARK: UICollectionViewDelegateFlowLayout
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    let category = EmojiCategories.all[section].rawValue
    return category.getSizeWithFont(font: UIFont.systemFontOfSize(15))
  }

  // MARK: HorizontalFloatingHeaderLayoutDelegate
  func collectionView(collectionView: UICollectionView, horizontalFloatingHeaderItemSizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return CGSize(width: 30, height: 30)
  }

  func collectionView(collectionView: UICollectionView, horizontalFloatingHeaderSizeForSectionAtIndex section: Int) -> CGSize {
    return CGSize(width: 80, height: 30)
  }

  func collectionView(collectionView: UICollectionView, horizontalFloatingHeaderItemSpacingForSectionAtIndex section: Int) -> CGFloat {
    return 8
  }

  func collectionView(collectionView: UICollectionView, horizontalFloatingHeaderColumnSpacingForSectionAtIndex section: Int) -> CGFloat {
    return 8
  }

  func collectionView(collectionView: UICollectionView, horizontalFloatingHeaderSectionInsetForSectionAtIndex section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
  }
}
