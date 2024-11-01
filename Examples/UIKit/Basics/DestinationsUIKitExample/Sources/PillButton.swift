//
//  PillButton.swift
//  CompositionRootApp
//
//  Created by Brett Walker on 5/3/24.
//

import UIKit

final class PillButton: UIControl {

    enum HighlightMode: Equatable {
        /// Background darkens when tapped
        case darken
        /// Background lightens when tapped
        case lighten

        case none  // do no highlighting
    }
    
    var identifier: String = UUID().uuidString

    lazy var backgroundView: UIView = {
        return UIView()
    }()
    

    /// an optional UILabel which displays the button's title
    var titleLabel: UILabel? {
       willSet {
           if let titleLabel {
               NSLayoutConstraint.deactivate(titleLabel.constraints)
               titleLabel.removeFromSuperview()
               self.updateConstraints()
           }
       }
       didSet {
           guard let titleLabel else { return }

           self.addSubview(titleLabel)
           titleLabel.translatesAutoresizingMaskIntoConstraints = false
           addLabelConstraints()
           
           self.setNeedsDisplay()
           self.setNeedsUpdateConstraints()
       }
    }


    var titleWidthMultiplier: CGFloat = 0.74 {
       didSet {
           titleWidthConstraint?.isActive = false
           titleWidthConstraint = titleLabel!.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: titleWidthMultiplier)
           titleWidthConstraint?.isActive = true
       }
    }

    var titleWidthConstraint: NSLayoutConstraint?


    var titleHeightMultiplier: CGFloat = 0.6 {
       didSet {
           titleHeightConstraint?.isActive = false
           titleHeightConstraint = titleLabel!.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: titleHeightMultiplier)
           titleHeightConstraint?.isActive = true
       }
    }
    var titleHeightConstraint: NSLayoutConstraint?

    /// Represents the color for the image or text. Set this instead of setting the color directly on the UILabel.
    var foregroundColor: UIColor = .black {
       didSet {
           titleLabel?.textColor = foregroundColor
           savedTintColor = foregroundColor
           
           self.setNeedsDisplay()
       }
    }

    /// Determines whether the button's background should have rounded caps. Default is false.
    var hasCappedSides: Bool {
       get {
           return _hasCappedSides
       }
       set {
           _hasCappedSides = newValue
           if (_hasCappedSides) {
               hasRoundedCorners = true
               // make the corner radius half the height of view so that it will appear as a contiguous circle on either side
               backgroundView.layer.cornerRadius = self.frame.size.height / 2
           } else {
               hasRoundedCorners = false
           }
           self.setNeedsLayout()
       }
    }
    var _hasCappedSides = false

    /// Determines whether the button's corners should be rounded. Use the `cornerRadius` property to adjust how round the corners are. Default is false.
    var hasRoundedCorners: Bool {
       get {
           return _hasRoundedCorners
       }
       set {
           _hasRoundedCorners = newValue
           if (_hasRoundedCorners) {
               backgroundView.layer.cornerRadius = 6.0
               backgroundView.layer.masksToBounds = true
           } else {
               backgroundView.layer.cornerRadius = 0.0
               backgroundView.layer.masksToBounds = false
           }
           self.setNeedsLayout()
       }
    }
    var _hasRoundedCorners = false


    /// Adjusts the corner radius, for use in adjusting the roundness of corners when the `roundedCorners` property is true.
    var cornerRadius: CGFloat = 0.0 {
       didSet {
           backgroundView.layer.cornerRadius = cornerRadius
       }
    }


    /// Defines the type of tap highlight animation. Default is `.none`.
    var highlightMode: HighlightMode = .none

    /// Determines the percentage to lighten or darken the background when the `highlightMode` property is set to `darken` or `lighten`. The default value is 0.3.
    var colorHighlightPercentage: CGFloat = 0.3

    /// Holds the original tint color (of either the text or image) when animating
    private var savedTintColor: UIColor?


    /// Holds the original background color when animating
    private var savedBackgroundColor: UIColor?

    private var targetForegroundColor: UIColor?

    override var backgroundColor: UIColor? {
        get {
           return backgroundView.backgroundColor
        }
        set {
            backgroundView.backgroundColor = newValue
            savedBackgroundColor = newValue
        }

    }


    var isActive = true {
       didSet {
           guard (isActive != oldValue) else {
               return
           }
                       
           self.isEnabled = isActive
           
           updateCurrentAction()
           
       }
    }
       
    private(set) var activeAction: VoidClosure? = {}
    private(set) var inactiveAction: VoidClosure? = { print("inactive") }
    var currentAction: VoidClosure? = {}
    private(set) var currentDownAction: VoidClosure? = {}
    private(set) var activeDownAction: VoidClosure? = {}
    private(set) var inactiveDownAction: VoidClosure? = { print("inactive") }

    /// Executes the provided closure when a user taps on the button.
    func tapAction(action: VoidClosure?) {
       activeAction = action
       updateCurrentAction()
    }

    func downAction(newAction: VoidClosure?) {
       activeDownAction = newAction
       updateCurrentDownAction()
    }

    override func accessibilityActivate() -> Bool {
       currentAction?()
       return true
    }

    private func removeActions() {
       activeAction = nil
       currentAction = nil
       inactiveAction = nil
       activeDownAction = nil
       inactiveDownAction = nil
       currentDownAction = nil
    }


    // MARK: layout methods

    init() {
       super.init(frame: .zero)
       commonInit()
    }


    required init?(coder: NSCoder) {
       super.init(coder: coder)
       commonInit()
    }

    private func commonInit() {
        setupUI()

        highlightMode = .darken
        titleLabel?.numberOfLines = 1
        titleLabel?.textColor = .white
        tintColor = .white
        backgroundColor = .systemBlue
        foregroundColor = .white
        setContentHuggingPriority(.defaultHigh, for: .horizontal)
        hasCappedSides = true

        accessibilityTraits = .button

        self.addTarget(self, action: #selector(touchDownHandler(_:event:)), for: .touchDown)
        self.addTarget(self, action: #selector(touchUpInsideHandler(_:event:)), for: .touchUpInside)
        self.addTarget(self, action: #selector(touchUpOutsideHandler(_:event:)), for: [.touchUpOutside, .touchDragExit])
        self.addTarget(self, action: #selector(touchCancel(_:event:)), for: .touchCancel)
    }

    override func layoutSubviews() {
       super.layoutSubviews()
       
       if (hasCappedSides) {
           // make sides capped (half-circle)
           backgroundView.layer.cornerRadius = frame.size.height / 2
       }
       
       // update accessibility concerns
        self.accessibilityFrame = backgroundView.frame
        if let text = titleLabel?.text, !text.isEmpty {
           self.accessibilityLabel = text
       }
       
    }

    private func setupUI() {
       
       backgroundView.backgroundColor = self.backgroundColor
       self.addSubview(backgroundView)
       backgroundView.isUserInteractionEnabled = false
       backgroundView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel = UILabel()
        if let titleLabel {
            titleLabel.textAlignment = .center
            titleLabel.backgroundColor = .clear
            titleLabel.textColor = self.foregroundColor
            titleLabel.isUserInteractionEnabled = false
            self.addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.isAccessibilityElement = false
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.minimumScaleFactor = 0.5
        }
   
       // auto layout
       NSLayoutConstraint.activate([
           backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
           backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
           backgroundView.topAnchor.constraint(equalTo: self.topAnchor),
           backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
       ])
       
       addLabelConstraints()
       
       self.isAccessibilityElement = true
    }


    private func addLabelConstraints() {
        guard let titleLabel else { return }

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])

        titleWidthMultiplier = 0.74
        titleHeightMultiplier = 0.6
    }


    // MARK: button actions

    private func updateCurrentAction() {

       currentAction = (isActive) ? activeAction : inactiveAction
    }

    private func updateCurrentDownAction() {

       currentDownAction = (isActive) ? activeDownAction : inactiveDownAction
    }


    @objc func touchDownHandler(_ sender: UIButton, event: UIEvent) {
       guard isActive else { return }
       
       
       switch highlightMode {
       case .darken:

            if let unwrappedColor = backgroundView.backgroundColor {
               
               UIView.animate(withDuration: 0.15, delay: 0.0, options: [ .allowAnimatedContent, .allowUserInteraction, .curveEaseInOut], animations: { [weak self] in
                   guard let strongSelf = self else { return }
                   strongSelf.backgroundView.backgroundColor = strongSelf.darken(color: unwrappedColor, amount: strongSelf.colorHighlightPercentage)

               })
            }
               
           
       case .lighten:

            if let unwrappedColor = backgroundView.backgroundColor {
               UIView.animate(withDuration: 0.15, delay: 0.0, options: [.beginFromCurrentState, .allowAnimatedContent, .allowUserInteraction, .curveEaseInOut], animations: { [weak self] in
                   guard let strongSelf = self else { return }
                   strongSelf.backgroundView.backgroundColor = strongSelf.lighten(color: unwrappedColor, amount: strongSelf.colorHighlightPercentage)

               })
            }

       case .none:
           break
           
       }
  
       currentDownAction?()
       
       self.setNeedsDisplay()
    }

    @objc func touchUpInsideHandler(_ sender: UIButton, event: UIEvent) {
       guard isActive else { return }

       // run the closure for the current action since the user lifted finger inside the button
       currentAction?()
       
       if highlightMode != .none {
           touchUpAnimation()
       }

    }

    @objc func touchCancel(_ sender: UIButton, event: UIEvent) {
       guard isActive else { return }
       
       touchUpAnimation()

    }

    @objc func touchUpOutsideHandler(_ sender: UIButton, event: UIEvent) {
       guard isActive else { return }
           
       if highlightMode != .none {
           touchUpAnimation()
       }
    }


    // MARK: animation methods

    private func touchUpAnimation() {
       UIView.animate(withDuration: 0.28, delay: 0.0, options: [.allowAnimatedContent, .curveEaseInOut, .beginFromCurrentState], animations: { [weak self] in
           guard let strongSelf = self else { return }

            strongSelf.backgroundView.backgroundColor = strongSelf.savedBackgroundColor

       })
    }

    private func lighten(color: UIColor, amount: CGFloat) -> UIColor {
       assert(amount >= 0.0 && amount <= 1.0, "Expecting amount between 0.0 and 1.0")
       return lightenOrDarken(color: color, amount: amount)

    }

    private func darken(color: UIColor, amount: CGFloat) -> UIColor {
       assert(amount >= 0.0 && amount <= 1.0, "Expecting amount between 0.0 and 1.0")
       return lightenOrDarken(color: color, amount: -amount)

    }

    private func lightenOrDarken(color: UIColor, amount: CGFloat) -> UIColor {
       assert(amount >= -1.0 && amount <= 1.0, "Expecting amount between -1.0 and 1.0")
       var red, green, blue, alpha: CGFloat
       (red, green, blue, alpha) = (0, 0, 0, 0)
       
       if (color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)) {
           // RGB color space
           red *= (1 + amount)
           blue *= (1 + amount)
           green *= (1 + amount)
           
           red = max(min(red, 1.0), 0.0)
           blue = max(min(blue, 1.0), 0.0)
           green = max(min(green, 1.0), 0.0)
           let newColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
           return newColor
       }
       
       var white: CGFloat = 0.0
       if (color.getWhite(&white, alpha: &alpha)) {
           white *= (1 + amount)
           white = max(min(white, 1.0), 0.0)
           
           return UIColor(white: white, alpha: alpha)
       }
       
       // unhandled color space
       return color
       
    }
}
