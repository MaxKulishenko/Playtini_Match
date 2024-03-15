//
//  ViewController.swift
//  Playtini_Match
//
//  Created by Maksym on 12.03.2024.
//

import UIKit
import AudioToolbox

final class ViewController: UIViewController {
    
    private var circleView: UIImageView?
    private var plusButton: UIButton?
    private var minusButton: UIButton?
    private var counterView: UILabel?
    private var mainContainer: UIStackView?
    private var sizingConteinerView: UIStackView?
    private var obstacleTopView: UIView?
    private var obstacleBottomView: UIView?
    private var engGameMenuButton: UIButton?
    private var isTopObstacleAnimating = false
    private var isBottomObstacleAnimating = false
    private var collisionCount: Int = 0
    private var isEndOfGame: Bool = false
    
    private var longPressGestureRecognizerForPlusButton = UILongPressGestureRecognizer()
    private var longPressGestureReconginizerForMinusButton = UILongPressGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        startRotatingCircle()
        setupLongPressGestureRecognizer()
        startMovingTopObstacle()
        startMovingBottomObstacle()
        // Do any additional setup after loading the view.
    }
}

// UI
extension ViewController {
    private func createCircleView() {
        // картинка для наглядності ефекту обертання
        circleView = UIImageView(image: .checkmark)
        
        guard let circleView = circleView else { return }
        
        circleView.contentMode = .scaleAspectFill
        circleView.frame = CGRect(x: 0,
                                  y: 0,
                                  width: 30,
                                  height: 30)
        circleView.center = view.center
        circleView.layer.cornerRadius = circleView.bounds.width / 2
        circleView.clipsToBounds = true
    }
    
    private func createSizingButtonsView() {
        createButtons()
    }
    
