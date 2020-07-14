//
//  FacilityDetails.swift
//  EastEndYouthServices
//
//  Created by Southampton Dev on 8/25/16.
//  Copyright © 2016 TOS. All rights reserved.
//

import UIKit



class FacilityDetails: UIView {
    
    var title: String
    var desc: String
    
//    override init(frame:CGRect) {
//        super.init(frame:frame)
//    }
    
    init(frame: CGRect, facility: Facility){
        
        self.title = facility.F_Name!
        self.desc = facility.Desc!

        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        
//        let testButton = UIButton(type: UIButtonType.System)
//        testButton.backgroundColor = UIColor.orangeColor()
//        testButton .setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
//        testButton.setTitle(self.ti, forState: UIControlState.Normal)
//        testButton.frame = CGRectMake(0,100, 100, 50)
        
        let labelDynamicLabel = UILabel()
        labelDynamicLabel.backgroundColor = UIColor.orange
        labelDynamicLabel.text = "A Dynamic Label"
        labelDynamicLabel.translatesAutoresizingMaskIntoConstraints = false
        labelDynamicLabel.frame = CGRect(x: 100,y: 100, width: 100, height: 200)

        addSubview(labelDynamicLabel)
        /*

        let leadingSpaceConstraint: NSLayoutConstraint = NSLayoutConstraint(item: labelDynamicLabel, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: labelDynamicLabel, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0);
        
        let topSpaceConstraint: NSLayoutConstraint = NSLayoutConstraint(item: labelDynamicLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: labelDynamicLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 10);
        

        addConstraint(leadingSpaceConstraint)
        addConstraint(topSpaceConstraint)
 */

    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



class CustomCallout: UIViewController {
    //MARK: Properties
    
    let colorDictionary = [
        "Red":UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),
        "Green":UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0),
        "Blue":UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0),
        ]
    
    //MARK: Instance methods
    func colorButton(withColor color:UIColor, title:String) -> UIButton{
        let newButton = UIButton(type: .system)
        newButton.backgroundColor = color
        newButton.setTitle(title, for: UIControlState())
        newButton.setTitleColor(UIColor.white, for: UIControlState())
        return newButton
    }
    
    
    func displayKeyboard(){
        //generate an array
        

        
        var buttonArray = [UIButton]()
        for (myKey,myValue) in colorDictionary{
            buttonArray += [colorButton(withColor: myValue, title: myKey)]
        }
        /* //Iteration one - singel stack view
         let stackView = UIStackView(arrangedSubviews: buttonArray)
         stackView.axis = .Horizontal
         stackView.distribution = .FillEqually
         stackView.alignment = .Fill
         stackView.spacing = 5
         stackView.translatesAutoresizingMaskIntoConstraints = false
         view.addSubview(stackView)
         */
        
        //Iteration two - nested stack views
        //set up the stack view
        let subStackView = UIStackView(arrangedSubviews: buttonArray)
        subStackView.axis = .horizontal
        subStackView.distribution = .fillEqually
        subStackView.alignment = .fill
        subStackView.spacing = 5
        //set up a label
        let label = UILabel()
        label.text = "Color Chooser"
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.black
        label.textAlignment = .center
        
        let blackButton = colorButton(withColor: UIColor.black, title: "Black")
        
        let stackView = UIStackView(arrangedSubviews: [label,subStackView,blackButton])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        //autolayout the stack view - pin 30 up 20 left 20 right 30 down
        let viewsDictionary = ["stackView":stackView]
        let stackView_H = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[stackView]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        let stackView_V = NSLayoutConstraint.constraints(withVisualFormat: "V:|-30-[stackView]-30-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: viewsDictionary)
        view.addConstraints(stackView_H)
        view.addConstraints(stackView_V)
    }
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        displayKeyboard()
        
    }
}


 
