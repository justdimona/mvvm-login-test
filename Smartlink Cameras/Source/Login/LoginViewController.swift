//
//  LoginViewController.swift
//  Smartlink Cameras
//
//  Created by SecureNet Mobile Team on 1/10/20.
//  Copyright © 2020 SecureNet Technologies, LLC. All rights reserved.
//

import RxSwift
import UIKit

final class LoginViewController: UIViewController, ViewModelAttachingProtocol {

    // MARK: - Conformance to ViewModelAttachingProtocol
    var bindings: LoginViewModel.Bindings {
        return LoginViewModel.Bindings(
            loginButtonTap: loginButton.rx.tap.asObservable(),
            rememberUserCheckboxTap: checkboxButton.rx.tap.asObservable(),
            usernameTextChanged: usernameTextField.rx.text.asObservable()
        )
    }
    
    var viewModel: Attachable<LoginViewModel>!
    
    func configureReactiveBinding(viewModel: LoginViewModel) -> LoginViewModel {
        viewModel.rememberUserCheckbox
            .map { $0 ? UIImage(named: "icon-checkmark") : nil }
            .subscribe(onNext: { [weak self] in self?.checkboxButton.setImage($0, for: []) })
            .disposed(by: disposeBag)
        return viewModel
    }
    
    
    // MARK: - Logic variables
    fileprivate let disposeBag = DisposeBag()
    
    
    // MARK: - UI variables
    fileprivate var areConstraintsSet: Bool = false
    
    fileprivate lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "smartlink_bg"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    fileprivate lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "smartlink_logo_light"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    fileprivate lazy var usernameTextField: BottomLineTextField = {
       let textField = BottomLineTextField()
        textField.borderStyle = .none
        textField.font = textField.font?.withSize(17.0)
        textField.returnKeyType = .next
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        textField.autocorrectionType = .no
        textField.placeholder = NSLocalizedString("Username", comment: "Username text field placeholder")
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    fileprivate lazy var passwordTextField: BottomLineTextField = {
       let textField = BottomLineTextField()
        textField.borderStyle = .none
        textField.font = textField.font?.withSize(17.0)
        textField.returnKeyType = .done
        textField.isSecureTextEntry = true
        textField.placeholder = NSLocalizedString("Password", comment: "Password text field placeholder")
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    fileprivate lazy var checkboxButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.borderWidth = 2.0
        button.tintColor = .darkGray
        return button
    }()
    
    fileprivate lazy var rememberUserLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Remember Me", comment: "Remember user label text")
        label.font = label.font.withSize(14.0)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate lazy var forgotPasswordButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.textColor = .darkGray
        button.setTitle(NSLocalizedString("Forgot Password?", comment: "Forgot password button title"), for: .normal)
        button.setTitleColor(.darkGray, for: [])
        button.titleLabel?.font = button.titleLabel?.font.withSize(14.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return button
    }()
    
    fileprivate lazy var loginButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(NSLocalizedString("Sign In", comment: "Login button text"), for: [])
        button.setTitleColor(.white, for: [])
        button.backgroundColor = UIColor(red: 62/255, green: 106/255, blue: 121/255, alpha: 1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    fileprivate lazy var diyStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .top
        stackView.axis = .horizontal
        stackView.spacing = 5.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    fileprivate lazy var diyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = label.font.withSize(14.0)
        label.text = NSLocalizedString("Installing a DIY System ?", comment: "DIY System label text")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate lazy var diyButton: UIButton = {
       let button = UIButton()
        button.setTitle(NSLocalizedString("Get Started", comment: "Get started DIY button title"), for: [])
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
        button.setTitleColor(.darkGray, for: [])
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    fileprivate lazy var viewTapGestureRecognizer: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        view.addGestureRecognizer(tap)
        return tap
    }()
    
    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !areConstraintsSet {
            areConstraintsSet = true
            configureConstraints()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureAppearance()
        
        usernameTextField.rx
            .controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] (_) in
                self?.passwordTextField.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
        
        passwordTextField.rx
            .controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] (_) in
                self?.passwordTextField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        setupKeyboardObservers()
    }
    

