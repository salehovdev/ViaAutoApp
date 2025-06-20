//
//  NewPostView.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 21.06.25.
//

import SwiftUI
import PhotosUI
import FirebaseAuth

struct NewPostView: View {
    
    let brands = Bundle.main.decodeBrand("carmodels.json")
    let cities = Bundle.main.decodeCity("italiancities.json")
    
    let fuelType = [
            "Petrol",
            "Diesel",
            "Hybrid",
            "Electric",
            "LPG",
            "CNG",
            "Plug-in Hybrid",
            "Mild Hybrid",
            "Hydrogen",
            "Flex Fuel"
    ]
    
    let carColors = [
        "Black",
        "White",
        "Gray",
        "Silver",
        "Blue",
        "Red",
        "Green",
        "Beige",
        "Brown",
        "Yellow",
        "Gold",
        "Orange",
        "Purple",
        "Maroon",
        "Bronze"
    ]
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [Image] = []
    @State private var imageDataArray: [Data] = []
    
    @State private var selectedBrand: String?
    @State private var selectedModel: String?
    @State private var showBrandModelPicker = false
    
    @State private var isKeyboardVisible = false
    
    @State private var priceText: String = ""
    @State private var mileText: String = ""
    @State private var motorText: Double? = nil
    @State private var noteText: String = ""
    @State private var yearSelection: Int = 2025
    @State private var citySelection: CityModel? = nil
    @State private var colorSelection: String = ""
    @State private var fuelSelection: String = ""
    
    @State private var showSuccessAlert = false
    
