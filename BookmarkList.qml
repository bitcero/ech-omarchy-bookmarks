import QtQuick
import qs.Commons
import "store.js" as Store

Item {
  id: root

  property int edge: 0
  property int textPad: 0
  property var marks: []
  property int total: 0
  property int selected: 0
  property color foreground: Color.menu.text
  property color selectedBackground: Color.menu.selectedBackground
  property color selectedText: Color.menu.selectedText
  property string fontFamily: Style.font.menuFamily

  readonly property int rowHeight: Math.max(
    Style.space(34), Style.font.body + Style.spacing.rowPaddingX * 2)

  readonly property int spacing: Style.space(2)
  readonly property int contentHeight: marks.length
    ? marks.length * rowHeight + (marks.length - 1) * spacing
    : rowHeight * 2

  signal hovered(int index)
  signal activated(var mark)

  ListView {
    id: list
    anchors.fill: parent
    anchors.leftMargin: root.edge
    anchors.rightMargin: root.edge
    visible: root.marks.length > 0
    model: root.marks
    currentIndex: Math.min(root.selected, root.marks.length - 1)
    highlightMoveDuration: 0
    spacing: root.spacing
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    delegate: Rectangle {
      id: row
      required property int index
      required property var modelData
      readonly property bool here: index === list.currentIndex

      width: ListView.view.width
      height: root.rowHeight
      radius: Style.cornerRadius
      color: here ? root.selectedBackground : "transparent"

      Text {
        id: ordinal
        anchors.left: parent.left
        anchors.leftMargin: root.textPad
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.PlainText
        text: row.index < 9 ? String(row.index + 1) : "·"
        color: row.here ? root.selectedText : root.foreground
        opacity: 0.45
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
      }

      Text {
        id: uses
        anchors.right: parent.right
        anchors.rightMargin: root.textPad
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.PlainText
        text: row.modelData.uses > 0 ? row.modelData.uses + "×" : ""
        color: row.here ? root.selectedText : root.foreground
        opacity: 0.45
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
      }

      Text {
        id: site
        anchors.right: uses.left
        anchors.rightMargin: Style.spacing.sm
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.PlainText
        text: Store.host(row.modelData.url)
        color: row.here ? root.selectedText : root.foreground
        opacity: 0.6
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
      }

      Text {
        anchors.left: ordinal.right
        anchors.leftMargin: Style.spacing.rowPaddingX
        anchors.right: site.left
        anchors.rightMargin: Style.spacing.md
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.PlainText
        text: row.modelData.name
        color: row.here ? root.selectedText : root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        elide: Text.ElideRight
      }

      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered(row.index)
        onClicked: root.activated(row.modelData)
      }
    }
  }

  Text {
    anchors.centerIn: parent
    visible: root.marks.length === 0
    textFormat: Text.PlainText
    horizontalAlignment: Text.AlignHCenter
    text: root.total
      ? "no match\nctrl+⏎ to save one with that name"
      : "no bookmarks\nctrl+⏎ to add one"
    color: root.foreground
    opacity: 0.55
    font.family: root.fontFamily
    font.pixelSize: Style.font.body
  }
}
