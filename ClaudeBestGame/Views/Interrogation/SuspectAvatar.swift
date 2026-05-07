import SwiftUI

struct SuspectAvatar: View {
    let name: String
    let job: String
    let age: Int
    let persona: String

    private var personaColor: Color {
        switch persona {
        case "stoic": return .blue
        case "anxious": return .yellow
        case "aggressive": return .red
        case "pitiful": return .purple
        case "intellectual": return .teal
        default: return .gray
        }
    }

    private var personaIcon: String {
        switch persona {
        case "stoic": return "person.fill"
        case "anxious": return "person.fill.questionmark"
        case "aggressive": return "person.fill.xmark"
        case "pitiful": return "person.fill.badge.minus"
        case "intellectual": return "person.fill.checkmark"
        default: return "person.fill"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(personaColor.opacity(0.25))
                    .frame(width: 56, height: 56)
                Image(systemName: personaIcon)
                    .font(.title)
                    .foregroundStyle(personaColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.headline).foregroundStyle(.white)
                Text("\(age)歳・\(job)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}

#Preview {
    SuspectAvatar(name: "佐藤 健司", job: "経理部長", age: 42, persona: "stoic")
        .padding()
        .background(Color.black)
}