    var isFormComplete: Bool {
        selectedBrand != nil &&
        !priceText.isEmpty &&
        !mileText.isEmpty &&
        motorText != nil &&
        citySelection != nil &&
        !fuelSelection.isEmpty &&
        !colorSelection.isEmpty &&
        !imageDataArray.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 20) {
                        brandSection
                        
                        textFieldSection
                        
                        pickerSection
                        
                        photosSection
                        
                        noteSection
                        
                        Spacer()
                    }
                    .hideKeyboardOnTap()
                }
                .alert("Post Shared", isPresented: $showSuccessAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Your car post was successfully shared.")
                }
                
                if !isKeyboardVisible {
                    Button {
                        uploadNewPost()
                    } label: {
                        Text("Share new post")
                            .font(.headline)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(isFormComplete ? .blue : .gray)
                            .clipShape(.capsule)
                    }
                    .disabled(!isFormComplete)
                    .padding(.top)
                }
            }
            .observeKeyboard($isKeyboardVisible)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("New Post")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        selectedBrand = nil
                        selectedModel = nil
                        priceText = ""
                        mileText = ""
                        noteText = ""
                        motorText = nil
                        yearSelection = 2025
                        citySelection = nil
                        colorSelection = ""
                        fuelSelection = ""
                    } label: {
                        Text("Reset")
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }
    
    func loadPhotos(from items: [PhotosPickerItem]) {
        Task {
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    let image = Image(uiImage: uiImage)
                    selectedImages.append(image)
                    imageDataArray.append(data)
                }
            }
            selectedItems = []
        }
    }
    
    func deleteImage(at index: Int) {
        guard selectedImages.indices.contains(index) else { return }
        selectedImages.remove(at: index)
        imageDataArray.remove(at: index)
    }
    
    func uploadNewPost() {
        guard let user = Auth.auth().currentUser else { return }
        
        let newPostId = UUID().uuidString
        
        Task {
            do {
                var imagePaths: [String] = []
                for imageData in imageDataArray {
                    let result = try await StorageManager.shared.savePostImageToFirebase(data: imageData, userId: user.uid, postId: newPostId)
                    imagePaths.append(result.path)
                }
                
                let post = CarPostModel(
                    id: newPostId,
                    userId: user.uid,
                    brandModel: selectedModel != nil ? "\(selectedBrand ?? "") \(selectedModel!)" : (selectedBrand ?? ""),
                    price: priceText,
                    mileage: mileText,
                    motor: String(motorText ?? 0),
                    city: citySelection?.city ?? "",
                    fuel: fuelSelection,
                    color: colorSelection,
                    year: yearSelection,
                    images: imagePaths,
                    notes: noteText,
                    date: Date()
                )
                
                try await PostManager.shared.uploadPost(post: post)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    showSuccessAlert = true
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    NewPostView()
}

extension NewPostView {
    private var brandSection: some View {
        VStack {
            HStack {
                Text("Brands and Models*")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            GridStack(rows: 3, colomns: 4) { row, col in
                let index = row * 4 + col
                if index < brands.count {
                    let brand = brands[index]
                    
                    BrandLogoView(image: brand.brand)
                        .background(
                            Circle()
                                .stroke(
                                    selectedBrand == brand.brand ? Color.green : .clear, lineWidth: 2
                                )
                        )
                } else {
                    Spacer()
                }
            }
            .padding(.top, 7)
            
            if let brand = selectedBrand, let model = selectedModel {
                HStack {
                    if model == "All" {
                        Text("Selected: \(brand)")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    } else {
                        Text("Selected: \(brand) \(model)")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                    Spacer()
                    Button(role: .destructive) {
                        selectedBrand = nil
                        selectedModel = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
                .padding(.top, 8)
            }
            
            Button {
                showBrandModelPicker = true
            } label: {
                Text("Show all")
                    .font(.headline)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(.red)
                    .clipShape(.capsule)
            }
            .padding(.top)
            .sheet(isPresented: $showBrandModelPicker) {
                BrandModelList(
                    selectedBrand: $selectedBrand,
                    selectedModel: $selectedModel,
                    isPresented: $showBrandModelPicker
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.gray, lineWidth: 0.5)
        }
    }
    
    private var textFieldSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Price*")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            TextField("Ex: 15000 €", text: $priceText)
                .padding()
                .background(.gray.opacity(0.2))
                .clipShape(.rect(cornerRadius: 20))
                .keyboardType(.decimalPad)
            
            HStack {
                Text("Mileage*")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.top)
            
            TextField("Ex: 100000 km", text: $mileText)
                .padding()
                .background(.gray.opacity(0.2))
                .clipShape(.rect(cornerRadius: 20))
                .keyboardType(.decimalPad)
            
            HStack {
                Text("Motor*")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.top)
            
            TextField("Ex: 2.0 L", value: $motorText, format: .number)
                .padding()
                .background(.gray.opacity(0.2))
                .clipShape(.rect(cornerRadius: 20))
                .keyboardType(.decimalPad)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.gray, lineWidth: 0.5)
        }
    }
    
    private var pickerSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("City*")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            Picker("Select a city", selection: $citySelection) {
                ForEach(cities, id: \.self) { city in
                    Text(city.city)
                        .tag(city as CityModel?)
                }
                .padding(.horizontal)
            }
            .pickerStyle(.navigationLink)
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 20))
            
            HStack {
                Text("Fuel*")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.top)
            
            Picker("Select fuel type", selection: $fuelSelection) {
                ForEach(fuelType, id: \.self) { fuel in
                    Text(fuel)
                        .tag(fuel)
                }
                .padding(.horizontal)
            }
            .pickerStyle(.navigationLink)
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 20))
            
            HStack {
                Text("Color*")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.top)
            
            Picker("Select color", selection: $colorSelection) {
                ForEach(carColors, id: \.self) { color in
                    Text(color)
                        .tag(color)
                }
                .padding(.horizontal)
            }
            .pickerStyle(.navigationLink)
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 20))
            
            HStack {
                Text("Year*")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.top)
            
            Picker("Select year", selection: $yearSelection) {
                ForEach((1965...2025).reversed(), id: \.self) { year in
                    Text(String(year)).tag(year)
                }
                .padding(.horizontal)
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 20))
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.gray, lineWidth: 0.5)
        }
    }
    
    private var noteSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Notes")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            TextEditor(text: $noteText)
                .frame(height: 150)
                .clipShape(.rect(cornerRadius: 20))
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.gray, lineWidth: 0.5)
        }
    }
    
    private var photosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Photos*")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                        ZStack(alignment: .topTrailing) {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 90)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .clipped()

                            Button {
                                deleteImage(at: index)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white)
                                    .background(Circle().fill(Color.black.opacity(0.6)))
                                    .font(.system(size: 18))
                                    .padding(6)
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            
            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 10,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Label("Add Photos", systemImage: "photo.badge.plus")
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .onChange(of: selectedItems) { newItems in
                loadPhotos(from: newItems)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.gray, lineWidth: 0.5)
        }
    }
}
