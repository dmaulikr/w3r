//
//  ViewController.swift
//  Wither
//
//  Created by Amy Joscelyn on 6/29/16.
//  Copyright © 2016 Amy Joscelyn. All rights reserved.
//

import UIKit

let winning_emoji = "👑"
let loss_emoji = "❌"
let war_emoji = "⚔"

let first_column = "1"
let second_column = "2"
let third_column = "3"

let player_string = "Player"
let ai_string = "AI"

class ViewController: UIViewController
{
    @IBOutlet weak var playerDeckView: CardView!
    @IBOutlet weak var playerDiscardView: CardView!
    @IBOutlet weak var aiDeckView: CardView!
    @IBOutlet weak var aiDiscardView: CardView!
    
    @IBOutlet weak var playerWar1View: CardView!
    @IBOutlet weak var playerWar2View: CardView!
    @IBOutlet weak var playerWar3View: CardView!
    @IBOutlet weak var aiWar1View: CardView!
    @IBOutlet weak var aiWar2View: CardView!
    @IBOutlet weak var aiWar3View: CardView!
    
    @IBOutlet weak var playerWar1AView: CardView!
    @IBOutlet weak var playerWar2AView: CardView!
    @IBOutlet weak var playerWar3AView: CardView!
    @IBOutlet weak var aiWar1AView: CardView!
    @IBOutlet weak var aiWar2AView: CardView!
    @IBOutlet weak var aiWar3AView: CardView!
    
    @IBOutlet weak var playGameButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var swapCards1And2Button: UIButton!
    @IBOutlet weak var swapCards2And3Button: UIButton!
    @IBOutlet weak var swapCards1And3Button: UIButton!
    
    @IBOutlet weak var war1ResultLabel: UILabel!
    @IBOutlet weak var war2ResultLabel: UILabel!
    @IBOutlet weak var war3ResultLabel: UILabel!
    
    @IBOutlet weak var playerCardsRemainingInDeckLabel: UILabel!
    @IBOutlet weak var aiCardsRemainingInDeckLabel: UILabel!
    
    @IBOutlet weak var resolveWarGuideLabel: UILabel!
    @IBOutlet weak var skipWarButton: UIButton!
    
    var lastLocation: CGPoint = CGPointMake(0, 0)
    var deckOriginalCenter: CGPoint = CGPointMake(0, 0)
    
    let game = Game.init()
    
    var savePlayerCards: [Card] = []
    var saveAICards: [Card] = []
    var discardPlayerCards: [Card] = []
    var discardAICards: [Card] = []
    
    var columnOfWar: String = ""
    var isWar1 = false
    var isWar2 = false
    var isWar3 = false
    
