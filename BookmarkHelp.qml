import QtQuick
import qs.Commons
import qs.Ui

Rectangle {
  id: root

  property int textLeft: 0
  property color foreground: Color.menu.text
  property string fontFamily: Style.font.menuFamily

  readonly property var shortcuts: [
    { action: "filter by name or url", keys: "type" },
    { action: "move", keys: "↑ ↓" },
    { action: "open in the browser", keys: "⏎" },
    { action: "open one of the first nine", keys: "alt+1…9" },
    { action: "save a new bookmark", keys: "ctrl+⏎" },
    { action: "edit the selected one", keys: "ctrl+e" },
    { action: "copy its url", keys: "alt+c" },
    { action: "delete it", keys: "supr · shift+backspace" },
    { action: "storage", keys: "ctrl+," },
    { action: "clear the filter, then close", keys: "esc" }
  ]

  height: rows.implicitHeight + Style.spacing.panelPadding * 2
  color: Color.menu.selectedBackground

  Rectangle {
    anchors.bottom: parent.bottom
    width: parent.width
    height: Math.max(1, Style.space(1))
    color: Color.menu.border
    opacity: 0.5
  }

  Column {
    id: rows
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.topMargin: Style.spacing.panelPadding
    anchors.leftMargin: root.textLeft
    anchors.rightMargin: root.textLeft
    spacing: Style.spacing.md

  Text {
    textFormat: Text.PlainText
    text: "SHORTCUTS"
    font.letterSpacing: 1
    color: Color.menu.selectedText
    font.family: root.fontFamily
    font.pixelSize: Style.font.bodySmall
  }

  Repeater {
    model: root.shortcuts

    Item {
      required property var modelData

      width: rows.width
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
}
