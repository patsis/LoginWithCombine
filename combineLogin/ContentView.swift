//
//  ContentView.swift
//  combineLogin
//
//  Created by Harry Patsis on 14/1/20.
//  Copyright © 2020 Harry Patsis. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  @ObservedObject var userViewModel: UserViewModel = UserViewModel()
  
  var body: some View {
    Form {
      Section(footer: Text(userViewModel.userNameMessage).foregroundColor(.red) ) {
        TextField("User name", text: $userViewModel.userName)
          .autocapitalization(.none)
      }
      Section(footer: Text(userViewModel.passwordMessage).foregroundColor(.red) ) {
        SecureField("Password", text: $userViewModel.password1)
        SecureField("Repeat Password", text: $userViewModel.password2)
      }
      Section {
        Button(action : {}) {
          Text("Sign up")
        }
        .disabled(!userViewModel.isValid)
      }
    }
    
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
