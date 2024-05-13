//
//  ContentView.swift
//  StringsConverter
//
//  Created by liao on 2024/4/30.
//

import SwiftUI

struct ContentView: View {
    
    @State private var isTarget: Bool = false
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(isTarget ? Color.green : Color.gray)
                .frame(width: 150,height: 150)
            Text("Drop the xslx or xml file here")
        }
        .padding().onDrop(of: [.spreadsheet,.xml], isTargeted: $isTarget, perform: { providers in
            
            guard let provider = providers.first else { return false }
                        
            let _ = provider.loadFileRepresentation(for: .spreadsheet) { url, isOk, error in
                if let url = url {
                    debugPrint(url)
                    XSLXManager.analysisXSLXFile(at: url.path)
                }
            }
            
            let _ = provider.loadFileRepresentation(for: .xml) { url, isOk, error in
                if let url = url {
                    debugPrint(url)
                    XMLManager.analysisXMLFile(at: url.path)
                }
            }
            
            return true
        })
    }
}

#Preview {
    ContentView()
}
