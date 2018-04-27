//
//  SinglePlayer.swift
//  QuizGame
//
//  Created by Dillon K Lau on 4/25/18.
//  Copyright © 2018 Dillon K Lau. All rights reserved.
//

import UIKit
import CoreMotion
class SinglePlayer: UIViewController {
    
    
    var quizGame = [Question]()
    var numberOfTotalQuestions: Int!
    var questionsTopic: String!
    var currentQuestionNumber: Int!
    
    var buttonAclicks: Int!
    var buttonBclicks: Int!
    var buttonCclicks: Int!
    var buttonDclicks: Int!
    
    var score: Int!
    var possibleScore = Int()
    
    var currentUrlString = String()
    
    //Game timer
    var gameTimer = Timer()
    var overallTimer = Timer()
    
    //Initalize game timer to 20
    var seconds = 20
    var waiting3Seconds: Bool!
    var timeStamp: Int!
    var gameEnded: Bool!
    
    //Manages tilt and stuff
    var motionManager: CMMotionManager!
    
    var selected = String()
    
    @IBOutlet weak var questionNumberLabel: UILabel!
    
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var buttonA: UIButton!
    @IBOutlet weak var buttonB: UIButton!
    @IBOutlet weak var buttonC: UIButton!
    @IBOutlet weak var buttonD: UIButton!
    
    @IBOutlet weak var timerNotificationLabel: UILabel!
    @IBOutlet weak var restartButton: UIButton!
    
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationItem.title = "Single Player"
        
        restartButton.isHidden = true
        
        gameEnded = false
        
        //Assign tags to 4 answer choices
        buttonA.tag = 0
        buttonB.tag = 1
        buttonC.tag = 2
        buttonD.tag = 3
        
        
        score = 0
        
        //Sets game to begin with question 1
        currentQuestionNumber = 0
        waiting3Seconds = false
        
        resetClicks()
        
        setButtonBorders()
        clearButtonBorders()
        
        
        //Start game timer
        startTimer()
        
        getJSONData()
        
