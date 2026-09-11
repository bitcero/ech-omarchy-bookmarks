import QtQuick
import Quickshell.Io
import qs.Commons

Item {
  id: root

  property string manifestPath: ""
  property color foreground: Color.menu.text
  property color highlight: Color.menu.selectedText
  property string fontFamily: Style.font.menuFamily

  property var meta: ({})

  signal opened(string url)

  FileView {
    path: root.manifestPath
    watchChanges: true
    printErrors: false
    onLoaded: {
      try {
        root.meta = JSON.parse(text())
      } catch (e) {}
    }
    onFileChanged: reload()
  }

  Column {
    anchors.centerIn: parent
    width: Math.min(parent.width - Style.spacing.panelPadding * 2,
                    Style.space(420))
    spacing: Style.spacing.lg

    Image {
      anchors.horizontalCenter: parent.horizontalCenter
      source: root.manifestPath.replace("manifest.json", "logo.svg")
      sourceSize.width: Style.space(220)
      fillMode: Image.PreserveAspectFit
      smooth: true
    }

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      textFormat: Text.PlainText
      text: (root.meta.name || "") + " " + (root.meta.version || "")
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.heading
    }

    Text {
      width: parent.width
      horizontalAlignment: Text.AlignHCenter
      wrapMode: Text.WordWrap
      textFormat: Text.PlainText
      text: root.meta.description || ""
      color: root.foreground
      opacity: 0.6
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
    }

    Text {
      id: link
      anchors.horizontalCenter: parent.horizontalCenter
      textFormat: Text.PlainText
      text: root.meta.homepage || ""
      color: root.highlight
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      font.underline: site.containsMouse

      MouseArea {
        id: site
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.opened(root.meta.homepage || "")
      }
    }

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      textFormat: Text.PlainText
      text: (root.meta.author || "") + " · " + (root.meta.license || "")
      color: root.foreground
      opacity: 0.45
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
    }
  }
}
