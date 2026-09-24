import SwiftUI
import AppKit

// MARK: - UI strings (app language: German / English)
struct Strings {
    let lang: String
    var isDE: Bool { lang == "Deutsch" }

    var title: String            { isDE ? "Korrektur" : "Proofreader" }
    var inputPlaceholder: String { isDE ? "Text eingeben…" : "Enter text…" }
    var correct: String          { isDE ? "Korrigieren" : "Correct" }
    var outputPlaceholder: String{ isDE ? "Korrigierter Text erscheint hier"
                                        : "Corrected text appears here" }
    var copy: String             { isDE ? "Kopieren" : "Copy" }
    var copied: String           { isDE ? "Kopiert!" : "Copied!" }
    var quit: String             { isDE ? "Beenden" : "Quit" }
    var screenshotHelp: String   { isDE ? "Text aus einem Screenshot korrigieren"
                                        : "Correct text from a screenshot" }
    var needKey: String          { isDE ? "Bitte zuerst den Gemini-Key in den Einstellungen eintragen (⌘,)."
                                        : "Please add your Gemini key in Settings first (⌘,)." }

    var settings: String         { isDE ? "Einstellungen" : "Settings" }
    var language: String         { isDE ? "App-Sprache" : "App language" }
    var apiKeyLabel: String      { isDE ? "Gemini API-Key" : "Gemini API key" }
    var apiKeyPlaceholder: String{ isDE ? "Key hier einfügen" : "Paste key here" }
    var apiKeyHint: String       { isDE ? "Kostenlos erstellbar auf aistudio.google.com/apikey"
                                        : "Create one for free at aistudio.google.com/apikey" }
}

// MARK: - Hover style for the small icon buttons
struct HoverIconStyle: ButtonStyle {
    @State private var hover = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(hover ? Color.gray.opacity(0.18) : .clear,
                        in: RoundedRectangle(cornerRadius: 7))
            .contentShape(Rectangle())
            .onHover { hover = $0 }
            .animation(.easeInOut(duration: 0.12), value: hover)
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

// MARK: - Main window
struct ContentView: View {
    @AppStorage("geminiKey") private var apiKey = ""
    @AppStorage("appLang")   private var appLang = "English"

    @State private var inputText  = ""
    @State private var outputText = ""
    @State private var isLoading  = false
    @State private var didCopy    = false

    var body: some View {
        let s = Strings(lang: appLang)

        VStack(spacing: 14) {

            // Header: title + settings
            HStack(spacing: 8) {
                Image(systemName: "checkmark.bubble.fill").foregroundStyle(.blue)
                Text(s.title).font(.headline)
                Spacer()
                if isLoading { ProgressView().controlSize(.small) }
                SettingsLink {
                    Image(systemName: "gearshape").font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(HoverIconStyle())
            }

            inputCard(s)

            // Correct + screenshot
            HStack(spacing: 8) {
                Button(action: correct) {
                    Text(s.correct).fontWeight(.medium)
                        .frame(maxWidth: .infinity).padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .disabled(inputText.isEmpty)

                Button { captureAndCorrect() } label: {
                    Image(systemName: "text.viewfinder").font(.system(size: 15))
                        .padding(.vertical, 6).padding(.horizontal, 4)
                }
                .buttonStyle(.bordered)
                .help(s.screenshotHelp)
            }

            outputCard(s)

            Divider().opacity(0.5)

            // Footer: copy + quit
            HStack {
                Button {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(outputText, forType: .string)
                    didCopy = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { didCopy = false }
                } label: {
                    Label(didCopy ? s.copied : s.copy,
                          systemImage: didCopy ? "checkmark" : "doc.on.doc")
                        .foregroundStyle(didCopy ? .green : .primary)
                }
                .buttonStyle(HoverIconStyle())
                .disabled(outputText.isEmpty)

                Spacer()

                Button { NSApp.terminate(nil) } label: {
                    Label(s.quit, systemImage: "power").foregroundStyle(.secondary)
                }
                .buttonStyle(HoverIconStyle())
            }
            .font(.callout)
        }
        .padding(16)
        .frame(width: 380)
    }

    // MARK: - Cards (input / output)
    func inputCard(_ s: Strings) -> some View {
        ZStack(alignment: .topLeading) {
            if inputText.isEmpty {
                Text(s.inputPlaceholder).foregroundStyle(.tertiary)
                    .padding(.horizontal, 10).padding(.vertical, 10)
                    .allowsHitTesting(false)
            }
            TextEditor(text: $inputText)
                .font(.body).scrollContentBackground(.hidden).padding(6)
        }
        .frame(height: 100)
        .background(Color(nsColor: .textBackgroundColor).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.25), lineWidth: 1))
    }

