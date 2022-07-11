//
//  ContentView.swift
//  EditModeMac
//
//  Created by Kamaal M Farah on 11/07/2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            EditButton()
            ChildView()
        }
        .frame(minWidth: 300, minHeight: 300)
        .withEditMode()
    }
}

struct ChildView: View {
    @Environment(\.editMode) var editMode

    var body: some View {
        Text("I'm \(editMode.isEditing ? "editing" : "not editing")")
    }
}

enum EditMode {
    case active
    case inactive

    var isEditing: Bool {
        self == .active
    }
}

extension EnvironmentValues {
    var editMode: EditMode {
        get { self[EditModeKey.self] }
        set { self[EditModeKey.self] = newValue }
    }
}

extension View {
    func withEditMode() -> some View {
        self
            .modifier(EditModeViewModifier())
    }
}

private struct EditModeViewModifier: ViewModifier {
    @State private var editMode: EditMode = .inactive

    func body(content: Content) -> some View {
        content
            .environment(\.editMode, editMode)
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name(rawValue: "change_edit_mode")), perform: { output in
                guard let newEditMode = output.object as? EditMode, newEditMode != editMode else { return }
                editMode = newEditMode
            })
    }
}

private struct EditModeKey: EnvironmentKey {
    static let defaultValue: EditMode = .inactive
}

struct EditButton: View {
    @Environment(\.editMode) var editMode

    init() { }

    var body: some View {
        Button(action: {
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "change_edit_mode"),
                object: editMode.isEditing ? EditMode.inactive : EditMode.active,
                userInfo: nil)
        }) {
            Text(editMode.isEditing ? "Done" : "Edit")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
