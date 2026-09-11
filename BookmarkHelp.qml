import QtQuick
import qs.Commons

Column {
  id: root

  property color foreground: Color.menu.text
  property string fontFamily: Style.font.menuFamily

  readonly property var shortcuts: [
    { action: "filter by name or url", keys: "type" },
    { action: "move", keys: "↑ ↓" },
    { action: "open in the browser", keys: "⏎" },
    { action: "save a new bookmark", keys: "ctrl+⏎" },
    { action: "edit the selected one", keys: "ctrl+e" },
    { action: "copy its url", keys: "alt+c" },
    { action: "delete it", keys: "shift+del" },
    { action: "storage", keys: "ctrl+," },
    { action: "clear the filter, then close", keys: "esc" }
  ]

  spacing: Style.spacing.md

  Text {
    textFormat: Text.PlainText
    text: "shortcuts"
    color: root.foreground
    font.family: root.fontFamily
    font.pixelSize: Style.font.heading
  }

  Repeater {
    model: root.shortcuts

    Item {
      required property var modelData

      width: root.width
      height: action.height

      Text {
        id: action
        anchors.left: parent.left
        textFormat: Text.PlainText
        text: parent.modelData.action
        color: root.foreground
        opacity: 0.7
        font.family: root.fontFamily
        font.pixelSize: Style.font.subtitle
      }

      Text {
        anchors.right: parent.right
        anchors.baseline: action.baseline
        textFormat: Text.PlainText
        text: parent.modelData.keys
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.subtitle
      }
    }
  }
}