    func outputCard(_ s: Strings) -> some View {
        ScrollView {
            HStack {
                Text(outputText.isEmpty ? s.outputPlaceholder : outputText)
                    .foregroundStyle(outputText.isEmpty ? .tertiary : .primary)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer(minLength: 0)
            }
            .padding(10)
        }
        .frame(height: 100)
        .background(Color.blue.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue.opacity(0.15), lineWidth: 1))
    }

    // MARK: - Correct (triggered only by the button)
    func correct() {
        guard !inputText.isEmpty else { return }
        correctWithGemini(imageBase64: nil)
    }

    // MARK: - Screenshot -> recognize text + correct
    func captureAndCorrect() {
        let path = NSTemporaryDirectory() + "proofread_shot.png"
        try? FileManager.default.removeItem(atPath: path)
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-i", path]     // interactive region selection
        task.terminationHandler = { _ in
            guard FileManager.default.fileExists(atPath: path),
                  let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
                  !data.isEmpty else { return }
            let base64 = data.base64EncodedString()
            DispatchQueue.main.async { self.correctWithGemini(imageBase64: base64) }
        }
        do { try task.run() }
        catch {
            DispatchQueue.main.async { self.outputText = "Screenshot error: \(error.localizedDescription)" }
        }
    }

    // MARK: - Gemini request
    func correctWithGemini(imageBase64: String?) {
        let s = Strings(lang: appLang)
        guard !apiKey.isEmpty else { outputText = s.needKey; return }

        isLoading = true
        let model = "gemini-3.6-flash"
        var comps = URLComponents(string:
            "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent")!
        comps.queryItems = [URLQueryItem(name: "key", value: apiKey)]

        var req = URLRequest(url: comps.url!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Build the request body. Text-only vs. image are two different prompts.
        var parts: [[String: Any]] = []
        if let img = imageBase64 {
            parts.append(["text": """
            Recognize the text in this image and correct its grammar, spelling, \
            and punctuation. Detect the language (German or English) automatically \
            and reply in the same language. Do not change the style or meaning. \
            Return only the corrected text — no explanations, no quotation marks.
            """])
            parts.append(["inline_data": ["mime_type": "image/png", "data": img]])
        } else {
            parts.append(["text": """
            You are a proofreader. Correct the following text's grammar, spelling, \
            and punctuation. Detect the language (German or English) automatically \
            and reply in the same language. Do not change the style or meaning. \
            Return only the corrected text — no explanations, no quotation marks.

            \(inputText)
            """])
        }

        req.httpBody = try? JSONSerialization.data(withJSONObject: ["contents": [["parts": parts]]])

        URLSession.shared.dataTask(with: req) { data, response, error in
            defer { DispatchQueue.main.async { isLoading = false } }
            if let error {
                DispatchQueue.main.async { outputText = "Network: \(error.localizedDescription)" }; return
            }
            guard let data else { DispatchQueue.main.async { outputText = "No response" }; return }
            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                let body = String(data: data, encoding: .utf8) ?? ""
                DispatchQueue.main.async { outputText = "HTTP \(http.statusCode): \(body)" }; return
            }
            guard let res = try? JSONDecoder().decode(GeminiResponse.self, from: data),
                  let text = res.candidates.first?.content.parts.first?.text else {
                DispatchQueue.main.async { outputText = "Could not parse response" }; return
            }
            DispatchQueue.main.async {
                outputText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }.resume()
    }
}

// MARK: - Settings (app language + API key)
struct SettingsView: View {
    @AppStorage("geminiKey") private var apiKey = ""
    @AppStorage("appLang")   private var appLang = "English"

    @Environment(\.dismiss) private var dismiss
    @State private var saved = false

    var body: some View {
        let s = Strings(lang: appLang)
        VStack(spacing: 0) {
            Form {
                Section {
                    Picker(s.language, selection: $appLang) {
                        Text("English").tag("English")
                        Text("Deutsch").tag("Deutsch")
                    }
                }
                Section(s.apiKeyLabel) {
                    SecureField(s.apiKeyPlaceholder, text: $apiKey)
                    Text(s.apiKeyHint).font(.caption).foregroundStyle(.secondary)
                }
            }
            .formStyle(.grouped)

            Divider()

            HStack {
                if saved {
                    Label(s.isDE ? "Gespeichert" : "Saved", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.callout)
                }
                Spacer()
                Button(s.isDE ? "Sichern & Schließen" : "Save & Close") {
                    saved = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { dismiss() }
                }
                .keyboardShortcut(.defaultAction)   // Enter triggers this button
                .buttonStyle(.borderedProminent)
            }
            .padding(12)
        }
        .frame(width: 430, height: 290)
    }
}

// MARK: - Gemini response model
struct GeminiResponse: Codable {
    let candidates: [Candidate]
    struct Candidate: Codable { let content: Content }
    struct Content: Codable { let parts: [Part] }
    struct Part: Codable { let text: String }
}
