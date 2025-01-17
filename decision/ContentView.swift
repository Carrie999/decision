//
//  ContentView.swift
//  decision
//
//  Created by  玉城 on 2024/11/17.
//
import SwiftUI
import Foundation
import StoreKit

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack{
        TabView(selection: $selectedTab) {
            // Tab 1
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "circle.circle.fill" : "circle.circle")
                }
                .tag(0)

            // Tab 2
            SearchView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "dollarsign.circle.fill" : "dollarsign.circle")
                }
                .tag(1)

            // Tab 3
            FavoritesView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "07.circle.fill" : "07.circle")
                }
                .tag(2)

            // Tab 4
            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "rectangle.on.rectangle.circle.fill" : "rectangle.on.rectangle.circle")
                }
                .tag(3)
        }
        .accentColor(.blue) // 修改选中的图标颜色
        }
    }
}

// 示例内容视图
struct HomeView: View {
    var body: some View {
        ZStack{
            RouletteWheel().padding(0)
        }
      

    }
}


// 转盘
struct RouletteWheel: View {
  
    
    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var result: String = ""
    @State private var showResult = false
    
    @State private var savedTitle: String = ""
    @State private var options = [
        "宫保鸡丁盖饭", "红烧牛肉面", "海鲜炒饭", "麻辣烫", "烤肉拌饭",
        "糖醋里脊", "蒜蓉蒸虾", "清蒸鲈鱼", "番茄炒蛋", "酸辣土豆丝",
        "披萨", "牛排配蔬菜", "意大利面", "汉堡", "墨西哥鸡肉卷",
        "煎饺", "寿司拼盘", "沙拉", "鸡蛋灌饼", "杂粮粥"
    ]
    
    @State private var items = []
    
    @State private var options2: [String] = [
       
    ]
    
    let languageCode = Locale.current.languageCode ?? "en"


    

    
    let baseColors: [Color] = [
        .red, .blue, .green, .orange, .purple,
        .pink, .yellow, .cyan, .indigo, .mint,
        .pink.opacity(0.9), .yellow.opacity(0.9),
        .green.opacity(0.9), .blue.opacity(0.9),
        .orange.opacity(0.9), .purple.opacity(0.9),
        .red, .blue, .green, .orange, .purple,
        .pink, .yellow, .cyan, .indigo, .mint,
        .pink.opacity(0.9), .yellow.opacity(0.9),
        .green.opacity(0.9), .blue.opacity(0.9),
        .orange.opacity(0.9), .purple.opacity(0.9),
        .red, .blue, .green, .orange, .purple,
        .pink, .yellow, .cyan, .indigo, .mint,
        .pink.opacity(0.9), .yellow.opacity(0.9),
        .green.opacity(0.9), .blue.opacity(0.9),
        .orange.opacity(0.9), .purple.opacity(0.9),
        .red, .blue, .green, .orange, .purple,
        .pink, .yellow, .cyan, .indigo, .mint,
        .pink.opacity(0.9), .yellow.opacity(0.9),
        .green.opacity(0.9), .blue.opacity(0.9),
        .orange.opacity(0.9), .purple.opacity(0.9),
        .red, .blue, .green, .orange, .purple,
        .pink, .yellow, .cyan, .indigo, .mint,
        .pink.opacity(0.9), .yellow.opacity(0.9),
        .green.opacity(0.9), .blue.opacity(0.9),
        .orange.opacity(0.9), .purple.opacity(0.9),
        .red, .blue, .green, .orange, .purple,
        .pink, .yellow, .cyan, .indigo, .mint,
        .pink.opacity(0.9), .yellow.opacity(0.9),
        .green.opacity(0.9), .blue.opacity(0.9),
        .orange.opacity(0.9), .purple.opacity(0.9),
    ]
    
    var colors: [Color] {
        var result = [Color]()
        for i in 0..<options.count {
            result.append(baseColors[i % baseColors.count])
        }
        return result
    }
    
    func calculateSliceAngle() -> Double {
        guard options.count > 0 else { return 0 }
        return 360.0 / Double(options.count)
    }
    
    func safeIndex(_ index: Int) -> Int {
        let count = options.count
        guard count > 0 else { return 0 }
        return ((index % count) + count) % count
    }
    
    // 修改后的重置函数
    func reset() {
        guard !isSpinning else { return }
        
        isSpinning = true
        showResult = false
        result = ""
        
        // 计算目标角度：当前角度的下一个整圈
        let currentRotation = rotation.truncatingRemainder(dividingBy: 360)
        let targetRotation = rotation + (360 - currentRotation)
        
        withAnimation(.easeInOut(duration: 1)) {
            rotation = targetRotation
        }
        
        // 重置完成后更新状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isSpinning = false
        }
    }
    @State private var showSheet3 = false // 用于控制弹窗显示
       @State private var showMessage = false // 用于控制支付按钮的状态
    @StateObject var storeKit = StoreKitManager()
    @State var isPurchased: Bool = false
    @State var isPurchasedId: String? = ""
    @State private var purchasedStatus: [String: Bool] = [:] // Key: Product ID, Value: Purchased status
    @State private var anyProductPurchased: Bool = false
    @State private var selectedProductId: String = "decison.tip"
    @State private var selectedProduct: Product? = nil

    
//    
//    func checkPurchases(product: Product) {
//        //        print("checkPurchases111")
//        Task {
//            
//            do {
//                //                print("111checkPurchases")
//                let purchased = try await storeKit.isPurchased(product)
//                DispatchQueue.main.async {
//                    UserDefaults.standard.set(purchased, forKey: product.id )
//                    purchasedStatus[product.id] = purchased // 存储每个产品的购买状态
//                    //                  print("11111\(product.id)+\(purchased)")
//                    updateAnyProductPurchased()
//                }
//            } catch {
//                //               print("checkPurchases1111111111111111111111111111")
//                //               print("Failed2 to check purchase status for \(product.id) after delay: \(error)")
//            }
//        }
//        
//    }
    
