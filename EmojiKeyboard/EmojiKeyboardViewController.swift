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
  func getSizeWithFont (width: CGFloat = .greatestFiniteMagnitude, height: CGFloat = .greatestFiniteMagnitude, font: UIFont) -> CGSize {
    return boundingRect(
      with: CGSize(width: width, height: height),
      options: .usesLineFragmentOrigin,
      attributes: [NSFontAttributeName: font],
      context: nil).size
  }
}

extension String {
  func getSizeWithFont (width: CGFloat = .greatestFiniteMagnitude, height: CGFloat = .greatestFiniteMagnitude, font: UIFont) -> CGSize {
    return (self as NSString).getSizeWithFont(
      width: width,
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
    emojiLabel?.textColor = .black
    emojiLabel?.font = UIFont(name: "AppleColorEmoji", size: 15)!
    emojiLabel?.textAlignment = .center
    contentView.addSubview(emojiLabel!)
    emojiLabel?.translatesAutoresizingMaskIntoConstraints = false
    emojiLabel?.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
    emojiLabel?.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
    emojiLabel?.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
    emojiLabel?.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
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
    titleLabel?.textColor = .black
    titleLabel?.font = UIFont.systemFont(ofSize: 15)
    titleLabel?.textAlignment = .center
    addSubview(titleLabel!)
    titleLabel?.translatesAutoresizingMaskIntoConstraints = false
    titleLabel?.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    titleLabel?.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    titleLabel?.topAnchor.constraint(equalTo: topAnchor).isActive = true
    titleLabel?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
  }
}

protocol EmojiKeyboardViewControllerDelegate: class {
  func emojiKeyboardViewController(_ emojiKeyboardViewContorller: EmojiKeyboardViewController, didPress emoji: String)
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
      collectionView?.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
      collectionView?.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
      collectionView?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
      collectionView?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    // Setup Flow Layout
    if horizontalFloatingFlowLayout == nil {
      horizontalFloatingFlowLayout = HorizontalFloatingHeaderLayout()
      collectionView?.collectionViewLayout = horizontalFloatingFlowLayout!
    }

    // Register Cell
    collectionView?.register(
      EmojiCollectionViewCell.self,
      forCellWithReuseIdentifier: EmojiCollectionViewCell.cellReuseIdentifier)

    // Register Header
    collectionView?.register(
      EmojiCollectionViewHeader.self,
      forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
      withReuseIdentifier: EmojiCollectionViewHeader.headerReuseIdentifier)
  }

  // MARK: UICollectionViewDataSource
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return EmojiCategories.all.count
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return EmojiDataSource.shared[EmojiCategories.all[section]].count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: EmojiCollectionViewCell.cellReuseIdentifier,
      for: indexPath) as! EmojiCollectionViewCell

    let emoji = EmojiDataSource.shared[EmojiCategories.all[indexPath.section]][indexPath.item]
    cell.emojiLabel?.text = "\(emoji)"

    return cell
  }

  // MARK: UICollectionViewDelegate
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.deselectItem(at: indexPath, animated: true)

    let emoji = EmojiDataSource.shared[EmojiCategories.all[indexPath.section]][indexPath.item]
    delegate?.emojiKeyboardViewController(self, didPress: emoji)
  }

  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let header = collectionView.dequeueReusableSupplementaryView(
      ofKind: kind,
      withReuseIdentifier: EmojiCollectionViewHeader.headerReuseIdentifier,
      for: indexPath) as! EmojiCollectionViewHeader

    let category = EmojiCategories.all[indexPath.section].rawValue
    header.titleLabel?.text = category

    return header
  }

  // MARK: UICollectionViewDelegateFlowLayout
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    let category = EmojiCategories.all[section].rawValue
    return category.getSizeWithFont(font: UIFont.systemFont(ofSize: 15))
  }

  // MARK: HorizontalFloatingHeaderLayoutDelegate
  func collectionView(_ collectionView: UICollectionView, horizontalFloatingHeaderItemSizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
    return CGSize(width: 30, height: 30)
  }

  func collectionView(_ collectionView: UICollectionView, horizontalFloatingHeaderSizeForSectionAtIndex section: Int) -> CGSize {
    return CGSize(width: 80, height: 30)
  }

  func collectionView(_ collectionView: UICollectionView, horizontalFloatingHeaderItemSpacingForSectionAtIndex section: Int) -> CGFloat {
    return 8
  }

  func collectionView(_ collectionView: UICollectionView, horizontalFloatingHeaderColumnSpacingForSectionAtIndex section: Int) -> CGFloat {
    return 8
  }

  func collectionView(_ collectionView: UICollectionView, horizontalFloatingHeaderSectionInsetForSectionAtIndex section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
  }
}
