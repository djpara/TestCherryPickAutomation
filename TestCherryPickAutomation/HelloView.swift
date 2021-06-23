//
//  HelloView.swift
//  TestCherryPickAutomation
//
//  Created by David Para on 6/22/21.
//

import SwiftUI

struct HelloView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Hello, World!")
            Text("Hello, You!")
        }
    }
}

struct HelloView_Previews: PreviewProvider {
    static var previews: some View {
        HelloView()
    }
}
