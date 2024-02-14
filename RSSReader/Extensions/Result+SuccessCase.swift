//
//  Result+SuccessCase.swift
//  RSSReader
//
//  Created by Heorhi Heilik on 14.02.24.
//

import Foundation

extension Result where Success == Void {
    public static var success: Result { .success(()) }
}
