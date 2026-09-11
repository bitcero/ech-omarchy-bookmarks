import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Ui
import "store.js" as Store

Item {
  id: root

  readonly property string stateDir:
    Quickshell.env("HOME") + "/.local/state/omarchy"
  readonly property string settingsPath:
    stateDir + "/ech-bookmarks-settings.json"
  readonly property string defaultPath: stateDir + "/ech-bookmarks.json"

  property string filePath: defaultPath
  property var marks: []
  property string query: ""
  property int selected: 0
  property string mode: "list"
  property string editId: ""
  property string notice: ""
  property bool opened: false

  property color background: Color.menu.background
  property color foreground: Color.menu.text
  property color border: Color.menu.border
  property color scrim: Color.menu.scrim
  property color selectedBackground: Color.menu.selectedBackground
  property color selectedText: Color.menu.selectedText
  property var borderSpec: Border.surfaceSpec(
    "menu", "border", border, Math.max(1, Style.space(2)))
  property string fontFamily: Style.font.menuFamily

  readonly property int headPad: Style.spacing.rowPaddingX
  readonly property int ruleHeight: Math.max(1, Style.space(1))
  readonly property var shown: Store.filter(marks, query)
  readonly property var current: shown[Math.min(selected, shown.length - 1)]
    || null

  function open(payload) {
    query = ""
    selected = 0
    mode = "list"
    notice = ""
    opened = true
    Qt.callLater(function () { keys.forceActiveFocus() })
  }

  function close() {
    opened = false
    mode = "list"
  }

  function toggle() {
    if (opened) close()
    else open("{}")
  }

  function move(delta) {
    var last = Math.max(0, shown.length - 1)
    selected = Math.max(0, Math.min(last, selected + delta))
  }

  function store(next) {
    marks = next
    file.setText(Store.serialize(next))
  }

  function launch(mark) {
    if (!mark) return
    run(opener, ["xdg-open", Store.fullUrl(mark.url)])
    store(Store.countUse(marks, mark.id))
    close()
  }

  function copy(mark) {
    if (!mark) return
    run(copier, ["wl-copy", "--", Store.fullUrl(mark.url)])
    flash("copiado")
  }

  function compose() {
    editId = ""
    form.urlText = ""
    form.nameText = query
    mode = "form"
  }

  function edit(mark) {
    if (!mark) return
    editId = mark.id
    form.urlText = Store.fullUrl(mark.url)
    form.nameText = mark.name
    mode = "form"
  }

  function commit() {
    var next = Store.upsert(
      marks, { id: editId, url: form.urlText, name: form.nameText })
    if (!next) { flash("hace falta una url"); return }
    store(next)
    query = ""
    selected = 0
    back()
  }

  function drop(mark) {
    if (!mark) return
    store(Store.remove(marks, mark.id))
    selected = 0
    flash("borrado · " + mark.name)
  }

  function settings() {
    panelSettings.pathText = filePath
    mode = "settings"
  }

  function relocate(raw) {
    var to = expand(raw)
    if (!to || to === filePath) { back(); return }
    run(mover, ["bash", "-c", moveCommand(filePath, to)])
    filePath = to
    settingsFile.setText(JSON.stringify({ path: to }, null, 2) + "\n")
    back()
  }

  function expand(raw) {
    return raw.trim().replace(/^~/, Quickshell.env("HOME"))
  }

  // Bookmarks already at the destination are the user's own, most likely a
  // copy synced from elsewhere: they win and our file stays put.
  function moveCommand(from, to) {
    return "mkdir -p \"$(dirname '" + to + "')\"; "
      + "[ -s '" + to + "' ] || mv '" + from + "' '" + to + "'"
  }

  function back() {
    mode = "list"
    Qt.callLater(function () { keys.forceActiveFocus() })
  }

  function run(proc, command) {
    proc.command = command
    proc.running = true
  }

  function flash(text) {
    notice = text
    noticeTimer.restart()
  }

  Timer {
    id: noticeTimer
    interval: 2000
    onTriggered: root.notice = ""
  }

  Process { id: opener }
  Process { id: copier }
  Process { id: mover }

  FileView {
    id: settingsFile
    path: root.settingsPath
    watchChanges: true
    atomicWrites: true
    printErrors: false
    onLoaded: {
      try {
        var saved = JSON.parse(text()).path
        if (saved) root.filePath = saved
      } catch (e) {}
    }
    onFileChanged: reload()
  }

  FileView {
    id: file
    path: root.filePath
    watchChanges: true
    atomicWrites: true
    printErrors: false
    onLoaded: root.marks = Store.parse(text())
    onLoadFailed: root.marks = []
    onFileChanged: reload()
  }

  PanelWindow {
    id: panel
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "ech-bookmarks"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Rectangle { anchors.fill: parent; color: root.scrim }
    MouseArea { anchors.fill: parent; onClicked: root.close() }

    BorderSurface {
      id: card
      width: Math.min(Style.space(760), panel.width - Style.gapsOut * 2)
      height: Math.min(Style.space(600), panel.height - Style.gapsOut * 2)
      radius: Style.cornerRadius
      anchors.centerIn: parent
      color: root.background
      borderSpec: root.borderSpec
      padding: Style.spacing.panelPadding

      MouseArea { anchors.fill: parent; onClicked: {} }

      Item {
        id: keys
        anchors.fill: parent
        focus: root.mode === "list"
        Keys.priority: Keys.BeforeItem
        Keys.onPressed: function (event) {
          if (root.mode !== "list") return
          event.accepted = true

          if (event.key === Qt.Key_Escape) {
            if (root.query) root.query = ""
            else root.close()
          } else if (isEnter(event) && mod(event, Qt.ControlModifier)) {
            root.compose()
          } else if (isEnter(event)) {
            root.launch(root.current)
          } else if (event.key === Qt.Key_F2) {
            root.edit(root.current)
          } else if (event.key === Qt.Key_C && mod(event, Qt.AltModifier)) {
            root.copy(root.current)
          } else if (event.key === Qt.Key_Delete
                     && mod(event, Qt.ShiftModifier)) {
            root.drop(root.current)
          } else if (event.key === Qt.Key_Comma
                     && mod(event, Qt.ControlModifier)) {
            root.settings()
          } else if (event.key === Qt.Key_Up) {
            root.move(-1)
          } else if (event.key === Qt.Key_Down) {
            root.move(1)
          } else if (Util.editsFilter(event, root.query)) {
            root.query = Util.editedFilter(event, root.query)
            root.selected = 0
          } else if (typed(event)) {
            root.query += event.text
            root.selected = 0
          } else {
            event.accepted = false
          }
        }

        function isEnter(event) {
          return event.key === Qt.Key_Return || event.key === Qt.Key_Enter
        }

        function mod(event, which) {
          return (event.modifiers & which) !== 0
        }

        function typed(event) {
          return event.text.length === 1 && event.text.charCodeAt(0) >= 32
        }
      }

      Column {
        id: content
        anchors.fill: parent
        spacing: 0

        readonly property int inset: card.contentLeftInset
        readonly property int pad: Style.space(8)
        readonly property int textLeft: inset + pad

        Item {
          width: parent.width
          height: fresh.height + root.headPad * 2

          Item {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: content.textLeft
            anchors.rightMargin: content.textLeft
            anchors.verticalCenter: parent.verticalCenter
            height: fresh.height

            Text {
              id: glass
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
              textFormat: Text.PlainText
              text: "\uf002"
              color: root.foreground
              opacity: 0.45
              font.family: root.fontFamily
              font.pixelSize: Style.font.body
            }

            Button {
              id: fresh
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              text: "+ nuevo"
              bordered: true
              foreground: root.foreground
              fontFamily: root.fontFamily
              fontSize: Style.font.caption
              onClicked: root.compose()
            }

            Text {
              id: count
              anchors.right: fresh.left
              anchors.rightMargin: Style.spacing.md
              anchors.verticalCenter: parent.verticalCenter
              textFormat: Text.PlainText
              text: root.shown.length
                + (root.shown.length === 1 ? " marcador" : " marcadores")
              color: root.foreground
              opacity: 0.45
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
            }

            Text {
              anchors.left: glass.right
              anchors.leftMargin: Style.spacing.md
              anchors.right: count.left
              anchors.rightMargin: Style.spacing.md
              anchors.verticalCenter: parent.verticalCenter
              textFormat: Text.PlainText
              text: root.query ? root.query : "buscar por nombre o url…"
              color: root.foreground
              opacity: root.query ? 1 : 0.45
              font.family: root.fontFamily
              font.pixelSize: Style.font.title
              elide: Text.ElideRight
            }
          }
        }

        Rectangle {
          width: parent.width
          height: root.ruleHeight
          color: root.border
          opacity: 0.5
        }

        Item {
          width: parent.width
          height: parent.height - y - foot.height - root.ruleHeight

          BookmarkList {
            id: rows
            anchors.fill: parent
            edge: content.pad
            textPad: content.inset
            visible: root.mode === "list"
            marks: root.shown
            total: root.marks.length
            selected: root.selected
            foreground: root.foreground
            selectedBackground: root.selectedBackground
            selectedText: root.selectedText
            fontFamily: root.fontFamily
            onHovered: function (index) { root.selected = index }
            onActivated: function (mark) { root.launch(mark) }
          }

          BookmarkForm {
            id: form
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: content.inset
            anchors.rightMargin: content.inset
            visible: root.mode === "form"
            editing: root.editId !== ""
            foreground: root.foreground
            fontFamily: root.fontFamily
            onAccepted: root.commit()
            onCanceled: root.back()
          }

          BookmarkSettings {
            id: panelSettings
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: content.inset
            anchors.rightMargin: content.inset
            visible: root.mode === "settings"
            defaultPath: root.defaultPath
            foreground: root.foreground
            fontFamily: root.fontFamily
            onAccepted: root.relocate(panelSettings.pathText)
            onCanceled: root.back()
          }
        }

        Rectangle {
          id: rule
          width: parent.width
          height: root.ruleHeight
          color: root.border
          opacity: 0.5
        }

        Item {
          id: foot
          width: parent.width
          height: hints.height + root.headPad * 2

          Text {
            id: hints
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: content.textLeft
            anchors.rightMargin: content.textLeft
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            text: root.notice ? root.notice : hintLine
            color: root.foreground
            opacity: 0.45
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            elide: Text.ElideRight

            readonly property string hintLine: root.mode === "list"
              ? "↑↓ mover · ⏎ abrir · ctrl+⏎ nuevo · F2 editar · "
                + "alt+c copiar · shift+supr borrar · ctrl+, dónde se guardan"
              : "⏎ confirmar · esc cancelar"
          }
        }
      }
    }
  }
}