//    func checkPurchases(product: Product) {
//        //        print("checkPurchases111")
//        Task {
//            
//            do {
//                //                print("111checkPurchases")
//                let purchased = try await storeKit.isPurchased(product)
//                DispatchQueue.main.async {
//                    UserDefaults.standard.set(purchased, forKey: product.id )
//                    purchasedStatus[product.id] = purchased // 存储每个产品的购买状态
//                    //                  print("11111\(product.id)+\(purchased)")
////                    updateAnyProductPurchased()
//                }
//            } catch {
//                //               print("checkPurchases1111111111111111111111111111")
//                //               print("Failed2 to check purchase status for \(product.id) after delay: \(error)")
//            }
//        }
//        
//    }
    var body: some View {
        VStack {
            
            HStack{
                
               
                VStack {
                    // 爱心图标，点击弹出sheet
                    Image(systemName: "heart.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 24))
                        .onTapGesture {
                            showSheet3.toggle()
                        }
                        .padding()

                    // 这里可以加入其他视图内容
                }
                .sheet(isPresented: $showSheet3) {
                    
                   
                    // 弹出层的内容
                    VStack(spacing: 20) {
                        
                      Image("meow")
                          .resizable()
                          .scaledToFit()
                          .frame(width: 200, height: 200)
                          .cornerRadius(20)
                        Text("Support My Work")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text("Your generous support helps me continue developing and improving this app. Your appreciation means the world to me!")
                            .font(.body)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        
                        VStack {
                            // 使用 ForEach 显示产品列表
                            ForEach(storeKit.storeProducts) { product in
                                HStack {
                                    Spacer()
                                    Text(product.displayPrice)
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(Color.black)
                                    
                                    Spacer()

                                    
                                }.onAppear {
                                    selectedProduct = product
//                                    checkPurchases(product: product)
                                }
                            }
                            
                           
                            
                            
                        }
                        
                        Button(action: {
                            //                        print(storeKit.storeProducts)
                            
                            //                        if isPurchased {
                            //
                            //
                            //
                            //                        }
                            if UserDefaults.standard.bool(forKey: "decison.tip") == true {
                                return
                            }
                            Task{
                                if let product = selectedProduct {
                                    try await storeKit.purchase(product)
                                }
                              
                                
                            }
                            
                        }) {
                            //                           CourseItem(storeKit: storeKit, product: product)
                            
                            if (isPurchased || UserDefaults.standard.bool(forKey: "decison.tip") == true) {
                              
                                Text("Thank you for your support!")
                                    .font(.body)
                                    .foregroundColor(.blue.opacity(0.8))
                                    .padding(.top)
                        
                                
                            } else {
                                Text("Donate")
                                    .font(.title2)
                                    .padding()
                                    .background(Color.blue.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .padding(.horizontal,30)
                            }
                            
                        }   
                        .onChange(of: storeKit.purchasedCourses) { _ in
                            Task {
                                if let productToCheck = selectedProduct {
                                    if let purchased = try? await storeKit.isPurchased(productToCheck) {
                                        isPurchased = purchased
                                        UserDefaults.standard.set(isPurchased, forKey: "isPurchased")
                                        UserDefaults.standard.set(isPurchased, forKey: "decison.tip")
                                        
                                      
                                        
                                        
                                    } else {
                                        // 如果购买检查失败，默认将 isPurchased 设置为 false
                                        isPurchased = false
                                        UserDefaults.standard.set(false, forKey: "isPurchased")
                                        UserDefaults.standard.set(false, forKey: "decison.tip")
                                      
                                    }
                                } else {
                                    // 处理 selectedProduct 为空的情况
                                    print("No product selected to check purchase status.")
                                }
                            }
                        }
//                        Button(action: {
//                            // 这里可以链接到支付流程
//                            showMessage = true
//                        }) {
//                            Text("Donate")
//                                .font(.title2)
//                                .padding()
//                                .background(Color.blue)
//                                .foregroundColor(.white)
//                                .cornerRadius(10)
//                        }
//                        
//                        // 显示支付消息
//                        if showMessage {
//                            Text("Thank you for your support!")
//                                .font(.body)
//                                .foregroundColor(.green)
//                                .padding(.top)
//                        }
                    }
                    .padding()
                }
                
                Spacer()
          

                
                NavigationLink(
                       destination: ItemListView(),
                       label: {
                           Image(systemName: "list.bullet.below.rectangle")
                               .foregroundColor(.blue)
                               .font(.system(size: 24))
                       }
                   )
                   .simultaneousGesture(
                       TapGesture().onEnded {
                           showResult = false // 在点击时设置 a 为 false
                       }
                   )
                   .padding()
                

                Spacer().frame(width: 20)
            }
            
            
            
            Spacer().frame(height: 0)
            
            Text("\(savedTitle)")
                .font(.system(size: 24, weight: .bold, design: .default)) // 设置字体大小、粗细和设计风格
                .foregroundColor(.blue)           // 设置文字颜色为白色
                .padding()                         // 增加一些内边距
                .background(Color.gray.opacity(0.1))            // 设置背景颜色为蓝色
                .cornerRadius(18)                   // 给背景添加圆角
     
            
            Text(showResult ? "\(result)":"???")
                .font(.title)
                .padding()
                .transition(.opacity)
                .animation(.easeInOut, value: showResult)
//                .opacity()
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 360, height: 360)
                
                ForEach(0..<options.count, id: \.self) { index in
                    let startAngle = Double(index) * calculateSliceAngle()
                    ZStack {
                        Path { path in
                            path.move(to: CGPoint(x: 200, y: 200))
                            path.addArc(center: CGPoint(x: 200, y: 200),
                                      radius: 180,
                                      startAngle: .degrees(startAngle),
                                      endAngle: .degrees(startAngle + calculateSliceAngle()),
                                      clockwise: false)
                            path.closeSubpath()
                        }
                        .fill(colors[index % colors.count])
                    }
                }
                .rotationEffect(.degrees(rotation))
                
                ForEach(0..<options.count, id: \.self) { index in
                    let startAngle = Double(index) * calculateSliceAngle()
                    let midAngle = startAngle + (calculateSliceAngle() / 2)
                    
                    Text(options[index])
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .bold))
                        .rotationEffect(.degrees(-90))
                        .offset(y: -120)
                        .rotationEffect(.degrees(90 + midAngle))
                        .rotationEffect(.degrees(rotation))
                }
                
                Triangle()
                    .fill(Color.white)
                    .frame(width: 20, height: 30)
                    .offset(y: -60)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Text("转动")
                            .foregroundColor(.black)
                            .font(.system(size: 18, weight: .bold))
                    )
                    .onTapGesture {
                        if !isSpinning {
                            spin()
                        }
                    }
            }
            .frame(width: 400, height: 400)
            
            Button(action: reset) {
                Text("还原转盘")
                    .foregroundColor(.blue)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(26)
            }
            .disabled(isSpinning)
            .padding(.top, 20)
            
            Spacer()
 
          
        }.padding(0).onAppear {
            // 不存在的title
            if let title = UserDefaults.standard.string(forKey: "selectedTitle") {
              
                           savedTitle = title

                if title == "" {

                    
                    if languageCode.starts(with: "zh"){
                        savedTitle = "今天吃什么"
                        options = [
                            "宫保鸡丁盖饭", "红烧牛肉面", "海鲜炒饭", "麻辣烫", "烤肉拌饭",
                            "糖醋里脊", "蒜蓉蒸虾", "清蒸鲈鱼", "番茄炒蛋", "酸辣土豆丝",
                            "披萨", "牛排配蔬菜", "意大利面", "汉堡", "墨西哥鸡肉卷",
                            "煎饺", "寿司拼盘", "沙拉", "鸡蛋灌饼", "杂粮粥"
                        ]
                    }else{
                        savedTitle = "What to eat today"
                        options = [
                            "Grilled Salmon", "Chicken Caesar Salad", "Beef Stroganoff", "Vegetable Stir-fry", "Shrimp Alfredo Pasta",
                            "BBQ Ribs", "Margarita Pizza", "Lemon Herb Roasted Chicken", "Lobster Bisque", "Spaghetti Carbonara",
                            "Fish and Chips", "Turkey Club Sandwich", "Mushroom Risotto", "Honey Garlic Pork Chops", "Eggplant Parmesan",
                            "Buffalo Wings", "Chicken Tikka Masala", "Vegan Buddha Bowl", "Clam Chowder", "Pulled Pork Sandwich"
                        ]
                    }
                   
                    
                    
                    
                    
                   
                    
                    
                    
                      
//                        saveItems()
                }else{
                   
                    if let data = UserDefaults.standard.data(forKey: "savedItems"),
                       let decoded = try? JSONDecoder().decode([Item].self, from: data) {
                        self.items = decoded

                        let item2 =  decoded.first { $0.title == UserDefaults.standard.string(forKey: "selectedTitle") }
    
                        options2 = []
                        // 将 item2.subitems 的内容推送到 options2 数组中
                        item2!.subitems.forEach { content in
                            options2.append(content.content)
                        }
                        options = options2
    
    
                    }
                }
                
                
                
            } else {

                
                if languageCode.starts(with: "zh"){
                    savedTitle = "今天吃什么"
                    options = [
                        "宫保鸡丁盖饭", "红烧牛肉面", "海鲜炒饭", "麻辣烫", "烤肉拌饭",
                        "糖醋里脊", "蒜蓉蒸虾", "清蒸鲈鱼", "番茄炒蛋", "酸辣土豆丝",
                        "披萨", "牛排配蔬菜", "意大利面", "汉堡", "墨西哥鸡肉卷",
                        "煎饺", "寿司拼盘", "沙拉", "鸡蛋灌饼", "杂粮粥"
                    ]
                }else{
                    savedTitle = "What to eat today"
                    options = [
                        "Grilled Salmon", "Chicken Caesar Salad", "Beef Stroganoff", "Vegetable Stir-fry", "Shrimp Alfredo Pasta",
                        "BBQ Ribs", "Margarita Pizza", "Lemon Herb Roasted Chicken", "Lobster Bisque", "Spaghetti Carbonara",
                        "Fish and Chips", "Turkey Club Sandwich", "Mushroom Risotto", "Honey Garlic Pork Chops", "Eggplant Parmesan",
                        "Buffalo Wings", "Chicken Tikka Masala", "Vegan Buddha Bowl", "Clam Chowder", "Pulled Pork Sandwich"
                    ]
                }
                
            }
            
            
            
            
        }
        
    }
    
 
    
    private func saveTitleToUserDefaults(title: String) {
           UserDefaults.standard.set(title, forKey: "selectedTitle")
       }
    
    func spin() {
        guard !options.isEmpty else { return }
        
        isSpinning = true
        showResult = false
        
        let rotations = Double.random(in: 3...10) * 360
        let extraRotation = Double.random(in: 0...360)
        let finalRotation = rotation + rotations + extraRotation
        
        withAnimation(.easeInOut(duration: 3)) {
            rotation = finalRotation
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let sliceAngle = calculateSliceAngle()
            guard sliceAngle > 0 else { return }
            
            let normalizedRotation = rotation.truncatingRemainder(dividingBy: 360)
            let adjustedRotation = (360 - normalizedRotation - 90).truncatingRemainder(dividingBy: 360)
            
            var index = Int(floor(adjustedRotation / sliceAngle))
            index = safeIndex(index)
            
            if index >= 0 && index < options.count {
                result = options[index]
                showResult = true
            } else {
                result = options[0]
                showResult = true
            }
            
            isSpinning = false
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct SearchView: View {
    var body: some View {
        CoinFlipView()
//        Text("Search")
//            .font(.largeTitle)
//            .foregroundColor(.green)
    }
}

struct FavoritesView: View {
    var body: some View {
        RandomNumberView()
//        Text("Favorites")
//            .font(.largeTitle)
//            .foregroundColor(.red)
    }
}

struct ProfileView: View {
    var body: some View {
        
        CardFlipView()
      
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}





struct RandomNumberView: View {
    @State private var randomNumbers: [Int] = []
    @State private var showingSettings = false
    @State private var minRange: String = ""
    @State private var maxRange: String = ""
    @State private var numberCount: String = ""
    @State private var currentMin: Int
    @State private var currentMax: Int
    @State private var currentCount: Int
    
    init() {
        // 从UserDefaults加载保存的设置
        let defaults = UserDefaults.standard
        let savedMin = defaults.integer(forKey: "minRange")
        let savedMax = defaults.integer(forKey: "maxRange")
        let savedCount = defaults.integer(forKey: "numberCount")
        
        // 设置初始值
        let initialMin = savedMin == 0 ? 1 : savedMin
        let initialMax = savedMax == 0 ? 100 : savedMax
        let initialCount = savedCount == 0 ? 1 : savedCount
        
        _currentMin = State(initialValue: initialMin)
        _currentMax = State(initialValue: initialMax)
        _currentCount = State(initialValue: initialCount)
        
        // 确保初始化时生成正确数量的随机数
        _randomNumbers = State(initialValue: Array(0..<initialCount).map { _ in
            Int.random(in: initialMin...initialMax)
        })
    }
    
    // 生成指定数量的随机数的函数
    private func generateRandomNumbers(min: Int, max: Int, count: Int) -> [Int] {
        // 确保生成准确数量的随机数
        var numbers: [Int] = []
        for _ in 0..<count {
            numbers.append(Int.random(in: min...max))
        }
        return numbers
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ScrollView {
              
                    if (randomNumbers.count == 1){
                        Spacer().frame(height: 180)
                        Text("\(randomNumbers[0])")
                                       .font(.system(size: 120))
                                       .fontWeight(.bold)
                                       .padding()
                                       .frame(minWidth: 200, minHeight: 200)
                                   
                    }else{
                        
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 100), spacing: 15)
                        ], spacing: 15) {
                          
                        // 使用indices确保遍历整个数组
                        ForEach(0..<randomNumbers.count, id: \.self) { index in
                            Text("\(randomNumbers[index])")
                                .font(.system(size: 46))
                                .fontWeight(.bold)
                                .padding()
                                .frame(minWidth: 100, minHeight: 100)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(15)
                                .transition(.scale)
                        }
                        }
                        .padding()
                        
                    }
               
                
                
            }
            .frame(maxHeight: UIScreen.main.bounds.height * 0.6)
            
            Text("\(currentMin) - \(currentMax)")
                .foregroundColor(.gray)
            
            HStack(spacing: 20) {
                
                Button(action: {
                    minRange = String(currentMin)
                    maxRange = String(currentMax)
                    numberCount = String(currentCount)
                    showingSettings = true
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20))
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }.opacity(0)
                // 生成随机数按钮
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        // 确保生成新的随机数数组
                        randomNumbers = generateRandomNumbers(
                            min: currentMin,
                            max: currentMax,
                            count: currentCount
                        )
                    }
                }) {
                    Text("生成随机数")
                        .bold()
                        .padding(.horizontal, 30)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(40)
                        .font(.system(size: 20))
                }
                
                // 设置按钮
                Button(action: {
                    minRange = String(currentMin)
                    maxRange = String(currentMax)
                    numberCount = String(currentCount)
                    showingSettings = true
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20))
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding(.bottom)
        }
        .sheet(isPresented: $showingSettings) {
            NavigationView {
                Form {
                    Section(header: Text("设置随机数范围")) {
                        TextField("最小值", text: $minRange)
                            .keyboardType(.numberPad)
                        
                        TextField("最大值", text: $maxRange)
                            .keyboardType(.numberPad)
                    }
                    
                    Section(header: Text("设置随机数数量")) {
                        TextField("数量", text: $numberCount)
                            .keyboardType(.numberPad)
                    }
                }
                .navigationTitle("设置")
                .navigationBarItems(
                    leading: Button("取消") {
                        showingSettings = false
                    },
                    trailing: Button("保存") {
                        if let min = Int(minRange),
                           let max = Int(maxRange),
                           let count = Int(numberCount),
                           min < max,
                           count > 0 {
                            currentMin = min
                            currentMax = max
                            currentCount = count
                            
                            // 保存到UserDefaults
                            let defaults = UserDefaults.standard
                            defaults.set(min, forKey: "minRange")
                            defaults.set(max, forKey: "maxRange")
                            defaults.set(count, forKey: "numberCount")
                            
                            // 生成新的随机数
                            withAnimation(.easeInOut(duration: 0.3)) {
                                randomNumbers = generateRandomNumbers(
                                    min: currentMin,
                                    max: currentMax,
                                    count: currentCount
                                )
                            }
                        }
                        showingSettings = false
                    }
                )
            }
        }
    }
}



