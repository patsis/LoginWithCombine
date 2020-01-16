//
//  UserViewModel.swift
//  combineLogin
//
//  Created by Harry Patsis on 14/1/20.
//  Copyright © 2020 Harry Patsis. All rights reserved.
//

import Foundation
import Combine

class UserViewModel: ObservableObject {
  /// input
  @Published var userName = ""
  @Published var password1 = ""
  @Published var password2 = ""
  
  /// output
  @Published var isValid = false
  @Published var userNameMessage = ""
  @Published var passwordMessage = ""
  
  var userUnitialized = true
  var passUninitialized = true
  
  private var cancellableSet: Set<AnyCancellable> = []
  
  private var isUserNameValidPublisher: AnyPublisher<Bool, Never> {
    $userName
      .debounce(for: 0.8, scheduler: RunLoop.main)
      .removeDuplicates()
      .map { input in
        if input.count < 3 && !self.userUnitialized {
          return false
        }
        self.userUnitialized = false
        return true }
      .eraseToAnyPublisher()
  }
  
  private var isPasswordEmptyPublisher: AnyPublisher<Bool, Never> {
    $password1
      .debounce(for: 0.8, scheduler: RunLoop.main)
      .removeDuplicates()
      .map { input in
        return input.isEmpty }
      .eraseToAnyPublisher()
  }
  
  private var isPasswordDifferentPublisher: AnyPublisher<Bool, Never> {
    Publishers.CombineLatest($password1, $password2)
      .debounce(for: 0.5, scheduler: RunLoop.main)
      .map {pass1, pass2 in
        return pass1 != pass2}
      .eraseToAnyPublisher()
  }
  
  enum PasswordCheck {
    case valid
    case uninitialized
    case empty
    case different
  }
  
  private var isPasswordValidPublisher: AnyPublisher<PasswordCheck, Never> {
    Publishers.CombineLatest(isPasswordEmptyPublisher, isPasswordDifferentPublisher)
      .map { isEmpty, isDifferent in
        if isEmpty {
          if self.passUninitialized {
            return .uninitialized
          }
          return .empty
        }
        self.passUninitialized = false
        if isDifferent {
          return .different
        }
        return .valid }
      .eraseToAnyPublisher()
  }
  
  private var isCredentialsValidPublisher: AnyPublisher<Bool, Never> {
    Publishers.CombineLatest(isUserNameValidPublisher, isPasswordValidPublisher)
      .map { userNameValid, passwordValid in
        return userNameValid && passwordValid == .valid }
      .eraseToAnyPublisher()
  }
  
  init() {
    isUserNameValidPublisher
      .receive(on: RunLoop.main)
      .map { valid in
        valid ? "" : "User name too short"}
      .assign(to: \.userNameMessage, on: self)
      .store(in: &cancellableSet)
    
    isPasswordValidPublisher
      .receive(on: RunLoop.main)
      .map { passwordCheck in
        switch passwordCheck {
        case .empty:
          return "Password must not be empty"
        case .different:
          return "Passwords must be the same"
        default:
          return ""
        }
    }
    .assign(to: \.passwordMessage, on: self)
    .store(in: &cancellableSet)
  
  
    isCredentialsValidPublisher
      .receive(on: RunLoop.main)
      .assign(to: \.isValid, on: self)
      .store(in: &cancellableSet)
  }
}
