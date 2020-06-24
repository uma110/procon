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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingComponentInit()
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
    
    func loadingCompleteMessage(){
        activityIndicatorView.stopAnimating()
        message.text = "解析が完了しました。\n次に進むには、OKを押して下さい。"
        let alert = UIAlertController(title: "", message: "質問・回答画面に映ります。よろしいですか？", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {action in print("OK")
            self.moveQuestionScene()
        })
        
        alert.addAction(okAction)
        self.present(alert,animated: true,completion: nil)
    }
    
    func moveQuestionScene(){
        let questionScene = self.storyboard?.instantiateViewController(identifier: "QuestionSceneVC") as! QuestionSceneVC
        
        //データを次のシーンに受け渡す処理
        questionScene.mainContext = receivedTextFromPreScene
        
        questionScene.modalPresentationStyle = .fullScreen
        self.present(questionScene,animated: true,completion: nil)
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
        let text = receivedTextFromPreScene
        print("================")
        print(text)
        /*
        let pattern = NSRegularExpression.escapedPattern(for: "\n")
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        print(regex.numberOfMatches(in: text, range: NSRange(0..<text.utf16.count)))
        */
        var result = text.replacingOccurrences(of: "(\n){1}", with: " ", options: NSString.CompareOptions.regularExpression, range:text.range(of: text))
        print("========RESULT1=========")
        print(result)
        result = result.replacingOccurrences(of: "[\\s]+",with: " ", options: NSString.CompareOptions.regularExpression, range:result.range(of: result))
        print("========RESULT2========")
        print(result)
    }
    
    @IBAction func debugFunc3(_ sender: Any) {
        loadingCompleteMessage()
    }
}