struct CoinFlipView: View {
    @State private var isFlipping = false
    @State private var rotationDegree = 0.0
    @State private var offsetY: CGFloat = 0
    @State private var showHeads = true
    
    let flipDuration = 1.0
    // 定义硬币最终停留时略微朝上的角度
    let finalAngle = 0.0
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                // 硬币正面
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Text("0") .bold()
                            .font(.system(size: 44))
                            .foregroundColor(.orange)
                    )
                    .opacity(showHeads ? 1 : 0)
                   
                
                // 硬币反面
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Text("1") .bold()
                            .font(.system(size: 44))
                            .foregroundColor(.orange)
                            
                            
                    )
                    .opacity(showHeads ? 0 : 1)
            }
            .rotation3DEffect(
                .degrees(rotationDegree),
                axis: (x: 1.0, y: 0.0, z: 0.0)
            )
            .offset(y: offsetY)
            Spacer().frame(height: 20)
            
            Button("抛硬币") {
                flipCoin()
            }
            .bold()
            .disabled(isFlipping)
            .padding(.horizontal, 40)
            .padding(.vertical, 16)

            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(40)
            .font(.system(size: 20))
            
            Spacer().frame(height: 40)
           
            
//            Text("还原转盘")
//                .background(Color.blue)
//                .foregroundColor(.white)
//                
//     
//                .cornerRadius(26)
            
            
            
        }
        // 初始状态也设置成略微朝上的角度
        .onAppear {
            rotationDegree = finalAngle
        }
    }
    
    func flipCoin() {
        guard !isFlipping else { return }
        
        isFlipping = true
        let finalShowHeads = Bool.random()
        
        // 重置角度为0
        withAnimation(.linear(duration: 0)) {
            rotationDegree = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            // 计算最终旋转角度，确保停在略微朝上的位置
            let rotations = Double.random(in: 5...7)
            let baseRotation = rotations * 360
            // 根据正反面计算最终角度
            var finalRotation = baseRotation + (finalShowHeads ? finalAngle : (180 + finalAngle))

            finalRotation =  Double((Int(finalRotation) / 180) * 180) + 10
           
//            print(finalRotation.truncatingRemainder(dividingBy: 180))
            // 上升动画
            withAnimation(.easeOut(duration: flipDuration)) {
                offsetY = -700
                rotationDegree = finalRotation
            }
            
            // 下落动画
            DispatchQueue.main.asyncAfter(deadline: .now() + flipDuration * 0.5) {
                withAnimation(.easeIn(duration: flipDuration * 0.5)) {
                    offsetY = 0
                }
            }
            
            // 重置状态
            DispatchQueue.main.asyncAfter(deadline: .now() + flipDuration) {
                showHeads = finalShowHeads
                isFlipping = false
            }
        }
    }
}



