import QtQuick
import qs.Commons
import qs.Ui

Rectangle {
  id: root

  property int textLeft: 0
  property string defaultPath: ""
  property alias pathText: pathField.text
  property color foreground: Color.menu.text
  property string fontFamily: Style.font.menuFamily

  signal accepted()
  signal canceled()

  height: box.implicitHeight + Style.spacing.panelPadding * 2
  color: Color.menu.selectedBackground

  onVisibleChanged: {
    if (visible) Qt.callLater(function () { pathField.forceActiveFocus() })
  }

  Rectangle {
    anchors.bottom: parent.bottom
    width: parent.width
    height: Math.max(1, Style.space(1))
    color: Color.menu.border
    opacity: 0.5
  }

  Column {
    id: box
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.topMargin: Style.spacing.panelPadding
    anchors.leftMargin: root.textLeft
    anchors.rightMargin: root.textLeft
    spacing: Style.spacing.md

    Text {
      textFormat: Text.PlainText
      text: "STORAGE"
      color: Color.menu.selectedText
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      font.letterSpacing: 1
    }

    Rectangle {
      width: parent.width
      height: pathField.implicitHeight + Style.spacing.md
      radius: Style.cornerRadius
      color: Color.menu.background
      border.color: Color.menu.border
      border.width: Math.max(1, Style.space(1))

      TextField {
        id: pathField
        anchors.fill: parent
        anchors.leftMargin: Style.spacing.rowPaddingX
        anchors.rightMargin: Style.spacing.rowPaddingX
        background: null
        placeholderText: root.defaultPath
        foreground: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.subtitle
        onAccepted: root.accepted()
        Keys.onEscapePressed: root.canceled()
      }
    }

    Text {
      width: parent.width
      textFormat: Text.PlainText
      wrapMode: Text.WordWrap
      text: "Moves the file. Bookmarks already at the new path win."
      color: root.foreground
      opacity: 0.55
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
    }
  }
}
