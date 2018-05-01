//
//  Multiplayer.swift
//  QuizGame
//
//  Created by Dillon K Lau on 4/25/18.
//  Copyright © 2018 Dillon K Lau. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import CoreMotion


var players =  [Player]()

class Multiplayer: UIViewController ,MCBrowserViewControllerDelegate, MCSessionDelegate {
    //Player 1 will awlays be in color
    //Players
    @IBOutlet weak var player1: UIImageView! //red
    @IBOutlet weak var player2: UIImageView! //yellow
    @IBOutlet weak var player3: UIImageView! //green
    @IBOutlet weak var player4: UIImageView! //blue
    
    @IBOutlet weak var player1Label: UILabel!
    @IBOutlet weak var player2Label: UILabel!
    @IBOutlet weak var player3Label: UILabel!
    @IBOutlet weak var player4Label: UILabel!
    
    //@IBOutlet weak var buttonA: UIButton!
    //@IBOutlet weak var buttonB: UIButton!
    //@IBOutlet weak var buttonC: UIButton!
    //@IBOutlet weak var buttonD: UIButton!
    
    
    
    //Multiplayer Session
    
    //var session: MCSession!
    //var peerID: MCPeerID!
    var browser: MCBrowserViewController!
    var assistant: MCAdvertiserAssistant!
    
    var numberOfAnswersSubmitted: Int!
    
    //Quiz
    var quizGame = [Question]()
    var numberOfTotalQuestions: Int!
    var questionsTopic: String!
    var currentQuestionNumber: Int!
    
     var imgNumber = Int()
    
    //Json parsing
    var currentUrlString = String()
    
    //players
    var playerCount = Int()
    
    @IBOutlet weak var timerNotificationLabel: UILabel!
    
    
    //-------------------------------------
    
    
    //var quizGame = [Question]()
    //var numberOfTotalQuestions: Int!
    //var questionsTopic: String!
    //var currentQuestionNumber: Int!
    
    var buttonAclicks: Int!
    var buttonBclicks: Int!
    var buttonCclicks: Int!
    var buttonDclicks: Int!
    
    var answerASelect = Bool()
    var answerBSelect = Bool()
    var answerCSelect = Bool()
    var answerDSelect = Bool()
    
    var score: Int!
    var possibleScore = Int()
    
    //var currentUrlString = String()
    
    //Game timer
    var gameTimer = Timer()
    var overallTimer = Timer()
    var actionTimer = Timer()
    
    //Initalize game timer to 20
    var seconds = 20
    var waiting3Seconds: Bool!
    var timeStamp: Int!
    var gameEnded: Bool!
    
    //Manages motion
    let motionManager = CMMotionManager()
    var time = 3
    var time2 = 0
    
    //var selected = String()
    
    @IBOutlet weak var questionNumberLabel: UILabel!
    
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var buttonA: UIButton!
    @IBOutlet weak var buttonB: UIButton!
    @IBOutlet weak var buttonC: UIButton!
    @IBOutlet weak var buttonD: UIButton!
    
    //@IBOutlet weak var timerNotificationLabel: UILabel!
    @IBOutlet weak var restartButton: UIButton!
    
