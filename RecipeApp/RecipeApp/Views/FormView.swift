import SwiftUI
import PDFKit

struct GovernmentForm: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let iconName: String
    let pdfFilename: String // just the name, no ".pdf"
}

let rawForms: [GovernmentForm] = [
    GovernmentForm(
        name: "SIN Application",
        description: "Application for a Social Insurance Number (NAS-2120).",
        iconName: "person.text.rectangle",
        pdfFilename: "SINApplication"
    ),
    GovernmentForm(
        name: "PPTC 153",
        description: "Adult General Passport Application.",
        iconName: "doc.text",
        pdfFilename: "PPTC153"
    ),
    GovernmentForm(
        name: "PPTC 155",
        description: "Child General Passport Application.",
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

    // Sheet states for PDF presentation
    @State private var showingPDF: Bool = false
    @State private var selectedPDFUrl: URL? = nil
    @State private var selectedForm: GovernmentForm? = nil
    @State private var annotations: [PDFAnnotationGuide] = []

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
            // Present FormDetailView as a sheet
            .sheet(item: $showingFormDetail) { form in
                FormDetailView(form: form) { url in
                    showingFormDetail = nil
                    // After a brief delay, present the PDF sheet with annotations
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        selectedPDFUrl = url
                        selectedForm = form
                        Task {
                            // Load translated annotations for this form
                            annotations = await annotationGuides(for: form, language: appSettings.selectedLanguage)
                            showingPDF = true
                        }
                    }
                }
                .environmentObject(appSettings)
            }
            // Present PDFOptionsView from the parent
            .sheet(isPresented: $showingPDF) {
                if let url = selectedPDFUrl {
                    PDFOptionsView(pdfURL: url, annotations: annotations)
                }
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

// MARK: - PDF Annotation Overlay Data
struct PDFAnnotationGuide: Identifiable {
    let id = UUID()
    let page: Int
    let x: CGFloat    // 0.0 - 1.0 (relative horizontal position)
    let y: CGFloat    // 0.0 - 1.0 (relative vertical position)
    let text: String  // Explanation text (translated)
}

// Only add annotations to PPTC 153
func annotationGuides(for form: GovernmentForm, language: String) async -> [PDFAnnotationGuide] {
    guard form.pdfFilename == "PPTC153" else { return [] }
    // Example: These are sample annotations, adjust (page, x, y, text) for your needs.
    let annotation1 = PDFAnnotationGuide(
        page: 0,
        x: 0.25, y: 0.15,
        text: await TranslationTool(
            text: "This section is for the applicant's surname (last name).",
            targetLanguage: language
        )
    )
    let annotation2 = PDFAnnotationGuide(
        page: 0,
        x: 0.60, y: 0.38,
        text: await TranslationTool(
            text: "Place your signature in the box.",
            targetLanguage: language
        )
    )
    let annotation3 = PDFAnnotationGuide(
        page: 0,
        x: 0.45, y: 0.80,
        text: await TranslationTool(
            text: "Make sure to provide your date of birth in the format YYYY-MM-DD.",
            targetLanguage: language
        )
    )
    return [annotation1, annotation2, annotation3]
}

// MARK: PDFKitView (no annotation logic here; overlay is in parent)
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
        let doc = PDFDocument(url: url)
        pdfView.document = doc
    }
}

// MARK: FormDetailView
struct FormDetailView: View {
    @EnvironmentObject var appSettings: AppSettings

    let form: GovernmentForm
    var onViewPDF: ((URL) -> Void)?

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
                    onViewPDF?(url)
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

// MARK: PDFOptionsView with Annotation Overlay
struct PDFOptionsView: View {
    let pdfURL: URL
    var annotations: [PDFAnnotationGuide] = []
    @Environment(\.dismiss) private var dismiss

    @State private var showingPopover: PDFAnnotationGuide? = nil

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
            ZStack(alignment: .topLeading) {
                PDFKitView(url: pdfURL)
                    .edgesIgnoringSafeArea(.all)
                GeometryReader { geo in
                    ForEach(annotations) { ann in
                        // Only display annotations for the first page for now.
                        // If supporting multipage: check which page is visible in PDFView (advanced)
                        if ann.page == 0 {
                            Button(action: { showingPopover = ann }) {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.blue)
                                    .background(Color.white.opacity(0.9))
                                    .clipShape(Circle())
                            }
                            .position(
                                x: geo.size.width * ann.x,
                                y: geo.size.height * ann.y
                            )
                        }
                    }
                }
                .popover(item: $showingPopover) { ann in
                    Text(ann.text)
                        .padding()
                        .background(Color.yellow.opacity(0.9))
                        .cornerRadius(12)
                        .frame(maxWidth: 250)
                }
            }
        }
    }
}

#Preview {
    FormView()
        .environmentObject(AppSettings())
}
