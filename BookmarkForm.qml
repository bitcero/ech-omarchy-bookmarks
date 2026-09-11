import QtQuick
import qs.Commons
import qs.Ui

Column {
  id: root

  property bool editing: false
  property alias nameText: nameField.text
  property alias urlText: urlField.text
  property color foreground: Color.foreground
  property string fontFamily: Style.font.family

  signal accepted()
  signal canceled()

  spacing: Style.spacing.md

  onVisibleChanged: {
    if (visible) Qt.callLater(function () { urlField.forceActiveFocus() })
  }

  Text {
    textFormat: Text.PlainText
    text: root.editing ? "editar marcador" : "guardar un marcador nuevo"
    color: root.foreground
    font.family: root.fontFamily
    font.pixelSize: Style.font.heading
  }

  Column {
    width: parent.width
    spacing: Style.spacing.xs

    Text {
      textFormat: Text.PlainText
      text: "url"
      color: root.foreground
      opacity: 0.55
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
    }

    TextField {
      id: urlField
      width: parent.width
      placeholderText: "github.com/pulls?q=is:open+review-requested:@me"
      foreground: root.foreground
      font.family: root.fontFamily
      onAccepted: root.accepted()
      Keys.onEscapePressed: root.canceled()
      KeyNavigation.tab: nameField
    }
  }

  Column {
    width: parent.width
    spacing: Style.spacing.xs

    Text {
      textFormat: Text.PlainText
      text: "nombre"
      color: root.foreground
      opacity: 0.55
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
    }

    TextField {
      id: nameField
      width: parent.width
      placeholderText: "PRs esperando mi review"
      foreground: root.foreground
      font.family: root.fontFamily
      onAccepted: root.accepted()
      Keys.onEscapePressed: root.canceled()
    }
  }
}
