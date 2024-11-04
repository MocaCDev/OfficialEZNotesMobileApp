//
//  MessagesModel.swift
//  EZNotes-2
//
//  Created by Aidan White on 10/28/24.
//
import SwiftUI

struct MessageDetails: Hashable, Encodable, Decodable {
    let MessageID: UUID
    let MessageContent: String
    let userSent: Bool
    let dateSent: Date
}

struct MessageView: View {
    var message: MessageDetails
    
    @Binding public var aiIsTyping: Bool
    
    var body: some View {
        VStack {
            if !message.userSent {
                VStack {
                    VStack {
                        HStack {
                            Image("AI-Chat")//systemName: "sparkle")
                                .resizableImage(width: 20, height: 20)
                            
                            Text(message.MessageContent)
                                .frame(minWidth: 20,  alignment: .leading)
                                .foregroundStyle(.black)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(.white.opacity(0.85))
                                )
                            /*.background(
                             RoundedRectangle(cornerRadius: 10)
                             .fill(MeshGradient(width: 3, height: 3, points: [
                             .init(0, 0), .init(0.3, 0), .init(1, 0),
                             .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
                             .init(0, 1), .init(0.5, 1), .init(1, 1)
                             ], colors: [
                             Color.EZNotesOrange, Color.EZNotesOrange, Color.EZNotesBlue,
                             Color.EZNotesBlue, Color.EZNotesBlue, Color.EZNotesGreen,
                             Color.EZNotesOrange, Color.EZNotesGreen, Color.EZNotesBlue
                             /*Color.EZNotesBlue, .indigo, Color.EZNotesOrange,
                              Color.EZNotesOrange, .mint, Color.EZNotesBlue,
                              Color.EZNotesBlack, Color.EZNotesBlack, Color.EZNotesBlack*/
                             ])).overlay(Color.EZNotesBlack.opacity(0.4))//(Color.EZNotesLightBlack)
                             )*/
                                .font(.system(size: 13))
                                .minimumScaleFactor(0.5)
                                .multilineTextAlignment(.leading)
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: 340, alignment: .leading)
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 15)
            } else {
                VStack {
                    VStack {
                        Text(message.MessageContent)
                            .frame(minWidth: 10, alignment: .trailing)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.EZNotesBlue)
                            )
                            .font(.system(size: 13))
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.leading)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: 340, alignment: .trailing)
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                .padding(.bottom, 15)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