    private func createButtons() {
        plusButton = UIButton(type: .system)
        minusButton = UIButton(type: .system)
        sizingConteinerView = UIStackView()
        counterView = UILabel()
        
        guard let plusButton = plusButton,
              let minusButton = minusButton,
              let sizingConteinerView = sizingConteinerView,
              let counterView = counterView else {
                  return
              }
        
        plusButton.setTitle("+", for: .normal)
        plusButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        plusButton.addTarget(self, action: #selector(plusButtonLongPressed(_:)), for: .touchDown)
        plusButton.addTarget(self, action: #selector(plusButtonTouchEnded(_:)), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(plusButtonTouchEnded(_:)), for: .touchUpOutside)
        
        minusButton.setTitle("-", for: .normal)
        minusButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        minusButton.addTarget(self, action: #selector(minusButtonLongPressed(_:)), for: .touchDown)
        minusButton.addTarget(self, action: #selector(minusButtonTouchEnded(_:)), for: .touchUpInside)
        minusButton.addTarget(self, action: #selector(minusButtonTouchEnded(_:)), for: .touchUpOutside)
        
        counterView.text = "0"
        counterView.textColor = .blue
        
        sizingConteinerView.alignment = .center
        sizingConteinerView.distribution = .equalSpacing
        sizingConteinerView.spacing = 20
        sizingConteinerView.axis = .horizontal
        sizingConteinerView.addArrangedSubview(minusButton)
        sizingConteinerView.addArrangedSubview(counterView)
        sizingConteinerView.addArrangedSubview(plusButton)
    }
    
    private func setupUI() {
        createCircleView()
        createSizingButtonsView()
        createTopObstacleView()
        createBottomObstacleView()
        
        guard let circleView = circleView,
              let sizingConteinerView = sizingConteinerView else { return }
        
        view.addSubview(circleView)
        view.addSubview(sizingConteinerView)
        circleView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        circleView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        sizingConteinerView.translatesAutoresizingMaskIntoConstraints = false
        sizingConteinerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                    constant: -20).isActive = true
        sizingConteinerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                     constant: 30).isActive = true
        sizingConteinerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                      constant: -30).isActive = true
    }
    
    private func createTopObstacleView() {
        guard let circleView = circleView else { return }
        
        let obstacleHeight: CGFloat = 20
        let obstacleYPositionTop: CGFloat = circleView.frame.origin.y - obstacleHeight
        
        obstacleTopView = UIView(frame: CGRect(x: view.bounds.width,
                                               y: obstacleYPositionTop,
                                               width: view.bounds.width * 0.8,
                                               height: obstacleHeight))
        
        guard let obstacleTopView = obstacleTopView else { return }
        
        obstacleTopView.backgroundColor = .red
        obstacleTopView.layer.cornerRadius = 10
        view.addSubview(obstacleTopView)
    }
    
    private func createBottomObstacleView() {
        guard let circleView = circleView else { return }
        
        let obstacleHeight: CGFloat = 20
        let obstacleYPositionBottom: CGFloat = circleView.frame.origin.y + circleView.frame.size.height
        
        obstacleBottomView = UIView(frame: CGRect(x: view.bounds.width,
                                                  y: obstacleYPositionBottom,
                                                  width: view.bounds.width * 0.8,
                                                  height: obstacleHeight))
        
        guard let obstacleBottomView = obstacleBottomView else { return }
        
        obstacleBottomView.backgroundColor = .green
        obstacleBottomView.layer.cornerRadius = 10
        view.addSubview(obstacleBottomView)
    }
    
    private func isCircleFitInScreen() -> Bool {
        guard let circleView = circleView else { return false }
        
        let circleFrameInSuperview = circleView.convert(circleView.bounds, to: view)
        
        return view.bounds.contains(circleFrameInSuperview)
    }
    
    private func startRotatingCircle() {
        guard let circleView = circleView else { return }
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: Double.pi * 2.0)
        rotationAnimation.duration = 2.0
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = Float.greatestFiniteMagnitude
        circleView.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    private func showCollisionAlert() {
        pauseAnimations()
        
        let alert = UIAlertController(title: "Collision Alert",
                                      message: "The circle collided with the obstacles 5 times! \n You need to restart screen.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func addEndGameMenu() {
        engGameMenuButton = UIButton()
        
        guard let engGameMenuButton = engGameMenuButton else { return }
        
        engGameMenuButton.setTitle("Start New Game", for: .normal)
        engGameMenuButton.setTitleColor(.blue, for: .normal)
        
        engGameMenuButton.titleLabel?.font = UIFont(name: "Helvetica", size: 16)
        
        engGameMenuButton.addTarget(self, action: #selector(startNewGame(_:)), for: .touchUpInside)
        view.addSubview(engGameMenuButton)
        
        engGameMenuButton.translatesAutoresizingMaskIntoConstraints = false
        
        engGameMenuButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        engGameMenuButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func removeEndGameMenu() {
        engGameMenuButton?.removeFromSuperview()
    }
    
    @objc private func startNewGame(_ sender: Any) {
        isEndOfGame = false
        
        removeEndGameMenu()
        setupUI()
        startRotatingCircle()
        setupLongPressGestureRecognizer()
        startMovingTopObstacle()
        startMovingBottomObstacle()
    }
    
    private func pauseAnimations() {
        // видаляємо все з екрану як закінчилася гра
        view.subviews.forEach { $0.removeFromSuperview() }
        
        isEndOfGame = true
    }
}

extension ViewController {
    @objc func increaseCircleSize() {
        guard isCircleFitInScreen() else { return }
        
        UIView.animate(withDuration: 0.1, animations: {
            guard let circleView = self.circleView else { return }
            
            circleView.transform = circleView.transform.scaledBy(x: 1.1, y: 1.1)
        }) { _ in
            //  рекурсивно викликаємо для постійної анімації
            self.plusButtonLongPressed(self)
        }
    }
    
    @objc func decreaseCircleSize() {
        guard let circleView = circleView,
              circleView.frame.width >= 15,
              circleView.frame.height >= 15 else { return }
        
        UIView.animate(withDuration: 0.1, animations: {
            guard let circleView = self.circleView else { return }
            
            circleView.transform = circleView.transform.scaledBy(x: 0.9, y: 0.9)
        }) { _ in
            // рекурсивно викликаємо себе
            self.minusButtonLongPressed(self)
        }
    }
    
    private func stopChangingCircleSize() {
        longPressGestureRecognizerForPlusButton.isEnabled = false
        longPressGestureRecognizerForPlusButton.isEnabled = true
        longPressGestureReconginizerForMinusButton.isEnabled = false
        longPressGestureReconginizerForMinusButton.isEnabled = true
    }
    
    private func startMovingTopObstacle() {
        guard !isTopObstacleAnimating, !isEndOfGame else { return }
        
        isTopObstacleAnimating = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1...5)) { [weak self, weak obstacleTopView] in
            guard let self = self, !self.isEndOfGame else { return }
            
            guard let obstacleTopView = obstacleTopView else { return }
            
            self.animateObstacle(obstacleTopView,
                                 from: self.view.bounds.width,
                                 to: -obstacleTopView.frame.size.width) { [weak self, weak obstacleTopView] in
                obstacleTopView?.removeFromSuperview()
                self?.isTopObstacleAnimating = false
                self?.createTopObstacleView()
                self?.startMovingTopObstacle()
                self?.checkCollision()
            }
        }
    }
    
    private func startMovingBottomObstacle() {
        guard !isBottomObstacleAnimating, !isEndOfGame else { return }
        
        isBottomObstacleAnimating = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1...5)) { [weak self, weak obstacleBottomView] in
            guard let self = self, !self.isEndOfGame else { return }
            
            guard let obstacleBottomView = obstacleBottomView else { return }
            
            self.animateObstacle(obstacleBottomView,
                                 from: self.view.bounds.width,
                                 to: -obstacleBottomView.frame.size.width) { [weak self, weak obstacleBottomView] in
                obstacleBottomView?.removeFromSuperview()
                self?.isBottomObstacleAnimating = false
                self?.createBottomObstacleView()
                self?.startMovingBottomObstacle()
                self?.checkCollision()
            }
        }
    }
    
    private func animateObstacle(_ obstacle: UIView,
                                 from startX: CGFloat,
                                 to endX: CGFloat,
                                 completion: @escaping () -> Void) {
        UIView.animate(withDuration: 3,
                       delay: 0,
                       options: .curveLinear,
                       animations: {
            obstacle.frame.origin.x = endX
        }) { [weak obstacle] (_) in
            completion()
            
            obstacle?.removeFromSuperview()
        }
    }
    
    private func checkCollision() {
        guard let obstacleTopView = obstacleTopView,
              let obstacleBottomView = obstacleBottomView,
              let circleView = circleView else { return }
        
        if obstacleTopView.frame.intersects(circleView.frame) ||
        obstacleBottomView.frame.intersects(circleView.frame) ||
        obstacleTopView.bounds.intersects(circleView.bounds) ||
        obstacleBottomView.bounds.intersects(circleView.bounds) {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            collisionCount += 1
            counterView?.text = "\(collisionCount)"
            
            if collisionCount == 5 {
                showCollisionAlert()
                
                collisionCount = 0
                counterView?.text = "\(collisionCount)"
                isTopObstacleAnimating = false
                isBottomObstacleAnimating = false
                
                obstacleTopView.removeFromSuperview()
                obstacleBottomView.removeFromSuperview()
                
                addEndGameMenu()
            }
        }
    }
}

extension ViewController {
    private func setupLongPressGestureRecognizer() {
        longPressGestureRecognizerForPlusButton = UILongPressGestureRecognizer(target: self,
                                                                               action: #selector(plusButtonLongPressed(_:)))
        longPressGestureRecognizerForPlusButton.minimumPressDuration = 0.1
        plusButton?.addGestureRecognizer(longPressGestureRecognizerForPlusButton)
        
        longPressGestureReconginizerForMinusButton = UILongPressGestureRecognizer(target: self,
                                                                                  action: #selector(minusButtonLongPressed(_:)))
        longPressGestureReconginizerForMinusButton.minimumPressDuration = 0.1
        minusButton?.addGestureRecognizer(longPressGestureReconginizerForMinusButton)
    }
    
    @objc private func plusButtonLongPressed(_ sender: Any) {
        if longPressGestureRecognizerForPlusButton.state == .began || longPressGestureRecognizerForPlusButton.state == .changed {
            increaseCircleSize()
        }
    }
    
    @objc private func plusButtonTouchEnded(_ sender: Any) {
        stopChangingCircleSize()
    }
    
    @objc private func minusButtonLongPressed(_ sender: Any) {
        if longPressGestureReconginizerForMinusButton.state == .began || longPressGestureReconginizerForMinusButton.state == .changed {
            decreaseCircleSize()
        }
    }
    
    @objc private func minusButtonTouchEnded(_ sender: Any) {
        stopChangingCircleSize()
    }
}