struct CardFlipView: View {
    // 选项列表
//    var options = [
//        "宫保鸡丁盖饭", "红烧牛肉面", "海鲜炒饭", "麻辣烫", "烤肉拌饭",
//        "糖醋里脊", "蒜蓉蒸虾", "清蒸鲈鱼", "番茄炒蛋", "酸辣土豆丝",
//        "披萨", "牛排配蔬菜", "意大利面", "汉堡", "墨西哥鸡肉卷",
//        "煎饺", "寿司拼盘", "沙拉", "鸡蛋灌饼", "杂粮粥"
//    ]
//    
    // 状态变量
    @State private var shuffledOptions: [String] = []
    @State private var flippedIndices: [Bool] = []
    @State private var isShuffling = false
    
    
    @State private var options2: [String] = [
       
    ]
    @State private var options: [String] = []
    @State private var  savedTitle: String = ""
    let languageCode = Locale.current.languageCode ?? "en"


    
    var body: some View {
        VStack(spacing: 20) {
            // 卡片列表
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(shuffledOptions.indices, id: \.self) { index in
                        CardView(
                            text: shuffledOptions[index],
                            isFlipped: flippedIndices[index]
                        )
                        .onTapGesture {
                            withAnimation {
                                flippedIndices[index].toggle()
                            }
                        }
                    }
                }
                .padding()
            }
            
            
                        // 给背景添加圆角
            // 重新打乱按钮
            Button(action: shuffleCards) {
               
                Text("重新打乱")
                    .bold()

                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)

                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(40)
                    .font(.system(size: 20))
            }
            
            Text("\(savedTitle)")
                .font(.system(size: 22, weight: .bold, design: .default)) // 设置字体大小、粗细和设计风格
//                .foregroundColor(.blue)           // 设置文字颜色为白色
//                .padding()                         // 增加一些内边距
//                .background(Color.gray.opacity(0.1))            // 设置背景颜色为蓝色
                .cornerRadius(18)
            Spacer().frame(height: 0)
            
         
            
            
            
            
        }
        .onAppear {
            shuffleCards()
            
            
            // 不存在的title
            if let title = UserDefaults.standard.string(forKey: "selectedTitle") {
              
                savedTitle = title


                
                if title == "" {

                    if languageCode.starts(with: "zh"){
                        savedTitle = "今天吃什么"
                        options = [
                            "宫保鸡丁盖饭", "红烧牛肉面", "海鲜炒饭", "麻辣烫", "烤肉拌饭",
                            "糖醋里脊", "蒜蓉蒸虾", "清蒸鲈鱼", "番茄炒蛋", "酸辣土豆丝",
                            "披萨", "牛排配蔬菜", "意大利面", "汉堡", "墨西哥鸡肉卷",
                            "煎饺", "寿司拼盘", "沙拉", "鸡蛋灌饼", "杂粮粥"
                        ]
                    }else{
                        
                        savedTitle = "What to eat today"
              
                        options = [
                            "Grilled Salmon", "Chicken Caesar Salad", "Beef Stroganoff", "Vegetable Stir-fry", "Shrimp Alfredo Pasta",
                            "BBQ Ribs", "Margarita Pizza", "Lemon Herb Roasted Chicken", "Lobster Bisque", "Spaghetti Carbonara",
                            "Fish and Chips", "Turkey Club Sandwich", "Mushroom Risotto", "Honey Garlic Pork Chops", "Eggplant Parmesan",
                            "Buffalo Wings", "Chicken Tikka Masala", "Vegan Buddha Bowl", "Clam Chowder", "Pulled Pork Sandwich"
                        ]
                      
                        
                        
                    }
                   
                      
//                        saveItems()
                }else{
                    if let data = UserDefaults.standard.data(forKey: "savedItems"),
                       let decoded = try? JSONDecoder().decode([Item].self, from: data) {
//                        self.items = decoded

                       
                        let item2 =  decoded.first { $0.title == UserDefaults.standard.string(forKey: "selectedTitle") }
    
                        options2 = []
                        // 将 item2.subitems 的内容推送到 options2 数组中
                        item2!.subitems.forEach { content in
                            options2.append(content.content)
                        }
                        options = options2
    
    
                    }
                }
                
                
                
            } else {

                
                if languageCode.starts(with: "zh"){
                    savedTitle = "今天吃什么"
                    options = [
                        "宫保鸡丁盖饭", "红烧牛肉面", "海鲜炒饭", "麻辣烫", "烤肉拌饭",
                        "糖醋里脊", "蒜蓉蒸虾", "清蒸鲈鱼", "番茄炒蛋", "酸辣土豆丝",
                        "披萨", "牛排配蔬菜", "意大利面", "汉堡", "墨西哥鸡肉卷",
                        "煎饺", "寿司拼盘", "沙拉", "鸡蛋灌饼", "杂粮粥"
                    ]
                }else{
                    
                    savedTitle = "What to eat today"
          
                    options = [
                        "Grilled Salmon", "Chicken Caesar Salad", "Beef Stroganoff", "Vegetable Stir-fry", "Shrimp Alfredo Pasta",
                        "BBQ Ribs", "Margarita Pizza", "Lemon Herb Roasted Chicken", "Lobster Bisque", "Spaghetti Carbonara",
                        "Fish and Chips", "Turkey Club Sandwich", "Mushroom Risotto", "Honey Garlic Pork Chops", "Eggplant Parmesan",
                        "Buffalo Wings", "Chicken Tikka Masala", "Vegan Buddha Bowl", "Clam Chowder", "Pulled Pork Sandwich"
                    ]
                  
                    
                    
                }
                
            }

        }
    }
    
    // 卡片洗牌函数
    func shuffleCards() {
        isShuffling = true
        shuffledOptions = options.shuffled()
        flippedIndices = Array(repeating: false, count: options.count)
        
        // 增加一个短暂的动画效果
        withAnimation(.easeOut(duration: 0.3)) {
            isShuffling = false
        }
    }
}

