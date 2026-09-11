import QtQuick
import qs.Commons
import qs.Ui

Rectangle {
  id: root

  property bool editing: false
  property int textLeft: 0
  property alias nameText: nameField.text
  property alias urlText: urlField.text
  property color foreground: Color.menu.text
  property color highlight: Color.menu.selectedText
  property string fontFamily: Style.font.menuFamily

  signal accepted()
  signal canceled()

  height: fields.implicitHeight + Style.spacing.panelPadding * 2
  color: Color.menu.selectedBackground

  onVisibleChanged: {
    if (visible) Qt.callLater(function () { urlField.forceActiveFocus() })
  }

  Rectangle {
    anchors.bottom: parent.bottom
    width: parent.width
    height: Math.max(1, Style.space(1))
    color: Color.menu.border
    opacity: 0.5
  }

  Column {
    id: fields
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.topMargin: Style.spacing.panelPadding
    anchors.leftMargin: root.textLeft
    anchors.rightMargin: root.textLeft
    spacing: Style.spacing.md

    Item {
      width: parent.width
      height: title.height

      Text {
        id: title
        anchors.left: parent.left
        textFormat: Text.PlainText
        text: root.editing ? "EDIT BOOKMARK" : "SAVE A NEW BOOKMARK"
        color: root.highlight
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
        font.letterSpacing: 1
      }

      Text {
        anchors.right: parent.right
        anchors.baseline: title.baseline
        textFormat: Text.PlainText
        text: "esc to cancel"
        color: root.foreground
        opacity: 0.45
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
      }
    }

    Column {
      width: parent.width
      spacing: Style.spacing.xs

      Text {
        textFormat: Text.PlainText
        text: "URL"
        color: root.foreground
        opacity: 0.55
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
        font.letterSpacing: 1
      }

      Rectangle {
        width: parent.width
        height: urlField.implicitHeight + Style.spacing.md
        radius: Style.cornerRadius
        color: Color.menu.background
        border.color: Color.menu.border
        border.width: Math.max(1, Style.space(1))

        TextField {
          id: urlField
          anchors.fill: parent
          anchors.leftMargin: Style.spacing.rowPaddingX
          anchors.rightMargin: Style.spacing.rowPaddingX
          background: null
          placeholderText: "paste the url with your filters here"
          foreground: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.subtitle
          onAccepted: root.accepted()
          Keys.onEscapePressed: root.canceled()
          KeyNavigation.tab: nameField
        }
      }
    }

    Column {
      width: parent.width
      spacing: Style.spacing.xs

      Text {
        textFormat: Text.PlainText
        text: "NAME"
        color: root.foreground
        opacity: 0.55
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
        font.letterSpacing: 1
      }

      Rectangle {
        width: parent.width
        height: nameField.implicitHeight + Style.spacing.md
        radius: Style.cornerRadius
        color: Color.menu.background
        border.color: Color.menu.border
        border.width: Math.max(1, Style.space(1))

        TextField {
          id: nameField
          anchors.fill: parent
          anchors.leftMargin: Style.spacing.rowPaddingX
          anchors.rightMargin: Style.spacing.rowPaddingX
          background: null
          placeholderText: "e.g. Linear · my P1 bugs this cycle"
          foreground: root.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.subtitle
          onAccepted: root.accepted()
          Keys.onEscapePressed: root.canceled()
        }
      }
    }

    Row {
      spacing: Style.spacing.md

      Button {
        text: (root.editing ? "update" : "save") + " ⏎"
        selected: true
        foreground: root.foreground
        fontFamily: root.fontFamily
        fontSize: Style.font.bodySmall
        onClicked: root.accepted()
      }

      Button {
        text: "cancel"
        foreground: root.foreground
        fontFamily: root.fontFamily
        fontSize: Style.font.bodySmall
        onClicked: root.canceled()
      }
    }
  }
}
