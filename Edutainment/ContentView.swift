//
//  ContentView.swift
//  Edutainment
//
//  Created by Nilesh Rathod on 03/05/23.
//

import SwiftUI


struct LabelStyle : ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.blue)
            .clipShape(Capsule())
            .foregroundColor(.white)
            .font(.body)
            .padding(.bottom, 10)
            .padding(.top, 10)
    }
}


extension View {
    func applyLableStyle() -> some View{
        self.modifier(LabelStyle())
    }
    
    func answerButtonStyle() -> some View {
        self.modifier(CreateAnswerButton())
    }
}

struct CreateAnswerButton: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .frame(width: 150, height: 50, alignment: .center)
            .background(.blue)
            .clipShape(Capsule())
    }
}


struct ContentView: View {
    
    
    @State private var startGame = false
    @State private var tableOfMultiplication = 11
    @State private var currentQuestion = 0
    @State private var totalQuestion = "5"
    @State private var questionList = [QuestionData]()
    @State private var answerList = [QuestionData]()
    @State private var totalScore = 0
    @State private var remainingQuestions = 0
    @State private var selectedNumber = 0
    @State private var isCorrect = false
    @State private var isWrong = false
    @State private var isShowAlert = false
    @State private var alertTitle = ""
    @State private var buttonAlertTitle = ""
    @State private var isWinGame = false
    
    let questionVarients = ["5","10","20"]
    
    var body: some View {
        NavigationView {
            VStack {
                if startGame {
                    VStack {
                        Text("\(questionList[currentQuestion].question)")
                            .font(.largeTitle)
                        
                        ForEach (0 ..< 4, id: \.self) { number in
                            
                            HStack {
                                Button(action: {
                                    withAnimation {
                                        checkAnswer(number)
                                    }
                                }) {
                                    
                                    Text("\(self.answerList[number].answer)")
                                        .foregroundColor(Color.black)
                                        .font(.title)
                                }
                                .answerButtonStyle()
                                .rotation3DEffect(.degrees(self.isCorrect && self.selectedNumber == number ? 360 : 0), axis: (x: 0, y: 1, z: 0))
                                .rotation3DEffect(.degrees(self.isWrong && self.selectedNumber == number ? 180 : 0), axis: (x: 0, y: 0, z: 0.5))
                            }
                        }
                    }
                } else {
                    VStack {
                        Section {
                            Text("Please select a multiplication table for practice")
                                .applyLableStyle()
                            Picker("", selection: $tableOfMultiplication){
                                ForEach(11..<20, id: \.self){
                                    Text("\($0)")
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(20)
                        }
                        
                        Section {
                            Text("How many question you want to be asked?")
                                .applyLableStyle()
                            Picker("", selection: $totalQuestion){
                                ForEach(questionVarients, id: \.self){
                                    Text("\($0)")
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(20)
                        }
                        
                        Spacer()
                        
                        Button("Start Game"){
                            startNewGame()
                        }
                        .padding()
                        .background(.red)
                        .clipShape(Capsule())
                        .foregroundColor(.white)
                        
                        Spacer(minLength: 30)
                        
                    }
                }
            }
            .alert(alertTitle, isPresented: $isShowAlert){
                Button(buttonAlertTitle){
                    if self.isWinGame {
                        
                        self.isWinGame = false
                        self.isCorrect = false
                        self.startGame  = false
                    } else if self.isCorrect  {
                        self.isCorrect = false
                        self.newQuestion()
                    } else {
                        self.isWrong = false
                    }
                }
            } message: {
                Text(" You score is: \(totalScore)")
            }
            
            .navigationTitle("Edutainment Game")
        }
        
    }
    
    func checkAnswer(_ number: Int) {
        self.selectedNumber = number
        if answerList[number].answer == questionList[currentQuestion].answer {
            self.isCorrect = true
            self.remainingQuestions -= 1
            DispatchQueue.main.asyncAfter(deadline: .now() ) {
                if self.remainingQuestions == 0 {
                    self.alertTitle = "You win"
                    self.buttonAlertTitle = "Start new game"
                    self.totalScore += 1
                    self.isWinGame = true
                    self.isShowAlert = true
                } else {
                    self.totalScore += 1
                    self.alertTitle = "Correct!!!"
                    self.buttonAlertTitle = "New Question"
                    self.isShowAlert = true
                }
            }
        } else {
            isWrong = true
            DispatchQueue.main.asyncAfter(deadline: .now() ) {
                self.alertTitle = "Wrong!!!"
                self.buttonAlertTitle = "Tray again"
                self.isShowAlert = true
            }
        }
    }
    
    func startNewGame() {
        startGame = true
        questionList = []
        createQuestionList()
        currentQuestion = 0
        self.setCountOfQuestions()
        answerList = []
        createAnswersList()
        totalScore = 0
    }
    
    func setCountOfQuestions() {
        guard let count = Int(self.totalQuestion) else {
            remainingQuestions  = questionList.count
            return
        }
        
        remainingQuestions = count
    }
    
    func createQuestionList(){
        let questionCount = Int(totalQuestion) ?? 5
        for i in 11...tableOfMultiplication {
            for j in 1...(questionCount) {
                questionList.append( QuestionData(question: "How much is: \(i) * \(j) ?", answer: i * j))
            }
        }
        print("LIST_SIZE \(questionList.count)")
        questionList.shuffle()
        currentQuestion = 0
        answerList = []
    }
    
    func createAnswersList() {
        if currentQuestion + 4 < questionList.count {
            for i in currentQuestion ... currentQuestion + 3 {
                answerList.append(questionList[i])
            }
        } else {
            for i in questionList.count - 4 ..< questionList.count {
                answerList.append(questionList[i])
            }
        }
        self.answerList.shuffle()
    }
    
    func newQuestion() {
        print("currentQuestion \(currentQuestion)")
        
        self.currentQuestion += 1
        self.answerList = []
        self.createAnswersList()
    }
}

struct QuestionData {
    var question: String
    var answer: Int
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