    var warSkippedByPlayer = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.createGameSpace()
        self.resetGame()
        self.game.startGame()
    }
    
    func createGameSpace()
    {
        self.view.backgroundColor = UIColor.blackColor()
        
        self.customizeButton(self.playGameButton)
        self.customizeButton(self.settingsButton)
        self.customizeButton(self.swapCards1And2Button)
        self.customizeButton(self.swapCards2And3Button)
        self.customizeButton(self.swapCards1And3Button)
        self.customizeButton(self.skipWarButton)
        
        self.swapCards1And2Button.hidden = true
        self.swapCards2And3Button.hidden = true
        self.swapCards1And3Button.hidden = true
        
        self.skipWarButton.hidden = true
        self.resolveWarGuideLabel.hidden = true
        
        self.war1ResultLabel.hidden = true
        self.war2ResultLabel.hidden = true
        self.war3ResultLabel.hidden = true
        
        self.deckOriginalCenter = self.playerDeckView.center
        
        self.panGestures()
        
        self.playGameButton.setTitle("", forState: UIControlState.Normal)
        self.playGameButton.enabled = false
    }
    
    func customizeButton(button: UIButton)
    {
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.whiteColor().CGColor
        button.clipsToBounds = true
    }
    
    func panGestures()
    {
        let deckPanGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handleDeckPanGesture))
        self.playerDeckView.addGestureRecognizer(deckPanGesture)
        self.playerDeckView.userInteractionEnabled = true
    }
    
    func handleDeckPanGesture(panGesture: UIPanGestureRecognizer)
    {
        if panGesture.state == UIGestureRecognizerState.Began
        {
            self.playerDeckView?.bringSubviewToFront(self.view)
            self.lastLocation = self.playerDeckView.center
        }
        if panGesture.state == UIGestureRecognizerState.Changed
        {
            let translation = panGesture.translationInView(self.view!)
            self.playerDeckView.center = CGPointMake(lastLocation.x + translation.x, lastLocation.y + translation.y)
            
            if self.playerDeckView.center.y <= 450.0 && self.playerWar1View.hidden == true
            {
                self.newRound()
            }
        }
        if panGesture.state == UIGestureRecognizerState.Ended
        {
            self.playerDeckView.center = self.deckOriginalCenter
        }
    }
    
    func resetGame()
    {
        self.aiDeckView.faceUp = false
        self.playerDeckView.faceUp = false
        
        self.clearAllWarCardViewsAndTempHands()
        
        self.aiDiscardView.card = nil;
        self.playerDiscardView.card = nil;
    }
    
    func clearAllWarCardViewsAndTempHands()
    {
        self.playerWar1View.card = nil
        self.playerWar2View.card = nil
        self.playerWar3View.card = nil
        self.aiWar1View.card = nil
        self.aiWar2View.card = nil
        self.aiWar3View.card = nil
        
        self.playerWar1AView.card = nil
        self.playerWar2AView.card = nil
        self.playerWar3AView.card = nil
        self.aiWar1AView.card = nil
        self.aiWar2AView.card = nil
        self.aiWar3AView.card = nil
        
        self.discardPlayerCards.removeAll()
        self.discardAICards.removeAll()
        self.savePlayerCards.removeAll()
        self.saveAICards.removeAll()
        
        self.game.warIsDone()
    }
    
    func newRound()
    {
        self.game.drawHands()
        self.cardsRemaining()
        
        if self.game.player.hand.count == 3 && self.game.aiPlayer.hand.count == 3
        {
            self.aiWar1View.card = self.game.aiPlayer.hand[0]
            self.aiWar2View.card = self.game.aiPlayer.hand[1]
            self.aiWar3View.card = self.game.aiPlayer.hand[2]
            self.playerWar1View.card = self.game.player.hand[0]
            self.playerWar2View.card = self.game.player.hand[1]
            self.playerWar3View.card = self.game.player.hand[2]
            
            self.game.aiPlayer.hand.removeAll()
            self.game.player.hand.removeAll()
            
            self.swapCards1And2Button.hidden = false
            self.swapCards2And3Button.hidden = false
            self.swapCards1And3Button.hidden = false
            
            self.playGameButton.setTitle("READY!", forState: UIControlState.Normal)
            self.playGameButton.enabled = true
            
            self.playerDeckView.userInteractionEnabled = false
            
            //***************************************
            //for testing purposes, this code can be commented out
            //            self.aiWar1View.faceUp = false
            //            self.aiWar2View.faceUp = false
            //            self.aiWar3View.faceUp = false
            //***************************************
        }
    }
    
    func cardsRemaining()
    {
        self.playerCardsRemainingInDeckLabel.text = "Cards: \(self.game.player.deck.cards.count + self.game.player.hand.count)"
        self.aiCardsRemainingInDeckLabel.text = "Cards: \(self.game.aiPlayer.deck.cards.count + self.game.aiPlayer.hand.count)"
    }
    
    @IBAction func playGameButtonTapped(button: UIButton)
    {
        if button.titleLabel?.text == "READY!"
        {
            self.aiWar1View.faceUp = true
            self.aiWar2View.faceUp = true
            self.aiWar3View.faceUp = true
            
            self.judgeRound()
        }
        else if button.titleLabel?.text == "END ROUND"
        {
            self.endRound()
        }
        else if button.titleLabel?.text == "WAR!"
        {
            self.hideWarLabel(self.columnOfWar)
            self.playWarInColumn(self.columnOfWar)
        }
    }
    
    func hideWarLabel(column: String)
    {
        switch column
        {
        case first_column:
            self.war1ResultLabel.hidden = true
        case second_column:
            self.war2ResultLabel.hidden = true
        default:
            self.war3ResultLabel.hidden = true
        }
    }
    
    func judgeRound()
    {
        let playerCard1 = self.cardToJudge(player_string, column: first_column)
        let playerCard2 = self.cardToJudge(player_string, column: second_column)
        let playerCard3 = self.cardToJudge(player_string, column: third_column)
        
        let aiCard1 = self.cardToJudge(ai_string, column: first_column)
        let aiCard2 = self.cardToJudge(ai_string, column: second_column)
        let aiCard3 = self.cardToJudge(ai_string, column: third_column)
        
        let winnerOf1 = self.game.twoCardFaceOff(playerCard1, aiPlayerCard: aiCard1)
        let winnerOf2 = self.game.twoCardFaceOff(playerCard2, aiPlayerCard: aiCard2)
        let winnerOf3 = self.game.twoCardFaceOff(playerCard3, aiPlayerCard: aiCard3)
        
        print("\(winnerOf1) won 1, \(winnerOf2) won 2, \(winnerOf3) won 3")
        
        self.awardRoundWithResult(winnerOf1, cardResult2: winnerOf2, cardResult3: winnerOf3)
    }
    
    func cardToJudge(player: String, column: String) -> Card
    {
        var card: Card?
        
        if player == player_string
        {
            if column == first_column
            {
                if let playerCard1A = self.playerWar1AView.card
                {
                    card = playerCard1A
                }
                else
                {
                    card = self.playerWar1View.card!
                }
            }
            else if column == second_column
            {
                if let playerCard2A = self.playerWar2AView.card
                {
                    card = playerCard2A
                }
                else
                {
                    card = self.playerWar2View.card!
                }
            }
            else if column == third_column
            {
                if let playerCard3A = self.playerWar3AView.card
                {
                    card = playerCard3A
                }
                else
                {
                    card = self.playerWar3View.card!
                }
            }
        }
        if player == ai_string
        {
            if column == first_column
            {
                if let aiCard1A = self.aiWar1AView.card
                {
                    card = aiCard1A
                }
                else
                {
                    card = self.aiWar1View.card!
                }
            }
            else if column == second_column
            {
                if let aiCard2A = self.aiWar2AView.card
                {
                    card = aiCard2A
                }
                else
                {
                    card = self.aiWar2View.card!
                }
            }
            else if column == third_column
            {
                if let aiCard3A = self.aiWar3AView.card
                {
                    card = aiCard3A
                }
                else
                {
                    card = self.aiWar3View.card!
                }
            }
        }
        return card!
    }
    
    func awardRoundWithResult(cardResult1: String, cardResult2: String, cardResult3: String)
    {
        let results = [cardResult1, cardResult2, cardResult3]
        let resultLabels = [self.war1ResultLabel, self.war2ResultLabel, self.war3ResultLabel]
        
        for i in 0..<results.count
        {
            let result = results[i]
            
            switch result
            {
            case player_string:
                resultLabels[i].text = winning_emoji
            case "AI":
                resultLabels[i].text = loss_emoji
            default:
                resultLabels[i].text = war_emoji
            }
        }
        
        self.war1ResultLabel.hidden = false
        self.war2ResultLabel.hidden = false
        self.war3ResultLabel.hidden = false
        
        self.playGameButton.setTitle("", forState: UIControlState.Normal)
        self.playGameButton.enabled = false
        
        self.roundSpoils()
    }
    
    func roundSpoils()
    {
        self.swapCards1And2Button.hidden = true
        self.swapCards2And3Button.hidden = true
        self.swapCards1And3Button.hidden = true
        
        let resultsArray = [self.war1ResultLabel, self.war2ResultLabel, self.war3ResultLabel]
        
        var winCount = 0
        var lossCount = 0
        var warCount = 0
        
        for result in resultsArray
        {
            if result.text == winning_emoji
            {
                winCount += 1
            }
            else if result.text == loss_emoji
            {
                lossCount += 1
            }
            else if result.text == war_emoji
            {
                warCount += 1
            }
        }
        
        print("crowns: \(winCount), X's: \(lossCount), swords: \(warCount)")
        
        var column = ""
        
        if winCount == 3
        {
            print("case #1 (player wins all!)")
            self.saveAllCards(player_string)
            self.discardAllCards(ai_string)
            
            self.prepButtonForRoundEnd()
        }
        else if lossCount == 3
        {
            print("case #2 (AI wins all)")
            self.discardAllCards(player_string)
            self.saveAllCards(ai_string)
            
            self.prepButtonForRoundEnd()
        }
        else if winCount == 2
        {
            print("case #3 (player wins two)")
            if lossCount == 1
            {
                column = self.columnOfResult(loss_emoji)
                
                if column == first_column
                {
                    self.discardSingleCard(player_string, column: first_column)
                    self.saveSingleCard(player_string, column: second_column)
                    self.saveSingleCard(player_string, column: third_column)
                }
                else if column == second_column
                {
                    self.saveSingleCard(player_string, column: first_column)
                    self.discardSingleCard(player_string, column: second_column)
                    self.saveSingleCard(player_string, column: third_column)
                }
                else if column == third_column
                {
                    self.saveSingleCard(player_string, column: first_column)
                    self.saveSingleCard(player_string, column: second_column)
                    self.discardSingleCard(player_string, column: third_column)
                }
                
                self.discardAllCards(ai_string)
                
                self.prepButtonForRoundEnd()
            }
            else //war
            {
                column = self.columnOfResult(war_emoji)
                let warValue = self.cardValueOfWar(column)
                print("AI has lost, but gets to pass on the war.")
                let willResolveWar = self.game.aiPlayer.shouldResolveWar(warValue)
                
                if willResolveWar
                {
                    self.columnOfWar = column
                    self.prepForWar(column)
                }
                else
                {
                    print("AI PASSES ON WAR.")
                    
                    self.saveAllCards(player_string)
                    
                    if column == first_column
                    {
                        self.saveSingleCard(ai_string, column: first_column)
                        self.discardSingleCard(ai_string, column: second_column)
                        self.discardSingleCard(ai_string, column: third_column)
                    }
                    else if column == second_column
                    {
                        self.discardSingleCard(ai_string, column: first_column)
                        self.saveSingleCard(ai_string, column: second_column)
                        self.discardSingleCard(ai_string, column: third_column)
                    }
                    else if column == third_column
                    {
                        self.discardSingleCard(ai_string, column: first_column)
                        self.discardSingleCard(ai_string, column: second_column)
                        self.saveSingleCard(ai_string, column: third_column)
                    }
                    
                    self.prepButtonForRoundEnd()
                }
            }
        }
        else if lossCount == 2
        {
            print("case #4 (player loses 2)")
            if winCount == 1
            {
                column = self.columnOfResult(winning_emoji)
                
                if column == first_column
                {
                    self.discardSingleCard(ai_string, column: first_column)
                    self.saveSingleCard(ai_string, column: second_column)
                    self.saveSingleCard(ai_string, column: third_column)
                }
                else if column == second_column
                {
                    self.saveSingleCard(ai_string, column: first_column)
                    self.discardSingleCard(ai_string, column: second_column)
                    self.saveSingleCard(ai_string, column: third_column)
                }
                else if column == third_column
                {
                    self.saveSingleCard(ai_string, column: first_column)
                    self.saveSingleCard(ai_string, column: second_column)
                    self.discardSingleCard(ai_string, column: third_column)
                }
                
                self.discardAllCards(player_string)
                
                self.prepButtonForRoundEnd()
            }
            else if warSkippedByPlayer
            {
                print("war has been skipped!--in method")
                
                self.saveAllCards(ai_string)
                
                column = self.columnOfResult(war_emoji)
                
                if column == first_column
                {
                    self.saveSingleCard(player_string, column: first_column)
                    self.discardSingleCard(player_string, column: second_column)
                    self.discardSingleCard(player_string, column: third_column)
                }
                else if column == second_column
                {
                    self.discardSingleCard(player_string, column: first_column)
                    self.saveSingleCard(player_string, column: second_column)
                    self.discardSingleCard(player_string, column: third_column)
                }
                else if column == third_column
                {
                    self.discardSingleCard(player_string, column: first_column)
                    self.discardSingleCard(player_string, column: second_column)
                    self.saveSingleCard(player_string, column: third_column)
                }
                
                self.endRound()
            }
            else //war
            {
                print("playing the war now...")
                column = self.columnOfResult(war_emoji)
                
                self.skipWarButton.hidden = false
                self.resolveWarGuideLabel.hidden = false
                
                self.prepForWar(column)
            }
        }
        else //there is at least one war that needs to be resolved in order to determine a clear winner
        {
            print("case #5 (no clear winner... yet)")
            if warCount == 1
            {
                column = self.columnOfResult(war_emoji)
                self.prepForWar(column)
            }
            else if warCount == 2
            {
                if winCount == 1
                {
                    column = self.columnOfResult(winning_emoji)
                }
                else
                {
                    column = self.columnOfResult(loss_emoji)
                }
                
                var firstWar = 0
                var secondWar = 0
                
                switch column
                {
                case first_column:
                    //wars are 2 and 3
                    firstWar = self.cardValueOfWar(second_column)
                    secondWar = self.cardValueOfWar(third_column)
                    
                    if firstWar > secondWar //>=?
                    {
                        self.prepForWar(second_column)
                    }
                    else
                    {
                        self.prepForWar(third_column)
                    }
                case second_column:
                    //wars are 1 and 3
                    firstWar = self.cardValueOfWar(first_column)
                    secondWar = self.cardValueOfWar(third_column)
                    
                    if firstWar > secondWar //>=?
                    {
                        self.prepForWar(first_column)
                    }
                    else
                    {
                        self.prepForWar(third_column)
                    }
                default:
                    //wars are 1 and 2
                    firstWar = self.cardValueOfWar(first_column)
                    secondWar = self.cardValueOfWar(second_column)
                    
                    if firstWar > secondWar //>=?
                    {
                        self.prepForWar(second_column)
                    }
                    else
                    {
                        self.prepForWar(third_column)
                    }
                }
            }
        }
    }
    
    func columnOfResult(result: String) -> String
    {
        var column = ""
        
        if self.war1ResultLabel.text == result
        {
            column = first_column
        }
        if self.war2ResultLabel.text == result
        {
            column = second_column
        }
        if self.war3ResultLabel.text == result
        {
            column = third_column
        }
        
        return column
    }
    
    func saveAllCards(player: String)
    {
        var cardsToSave: [Card] = []
        
        if player == player_string
        {
            cardsToSave = [ self.playerWar1View.card!, self.playerWar2View.card!, self.playerWar3View.card! ]
            cardsToSave.appendContentsOf(self.game.player.warCards)
            
            self.savePlayerCards.appendContentsOf(cardsToSave)
        }
        else if player == ai_string
        {
            cardsToSave = [ self.aiWar1View.card!, self.aiWar2View.card!, self.aiWar3View.card! ]
            cardsToSave.appendContentsOf(self.game.aiPlayer.warCards)
            
            self.saveAICards.appendContentsOf(cardsToSave)
        }
    }
    
    func discardAllCards(player: String)
    {
        var cardsToDiscard: [Card] = []
        
        if player == player_string
        {
            cardsToDiscard = [ self.playerWar1View.card!, self.playerWar2View.card!, self.playerWar3View.card! ]
            
            if let warCard1A = self.playerWar1AView.card
            {
                cardsToDiscard.append(warCard1A)
            }
            if let warCard2A = self.playerWar2AView.card
            {
                cardsToDiscard.append(warCard2A)
            }
            if let warCard3A = self.playerWar3AView.card
            {
                cardsToDiscard.append(warCard3A)
            }
            
            self.discardPlayerCards.appendContentsOf(cardsToDiscard)
        }
        else if player == ai_string
        {
            cardsToDiscard = [ self.aiWar1View.card!, self.aiWar2View.card!, self.aiWar3View.card! ]
            
            if let warCard1A = self.aiWar1AView.card
            {
                cardsToDiscard.append(warCard1A)
            }
            if let warCard2A = self.aiWar2AView.card
            {
                cardsToDiscard.append(warCard2A)
            }
            if let warCard3A = self.aiWar3AView.card
            {
                cardsToDiscard.append(warCard3A)
            }
            
            self.discardAICards.appendContentsOf(cardsToDiscard)
        }
    }
    
    func saveSingleCard(player: String, column: String)
    {
        if player == player_string
        {
            if column == first_column
            {
                self.savePlayerCards.append(self.playerWar1View.card!)
                
                if let warCard1A = self.playerWar1AView.card
                {
                    self.savePlayerCards.append(warCard1A)
                }
            }
            else if column == second_column
            {
                self.savePlayerCards.append(self.playerWar2View.card!)
                
                if let warCard2A = self.playerWar2AView.card
                {
                    self.savePlayerCards.append(warCard2A)
                }
            }
            else if column == third_column
            {
                self.savePlayerCards.append(self.playerWar3View.card!)
                
                if let warCard3A = self.playerWar3AView.card
                {
                    self.savePlayerCards.append(warCard3A)
                }
            }
        }
        else if player == ai_string
        {
            if column == first_column
            {
                self.saveAICards.append(self.aiWar1View.card!)
                
                if let warCard1A = self.aiWar1AView.card
                {
                    self.saveAICards.append(warCard1A)
                }
            }
            else if column == second_column
            {
                self.saveAICards.append(self.aiWar2View.card!)
                
                if let warCard2A = self.aiWar2AView.card
                {
                    self.saveAICards.append(warCard2A)
                }
            }
            else if column == third_column
            {
                self.saveAICards.append(self.aiWar3View.card!)
                
                if let warCard3A = self.aiWar3AView.card
                {
                    self.saveAICards.append(warCard3A)
                }
            }
        }
    }
    
    func discardSingleCard(player: String, column: String)
    {
        if player == player_string
        {
            if column == first_column
            {
                self.discardPlayerCards.append(self.playerWar1View.card!)
                
                if let warCard1A = self.playerWar1AView.card
                {
                    self.discardPlayerCards.append(warCard1A)
                }
            }
            else if column == second_column
            {
                self.discardPlayerCards.append(self.playerWar2View.card!)
                
                if let warCard2A = self.playerWar2AView.card
                {
                    self.discardPlayerCards.append(warCard2A)
                }
            }
            else if column == third_column
            {
                self.discardPlayerCards.append(self.playerWar3View.card!)
                
                if let warCard3A = self.playerWar3AView.card
                {
                    self.discardPlayerCards.append(warCard3A)
                }
            }
        }
        else if player == ai_string
        {
            if column == first_column
            {
                self.discardAICards.append(self.aiWar1View.card!)
                
                if let warCard1A = self.aiWar1AView.card
                {
                    self.discardAICards.append(warCard1A)
                }
            }
            else if column == second_column
            {
                self.discardAICards.append(self.aiWar2View.card!)
                
                if let warCard2A = self.aiWar2AView.card
                {
                    self.discardAICards.append(warCard2A)
                }
            }
            else if column == third_column
            {
                self.discardAICards.append(self.aiWar3View.card!)
                
                if let warCard3A = self.aiWar3AView.card
                {
                    self.discardAICards.append(warCard3A)
                }
            }
        }
    }
    
    func cardValueOfWar(column: String) -> Int
    {
        switch column
        {
        case first_column:
            return (self.aiWar1View.card?.cardValue)!
        case second_column:
            return (self.aiWar2View.card?.cardValue)!
        default:
            return (self.aiWar3View.card?.cardValue)!
        }
    }
    
    func prepForWar(column: String)
    {
        self.columnOfWar = column
        
        switch column
        {
        case first_column:
            self.isWar1 = true
        //            self.war1ResultLabel.backgroundColor = UIColor.greenColor() //constant?
        case second_column:
            self.isWar2 = true
        //            self.war2ResultLabel.backgroundColor = UIColor.greenColor()
        default:
            self.isWar3 = true
            //            self.war3ResultLabel.backgroundColor = UIColor.greenColor()
        }
        
        self.playGameButton.setTitle("WAR!", forState: UIControlState.Normal)
        self.playGameButton.enabled = true
    }
    
    func prepButtonForRoundEnd()
    {
        self.playGameButton.setTitle("END ROUND", forState: UIControlState.Normal)
        self.playGameButton.enabled = true
    }
    
    func endRound()
    {
        self.war1ResultLabel.text = ""
        self.war2ResultLabel.text = ""
        self.war3ResultLabel.text = ""
        
        self.warSkippedByPlayer = false
        self.skipWarButton.hidden = true
        self.resolveWarGuideLabel.hidden = true
        
        print("Player saves \(self.savePlayerCards.count) cards and discards \(self.discardPlayerCards.count) cards, AI saves \(self.saveAICards.count) cards and discards \(self.discardAICards.count) cards.")
        
        self.game.player.discard.appendContentsOf(self.discardPlayerCards)
        self.game.aiPlayer.discard.appendContentsOf(self.discardAICards)
        self.game.player.deck.cards.appendContentsOf(self.savePlayerCards)
        self.game.aiPlayer.deck.cards.appendContentsOf(self.saveAICards)
        
        self.clearAllWarCardViewsAndTempHands()
        self.cardsRemaining()
        
        if let lastAICardDiscarded = self.game.aiPlayer.discard.last
        {
            self.aiDiscardView.card = lastAICardDiscarded
        }
        
        if let lastPlayerCardDiscarded = self.game.player.discard.last
        {
            self.playerDiscardView.card = lastPlayerCardDiscarded
        }
        
        self.playGameButton.setTitle("", forState: UIControlState.Normal)
        self.playGameButton.enabled = false
        
        self.playerDeckView.userInteractionEnabled = true
    }
    
    @IBAction func settingsButtonTapped(sender: AnyObject)
    {
        
    }
    
    @IBAction func swapCards1And2ButtonTapped(sender: AnyObject)
    {
        let card1 = self.playerWar1View.card
        self.playerWar1View.card = self.playerWar2View.card
        self.playerWar2View.card = card1
    }
    
    @IBAction func swapCards2And3ButtonTapped(sender: AnyObject)
    {
        let card2 = self.playerWar2View.card
        self.playerWar2View.card = self.playerWar3View.card
        self.playerWar3View.card = card2
    }
    
    @IBAction func swapCards1And3ButtonTapped(sender: AnyObject)
    {
        let card1 = self.playerWar1View.card
        self.playerWar1View.card = self.playerWar3View.card
        self.playerWar3View.card = card1
    }
    
    @IBAction func skipWarButtonTapped(sender: AnyObject)
    {
        print("WE'RE SKIPPING THIS WAR...")
        self.warSkippedByPlayer = true
        self.judgeRound()
    }
    
    func playWarInColumn(column: String)
    {
        self.game.war()
        
        if self.game.player.warCards.count == 1
        {
            if column == first_column
            {
                self.playerWar1AView.card = self.game.player.warCards.first
                self.aiWar1AView.card = self.game.aiPlayer.warCards.first
                
                self.war1ResultLabel.backgroundColor = UIColor.clearColor()
            }
            else if column == second_column
            {
                self.playerWar2AView.card = self.game.player.warCards.first
                self.aiWar2AView.card = self.game.aiPlayer.warCards.first
                
                self.war2ResultLabel.backgroundColor = UIColor.clearColor()
            }
            else if column == third_column
            {
                self.playerWar3AView.card = self.game.player.warCards.first
                self.aiWar3AView.card = self.game.aiPlayer.warCards.first
                
                self.war3ResultLabel.backgroundColor = UIColor.clearColor()
            }
        }
        if self.game.player.warCards.count == 2
        {
            //  
        }
        self.playGameButton.setTitle("READY!", forState: UIControlState.Normal)
    }
    
    func resolveWar(playerCard: Card, aiPlayerCard: Card) -> String
    {
        return self.game.twoCardFaceOff(playerCard, aiPlayerCard: aiPlayerCard)
    }
    
}
