const { test } = require("node:test")
const assert = require("node:assert")
const S = require("../store.js")

test("a url keeps its query string, which is where the filter lives", () => {
  const url = "github.com/pulls?q=is%3Aopen+review-requested%3A%40me"
  assert.equal(S.cleanUrl("https://" + url), url)
})

test("search matches terms in any order, across name and url", () => {
  const marks = [
    { id: "1", name: "PRs esperando review", url: "github.com/pulls", uses: 0 },
    { id: "2", name: "Triage", url: "linear.app/team/ENG/triage", uses: 0 }
  ]
  assert.equal(S.filter(marks, "github review").length, 1)
  assert.equal(S.filter(marks, "review github")[0].id, "1")
})

test("most used comes first", () => {
  const marks = [
    { id: "1", name: "A", url: "a.com", uses: 2 },
    { id: "2", name: "B", url: "b.com", uses: 9 }
  ]
  assert.equal(S.filter(marks, "")[0].id, "2")
})

test("editing a bookmark preserves its use count", () => {
  const marks = [{ id: "1", name: "A", url: "a.com", uses: 7 }]
  const next = S.upsert(marks, { id: "1", name: "A2", url: "a.com/x" })
  assert.equal(next[0].uses, 7)
  assert.equal(next[0].url, "a.com/x")
})

test("a bookmark with no name falls back to its host", () => {
  const next = S.upsert([], { name: "  ", url: "https://www.github.com/pulls" })
  assert.equal(next[0].name, "github.com")
})

test("a bookmark with no url is rejected", () => {
  assert.equal(S.upsert([], { name: "x", url: "  " }), null)
})

test("a corrupt file yields no bookmarks instead of throwing", () => {
  assert.deepEqual(S.parse("{not json"), [])
})

