#import "boxr.typ": *

#set page(
  "a3",
  margin: 0mm
)
#set align(center + horizon)
#render_structure(
  "box",
  width: 100pt,
  height: 100pt,
  depth: 100pt,
  tab_size: 20pt
)
#v(3em)
#render_structure(
  "box",
  color: black,
  width: 100pt,
  height: 100pt,
  depth: 100pt,
  tab_size: 20pt
)