// 修改后的卡片视图
struct CardView: View {
    let text: String
    let isFlipped: Bool
    
    var body: some View {
        ZStack {
            // 背面卡片
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.blue.opacity(0.1))
                .frame(height: 120)
                .overlay(
                    Text("点击查看")
                        .font(.title2)
                        .foregroundColor(.blue)
                   
                )
                .opacity(isFlipped ? 0 : 1)

            // 正面卡片
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.orange)
                .frame(height: 120)
                .overlay(
                    Text(text)
                        .font(.system(size: 20))
                        .foregroundColor(.white).padding()
                )
                .rotation3DEffect(
                    .degrees(180),
                    axis: (x: 0, y: 1, z: 0)
                )
                .opacity(isFlipped ? 1 : 0)
        }
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
//        .shadow(radius: 5)
        .animation(.easeInOut(duration: 0.5), value: isFlipped)
    }
}




struct Item: Identifiable, Codable {
    let id: UUID
    var title: String
    var subitems: [SubItem]
    
    init(id: UUID = UUID(), title: String, subitems: [SubItem] = []) {
        self.id = id
        self.title = title
        self.subitems = subitems
    }
}

struct SubItem: Identifiable, Codable {
    let id: UUID
    var content: String
    
    init(id: UUID = UUID(), content: String) {
        self.id = id
        self.content = content
    }
}





// ItemViewModel.swift
class ItemViewModel: ObservableObject {
    let languageCode = Locale.current.languageCode ?? "en"
    @Published var items: [Item] {
        didSet {
            saveItems()
        }
    }
    
