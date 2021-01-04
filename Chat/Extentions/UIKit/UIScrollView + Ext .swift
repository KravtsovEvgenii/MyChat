//
//  UIScrollView + Ext .swift
//  Chat
//
//  Created by User on 03.01.2021.
//

import UIKit

extension UIScrollView {
    //Проверяем выходит ли новое сообщение за пределы экрана
    var isAtBottom: Bool {
        return contentOffset.y >= verticalOffsetForBottom
    }
    var verticalOffsetForBottom: CGFloat {
      let scrollViewHeight = bounds.height
      let scrollContentSizeHeight = contentSize.height
      let bottomInset = contentInset.bottom
      let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
      return scrollViewBottomOffset
    }
}
