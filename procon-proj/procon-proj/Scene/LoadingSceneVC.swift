//
//  LoadingSceneVC.swift
//  procon-proj
//
//  Created by 伊東佑真 on 2020/06/23.
//  Copyright © 2020 伊東佑真. All rights reserved.
//

import UIKit
import NaturalLanguage

class LoadingSceneVC: UIViewController {
    
    var activityIndicatorView = UIActivityIndicatorView()
    
    var receivedTextFromPreScene:String = ""
    
    @IBOutlet weak var message: UITextView!
    
    private var questions:[String] = []
    private var qaData:[QAData] = []
    private static let MAXNUM_EXTRACT_TOPDATA:Int = 10
//    private static let MINNUM_FILTER_SCORE:Double = 10.0
    private static let MINNUM_FILTER_SCORE:Double = -100
      
    
    let bert = BERT()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingComponentInit()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        makeQuestions()
    }
    
    func loadingComponentInit(){
        message.text = "質問・回答作成中です。\n解析が終わるまで少々お待ち下さい。"
        
        var position = view.center
        position = CGPoint(x: position.x, y: position.y - 100)
        activityIndicatorView.center = position
        activityIndicatorView.style = .large
        activityIndicatorView.color = .black
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        activityIndicatorView.hidesWhenStopped = true
    }
    
    private func loadingCompleted(){
        activityIndicatorView.stopAnimating()
        message.text = "解析が完了しました。\n次に進むには、OKを押して下さい。"
        let alert = UIAlertController(title: "", message: "質問・回答画面に映ります。よろしいですか？", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {action in print("OK")
            self.moveQuestionScene()
        })
        
        alert.addAction(okAction)
        self.present(alert,animated: true,completion: nil)
    }
    
    private func moveQuestionScene(){
        let questionScene = self.storyboard?.instantiateViewController(identifier: "QuestionSceneVC") as! QuestionSceneVC
        
        //データを次のシーンに受け渡す処理
        questionScene.mainContext = receivedTextFromPreScene
        questionScene.receivedQAData = qaData
        
        questionScene.modalPresentationStyle = .fullScreen
        self.present(questionScene,animated: true,completion: nil)
    }
    
    private func makeQuestions(){
        let text = "Once upon a time, there lived an old couple in a small village.One day the old wife was washing her clothes in the river when a huge peach came tumbling down the stream.The old woman brought the peach home and cut it up to share with her husband.To their great surprise, a healthy baby boy came right out of the peach! The old couple said, “Let’s name him Momotaro (Peach-boy) as he was born from a peach.” They brought him up with love and care."
        receivedTextFromPreScene = text
        /*
         let questions:[String] = ["Who lived in a small village?","Who was washing clothes?","bobobobo sisisi fs?"]
         */
        
        /*
        questions = ["Where did baby boy have ?","What was the peach - boymoanto name?","The name of what is the waist used to have ?","The peach - boy can be what in the book ?","The iPods has name the first solar couple for what ?","Where did baby boys have that were ?"]
        */
        
        questions = ["Who lived in a small village?","Who was washing clothes?","bobobobo sisisi fs?","What city was the first waist iPod located to NYC ?","The peach - boy can be what in the book ?","The couple did what other film have his first album with ?","In what year was the name of a couple how much ?","The peachs has the name of what other film ?","In how many iPods were Chopin and his couple used ?","How many people were the first momo - taro ?","What does peach that Beyonce and Beyoncé were ?","How many people wrote the monkey for how much money ?","What does demon have the name of the book ?","coupleant what is a solar energy that the couple have ?","What year was the first momo - taro located ?","In what year dumplings his first album in NYC ?","What type of Beyonce was a monkey in 2014 ?","In what is the name used to waist the book ?","What are companions to the firstant couplehausmo ?","What was the first solar energy used to peach ?","The film is the baby for Chopin in what other name ?","The most how much pheasant did the film have ?","When was the first iPod version of dumplings used ?","The iPod game does have how many dumplings from ?","What city is a of the pheasants in ?","The first to have the name of what baby was Chopin ?","In NYC , Who dumplings his first album from ?","The name what does waist to Mr . Twilight Princess ?","How much is peach - boy located in the city ?","Beyonce wrote that Who did the book waist with ?","The book was what other pheasant for the film ?","In what dumplings of the book were used for ?","What did his name have that Chopin was pheasant ?","The first peach - boy did what name Chopin have ?","can have the first solar millet in what year ?","What other kind of companions are the Gelun ?","The name of his first album , what is peach ?","What was used in name of the film for his name ?","What island was the first solar energy iPodant couple located ?","How many people were on the first island located in NYC ?","antantantantmo , what waist was used ?","How much is an island to be in the city located ?","coupleantantmo is the name of couple , what ?","The first year did NYC have a millet of what ?","The name of what baby was the first album used for ?","・The name of what is the waist used to have ?","What two people were the first peach - boy ?","The iPods has name the first solar couple for what ?","iPods are what city ' s pheasantant ?","The peach island of what year was the film used ?","The first pheasant solar energy was in what year ?","hat city and island are iPods to be not used ?","What is the monkey name of the film ?","Where did baby boy have ?","What was the peach - boymoanto name ?","In what other name was the book for a couple used ?","What island is a peach - boy in the book ?","In what peach island are a couple in the island ?","The name of the film is what millet coupleant ?","Chopin was demon of couple and island , how much ?","couple and island were a couple used for in what island ?","In what is the name of Chopin and his baby couple ?","What other island was the first momo - taro ?","In what year , the coupleant was pheasant ?","In the island , what people were a couple and couple ?"]
 
        analyzeAnswer()
    }
    
    private func analyzeAnswer(){
        let dispatchGroup = DispatchGroup()
        
        for question in questions{
            dispatchGroup.enter()
            DispatchQueue.main.async {
                print("one process started")
                
                self.makeQAData(question: question, text: self.receivedTextFromPreScene)
                
                print("one process finished")
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main){
            
            print("completed")
            for data in self.qaData{
                print(data.question)
                print(data.answer)
                print(data.score)
                print(data.range)
            }
            
            print("==========Sorted complete===========")
            let filterdData = self.qaData.filter{$0.score > LoadingSceneVC.MINNUM_FILTER_SCORE}
            let sortedData = filterdData.enumerated().sorted{(arg0,arg1) in arg0.element.score > arg1.element.score}
            var maxIndex:Int = LoadingSceneVC.MAXNUM_EXTRACT_TOPDATA
            if LoadingSceneVC.MAXNUM_EXTRACT_TOPDATA > sortedData.count{
                maxIndex = sortedData.count
            }
            
            let topData = sortedData[0..<maxIndex]
            var newData:[QAData] = []
            topData.forEach{
                let data = $0.element
                newData.append(data)
                print(data.question)
                print(data.answer)
                print(data.score)
                print(data.range)
            }
            self.qaData = newData
            
            self.loadingCompleted()
        }
    }
    
    private func makeQAData(question:String,text:String){
        let ansIndices = self.bert.findAnswer(for: question, in: text)
        let ans = String(ansIndices.answer)
        
        let location = ansIndices.answer.startIndex.utf16Offset(in: text)
        let length = ansIndices.answer.endIndex.utf16Offset(in: text) - location
        let range = NSRange(location: location, length: length)
        
        let score = ansIndices.score ?? -Double.infinity
        let data = QAData(question: question, answer: ans, range: range, score: score)
        self.qaData.append(data)
    }
    
    @IBAction func debugFunc1(_ sender: Any) {
        let text = "Use the Natural Language framework to perform tasks like language and script identification, tokenization, lemmatization, parts-of-speech tagging, and named entity recognition. I am a ironman. So I think you are my fun. Sorry boy."
        
        //        let text = receivedTextFromPreScene
        
        let senTokenizer = NLTokenizer(unit: .sentence)
        let wordTokenizer = NLTokenizer(unit: .word)
        
        senTokenizer.string = text
        wordTokenizer.string = text
        
        var sentences:[String] = []
        print("sentence")
        senTokenizer.enumerateTokens(in: text.startIndex..<text.endIndex){
            tokenRange,_ in
            sentences.append(String(text[tokenRange]))
            return true
        }
        
        for sentence in sentences{
            print(sentence)
        }
        
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        let options:NLTagger.Options = [.omitPunctuation, .omitWhitespace]
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options){
            tag,tokenRange in
            if let tag = tag{
                print("\(text[tokenRange]) : \(tag.rawValue)")
            }
            return true
        }
        /*
         print("word")
         wordTokenizer.enumerateTokens(in: text.startIndex..<text.endIndex){
         tokenRange,_ in
         print(text[tokenRange])
         return true
         }
         */
    }
    
    @IBAction func debugFunc2(_ sender: Any) {
//        makeQuestions()
        loadingCompleted()
    }
}

struct QAData{
    let question:String
    let answer:String
    let range:NSRange
    let score:Double
    init(question:String,answer:String,range:NSRange,score:Double) {
        self.question = question
        self.answer = answer
        self.range = range
        self.score = score
    }
}