    init() {
        // 首先初始化 items 属性
               self.items = []
               
               // 然后尝试加载保存的数据
               if let data = UserDefaults.standard.data(forKey: "savedItems"),
                  let decoded = try? JSONDecoder().decode([Item].self, from: data) {
                   self.items = decoded
                   
                   if(self.items.count == 0 ){
                       
                       if languageCode.starts(with: "zh"){
                           self.items = [
                            Item(title:  "今天吃什么？", subitems: [
                                SubItem(content: "宫保鸡丁盖饭"),
                                SubItem(content: "红烧牛肉面"),
                                SubItem(content: "海鲜炒饭"),
                                SubItem(content: "麻辣烫"),
                                SubItem(content: "烤肉拌饭"),
                                
                                SubItem(content: "糖醋里脊"),
                                SubItem(content: "蒜蓉蒸虾"),
                                SubItem(content: "清蒸鲈鱼"),
                                SubItem(content: "番茄炒蛋"),
                                SubItem(content: "酸辣土豆丝"),
                                
                                SubItem(content: "披萨"),
                                SubItem(content: "牛排配蔬菜"),
                                SubItem(content: "意大利面"),
                                SubItem(content: "汉堡"),
                                SubItem(content: "墨西哥鸡肉卷"),
                                
                                SubItem(content: "煎饺"),
                                SubItem(content: "寿司拼盘"),
                                SubItem(content: "沙拉"),
                                SubItem(content: "鸡蛋灌饼"),
                                SubItem(content: "杂粮粥")
                            ]),
                            Item(title:  "约会做什么？", subitems: [
                                SubItem(content: "一起看电影"),
                                SubItem(content: "去公园散步"),
                                SubItem(content: "一起做饭"),
                                SubItem(content: "去博物馆参观"),
                                SubItem(content: "一起逛书店"),
                                                                 
                                SubItem(content: "看一场音乐会"),
                                SubItem(content: "去咖啡馆聊天"),
                                SubItem(content: "一起做手工"),
                                SubItem(content: "参加美术展览"),
                                SubItem(content: "去游乐园玩"),
                                                                 
                                SubItem(content: "尝试新餐厅"),
                                SubItem(content: "去拍大头贴"),
                                SubItem(content: "打桌游"),
                                SubItem(content: "一起打羽毛球"),
                                SubItem(content: "去海边散步"),
                                                                 
                                SubItem(content: "看日落"),
                                SubItem(content: "夜晚看星星"),
                                SubItem(content: "去露营"),
                                SubItem(content: "一起做瑜伽"),
                                SubItem(content: "一起养植物")
                            ]),
                            Item(title:  "爱自己的方式", subitems: [
                                SubItem(content: "早睡早起，保持良好的作息"),
                                SubItem(content: "每天坚持喝足够的水"),
                                SubItem(content: "为自己做一顿健康美味的饭菜"),
                                SubItem(content: "定期锻炼身体，保持健康"),
                                SubItem(content: "读一本自己喜欢的书"),
                                SubItem(content: "给自己买一份小礼物"),
                                SubItem(content: "学会拒绝不必要的事情"),
                                SubItem(content: "独自旅行或探寻新的地方"),
                                SubItem(content: "练习冥想，放松身心"),
                                SubItem(content: "记录每天的感恩时刻"),
                                SubItem(content: "尝试学习一项新技能"),
                                SubItem(content: "听自己喜欢的音乐放松"),
                                SubItem(content: "为自己制定一个小目标并实现"),
                                SubItem(content: "给自己的房间整理和装饰"),
                                SubItem(content: "每天留一点时间做自己喜欢的事情"),
                                                                 
                                SubItem(content: "拥抱自然，去户外散步或登山"),
                                SubItem(content: "定期体检，关注自己的健康"),
                                SubItem(content: "减少使用手机，给自己一些独处时间"),
                                SubItem(content: "写日记表达自己的情绪"),
                                SubItem(content: "告诉自己：你很棒，你值得被爱")
                            ]),
                            
                           ]
                       }else{
                           self.items = [
                               Item(title: "What to eat today?", subitems: [
                                SubItem(content: "Grilled Salmon"),
                                SubItem(content: "Chicken Caesar Salad"),
                                SubItem(content: "Beef Stroganoff"),
                                SubItem(content: "Vegetable Stir-fry"),
                                SubItem(content: "Shrimp Alfredo Pasta"),

                                SubItem(content: "BBQ Ribs"),
                                SubItem(content: "Margarita Pizza"),
                                SubItem(content: "Lemon Herb Roasted Chicken"),
                                SubItem(content: "Lobster Bisque"),
                                SubItem(content: "Spaghetti Carbonara"),

                                SubItem(content: "Fish and Chips"),
                                SubItem(content: "Turkey Club Sandwich"),
                                SubItem(content: "Mushroom Risotto"),
                                SubItem(content: "Honey Garlic Pork Chops"),
                                SubItem(content: "Eggplant Parmesan"),

                                SubItem(content: "Buffalo Wings"),
                                SubItem(content: "Chicken Tikka Masala"),
                                SubItem(content: "Vegan Buddha Bowl"),
                                SubItem(content: "Clam Chowder"),
                                SubItem(content: "Pulled Pork Sandwich")
                          
                               ]),
                               Item(title: "What to do on a date?", subitems: [
                                   SubItem(content: "Watch a movie together"),
                                   SubItem(content: "Take a walk in the park"),
                                   SubItem(content: "Cook a meal together"),
                                   SubItem(content: "Visit a museum"),
                                   SubItem(content: "Browse a bookstore together"),
                                                                                
                                   SubItem(content: "Attend a concert"),
                                   SubItem(content: "Chat at a café"),
                                   SubItem(content: "Do crafts together"),
                                   SubItem(content: "Visit an art exhibition"),
                                   SubItem(content: "Have fun at an amusement park"),
                                                                                
                                   SubItem(content: "Try a new restaurant"),
                                   SubItem(content: "Take photo booth pictures"),
                                   SubItem(content: "Play board games"),
                                   SubItem(content: "Play badminton together"),
                                   SubItem(content: "Take a walk on the beach"),
                                                                                
                                   SubItem(content: "Watch the sunset"),
                                   SubItem(content: "Stargaze at night"),
                                   SubItem(content: "Go camping"),
                                   SubItem(content: "Practice yoga together"),
                                   SubItem(content: "Grow plants together")
                               ]),
                               Item(title: "Ways to love yourself", subitems: [
                                   SubItem(content: "Go to bed early and wake up early, maintain a good routine"),
                                   SubItem(content: "Drink enough water every day"),
                                   SubItem(content: "Cook a healthy and delicious meal for yourself"),
                                   SubItem(content: "Exercise regularly to stay healthy"),
                                   SubItem(content: "Read a book you like"),
                                   SubItem(content: "Buy yourself a small gift"),
                                   SubItem(content: "Learn to say no to unnecessary things"),
                                   SubItem(content: "Travel alone or explore new places"),
                                   SubItem(content: "Practice meditation to relax your body and mind"),
                                   SubItem(content: "Record moments of gratitude every day"),
                                   SubItem(content: "Try to learn a new skill"),
                                   SubItem(content: "Listen to music you enjoy and relax"),
                                   SubItem(content: "Set a small goal for yourself and achieve it"),
                                   SubItem(content: "Organize and decorate your room"),
                                   SubItem(content: "Take time to do something you love every day"),
                                                                                
                                   SubItem(content: "Embrace nature by walking or hiking outdoors"),
                                   SubItem(content: "Have regular health checkups and take care of your health"),
                                   SubItem(content: "Reduce phone usage and give yourself some alone time"),
                                   SubItem(content: "Write a journal to express your emotions"),
                                   SubItem(content: "Tell yourself: You are amazing and deserve love")
                               ]),
                           ]
                       }
                       
                   }
               } else {
                   
                   if(self.items.count == 0 ){
                       
                       if languageCode.starts(with: "zh"){
                           self.items = [
                            Item(title:  "今天吃什么？", subitems: [
                                SubItem(content: "宫保鸡丁盖饭"),
                                SubItem(content: "红烧牛肉面"),
                                SubItem(content: "海鲜炒饭"),
                                SubItem(content: "麻辣烫"),
                                SubItem(content: "烤肉拌饭"),
                                
                                SubItem(content: "糖醋里脊"),
                                SubItem(content: "蒜蓉蒸虾"),
                                SubItem(content: "清蒸鲈鱼"),
                                SubItem(content: "番茄炒蛋"),
                                SubItem(content: "酸辣土豆丝"),
                                
                                SubItem(content: "披萨"),
                                SubItem(content: "牛排配蔬菜"),
                                SubItem(content: "意大利面"),
                                SubItem(content: "汉堡"),
                                SubItem(content: "墨西哥鸡肉卷"),
                                
                                SubItem(content: "煎饺"),
                                SubItem(content: "寿司拼盘"),
                                SubItem(content: "沙拉"),
                                SubItem(content: "鸡蛋灌饼"),
                                SubItem(content: "杂粮粥")
                            ]),
                            Item(title:  "约会做什么？", subitems: [
                                SubItem(content: "一起看电影"),
                                SubItem(content: "去公园散步"),
                                SubItem(content: "一起做饭"),
                                SubItem(content: "去博物馆参观"),
                                SubItem(content: "一起逛书店"),
                                                                 
                                SubItem(content: "看一场音乐会"),
                                SubItem(content: "去咖啡馆聊天"),
                                SubItem(content: "一起做手工"),
                                SubItem(content: "参加美术展览"),
                                SubItem(content: "去游乐园玩"),
                                                                 
                                SubItem(content: "尝试新餐厅"),
                                SubItem(content: "去拍大头贴"),
                                SubItem(content: "打桌游"),
                                SubItem(content: "一起打羽毛球"),
                                SubItem(content: "去海边散步"),
                                                                 
                                SubItem(content: "看日落"),
                                SubItem(content: "夜晚看星星"),
                                SubItem(content: "去露营"),
                                SubItem(content: "一起做瑜伽"),
                                SubItem(content: "一起养植物")
                            ]),
                            Item(title:  "爱自己的方式", subitems: [
                                SubItem(content: "早睡早起，保持良好的作息"),
                                SubItem(content: "每天坚持喝足够的水"),
                                SubItem(content: "为自己做一顿健康美味的饭菜"),
                                SubItem(content: "定期锻炼身体，保持健康"),
                                SubItem(content: "读一本自己喜欢的书"),
                                SubItem(content: "给自己买一份小礼物"),
                                SubItem(content: "学会拒绝不必要的事情"),
                                SubItem(content: "独自旅行或探寻新的地方"),
                                SubItem(content: "练习冥想，放松身心"),
                                SubItem(content: "记录每天的感恩时刻"),
                                SubItem(content: "尝试学习一项新技能"),
                                SubItem(content: "听自己喜欢的音乐放松"),
                                SubItem(content: "为自己制定一个小目标并实现"),
                                SubItem(content: "给自己的房间整理和装饰"),
                                SubItem(content: "每天留一点时间做自己喜欢的事情"),
                                                                 
                                SubItem(content: "拥抱自然，去户外散步或登山"),
                                SubItem(content: "定期体检，关注自己的健康"),
                                SubItem(content: "减少使用手机，给自己一些独处时间"),
                                SubItem(content: "写日记表达自己的情绪"),
                                SubItem(content: "告诉自己：你很棒，你值得被爱")
                            ]),
                            
                           ]
                       }else{
                           self.items = [
                               Item(title: "What to eat today?", subitems: [
                                   SubItem(content: "Kung Pao Chicken Rice"),
                                   SubItem(content: "Braised Beef Noodles"),
                                   SubItem(content: "Seafood Fried Rice"),
                                   SubItem(content: "Spicy Hot Pot"),
                                   SubItem(content: "Grilled Meat Rice Bowl"),
                                   
                                   SubItem(content: "Sweet and Sour Pork"),
                                   SubItem(content: "Steamed Shrimp with Garlic"),
                                   SubItem(content: "Steamed Bass"),
                                   SubItem(content: "Tomato and Egg Stir-fry"),
                                   SubItem(content: "Hot and Sour Shredded Potatoes"),
                                   
                                   SubItem(content: "Pizza"),
                                   SubItem(content: "Steak with Vegetables"),
                                   SubItem(content: "Pasta"),
                                   SubItem(content: "Hamburger"),
                                   SubItem(content: "Mexican Chicken Wrap"),
                                   
                                   SubItem(content: "Fried Dumplings"),
                                   SubItem(content: "Sushi Platter"),
                                   SubItem(content: "Salad"),
                                   SubItem(content: "Stuffed Pancake with Egg"),
                                   SubItem(content: "Multigrain Porridge")
                               ]),
                               Item(title: "What to do on a date?", subitems: [
                                   SubItem(content: "Watch a movie together"),
                                   SubItem(content: "Take a walk in the park"),
                                   SubItem(content: "Cook a meal together"),
                                   SubItem(content: "Visit a museum"),
                                   SubItem(content: "Browse a bookstore together"),
                                                                                
                                   SubItem(content: "Attend a concert"),
                                   SubItem(content: "Chat at a café"),
                                   SubItem(content: "Do crafts together"),
                                   SubItem(content: "Visit an art exhibition"),
                                   SubItem(content: "Have fun at an amusement park"),
                                                                                
                                   SubItem(content: "Try a new restaurant"),
                                   SubItem(content: "Take photo booth pictures"),
                                   SubItem(content: "Play board games"),
                                   SubItem(content: "Play badminton together"),
                                   SubItem(content: "Take a walk on the beach"),
                                                                                
                                   SubItem(content: "Watch the sunset"),
                                   SubItem(content: "Stargaze at night"),
                                   SubItem(content: "Go camping"),
                                   SubItem(content: "Practice yoga together"),
                                   SubItem(content: "Grow plants together")
                               ]),
                               Item(title: "Ways to love yourself", subitems: [
                                   SubItem(content: "Go to bed early and wake up early, maintain a good routine"),
                                   SubItem(content: "Drink enough water every day"),
                                   SubItem(content: "Cook a healthy and delicious meal for yourself"),
                                   SubItem(content: "Exercise regularly to stay healthy"),
                                   SubItem(content: "Read a book you like"),
                                   SubItem(content: "Buy yourself a small gift"),
                                   SubItem(content: "Learn to say no to unnecessary things"),
                                   SubItem(content: "Travel alone or explore new places"),
                                   SubItem(content: "Practice meditation to relax your body and mind"),
                                   SubItem(content: "Record moments of gratitude every day"),
                                   SubItem(content: "Try to learn a new skill"),
                                   SubItem(content: "Listen to music you enjoy and relax"),
                                   SubItem(content: "Set a small goal for yourself and achieve it"),
                                   SubItem(content: "Organize and decorate your room"),
                                   SubItem(content: "Take time to do something you love every day"),
                                                                                
                                   SubItem(content: "Embrace nature by walking or hiking outdoors"),
                                   SubItem(content: "Have regular health checkups and take care of your health"),
                                   SubItem(content: "Reduce phone usage and give yourself some alone time"),
                                   SubItem(content: "Write a journal to express your emotions"),
                                   SubItem(content: "Tell yourself: You are amazing and deserve love")
                               ]),
                           ]
                       }
                       
                   }
                   saveItems()
               }
    }
    
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "savedItems")
        }
    }
    
    private func loadItems() -> [Item]? {
        if let data = UserDefaults.standard.data(forKey: "savedItems"),
           let decoded = try? JSONDecoder().decode([Item].self, from: data) {
            return decoded
        }
        return nil
    }
    
    func updateItem(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        }
    }
    
    func updateAllItems(_ items2: [Item]) {
//            self.items = newItems
//        self.items.push()
        self.items.append(contentsOf: items2)
    }
    
    func deleteSubItem(from item: Item, at offsets: IndexSet) {
        var updatedItem = item
        updatedItem.subitems.remove(atOffsets: offsets)
        updateItem(updatedItem)
    }
    
    func addSubItem(to item: Item, content: String) {
        var updatedItem = item
        updatedItem.subitems.append(SubItem(content: content))
        updateItem(updatedItem)
    }
    
    func updateSubItem(in item: Item, subItem: SubItem, newContent: String) {
        var updatedItem = item
        if let index = updatedItem.subitems.firstIndex(where: { $0.id == subItem.id }) {
            updatedItem.subitems[index].content = newContent
            updateItem(updatedItem)
        }
    }
}

