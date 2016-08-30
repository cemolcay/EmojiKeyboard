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

public enum EmojiCategories: String {
  case people = "People"
  case nature = "Nature"
  case objects = "Objects"
  case places = "Places"
  case symbols = "Symbols"

  public static let all: [EmojiCategories] = [
    .people, .nature, .objects, .places, .symbols
  ]
}

public class EmojiItem {
  public let rawValue: String // UTF8 representation of emoji
  public var description: String? // Tags or keywords for emoji if provided in data file

  public init(rawValue: String) {
    self.rawValue = rawValue
  }
}

public class EmojiDataSource {
  public static let shared = EmojiDataSource()
  private var dataSource = [String: [EmojiItem]]()

  public init() {
    guard let emojiDataFileUrl = NSBundle.mainBundle().URLForResource("emoji", withExtension: "json"),
      let emojiData = NSData(contentsOfURL: emojiDataFileUrl),
      let emojiJSON = try? NSJSONSerialization.JSONObjectWithData(emojiData, options: .MutableContainers) as? [AnyObject],
      let json = emojiJSON
     else { return }

    for emojiCategory in json {
      guard let emojiCategory = emojiCategory as? [String: AnyObject],
        let title = emojiCategory["Title"] as? String,
        let data = emojiCategory["Data"] as? String
        else { continue }

      var items = [EmojiItem]()
      for item in data.componentsSeparatedByString(",") {
        items.append(EmojiItem(rawValue: item))
      }

      dataSource[title] = items
    }
  }

  public subscript(category: EmojiCategories) -> [String] {
    return dataSource[category.rawValue]?.flatMap({ $0.rawValue }) ?? []
  }
}