        loadQuestion()
        self.motionManager = CMMotionManager()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.motionManager.deviceMotionUpdateInterval = 1/60
        self.motionManager.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical)
        Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(updateMotion), userInfo: nil,repeats: true)
    }
    //Tried to write motion, needs testing, Can't know whats wrong yet
    @objc func updateMotion(){
        if let user = self.motionManager.deviceMotion{
            let orientation = user.attitude //Orientation of body relative to frame
            let accel = user.userAcceleration
            let gravity = user.gravity
            let rotate = user.rotationRate
            
            if accel.z > 2.5 || orientation.yaw > 1.0 || orientation.yaw < -1.0
            {
                self.submitSelection(accel)
                return
            }
            if rotate.x < -3.0
            {
                clearButtonBorders()
                if(buttonC.layer.borderColor == UIColor.red.cgColor )
                {
                    buttonA.layer.borderColor = UIColor.red.cgColor
                }
                else if(buttonD.layer.borderColor == UIColor.red.cgColor)
                {
                    buttonB.layer.borderColor = UIColor.red.cgColor
                }
            }
            else if rotate.x > 3.0
            {
                clearButtonBorders()
                if(buttonA.layer.borderColor == UIColor.red.cgColor )
                {
                    buttonC.layer.borderColor = UIColor.red.cgColor
                }
                else if(buttonB.layer.borderColor == UIColor.red.cgColor)
                {
                    buttonD.layer.borderColor = UIColor.red.cgColor
                }
            }
            else if rotate.y < -3.0
            {
                clearButtonBorders()
                if(buttonB.layer.borderColor == UIColor.red.cgColor )
                {
                    buttonA.layer.borderColor = UIColor.red.cgColor
                }
                else if(buttonD.layer.borderColor == UIColor.red.cgColor)
                {
                    buttonC.layer.borderColor = UIColor.red.cgColor
                }
            }
            else if rotate.y > 3.0
            {
                clearButtonBorders()
                if(buttonA.layer.borderColor == UIColor.red.cgColor )
                {
                    buttonB.layer.borderColor = UIColor.red.cgColor
                }
                else if(buttonC.layer.borderColor == UIColor.red.cgColor)
                {
                    buttonD.layer.borderColor = UIColor.red.cgColor
                }
            }
        }
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        //Randomize selection when shaking
        var rand = Int(arc4random_uniform(3))
        if motion == .motionShake{
            switch rand
            {
            case 0:
                clearButtonBorders()
                buttonA.layer.borderColor = UIColor.red.cgColor
            case 1:
                clearButtonBorders()
                buttonB.layer.borderColor = UIColor.red.cgColor
            case 2:
                clearButtonBorders()
                buttonC.layer.borderColor = UIColor.red.cgColor
            case 3:
                clearButtonBorders()
                buttonD.layer.borderColor = UIColor.red.cgColor
            default:
                clearButtonBorders()
            }
           // self.checkAnswer(selectedButton: rand)
        }
    }
    func setButtonBorders()
    {
        buttonA.layer.borderWidth = 5
        buttonA.layer.cornerRadius = 15
        
        buttonB.layer.borderWidth = 5
        buttonB.layer.cornerRadius = 15
        
        buttonC.layer.borderWidth = 5
        buttonC.layer.cornerRadius = 15
        
        buttonD.layer.borderWidth = 5
        buttonD.layer.cornerRadius = 15
    }
    
    func clearButtonBorders()
    {
        buttonA.layer.borderColor = UIColor.clear.cgColor
        buttonB.layer.borderColor = UIColor.clear.cgColor
        buttonC.layer.borderColor = UIColor.clear.cgColor
        buttonD.layer.borderColor = UIColor.clear.cgColor
    }
    
    
    //4 answer options are linked to this function
    //A = tag 0, B = tag 1, C = tag 3, D = tag 4
    @IBAction func answerButtonTouched(_ sender: UIButton)
    {
        clearButtonBorders()
        sender.layer.borderColor = UIColor.red.cgColor
        
        
        
        
        
        switch sender.tag {
        case 0:
            if buttonAclicks == 0
            {
                resetClicks()
            }
            buttonAclicks = buttonAclicks + 1
        case 1:
            if buttonBclicks == 0
            {
                resetClicks()
            }
            buttonBclicks = buttonBclicks + 1
        case 2:
            if buttonCclicks == 0
            {
                resetClicks()
            }
            buttonCclicks = buttonCclicks + 1
        case 3:
            if buttonDclicks == 0
            {
                resetClicks()
            }
            buttonDclicks = buttonDclicks + 1
        default:
            print("Error")
        }
        
        if buttonAclicks == 2 || buttonBclicks == 2 || buttonCclicks == 2 || buttonDclicks == 2
        {
            print("Submitted")
          
            checkAnswer(selectedButton: sender.tag)
            //Shows the answer
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(showCorrectAnswer), userInfo: nil,repeats: false)
            //Waits 3 secounds before laoding next answer
            Timer.scheduledTimer(timeInterval: 3.1, target: self, selector: #selector(attemptToLoadNextQuestion), userInfo: nil,repeats: false)
          
        }
        
    }
    
    func checkAnswer(selectedButton: Int)
    {
        let correct = quizGame[currentQuestionNumber].questionAnswer
        var number: Int = -1
        
        switch correct {
        case "A":
            number = 0
        case "B":
            number = 1
        case "C":
            number = 2
        case "D":
            number = 3
        default:
            number = -1
        }
        
        if selectedButton == number
        {
            score = score + 1
            possibleScore +=  1
            //Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(showCorrectAnswer), userInfo: nil,repeats: false)
            //showCorrectAnswer()
            print("Correct")
        }
        else
        {
            possibleScore +=  1
           // Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(showCorrectAnswer), userInfo: nil,repeats: false)
            
            print("Wrong")
        }
    }
    
    
    func resetClicks()
    {
        buttonAclicks = 0
        buttonBclicks = 0
        buttonCclicks = 0
        buttonDclicks = 0
    }
    
    
    @objc func attemptToLoadNextQuestion()
    {
        clearButtonBorders()
        if waiting3Seconds == true
        {
            enableButtons()
            
            waiting3Seconds = false
        }
        
        if currentQuestionNumber < numberOfTotalQuestions-1
        {
            currentQuestionNumber = currentQuestionNumber + 1
            gameTimer.invalidate()
            seconds = 20
            startTimer()
            loadQuestion()
            resetClicks()
        }
        else
        {
            print("No more questions!")
            endGame()
        }
    }
    
    
    @IBAction func restartButtonClicked(_ sender: Any)
    {
        print("Restart Clicked")
        restartGame()
    }
    
    func endGame()
    {
        gameEnded = true
        restartButton.isHidden = false
        print("No more questions!")
        //timerNotificationLabel.isHidden = true
        
        disableButtons()
        
        if score > 0
        {
            timerNotificationLabel.text = "YOU WON! You scored \(score!)/\(possibleScore)"
        }
        else
        {
            timerNotificationLabel.text = "YOU LOST!"
        }
        
    }
    
    
    func disableButtons()
    {
        buttonA.isEnabled = false
        buttonB.isEnabled = false
        buttonC.isEnabled = false
        buttonD.isEnabled = false
    }
    
    func enableButtons()
    {
        buttonA.isEnabled = true
        buttonB.isEnabled = true
        buttonC.isEnabled = true
        buttonD.isEnabled = true
    }
    
    
    
    @objc func updateTimer()
    {
        if gameEnded == false
        {
            
            if waiting3Seconds == true
            {
                if seconds == 20
                {
                    attemptToLoadNextQuestion()
                }
            }
            
            
            //Stops the timer once it hits 0
            if seconds <= 0
            {
                //This is where we will need to call a function to end the current question
                timerNotificationLabel.text = "\(seconds)"
                //gameTimer.invalidate()
               Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(showCorrectAnswer), userInfo: nil,repeats: false)
                possibleScore += 1
                Timer.scheduledTimer(timeInterval: 3.1, target: self, selector: #selector(attemptToLoadNextQuestion), userInfo: nil,repeats: false)
            }
            else
            {
                seconds = seconds - 1
                if seconds <= 20
                {
                    timerNotificationLabel.text = "\(seconds)"
                }
            }
        }
    }
    
    func startTimer()
    {
        timerNotificationLabel.text = "\(seconds)"
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(SinglePlayer.updateTimer)), userInfo: nil, repeats: true)
        //overallTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(SinglePlayer.updateTimer)), userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func readJSONData(_ object: [String: AnyObject]) {
        
        //print(object)
        
        if let topic = object["topic"] as? String, let numberOfQuestions = object["numberOfQuestions"] as? Int, let questions = object["questions"] as? [[String: AnyObject]] {
            
            for questions in questions {
                
                var optionAA: String!
                var optionBB: String!
                var optionCC: String!
                var optionDD: String!
                
                //print(questions["options"]!)
                
                if let options = questions["options"] as? [String: AnyObject]
                {
                    optionAA = options["A"]! as! String
                    optionBB = options["B"]! as! String
                    optionCC = options["C"]! as! String
                    optionDD = options["D"]! as! String
                }
                let number = Int(truncating: questions["number"] as! NSNumber)
                let question = questions["questionSentence"] as! String
                let correctAnswer = questions["correctOption"] as! String
                
                quizGame.append(Question(number: number, question: question, optionA: optionAA, optionB: optionBB, optionC: optionCC, optionD: optionDD, answer: correctAnswer))
                
                //print("Number: \(questions["number"]!) Sentence: \(questions["questionSentence"]!)")
                
            }
            
            questionsTopic = topic
            numberOfTotalQuestions = numberOfQuestions
            
            
        }
    }
    
    @objc func showCorrectAnswer()
    {
        seconds = 23
        //gameTimer.fire()
        
        disableButtons()
        
        clearButtonBorders()
        let correct = quizGame[currentQuestionNumber].questionAnswer
        switch correct {
        case "A":
            buttonA.layer.borderColor = UIColor.green.cgColor
        case "B":
            buttonB.layer.borderColor = UIColor.green.cgColor
        case "C":
            buttonC.layer.borderColor = UIColor.green.cgColor
        case "D":
            buttonD.layer.borderColor = UIColor.green.cgColor
        default:
            print("Error.")
        }
        
        waiting3Seconds = true
        
    }
    
    
    func getJSONData()
    {
        let semaphore = DispatchSemaphore(value: 0);
        let urlString = "http://www.people.vcu.edu/~ebulut/jsonFiles/quiz1.json"
        currentUrlString = urlString
        
        let url = URL(string: urlString)
        
        let session = URLSession.shared
        
        // create a data task
        let task = session.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            if let result = data{
                do{
                    let object = try JSONSerialization.jsonObject(with: result, options: .allowFragments)
                    
                    if let dictionary = object as? [String: AnyObject] {
                        self.readJSONData(dictionary)
                    }
                }
                catch{
                    print("Error")
                }
                semaphore.signal()
            }
            
        })
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }
    func getJSONData2()
    {
        let semaphore = DispatchSemaphore(value: 0);
        let urlString = "http://www.people.vcu.edu/~ebulut/jsonFiles/quiz2.json"
        currentUrlString = urlString
        
        let url = URL(string: urlString)
        
        let session = URLSession.shared
        
        // create a data task
        let task = session.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            if let result = data{
                do{
                    let object = try JSONSerialization.jsonObject(with: result, options: .allowFragments)
                    
                    if let dictionary = object as? [String: AnyObject] {
                        self.readJSONData(dictionary)
                    }
                }
                catch{
                    print("Error")
                }
                semaphore.signal()
            }
            
        })
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }
    
    func restartGame()
    {
        gameEnded = false
        
        restartButton.isHidden = true
        
        //Sets game to begin with question 1
        currentQuestionNumber = 0
        waiting3Seconds = false
        
        setButtonBorders()
        clearButtonBorders()
        
        score = 0
        possibleScore = 0
        //Start game timer
        seconds = 20
        
        quizGame.removeAll()
        
        if(currentUrlString == "http://www.people.vcu.edu/~ebulut/jsonFiles/quiz1.json" )
        {
            getJSONData2()
        }
        else if(currentUrlString == "http://www.people.vcu.edu/~ebulut/jsonFiles/quiz2.json")
        {
            getJSONData()
        }
        loadQuestion()
        
        timerNotificationLabel.isHidden = false
        
        enableButtons()
    }
    
    func testPrintArray()
    {
        //print(quizGame.count)
        for element in quizGame
        {
            print(element.questionNumber)
        }
    }
    
    func loadQuestion()
    {
        questionNumberLabel.text = "Question \(quizGame[currentQuestionNumber].questionNumber) of \(numberOfTotalQuestions!)"
        questionLabel.text = quizGame[currentQuestionNumber].questionQuestion
        buttonA.setTitle(quizGame[currentQuestionNumber].questionOptionA, for: .normal)
        buttonB.setTitle(quizGame[currentQuestionNumber].questionOptionB, for: .normal)
        buttonC.setTitle(quizGame[currentQuestionNumber].questionOptionC, for: .normal)
        buttonD.setTitle(quizGame[currentQuestionNumber].questionOptionD, for: .normal)
    }
    
    @IBAction func submitSelection(_ sender: Any) {
        
        checkAnswer(selectedButton: (sender as AnyObject).tag)
        attemptToLoadNextQuestion()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

class Question {
    
    var questionNumber: Int
    var questionQuestion: String
    var questionOptionA: String
    var questionOptionB: String
    var questionOptionC: String
    var questionOptionD: String
    var questionAnswer: String
    
    init(number: Int, question: String, optionA: String, optionB: String, optionC: String, optionD: String, answer: String) {
        
        questionNumber = number
        questionQuestion = question
        questionOptionA = optionA
        questionOptionB = optionB
        questionOptionC = optionC
        questionOptionD = optionD
        questionAnswer = answer
    }
}