func saveTitleToUserDefaults(title: String) {
    UserDefaults.standard.set(title, forKey: "selectedTitle")
    print("Title saved: \(title)")
}
// ItemListView.swift
struct ItemListView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ItemViewModel()
    
    
    
    func saveTitleToUserDefaults(title: String) {
        UserDefaults.standard.set(title, forKey: "selectedTitle")
        print("Title saved: \(title)")
    }
    
    var body: some View {
        List {
            ForEach(viewModel.items) { item in
                HStack {

                    if ( UserDefaults.standard.string(forKey: "selectedTitle") == item.title){
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                            .onTapGesture {
                                saveTitleToUserDefaults(title: item.title)
//                                print(1111111111)
//                                print(item.title)
                                dismiss()
                            }

                    }else{
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.gray)
                            .onTapGesture {
                                saveTitleToUserDefaults(title: item.title)
//                                print(1111111111)
//                                print(item.title)
                                dismiss()
                            }
                    }
                 
                    Text(item.title)
                        .foregroundColor(UserDefaults.standard.string(forKey: "selectedTitle") == item.title ? .blue: .black)
                        .onTapGesture {
                            saveTitleToUserDefaults(title: item.title)
//                            print(1111111111)
//                            print(item.title)
                            dismiss()
                        }
                    
                    
                    
                    Spacer()
                    NavigationLink(destination: EditItemView(item: item, viewModel: viewModel)) {
                        Image(systemName: "")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundColor(.blue)
                    }
                   
                    
                }
                
                
//                .listRowBackground(Color.clear)
//                .listRowSeparator(.hidden)
               
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
//
                        if(UserDefaults.standard.string(forKey: "selectedTitle") == item.title){
                            saveTitleToUserDefaults(title: "")
                            print("11111")
                        }else{
                            print("2222")
                        }
                        if let index = viewModel.items.firstIndex(where: { $0.id == item.id }) {
                              viewModel.items.remove(at: index)
                        }
                      
                        
                    } label: {
                        Label("删除", systemImage: "trash")
                    }
                }
                
//                
//                NavigationLink(destination: CreateItemView()) {
//                    Text("新建项目").foregroundStyle(.gray).font(.system(size: 12))
//                }
              
            }
            
            
       
          
            
            Text("  提示：左滑删除").foregroundStyle(.gray).font(.system(size: 12))
            
            
        }
        .navigationTitle("我的转盘")
        .navigationBarItems(
                    trailing: NavigationLink(destination: CreateItemView(viewModel: viewModel)) {
                        Image(systemName: "plus")
                    }
                )
    }
}




struct EditItemView: View {
    @ObservedObject var viewModel: ItemViewModel
    @Environment(\.dismiss) var dismiss
    @State private var item: Item
    @State private var showingAddSubItem = false
    @State private var showingBatchAddSubItems = false
    @State private var newSubItemContent = ""
    @State private var batchSubItemsContent = ""
    @State private var editingSubItem: SubItem?