    //-------------------------------------
    override func viewDidAppear(_ animated: Bool) {
        player1Label.sizeToFit()
        player2Label.sizeToFit()
        player3Label.sizeToFit()
        player4Label.sizeToFit()
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let context = CIContext(options: nil)
        //Gray Filtering
        /*let currentFilter = CIFilter(name: "CIPhotoEffectNoir")
         currentFilter!.setValue(CIImage(image: player2.image!), forKey: kCIInputImageKey)
         let output = currentFilter!.outputImage
         let cgImg = context.createCGImage(output!, from: output!.extent)
         let process = UIImage(cgImage: cgImg!)*/
        
        // player2.image = process //Grays player 2
        
        // player3.image = process //Grays player 3
        
        // player4.image = process //Grays player 4
        
        
        player1.isHidden = true
        player2.isHidden = true
        player3.isHidden = true
        player4.isHidden = true
        
        buttonA.tag = 0
        buttonB.tag = 1
        buttonC.tag = 2
        buttonD.tag = 3
        //self.peerID = MCPeerID(displayName: UIDevice.current.name)
        //self.session = MCSession(peer: peerID)
        
        self.player1.image = UIImage(named: "player1")
        self.player2.image = UIImage(named: "player2")
        self.player3.image = UIImage(named: "player3")
        self.player4.image = UIImage(named: "player4")
        
        //self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.none)
        
        self.browser = MCBrowserViewController(serviceType: "chat", session: players[0].playerSession)
        self.assistant = MCAdvertiserAssistant(serviceType: "chat", discoveryInfo: nil, session: players[0].playerSession)
        
        //imgNumber = 0
        
        //players.append(Player(peerId: self.peerID, img: imgNumber))
        
        assistant.start()
        players[0].playerSession.delegate = self
        players[0].playerSession.delegate = self
        
        updatePlayers()
        
        
        self.navigationItem.title = "MultiPlayer"
        
        restartButton.isHidden = true
        
        gameEnded = false
        
        numberOfAnswersSubmitted = 0
        
        
        score = 0
        
        //Sets game to begin with question 1
        currentQuestionNumber = 0
        waiting3Seconds = false
        
        resetClicks()
        
        updateGlobalTimer()
        
        setButtonBorders()
        clearButtonBorders()
        
        
        //Start game timer
        startTimer()
        
        getJSONData()
        
        loadQuestion()
        
        //playerCount = 1
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.motionManager.deviceMotionUpdateInterval = 1/60
        self.motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical)
        actionTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(updateMotion), userInfo: nil,repeats: true)
        seconds = 20
    }
    
    
    
    @objc func sendData()
    {
        
        //let msg = messageTF.text
        let dataToSend =  NSKeyedArchiver.archivedData(withRootObject: "")
        
        do{
            try players[0].playerSession.send(dataToSend, toPeers: players[0].playerSession.connectedPeers, with: .unreliable)
        }
        catch let err {
            //print("Error in sending data \(err)")
        }
        

    }
    
    
    @IBAction func restartButtonClicked(_ sender: Any) {
        
        let answer = "restart"
        let dataToSend =  NSKeyedArchiver.archivedData(withRootObject: answer)
        
        do{
            try players[0].playerSession.send(dataToSend, toPeers: players[0].playerSession.connectedPeers, with: .unreliable)
        }
        catch let err {
            //print("Error in sending data \(err)")
        }
        
        restartGame()
    }
    

    
    func canStart() -> Bool{
        return players.count > 1 && players.count <= 4
    }
    
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
        
        //updatePlayers()
        
    }

    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        print("Cancelled Browser")
        dismiss(animated: true, completion: nil)
        
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
        
        clearPlayerPicks()
    }
    
    
    
    @IBAction func answerButtonTouched(_ sender: UIButton) {
        
        
        
        
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
            let answer = String(sender.tag)
            player1Label.text = String(sender.tag)
            let dataToSend =  NSKeyedArchiver.archivedData(withRootObject: answer)
            
            do{
                try players[0].playerSession.send(dataToSend, toPeers: players[0].playerSession.connectedPeers, with: .unreliable)
            }
            catch let err {
                //print("Error in sending data \(err)")
            }
            
            updateAnswerLabels(answer: answer, id: players[0].playerPeerId)
            
            print("Submitted")
            
            checkAnswer(selectedButton: sender.tag)
            //Shows the answer
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(showCorrectAnswer), userInfo: nil,repeats: false)
            //Waits 3 secounds before laoding next answer
            if checkForAllSubmissions()
            {
                print("LOADING 4")
                print("Loading next question")
                Timer.scheduledTimer(timeInterval: 3.1, target: self, selector: #selector(attemptToLoadNextQuestion), userInfo: nil,repeats: false)
            }
            
        }
        
    }
    
    func checkForAllSubmissions() -> Bool
    {
        var tempCount: Int = 0
        
        if player1Label.text != ""
        {
            tempCount = tempCount + 1
        }
        
        if player2Label.text != ""
        {
            tempCount = tempCount + 1
        }
        
        if player3Label.text != ""
        {
            tempCount = tempCount + 1
        }
        
        if player4Label.text != ""
        {
            tempCount = tempCount + 1
        }
        
        if tempCount == players.count
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    
    func updateAnswerLabels(answer: String, id: MCPeerID)
    {
        
        var temp = answer
        
        switch temp {
        case "0":
            temp = "A"
        case "1":
            temp = "B"
        case "2":
            temp = "C"
        case "3":
            temp = "D"
        default:
            print("Error")
        }
        
        
        for x in players
        {
            if id == x.playerPeerId
            {
                if x.playerImg == 0
                {
                    player1Label.text = temp
                }
                else if x.playerImg == 1
                {
                    player2Label.text = temp
                }
                else if x.playerImg == 2
                {
                    player3Label.text = temp
                }
                else if x.playerImg == 3
                {
                    player4Label.text = temp
                }
            }
        }
        
    }
    
    
    
    
    func updatePlayers(){
        
        switch players.count {
        case 1:
            self.player1.isHidden = false
        case 2:
            self.player1.isHidden = false
            self.player2.isHidden = false
        case 3:
            self.player1.isHidden = false
            self.player2.isHidden = false
            self.player3.isHidden = false
        case 4:
            self.player1.isHidden = false
            self.player2.isHidden = false
            self.player3.isHidden = false
            self.player4.isHidden = false
        default:
            print("Error")
        }
        
        
    }
 

    

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            imgNumber = imgNumber + 1
            //players.append(Player(peerId: peerID, img: imgNumber))
            //sendData()
            //playerCount += 1
            
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("Im in here ...")
        
        /*
        if let receivedString = NSKeyedUnarchiver.unarchiveObject(with: data) as? String{
            //self.updateChatView(newText: receivedString, id: peerID)
            self.updatePlayers()
        }
 */
        
        DispatchQueue.main.async(execute: {
            
            if let receivedString = NSKeyedUnarchiver.unarchiveObject(with: data) as? String{
                if receivedString == "0" || receivedString == "1" || receivedString == "2" || receivedString == "3"
                {
                
                    self.updateAnswerLabels(answer: receivedString, id: peerID)
                    if self.checkForAllSubmissions()
                    {
                        print("String rcvd: \(receivedString)")
                        print("LOADING 1 from \(peerID)")
                        Timer.scheduledTimer(timeInterval: 3.1, target: self, selector: #selector(self.attemptToLoadNextQuestion), userInfo: nil,repeats: false)
                    }
                }
                else if receivedString == "restart"
                {
                    self.restartGame()
                }
                
                
            }
            
            //let playerIndex = (self.getPlayerIndex(by:peerID))!
            
            /*
            if let receivedString = NSKeyedUnarchiver.unarchiveObject(with: data) as? Int {
                //self.updatePlayers(number: receivedString, id: peerID)
                print(receivedString)
                if receivedString == self.playerCount
                {
                    self.playerCount = receivedString
                }
            }*/
            
            
            
        })
        
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
 
    
    
    
    
    
    @objc func updateTimer()
    {
        if gameEnded == false
        {
            /*
            if waiting3Seconds == true
            {
                if seconds == 20
                {
                    print("LOADING 2")
                    attemptToLoadNextQuestion()
                }
            }
 */
            
            
            //Stops the timer once it hits 0
            if seconds <= 0
            {
                //This is where we will need to call a function to end the current question
                timerNotificationLabel.text = "\(seconds)"
                //gameTimer.invalidate()
                Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(showCorrectAnswer), userInfo: nil,repeats: false)
                possibleScore += 1
                print("LOADING 3")
                Timer.scheduledTimer(timeInterval: 3.1, target: self, selector: #selector(attemptToLoadNextQuestion), userInfo: nil,repeats: false)
                
                gameTimer.invalidate()
                seconds = 20
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
    
    @objc func showCorrectAnswer()
    {
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
    
    @objc func updateGlobalTimer(){
        time = time - 1
        if time == 0 {
            //overallTimer.invalidate()
            actionTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(updateMotion), userInfo: nil,repeats: true)
        }
    }
    
    
    func startTimer()
    {
        timerNotificationLabel.text = "\(seconds)"
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(SinglePlayer.updateTimer)), userInfo: nil, repeats: true)
        
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
            clearPlayerPicks()
        }
        else
        {
            print("No more questions!")
            endGame()
        }
    }
    
    func clearPlayerPicks()
    {
        player1Label.text = ""
        player2Label.text = ""
        player3Label.text = ""
        player4Label.text = ""
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
    
    
    func loadQuestion()
    {
        gameTimer.fire()
        questionNumberLabel.text = "Question \(quizGame[currentQuestionNumber].questionNumber) of \(numberOfTotalQuestions!)"
        questionLabel.text = quizGame[currentQuestionNumber].questionQuestion
        buttonA.setTitle(quizGame[currentQuestionNumber].questionOptionA, for: .normal)
        buttonB.setTitle(quizGame[currentQuestionNumber].questionOptionB, for: .normal)
        buttonC.setTitle(quizGame[currentQuestionNumber].questionOptionC, for: .normal)
        buttonD.setTitle(quizGame[currentQuestionNumber].questionOptionD, for: .normal)
    }
    
    @objc func submitSelection(_ sender: Int) {
        
        print(sender)
        clearSelection()
        let answer = String(sender)
        player1Label.text = String(sender)
        let dataToSend =  NSKeyedArchiver.archivedData(withRootObject: answer)
        
        do{
            try players[0].playerSession.send(dataToSend, toPeers: players[0].playerSession.connectedPeers, with: .unreliable)
        }
        catch let err {
            //print("Error in sending data \(err)")
        }
        
        updateAnswerLabels(answer: answer, id: players[0].playerPeerId)
        
        
        checkAnswer(selectedButton: sender)
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(showCorrectAnswer), userInfo: nil,repeats: false)
        //Waits 3 secounds before laoding next answer
        
        if checkForAllSubmissions()
        {
            print("LOADING 6")
            print("Loading next question")
            Timer.scheduledTimer(timeInterval: 3.1, target: self, selector: #selector(attemptToLoadNextQuestion), userInfo: nil,repeats: false)
        }
        
        
        //Timer.scheduledTimer(timeInterval: 3.1, target: self, selector: #selector(attemptToLoadNextQuestion), userInfo: nil,repeats: false)
        
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
    
    func clearSelection()
    {
        answerASelect = false
        answerBSelect = false
        answerCSelect = false
        answerDSelect = false
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func updateMotion(){
        time = 3
        if let user = motionManager.deviceMotion{
            let orientation = user.attitude //Orientation of body relative to frame
            let accel = user.userAcceleration
            let gravity = user.gravity
            let rotate = user.rotationRate
            //print("in use")
            if accel.z > 2.5 || orientation.yaw > 1.0 || orientation.yaw < -1.0
            {
                if(answerASelect == true)
                {
                    submitSelection(buttonA.tag)
                    actionTimer.invalidate()
                    overallTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateGlobalTimer)), userInfo: nil, repeats: true)
                    
                    
                }
                else if(answerBSelect == true)
                {
                    submitSelection(buttonB.tag)
                    actionTimer.invalidate()
                    overallTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateGlobalTimer)), userInfo: nil, repeats: true)
                    
                    
                }
                else if(answerCSelect == true)
                {
                    submitSelection(buttonC.tag)
                    actionTimer.invalidate()
                    overallTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateGlobalTimer)), userInfo: nil, repeats: true)
                    
                    
                }
                else if(answerDSelect == true)
                {
                    submitSelection(buttonD.tag)
                    actionTimer.invalidate()
                    overallTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateGlobalTimer)), userInfo: nil, repeats: true)
                    
                    
                    
                }
                
                return
            }
            if rotate.x < -3.0
            {
                
                if(buttonC.layer.borderColor == UIColor.red.cgColor )
                {
                    clearButtonBorders()
                    clearSelection()
                    buttonA.layer.borderColor = UIColor.red.cgColor
                    answerASelect = true
                }
                else if(buttonD.layer.borderColor == UIColor.red.cgColor)
                {
                    clearButtonBorders()
                    clearSelection()
                    buttonB.layer.borderColor = UIColor.red.cgColor
                    answerBSelect = true
                }
            }
            else if rotate.x > 3.0
            {
                
                if(buttonA.layer.borderColor == UIColor.red.cgColor )
                {
                    clearButtonBorders()
                    clearSelection()
                    buttonC.layer.borderColor = UIColor.red.cgColor
                    answerCSelect = true
                }
                else if(buttonB.layer.borderColor == UIColor.red.cgColor)
                {
                    clearButtonBorders()
                    clearSelection()
                    buttonD.layer.borderColor = UIColor.red.cgColor
                    answerDSelect = true
                }
            }
            else if rotate.y < -3.0
            {
                
                if(buttonB.layer.borderColor == UIColor.red.cgColor )
                {
                    clearButtonBorders()
                    clearSelection()
                    buttonA.layer.borderColor = UIColor.red.cgColor
                    answerASelect = true
                }
                else if(buttonD.layer.borderColor == UIColor.red.cgColor)
                {
                    clearButtonBorders()
                    clearSelection()
                    buttonC.layer.borderColor = UIColor.red.cgColor
                    answerCSelect = true
                }
            }
            else if rotate.y > 3.0
            {
                
                if(buttonA.layer.borderColor == UIColor.red.cgColor )
                {
                    clearButtonBorders()
                    clearSelection()
                    buttonB.layer.borderColor = UIColor.red.cgColor
                    answerBSelect = true
                }
                else if(buttonC.layer.borderColor == UIColor.red.cgColor)
                {
                    clearButtonBorders()
                    clearSelection()
                    buttonD.layer.borderColor = UIColor.red.cgColor
                    answerDSelect = true
                }
            }
        }
    }
    //Currently doesnt work
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        //Randomize selection when shaking
        var rand = Int(arc4random_uniform(3))
        if motion == .motionShake{
            switch rand
            {
            case 0:
                clearButtonBorders()
                clearSelection()
                buttonA.layer.borderColor = UIColor.red.cgColor
                answerASelect = true
                
            case 1:
                clearButtonBorders()
                clearSelection()
                buttonB.layer.borderColor = UIColor.red.cgColor
                answerBSelect = true
            case 2:
                clearButtonBorders()
                clearSelection()
                buttonC.layer.borderColor = UIColor.red.cgColor
                answerCSelect = true
            case 3:
                clearButtonBorders()
                clearSelection()
                buttonD.layer.borderColor = UIColor.red.cgColor
                answerDSelect = true
            default:
                clearButtonBorders()
                clearSelection()
            }
            // self.checkAnswer(selectedButton: rand)
        }
    }
    
    
    func readJSONData(_ object: [String: AnyObject]) {
        
        
        
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
           
                
            }
            
            questionsTopic = topic
            numberOfTotalQuestions = numberOfQuestions
            
            
        }
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
//Possible Player Class
class Player {
    var playerPeerId: MCPeerID
    
    var playerImg: Int
    
    var playerSession: MCSession
    
    //var image: UIImage
    
    //var direction = 0 // north, south, east, west
    
    //var score = 0
    
    //var selectedAnswer = ""
    
    /*
    func randPicture() -> UIImage{
        let randNum = arc4random_uniform(4)+1
        let icon = UIImage(named: "icon\(randNum)")
        return icon!
    }
    */
    init(peerId: MCPeerID, img: Int, pSession: MCSession) {
        playerPeerId = peerId
        playerImg = img
        playerSession = pSession
        //self.image = UIImage()
        //self.image = randPicture()
    }
    /*
    init(peerId: MCPeerID, image: UIImage) {
        //self.peerId = peerId
        self.image = image
    }
    
    func awardPoints() {
        self.score += 10
    }*/
}

