import SwiftUI
import OpenAISwift

struct AuthenticationView: View {
   @State var country = "CA"
    @State var language = "en"

    var body: some View {
        VStack{
            HStack{
                Picker("Select a country", selection:$country){
                    ForEach(NSLocale.isoCountryCodes,id:\.self){
                        countryCode in Text(Locale.current.localizedString(forRegionCode: countryCode) ?? "")
                    }
                }
                .tint(.black)
                .fontWeight(.semibold)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 2)
                )
            }
            .padding()
            HStack{
                Picker("Select a language", selection:$language){
                    ForEach(NSLocale.isoLanguageCodes,id:\.self){
                        countryCode in Text(Locale.current.localizedString(forLanguageCode: countryCode) ?? "")
                    }
                }
                .tint(.black)
                .fontWeight(.semibold)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 2)
                )
            }
        }
    }
}

#Preview{
    AuthenticationView()
}
