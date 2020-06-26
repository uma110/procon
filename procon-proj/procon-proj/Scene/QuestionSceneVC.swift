//
//  QuestionSceneVC.swift
//  procon-proj
//
//  Created by 伊東佑真 on 2020/06/19.
//  Copyright © 2020 伊東佑真. All rights reserved.
//

import UIKit

class QuestionSceneVC: UIViewController,UIScrollViewDelegate{
    var receivedQAData:[QAData]?
    /*
    var questions:[String] = ["What are the two examples that the writer mentions as Japanese being not flexible?",
                              "What did elderly people do when foreigners crossed the street with the red light?",
                              "What does the writer suggest we do when your job at a restaurant doesn’t allow you to take orders from customers?",
                              "What surprised the writer about the leftover food when working at a restaurant in Japan?",
                              "Which of the following is the closest to the meaning of `bizarre`?\na) amazing b) strange  c) surprising  d) interesting]"]
    var answers:[String] = ["People don’t cross the street with the red light even when there are no cars.",
                            "They stared at the foreigners.",
                            "They should help taking orders when customers are waiting.",
                            "The fact that some restaurants throw away the clean leftover food.",
                            "b)"]
    var answerRanges:[NSRange] = [NSRange(location: 10, length: 10),
                                 NSRange(location: 30, length: 10),
                                 NSRange(location: 50, length: 10),
                                 NSRange(location: 70, length: 10),
                                 NSRange(location: 90, length: 10)]
    */
    var mainContext:String = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.When people talk about Japan, they would always think about how innovative and technological this country gets! Or how "
    @IBOutlet weak var contextField: UITextView!
    private var mutableAttrContext:NSMutableAttributedString?
    @IBOutlet weak var scrollView: UIScrollView!
    
    var questionTitle:UILabel = UILabel()
    var answerTitle:UILabel = UILabel()
    
    override func viewDidLoad() {
        print("view did load super")
        super.viewDidLoad()
        print("view did load current")
        
        contextField.text = mainContext
        mutableAttrContext = NSMutableAttributedString(string: mainContext)
        mutableAttrContext?.addAttributes([.font:contextField.font ?? 20], range: NSRange(location: 0, length: contextField.text.count))
        initializeScrollView(scrollView: scrollView)
    }
    
    func popupContextOn(range:NSRange){
        guard let mutableAttrContext = mutableAttrContext else {
            return
        }
        let strAttributes:[NSAttributedString.Key:Any] = [
            .backgroundColor:UIColor.yellow,
        ]
        mutableAttrContext.addAttributes(strAttributes, range: range)
        contextField.attributedText = mutableAttrContext
    }
    
    func popupContextOff(range:NSRange){
        guard let mutableAttrContext = mutableAttrContext else {
            return
        }
        mutableAttrContext.removeAttribute(.backgroundColor, range: range)
        contextField.attributedText = mutableAttrContext
    }
    
    func scrollViewReset(){
        for content in scrollView.subviews{
            content.removeFromSuperview()
        }
        initializeScrollView(scrollView: scrollView)
    }
    
    @objc func switchAnswerLabel(_ sender:CustomLabelSwitchButton){
        sender.switchLabel()
        guard let answer = sender.targetLabel else {return}
        if answer.isHidden{
            popupContextOff(range: sender.myAnswerRange!)
        }else{
            popupContextOn(range: sender.myAnswerRange!)
        }
    }
    
