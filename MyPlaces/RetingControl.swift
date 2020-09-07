//
//  RetingControl.swift
//  MyPlaces
//
//  Created by Лера Тарасенко on 04.09.2020.
//  Copyright © 2020 Лера Тарасенко. All rights reserved.
//

import UIKit

@IBDesignable class RetingControl: UIStackView {
    
    // MARK: Properties
    
    private var ratingButtons = [UIButton]()
    var rating = 0 {
        didSet {
            updateButtonSelectionState()
        }
    }
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0){
        didSet{ //изменение в реальном времени при изменении свойств в стори
            setupButtons() 
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet{
            setupButtons()
        }
    }
    
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder )
        setupButtons()
    }
    // MARK: Button action
    
    @objc func ratingButtonTapped(button: UIButton){
        guard let index = ratingButtons.firstIndex(of: button) else { return }
        
        //Calculate the rating of the selected button
        let selectedRating = index + 1
        
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    
    // MARK: Private methods
    
    private func setupButtons(){
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        ratingButtons.removeAll()
        
        //Load button image
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let highlightStar = UIImage(named: "highlightStar", in: bundle, compatibleWith: self.traitCollection)
        
        for _ in 0..<starCount{
            //Create button
            let button = UIButton()
            
            //Set the button image
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightStar, for: .highlighted)
            button.setImage(highlightStar, for: [.highlighted, .selected] )
            
            //Add constraints
            button.translatesAutoresizingMaskIntoConstraints = false //отключение автоматически сгенерированные констрейнты
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            //Setup the button action
            button.addTarget(self, action: #selector(ratingButtonTapped), for: .touchUpInside)
            
            //Add the button to the stack
            addArrangedSubview(button)
            
            //Add the new button on the reting button array
            ratingButtons.append(button)
        }
        
        updateButtonSelectionState()
        
    }
    
    private func updateButtonSelectionState(){
        for (index, button) in ratingButtons.enumerated(){
            button.isSelected =  index < rating
        }
    }
}
