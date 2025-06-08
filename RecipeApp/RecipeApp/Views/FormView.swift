import SwiftUI
import PDFKit

struct GovernmentForm: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let iconName: String
    let pdfFilename: String // just the name, no ".pdf"
}

// The raw (untranslated) form data
let rawForms: [GovernmentForm] = [
    GovernmentForm(
        name: "SIN Application",
        description: "Application for a Social Insurance Number (NAS-2120).",
        iconName: "person.text.rectangle",
        pdfFilename: "SINApplication"
    ),
    GovernmentForm(
        name: "PPTC 153",
        description: "Child General Passport Application.",
        iconName: "doc.text",
        pdfFilename: "PPTC153"
    ),
    GovernmentForm(
        name: "PPTC 155",
        description: "Statutory Declaration in Lieu of Guarantor.",
        iconName: "doc.richtext",
        pdfFilename: "PPTC155"
    ),
    GovernmentForm(
        name: "OHIP Registration Form",
        description: "Ontario Health Insurance Plan (OHIP) Registration (0265-08243E).",
        iconName: "heart.text.square",
        pdfFilename: "OHIPRegistration"
    ),
    GovernmentForm(
        name: "IMM 5009E",
        description: "Application for a Verification of Status or Replacement of an Immigration Document.",
        iconName: "person.crop.square.filled.and.at.rectangle",
        pdfFilename: "IMM5009E"
    )
]

struct FormView: View {
    @EnvironmentObject var appSettings: AppSettings

    @State private var searchText = ""
    @State private var showingFormDetail: GovernmentForm? = nil

    // Translatable UI strings
    @State private var popularFormsTitle = "Popular Forms"
    @State private var allFormsTitle = "All Forms"
    @State private var searchPrompt = "Search forms"
    @State private var addFormNavTitle = "Add Form"

    // The translated forms array
    @State private var translatedForms: [GovernmentForm] = []

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text(popularFormsTitle)
                    .font(.title)
                    .bold()
                    .padding([.leading, .top])

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(translatedForms) { form in
                            Button {
                                showingFormDetail = form
                            } label: {
                                VStack(spacing: 10) {
                                    Image(systemName: form.iconName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color("ColorBlue"))
                                        .clipShape(Circle())
                                    Text(form.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(width: 140, height: 140)
                                .background(Color("ColorLightGray"))
                                .cornerRadius(20)
                                .shadow(radius: 1)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                Text(allFormsTitle)
                    .font(.title2)
                    .bold()
                    .padding(.leading)
                    .padding(.top, 8)

                List(filteredForms) { form in
                    Button {
                        showingFormDetail = form
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: form.iconName)
                                .foregroundColor(Color("ColorBlue"))
                                .frame(width: 30, height: 30)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(form.name)
                                    .font(.headline)
                                Text(form.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                .listStyle(PlainListStyle())
                .searchable(text: $searchText, prompt: searchPrompt)
            }
            .navigationTitle(addFormNavTitle)
            .background(Color("ColorLightGray").ignoresSafeArea())
            .sheet(item: $showingFormDetail) { form in
                FormDetailView(form: form)
                    .environmentObject(appSettings)
            }
        }
        .task {
            await updateTranslations()
        }
        .onChange(of: appSettings.selectedLanguage) { _ in
            Task { await updateTranslations() }
        }
    }

    var filteredForms: [GovernmentForm] {
        if searchText.isEmpty {
            return translatedForms
        }
        return translatedForms.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    // Fetch translations for UI strings AND for each form's name/description
    func updateTranslations() async {
        popularFormsTitle = await TranslationTool(text: "Popular Forms", targetLanguage: appSettings.selectedLanguage)
        allFormsTitle = await TranslationTool(text: "All Forms", targetLanguage: appSettings.selectedLanguage)
        searchPrompt = await TranslationTool(text: "Search forms", targetLanguage: appSettings.selectedLanguage)
        addFormNavTitle = await TranslationTool(text: "Add Form", targetLanguage: appSettings.selectedLanguage)

        // Translate form names and descriptions
        var result: [GovernmentForm] = []
        for form in rawForms {
            async let translatedName = TranslationTool(text: form.name, targetLanguage: appSettings.selectedLanguage)
            async let translatedDesc = TranslationTool(text: form.description, targetLanguage: appSettings.selectedLanguage)
            let name = await translatedName
            let desc = await translatedDesc
            result.append(
                GovernmentForm(
                    name: name,
                    description: desc,
                    iconName: form.iconName,
                    pdfFilename: form.pdfFilename
                )
            )
        }
        translatedForms = result
    }
}

// MARK: PDFKitView
struct PDFKitView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = .white
        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
        pdfView.document = PDFDocument(url: url)
    }
}

// MARK: FormDetailView
struct FormDetailView: View {
    @EnvironmentObject var appSettings: AppSettings

    let form: GovernmentForm
    @State private var showPDF = false
    @State private var pdfURL: URL? = nil

    // Translatable UI strings
    @State private var viewPDFText = "View PDF"
    @State private var pdfNotAvailableText = "PDF not available for this form."

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: form.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .foregroundColor(Color("ColorBlue"))
                .padding(.top, 40)
            Text(form.name)
                .font(.title)
                .bold()
            Text(form.description)
                .font(.body)
                .padding(.horizontal)

            if let url = Bundle.main.url(forResource: form.pdfFilename, withExtension: "pdf") {
                Button(action: {
                    pdfURL = url
                    showPDF = true
                }) {
                    HStack {
                        Image(systemName: "doc.richtext")
                        Text(viewPDFText)
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color("ColorBlue"))
                    .cornerRadius(12)
                }
                .sheet(isPresented: $showPDF) {
                    if let url = pdfURL {
                        PDFOptionsView(pdfURL: url)
                    }
                }
            } else {
                Text(pdfNotAvailableText)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .task {
            viewPDFText = await TranslationTool(text: "View PDF", targetLanguage: appSettings.selectedLanguage)
            pdfNotAvailableText = await TranslationTool(text: "PDF not available for this form.", targetLanguage: appSettings.selectedLanguage)
        }
        .onChange(of: appSettings.selectedLanguage) { _ in
            Task {
                viewPDFText = await TranslationTool(text: "View PDF", targetLanguage: appSettings.selectedLanguage)
                pdfNotAvailableText = await TranslationTool(text: "PDF not available for this form.", targetLanguage: appSettings.selectedLanguage)
            }
        }
    }
}

// MARK: PDFOptionsView
struct PDFOptionsView: View {
    let pdfURL: URL
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .padding()
                }
                Spacer()
                ShareLink(item: pdfURL) {
                    Label("Share or Save", systemImage: "square.and.arrow.up")
                        .padding()
                }
            }
            .background(Color(.systemBackground).opacity(0.96))
            PDFKitView(url: pdfURL)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

#Preview {
    FormView()
        .environmentObject(AppSettings())
}