    init(item: Item, viewModel: ItemViewModel) {
        self.viewModel = viewModel
        _item = State(initialValue: item)
    }

    func saveTitleToUserDefaults(title: String) {
        UserDefaults.standard.set(title, forKey: "selectedTitle")
        print("Title saved: \(title)")
    }

    var body: some View {
        List {
            Section(header: Text("问题")) {
                TextField("问题", text: $item.title)
                    .onChange(of: item.title) { _ in
                        viewModel.updateItem(item)
                        saveTitleToUserDefaults(title: item.title)
                    }
            }

            Section(header: Text("选项   (左滑删除)")) {
                ForEach(item.subitems) { subItem in
                    if editingSubItem?.id == subItem.id {
                        TextField("内容", text: Binding(
                            get: { subItem.content },
                            set: { newValue in
                                viewModel.updateSubItem(in: item, subItem: subItem, newContent: newValue)
                                if let index = item.subitems.firstIndex(where: { $0.id == subItem.id }) {
                                    item.subitems[index].content = newValue
                                }
                            }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text(subItem.content)
                            .onTapGesture {
                                editingSubItem = subItem
                            }
                    }
                }
                .onDelete { indexSet in
                    viewModel.deleteSubItem(from: item, at: indexSet)
                    item.subitems.remove(atOffsets: indexSet)
                }
            }

            HStack {
                Button("添加新选项") {
                    showingAddSubItem = true
                }
                Spacer()
                
            }
            Button("批量添加") {
                showingBatchAddSubItems = true
            }
        }
        .navigationTitle("编辑")
        .alert("添加新选项", isPresented: $showingAddSubItem) {
            TextField("选项内容", text: $newSubItemContent)
            Button("取消", role: .cancel) {
                newSubItemContent = ""
            }
            Button("添加") {
                viewModel.addSubItem(to: item, content: newSubItemContent)
                item.subitems.append(SubItem(content: newSubItemContent))
                newSubItemContent = ""
            }
        }
        .sheet(isPresented: $showingBatchAddSubItems) {
            VStack(alignment: .leading) {
                Text("批量添加选项 每行一个")
                    .font(.headline)
                    .padding(.bottom)

               
                   TextEditor(text: $batchSubItemsContent)
                       .frame(minHeight: 200)
                       .padding(5)
                       .border(Color.gray.opacity(0.3), width: 1)

                HStack {
                    Button("取消", role: .cancel) {
                        batchSubItemsContent = ""
                        showingBatchAddSubItems = false
                    }
                    .padding()

                    Spacer()

                    Button("添加") {
                        let newContents = batchSubItemsContent.split(separator: "\n").map { String($0) }
                        for content in newContents {
                            let newSubItem = SubItem(content: content)
                            viewModel.addSubItem(to: item, content: content)
                            item.subitems.append(newSubItem)
                        }
                        batchSubItemsContent = ""
                        showingBatchAddSubItems = false
                    }
                    .padding()
                }
            }
            .padding()
        }
        
        
    }
}


struct CreateItemView: View {
    @ObservedObject var viewModel: ItemViewModel
    @Environment(\.dismiss) var dismiss
    @State private var newItem: Item
    @State private var showingAddSubItem = false
    @State private var newSubItemContent = ""
    @State private var editingSubItem: SubItem?
    @State private var showingBatchAddSubItems = false

    @State private var batchSubItemsContent = ""

    
    init(viewModel: ItemViewModel) {
        self.viewModel = viewModel
        // 初始化一个空的新项目
        _newItem = State(initialValue: Item(title: "", subitems: []))
    }
    
    func saveTitleToUserDefaults(title: String) {
        UserDefaults.standard.set(title, forKey: "selectedTitle")
        print("Title saved: \(title)")
    }
    
    var body: some View {
        List {
            Section(header: Text("问题")) {
                TextField("问题", text: $newItem.title)
                    .onChange(of: newItem.title) { _ in
                        saveTitleToUserDefaults(title: newItem.title)
                    }
            }
            
            Section(header: Text("选项   (左滑删除)")) {
                ForEach(newItem.subitems) { subItem in
                    if editingSubItem?.id == subItem.id {
                        TextField("内容", text: Binding(
                            get: { subItem.content },
                            set: { newValue in
                                if let index = newItem.subitems.firstIndex(where: { $0.id == subItem.id }) {
                                    newItem.subitems[index].content = newValue
                                }
                            }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text(subItem.content)
                            .onTapGesture {
                                editingSubItem = subItem
                            }
                    }
                }
                .onDelete { indexSet in
                    newItem.subitems.remove(atOffsets: indexSet)
                }
            }
            
            Button("添加新选项") {
                showingAddSubItem = true
            }
            
            Button("批量添加") {
                showingBatchAddSubItems = true
            }
        }
        .navigationTitle("新建")
        .navigationBarItems(
            trailing: Button("保存") {
                // 确保标题不为空
                if !newItem.title.isEmpty {
                    // 将新项目添加到 ViewModel 中
                    var items = viewModel.items
//                    items.append(newItem)
//                    viewModel.updateItem(items)
                    viewModel.updateAllItems([newItem])
                    dismiss()
                }
            }
        )
        .alert("添加新选项", isPresented: $showingAddSubItem) {
            TextField("选项内容", text: $newSubItemContent)
            Button("取消", role: .cancel) {
                newSubItemContent = ""
            }
            Button("添加") {
                if !newSubItemContent.isEmpty {
                    newItem.subitems.append(SubItem(content: newSubItemContent))
                    newSubItemContent = ""
                }
            }
        } .sheet(isPresented: $showingBatchAddSubItems) {
            VStack(alignment: .leading) {
                Text("批量添加选项 每行一个")
                    .font(.headline)
                    .padding(.bottom)

               
                   TextEditor(text: $batchSubItemsContent)
                       .frame(minHeight: 200)
                       .padding(5)
                       .border(Color.gray.opacity(0.3), width: 1)

                HStack {
                    Button("取消", role: .cancel) {
                        batchSubItemsContent = ""
                        showingBatchAddSubItems = false
                    }
                    .padding()

                    Spacer()

                    Button("添加") {
                        // 将用户输入的内容按行分割为数组
                        let newContents = batchSubItemsContent
                            .split(separator: "\n") // 以换行符为分隔符
                            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } // 去除每行前后的空格

                        // 过滤掉空行并创建 SubItem，添加到 newItem.subitems 中
                        for content in newContents where !content.isEmpty {
                            let newSubItem = SubItem(content: content)
                            newItem.subitems.append(newSubItem)
                        }

                        // 清空输入框并关闭批量添加弹窗
                        batchSubItemsContent = ""
                        showingBatchAddSubItems = false
                    }
                }
            }
            .padding()
        }
    }
}

// 1. 创建语言工具类
class LanguageManager {
    static let shared = LanguageManager()
    
    // 获取当前语言代码
    var currentLanguage: String {
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        return languageCode
    }
    
    // 检查是否是中文
    var isChinese: Bool {
        return currentLanguage.starts(with: "zh")
    }
    
    // 根据语言获取值
    func getValue<T>(chinese: T, english: T) -> T {
        return isChinese ? chinese : english
    }
}

// 2. 创建环境值来存储当前语言
struct CurrentLanguageKey: EnvironmentKey {
    static let defaultValue: String = Locale.current.language.languageCode?.identifier ?? "en"
}

extension EnvironmentValues {
    var currentLanguage: String {
        get { self[CurrentLanguageKey.self] }
        set { self[CurrentLanguageKey.self] = newValue }
    }
}
