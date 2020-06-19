//
//  QuestionSceneVC.swift
//  procon-proj
//
//  Created by 伊東佑真 on 2020/06/19.
//  Copyright © 2020 伊東佑真. All rights reserved.
//

import UIKit

class QuestionSceneVC: UIViewController,UIScrollViewDelegate{
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
    
    @IBOutlet weak var scrollView: UIScrollView!
    var questionTitle:UILabel = UILabel()
    var answerTitle:UILabel = UILabel()
    
    override func viewDidLoad() {
        print("view did load super")
        super.viewDidLoad()
        print("view did load current")
        
        initializeScrollView(scrollView: scrollView)
    }
    
    func scrollViewReset(){
        for content in scrollView.subviews{
            content.removeFromSuperview()
        }
        initializeScrollView(scrollView: scrollView)
    }
    
    @objc func switchAnswerLabel(_ sender:CustomLabelSwitchButton){
        sender.switchLabel()
    }
    
    func initializeScrollView(scrollView:UIScrollView){
        let initialOffsetX = CGFloat(5)
        let initialOffsetY = CGFloat(5)
        let contentSize = CGFloat(100)
        let contentOffset = CGFloat(20)
        let labelWidth = CGFloat(200)
        let labelHeight = CGFloat(35)
        
        let screenSize = UIScreen.main.bounds.size
        
        let scrollContentHeight = (contentSize + contentOffset) * CGFloat(questions.count + answers.count) + labelHeight * 2 + initialOffsetY * 3
        scrollView.contentSize = CGSize(width: screenSize.width, height: scrollContentHeight)
        
        questionTitle.frame = CGRect(x: initialOffsetX, y: initialOffsetY, width: labelWidth, height: labelHeight)
        questionTitle.text = "Question"
        questionTitle.backgroundColor = .systemYellow
        questionTitle.textAlignment = .center
        questionTitle.textColor = .black
        questionTitle.font = UIFont.systemFont(ofSize: 25)
        
        let answerTitleHeight = initialOffsetY * 2 + labelHeight + (contentSize + contentOffset) * CGFloat(questions.count)
        answerTitle.frame = CGRect(x: initialOffsetX, y: answerTitleHeight, width: labelWidth, height: labelHeight)
        answerTitle.text = "Answer"
        answerTitle.backgroundColor = .systemYellow
        answerTitle.textAlignment = .center
        answerTitle.textColor = .black
        answerTitle.font = UIFont.systemFont(ofSize: 25)
        
        scrollView.addSubview(questionTitle)
        scrollView.addSubview(answerTitle)
        
        for index in 0..<questions.count{
            let component = QuestionScrollComponents(id: index + 1, question: questions[index], answer: answers[index])
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
    
    init(id:Int,question:String,answer:String) {
        self.id = id
        
        self.questionLabel = UILabel()
        self.questionLabel.text = question
        self.questionLabel.numberOfLines = 0
        
        self.answerLabel = UILabel()
        self.answerLabel.text = answer
        self.answerLabel.numberOfLines = 0
        
        let questionNumImage = UIImage(systemName: String(id) + ".square")
        self.questionNumImageView = UIImageView(image:questionNumImage)
        
        self.answerDisplaySwitch = CustomLabelSwitchButton(targetLabel: answerLabel)
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
    init(targetLabel:UILabel) {
        super.init(frame:CGRect(x: 0, y: 0, width: 0, height: 0))
        self.targetLabel = targetLabel
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
