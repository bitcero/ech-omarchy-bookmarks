function cleanUrl(url) {
  return String(url || "").trim()
    .replace(/^https?:\/\//, "").replace(/\/+$/, "")
}

function host(url) {
  return (cleanUrl(url).split("/")[0] || "").replace(/^www\./, "")
}

function fullUrl(url) {
  var u = cleanUrl(url)
  return u ? "https://" + u : ""
}

function newId() {
  return String(Date.now()) + "-" + Math.random().toString(36).slice(2, 8)
}

function parse(raw) {
  try {
    var data = JSON.parse(raw)
    var list = Array.isArray(data) ? data : (data && data.bookmarks)
    if (!Array.isArray(list)) return []
    return list.filter(function (b) { return b && b.url }).map(function (b) {
      return {
        id: b.id || newId(),
        name: String(b.name || host(b.url)),
        url: cleanUrl(b.url),
        uses: Number(b.uses) || 0
      }
    })
  } catch (e) {
    return []
  }
}

function serialize(marks) {
  return JSON.stringify({ version: 1, bookmarks: marks }, null, 2) + "\n"
}

function filter(marks, query) {
  var terms = String(query || "").toLowerCase().trim().split(/\s+/)
    .filter(function (t) { return t })
  var hit = marks.filter(function (b) {
    if (!terms.length) return true
    var hay = (b.name + " " + b.url).toLowerCase()
    return terms.every(function (t) { return hay.indexOf(t) !== -1 })
  })
  return hit.sort(function (a, b) {
    return b.uses - a.uses || a.name.localeCompare(b.name)
  })
}

function upsert(marks, draft) {
  var url = cleanUrl(draft.url)
  if (!url) return null
  var name = String(draft.name || "").trim() || host(url)
  if (draft.id) {
    return marks.map(function (b) {
      return b.id === draft.id
        ? { id: b.id, name: name, url: url, uses: b.uses }
        : b
    })
  }
  return [{ id: newId(), name: name, url: url, uses: 0 }].concat(marks)
}

function remove(marks, id) {
  return marks.filter(function (b) { return b.id !== id })
}

function countUse(marks, id) {
  return marks.map(function (b) {
    return b.id === id
      ? { id: b.id, name: b.name, url: b.url, uses: b.uses + 1 }
      : b
  })
}

if (typeof module !== "undefined") {
  module.exports = {
    cleanUrl: cleanUrl, host: host, fullUrl: fullUrl, newId: newId,
    parse: parse, serialize: serialize, filter: filter, upsert: upsert,
    remove: remove, countUse: countUse
  }
}
