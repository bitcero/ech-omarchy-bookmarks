import QtQuick
import qs.Commons
import qs.Ui

Column {
  id: root

  property string defaultPath: ""
  property alias pathText: pathField.text
  property color foreground: Color.menu.text
  property string fontFamily: Style.font.menuFamily

  signal accepted()
  signal canceled()

  spacing: Style.spacing.md

  onVisibleChanged: {
    if (visible) Qt.callLater(function () { pathField.forceActiveFocus() })
  }

  Text {
    textFormat: Text.PlainText
    text: "where bookmarks are stored"
    color: root.foreground
    font.family: root.fontFamily
    font.pixelSize: Style.font.heading
  }

  TextField {
    id: pathField
    width: parent.width
    placeholderText: root.defaultPath
    foreground: root.foreground
    font.family: root.fontFamily
    onAccepted: root.accepted()
    Keys.onEscapePressed: root.canceled()
  }

  Text {
    width: parent.width
    textFormat: Text.PlainText
    wrapMode: Text.WordWrap
    text: "Changing the path moves the file. If bookmarks already exist at "
      + "the destination, those are kept and the current file stays where "
      + "it is."
    color: root.foreground
    opacity: 0.55
    font.family: root.fontFamily
    font.pixelSize: Style.font.caption
  }
}