    func initializeScrollView(scrollView:UIScrollView){
        let initialOffsetX = CGFloat(5)
        let initialOffsetY = CGFloat(5)
        let contentSize = CGFloat(100)
        let contentOffset = CGFloat(20)
        let labelWidth = CGFloat(200)
        let labelHeight = CGFloat(35)
        
        let screenSize = UIScreen.main.bounds.size
        
        var dataCount:Int = 0
        if receivedQAData != nil{
            dataCount = receivedQAData!.count
        }
        let scrollContentHeight = (contentSize + contentOffset) * CGFloat(dataCount * 2) + labelHeight * 2 + initialOffsetY * 3
        scrollView.contentSize = CGSize(width: screenSize.width, height: scrollContentHeight)
        
        questionTitle.frame = CGRect(x: initialOffsetX, y: initialOffsetY, width: labelWidth, height: labelHeight)
        questionTitle.text = "Question"
        questionTitle.backgroundColor = .systemYellow
        questionTitle.textAlignment = .center
        questionTitle.textColor = .black
        questionTitle.font = UIFont.systemFont(ofSize: 25)
        
        let answerTitleHeight = initialOffsetY * 2 + labelHeight + (contentSize + contentOffset) * CGFloat(dataCount)
        answerTitle.frame = CGRect(x: initialOffsetX, y: answerTitleHeight, width: labelWidth, height: labelHeight)
        answerTitle.text = "Answer"
        answerTitle.backgroundColor = .systemYellow
        answerTitle.textAlignment = .center
        answerTitle.textColor = .black
        answerTitle.font = UIFont.systemFont(ofSize: 25)
        
        scrollView.addSubview(questionTitle)
        scrollView.addSubview(answerTitle)
        
        guard let qaData = receivedQAData else{return}
        
        for (index,data) in qaData.enumerated(){
            let component = QuestionScrollComponents(id: index + 1, question: data.question, answer: data.answer,answerRange:data.range)
            component.add2ScrollView(scrollView: scrollView, questionLabelUnderHeight: questionTitle.frame.maxY, answerLabelUnderHeight: answerTitle.frame.maxY)
            
            component.answerDisplaySwitch.addTarget(self, action: #selector(switchAnswerLabel(_:)), for: .touchUpInside)
            
            component.answerLabel.isHidden = true
        }
    }
    
    @IBAction func backScene(_ sender: Any) {
        let titleScene = self.storyboard?.instantiateViewController(identifier: "TabController") as! TabController
        titleScene.modalPresentationStyle = .fullScreen
        self.present(titleScene,animated: true,completion: nil)
    }
}

struct QuestionScrollComponents{
    let id:Int
    let questionLabel:UILabel
    let answerLabel:UILabel
    let questionNumImageView:UIImageView
    let answerDisplaySwitch:CustomLabelSwitchButton
    
    init(id:Int,question:String,answer:String,answerRange:NSRange) {
        self.id = id
        
        self.questionLabel = UILabel()
        self.questionLabel.text = question
        self.questionLabel.numberOfLines = 0
        
        self.answerLabel = UILabel()
        self.answerLabel.text = answer
        self.answerLabel.numberOfLines = 0
        
        let questionNumImage = UIImage(systemName: String(id) + ".square")
        self.questionNumImageView = UIImageView(image:questionNumImage)
        
        self.answerDisplaySwitch = CustomLabelSwitchButton(targetLabel: answerLabel,myAnswerRange: answerRange)
        self.answerDisplaySwitch.setBackgroundImage(UIImage(systemName: String(id)+".square.fill"), for: .normal)
    }
    
    func add2ScrollView(scrollView:UIScrollView,questionLabelUnderHeight:CGFloat,answerLabelUnderHeight:CGFloat){
        let contentSize = CGFloat(100)
        let contentOffset = CGFloat(20)
        
        let textWidth = CGFloat(600)
        
        let initialOffsetX = CGFloat(5)
        let initialOffsetY = CGFloat(5)
        let questionContentHeight = questionLabelUnderHeight + initialOffsetY + (contentSize + contentOffset) * CGFloat(id - 1)
        questionNumImageView.frame = CGRect(x: initialOffsetX, y: questionContentHeight, width: contentSize, height: contentSize)
        questionLabel.frame = CGRect(x: initialOffsetX*2 + contentSize, y: questionContentHeight, width: textWidth, height: contentSize)
        
        let answerContentHeight = answerLabelUnderHeight + initialOffsetY + (contentSize + contentOffset) * CGFloat(id - 1)
        answerDisplaySwitch.frame = CGRect(x: initialOffsetX, y: answerContentHeight, width: contentSize, height: contentSize)
        answerLabel.frame = CGRect(x: initialOffsetX*2 + contentSize, y: answerContentHeight, width: textWidth, height: contentSize)
        
        scrollView.addSubview(questionNumImageView)
        scrollView.addSubview(questionLabel)
        scrollView.addSubview(answerDisplaySwitch)
        scrollView.addSubview(answerLabel)
    }
}

class CustomLabelSwitchButton:UIButton{
    var targetLabel:UILabel?
    var myAnswerRange:NSRange?
    
    init(targetLabel:UILabel,myAnswerRange:NSRange) {
        super.init(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
        self.targetLabel = targetLabel
        self.myAnswerRange = myAnswerRange
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    func switchLabel(){
        guard let label = targetLabel else{
            return
        }
        label.isHidden = !label.isHidden
    }
}
