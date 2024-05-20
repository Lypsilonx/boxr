#import "boxr.typ": *

#set page(
  "a3",
  margin: 0mm
)
#set align(center + horizon)
// #render_structure(
//   "structures/box",
//   width: 100pt,
//   height: 100pt,
//   depth: 100pt,
//   tab_size: 20pt
// )
// #render_structure(
//   "structures/ramp",
//   width: 100pt,
//   height: 50pt,
//   depth: 200pt,
//   tab_size: 20pt
// )
#render_structure(
  "structures/step",
  width: 100pt,
  height_1: 50pt,
  height_2: 30pt,
  depth_1: 100pt,
  depth_2: 80pt,
  tab_size: 20pt
)