    deinit {
        
    }

}

extension LoginViewController {
    
    fileprivate func configureAppearance() {
        view.backgroundColor = .white
                
        view.addSubview(backgroundImageView)
        view.addSubview(logoImageView)
        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(checkboxButton)
        view.addSubview(rememberUserLabel)
        view.addSubview(forgotPasswordButton)
        view.addSubview(loginButton)
        diyStackView.addArrangedSubview(diyLabel)
        diyButton.sizeToFit()
        diyStackView.addArrangedSubview(diyButton)
        view.addSubview(diyStackView)
    }
    
    fileprivate func configureConstraints() {
        
        NSLayoutConstraint.activate([
            
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.45),
            
            logoImageView.heightAnchor.constraint(equalToConstant: 50.0),
            logoImageView.leftAnchor.constraint(equalTo: backgroundImageView.leftAnchor),
            logoImageView.rightAnchor.constraint(equalTo: backgroundImageView.rightAnchor),
            NSLayoutConstraint(item: logoImageView, attribute: .centerY, relatedBy: .equal, toItem: backgroundImageView, attribute: .centerY, multiplier: 1.16, constant: 0.0),
            
            usernameTextField.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: 50.0),
            usernameTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20.0),
            usernameTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20.0),
            usernameTextField.heightAnchor.constraint(equalToConstant: 44.0),
            
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20.0),
            passwordTextField.leadingAnchor.constraint(equalTo: usernameTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: usernameTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalTo: usernameTextField.heightAnchor),
            
            checkboxButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 18.0),
            checkboxButton.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
            checkboxButton.heightAnchor.constraint(equalToConstant: 21.0),
            checkboxButton.widthAnchor.constraint(equalTo: checkboxButton.heightAnchor),
            
            rememberUserLabel.leftAnchor.constraint(equalTo: checkboxButton.rightAnchor, constant: 10.0),
            rememberUserLabel.centerYAnchor.constraint(equalTo: checkboxButton.centerYAnchor),
            
            forgotPasswordButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20.0),
            forgotPasswordButton.centerYAnchor.constraint(equalTo: rememberUserLabel.centerYAnchor),
            forgotPasswordButton.leftAnchor.constraint(equalTo: rememberUserLabel.rightAnchor),
            
            loginButton.topAnchor.constraint(equalTo: checkboxButton.bottomAnchor, constant: 18.0),
            loginButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20.0),
            loginButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20.0),
            NSLayoutConstraint(item: loginButton, attribute: .width, relatedBy: .equal, toItem: loginButton, attribute: .height, multiplier: 6.6, constant: 0.0),
            
            diyStackView.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 10.0),
            diyStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            diyLabel.centerYAnchor.constraint(equalTo: diyButton.centerYAnchor)
        ])
    }
    
}

private extension LoginViewController {
    // MARK: - Keyboard handlers
    
    func setupKeyboardObservers() {
        
        var bottomDiff: CGFloat { view.frame.height - diyStackView.frame.maxY }
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .observeOn(MainScheduler.instance)
            .compactMap { ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height }
            .subscribe(onNext: { [weak self] (height) in guard let self = self else { return }
                if self.view.frame.origin.y == 0 && bottomDiff < height {
                    self.view.frame.origin.y -= height - bottomDiff
                }
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (_) in guard let self = self else { return }
                self.view.frame.origin.y = 0
            })
            .disposed(by: disposeBag)
        
        viewTapGestureRecognizer.rx.event
            .bind { [weak self] _ in self?.view.endEditing(true) }
            .disposed(by: disposeBag)
            
    }
    
}

// MARK: - Custom elements

fileprivate final class BottomLineTextField: UITextField {
    
    var areConstraintsSet = false
    
    fileprivate lazy var bottomLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !areConstraintsSet {
            areConstraintsSet = true
            configureConstraints()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bottomLineView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            bottomLineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomLineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomLineView.heightAnchor.constraint(equalToConstant: 1.0),
            bottomLineView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}
