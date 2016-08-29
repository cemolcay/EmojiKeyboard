//
//  EmojiDataSource.swift
//  EmojiKeyboard
//
//  Created by Cem Olcay on 29/08/16.
//  Copyright © 2016 Mojilala. All rights reserved.
//
// Data source created with awesome:
// https://bitbucket.org/grumdrig/emoji-list
//

import UIKit

public enum EmojiCategory: String {
  case people = "People"
  case nature = "Nature"
  case objects = "Objects"
  case places = "Places"
  case symbols = "Symbols"

  public static let all: [EmojiCategory] = [
    .people, .nature, .objects, .places, .symbols
  ]
}

public class EmojiDataSource {
  private var emojis = [AnyObject]()

  public init() {
    guard let emojiDataFileUrl = NSBundle.mainBundle().URLForResource("emoji", withExtension: "json"),
      let emojiData = NSData(contentsOfURL: emojiDataFileUrl),
      let emojiJSON = try? NSJSONSerialization.JSONObjectWithData(emojiData, options: .MutableContainers) as? [AnyObject]
     else { return }

    emojis = emojiJSON ?? []
  }

  public subscript (category: EmojiCategory) -> [String] {
    return ((emojis.filter({ (($0 as? [String: AnyObject])?["Title"] as? String) == category.rawValue }).first as? [String: AnyObject])?["Data"] as? String)?.componentsSeparatedByString(",") ?? []
  }
}