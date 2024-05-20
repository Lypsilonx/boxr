#import "util.typ": *

#let combinators = (
  ":Pyth:": (a, b) => calc.sqrt(calc.pow(a, 2) + calc.pow(b, 2)),
  ":Add:": (a, b) => a + b,
  ":Sub:": (a, b) => a - b,
  ":Mul:": (a, b) => a * b,
  ":Div:": (a, b) => a / b,
)

#let get_from_args(args, name, default: 0pt) = {
  for arg in args.named() {
    if name.contains(arg.at(0)) {
      for combinator in combinators.keys() {
        if name.matches(regex("[a-zA-Z0-9_]*" + combinator + "[a-zA-Z0-9_]+")).len() == 1 {
          let first = if name.starts-with(combinator) {"0"} else {name.split(combinator).at(0)}
          let second = name.split(combinator).at(1)

          return combinators.at(combinator)(
            get_from_args(args, first) / 1pt,
            get_from_args(args, second) / 1pt
          ) * 1pt
        }
      }

      return arg.at(1)
    }
  }

  if (float(name) != none) {
    return float(name) * 1pt
  }
  
  return default
}

#let render_face(face, color, fold_stroke, cut_stroke, glue_pattern_p, args, offset: (0mm,0mm), comes_from: none) = {
  let has_child = (
    top: false,
    left: false,
    bottom: false,
    right: false
  )

  if (face.type == "box") {
    place(
      center + horizon,
      dx: offset.at(0),
      dy: offset.at(1)
    )[
      #box(
        width: get_from_args(args, face.width),
        height: get_from_args(args, face.height),
        fill: color,
        if face.keys().contains("id") and args.pos().len() > face.id {args.pos().at(face.id)}
      )
    ]

    if face.keys().contains("children") {
      for child in face.children.values().enumerate() {
        let add_offset = (0mm,0mm)
        let orientation = face.children.keys().at(child.at(0))

        has_child.at(orientation) = true

        if type(child.at(1)) == str {
          if child.at(1).starts-with("tab|") {

            let tab_width = get_from_args(args, child.at(1).split("|").at(1))

            if orientation == "top" {
              place(
                center + horizon,
                dx: offset.at(0),
                dy: offset.at(1) -(get_from_args(args, face.height) + tab_width) / 2,
              )[
                #tab(
                  get_from_args(args, face.width),
                  tab_width,
                  tab_width,
                  0deg,
                  color,
                  cut_stroke,
                  fold_stroke,
                  glue_pattern_p
                )
              ]
            } else if orientation == "left" {
              place(
                center + horizon,
                dx: offset.at(0) - (get_from_args(args, face.width) + tab_width) / 2,
                dy: offset.at(1)
              )[
                #tab(
                  get_from_args(args, face.height),
                  tab_width,
                  tab_width,
                  270deg,
                  color,
                  cut_stroke,
                  fold_stroke,
                  glue_pattern_p
                )
              ]
            } else if orientation == "bottom" {
              place(
                center + horizon,
                dx: offset.at(0),
                dy: offset.at(1) + (get_from_args(args, face.height) + tab_width) / 2
              )[
                #tab(
                  get_from_args(args, face.width),
                  tab_width,
                  tab_width,
                  180deg,
                  color,
                  cut_stroke,
                  fold_stroke,
                  glue_pattern_p
                )
              ]
            } else if orientation == "right" {
              place(
                center + horizon,
                dx: offset.at(0) + (get_from_args(args, face.width) + tab_width) / 2,
                dy: offset.at(1)
              )[
                #tab(
                  get_from_args(args, face.height),
                  tab_width,
                  tab_width,
                  90deg,
                  color,
                  cut_stroke,
                  fold_stroke,
                  glue_pattern_p
                )
              ]
            }
          }

          continue
        }

        let next_comes_from = none

        if orientation == "top" {
          add_offset = (
            0mm, -(get_from_args(args, face.height) + get_from_args(args, child.at(1).height)) / 2
          )
          next_comes_from = "bottom"
        } else if orientation == "left" {
          add_offset = (
            -(get_from_args(args, face.width) + get_from_args(args, child.at(1).width)) / 2, 0mm
          )
          next_comes_from = "right"
        } else if orientation == "bottom" {
          add_offset = (
            0mm, (get_from_args(args, face.height) + get_from_args(args, child.at(1).height)) / 2
          )
          next_comes_from = "top"
        } else if orientation == "right" {
          add_offset = (
            (get_from_args(args, face.width) + get_from_args(args, child.at(1).width)) / 2, 0mm
          )
          next_comes_from = "left"
        }

        render_face(
          child.at(1),
          color,
          fold_stroke,
          cut_stroke,
          glue_pattern_p,
          args,
          offset: (offset.at(0) + add_offset.at(0), offset.at(1) + add_offset.at(1)),
          comes_from: next_comes_from
        )
      }
    }
  } else if (face.type.starts-with("triangle")) {
    let width = get_from_args(args, face.width)
    let height = get_from_args(args, face.height)
    let direction = face.type.split("_").at(1)
    let points = if comes_from == "top" {
      (
        (0mm, 0mm),
        (width, 0mm),
        if direction == "left" {
          (width, height)
        } else {
          (0mm, height)
        }
      )
    } else if comes_from == "left" {
      (
        (0mm, height),
        (0mm, 0mm),
        if direction == "left" {
          (width, 0mm)
        } else {
          (width, height)
        }
      )
    } else if comes_from == "bottom" {
      (
        (width, height),
        (0mm, height),
        if direction == "left" {
          (0mm, 0mm)
        } else {
          (width, 0mm)
        }
      )
    } else if comes_from == "right" {
      (
        (width, 0mm),
        (width, height),
        if direction == "left" {
          (0mm, height)
        } else {
          (0mm, 0mm)
        }
      )
    }

    place(
      center + horizon,
      dx: offset.at(0),
      dy: offset.at(1)
    )[
      #polygon(
        fill: color,
        ..points
      )
    ]

    if comes_from == "top" {
      has_child.at("bottom") = true

      if direction == "left" {
        has_child.at("left") = true
      } else {
        has_child.at("right") = true
      }
    } else if comes_from == "left" {
      has_child.at("right") = true

      if direction == "left" {
        has_child.at("bottom") = true
      } else {
        has_child.at("top") = true
      }
    } else if comes_from == "bottom" {
      has_child.at("top") = true

      if direction == "left" {
        has_child.at("right") = true
      } else {
        has_child.at("left") = true
      }
    } else if comes_from == "right" {
      has_child.at("left") = true

      if direction == "left" {
        has_child.at("top") = true
      } else {
        has_child.at("bottom") = true
      }
    }

    place(
      center + horizon,
      dx: offset.at(0),
      dy: offset.at(1)
    )[
      #line(
        start: if direction == "left" {points.at(0)} else {points.at(1)},
        end: points.at(2),
        stroke: cut_stroke
      )
    ]

    if face.keys().contains("children") {
      for child in face.children.values().enumerate() {
        let add_offset = (0mm,0mm)
        let orientation = face.children.keys().at(child.at(0))

        has_child.at(orientation) = true

        if type(child.at(1)) == str {
          if child.at(1).starts-with("tab|") {

            let tab_width = get_from_args(args, child.at(1).split("|").at(1))

            if orientation == "top" {
              place(
                center + horizon,
                dx: offset.at(0),
                dy: offset.at(1) -(get_from_args(args, face.height) + tab_width) / 2,
              )[
                #tab(
                  get_from_args(args, face.width),
                  tab_width,
                  tab_width,
                  0deg,
                  color,
                  cut_stroke,
                  fold_stroke,
                  glue_pattern_p
                )
              ]
            } else if orientation == "left" {
              place(
                center + horizon,
                dx: offset.at(0) - (get_from_args(args, face.width) + tab_width) / 2,
                dy: offset.at(1)
              )[
                #tab(
                  get_from_args(args, face.height),
                  tab_width,
                  tab_width,
                  270deg,
                  color,
                  cut_stroke,
                  fold_stroke,
                  glue_pattern_p
                )
              ]
            } else if orientation == "bottom" {
              place(
                center + horizon,
                dx: offset.at(0),
                dy: offset.at(1) + (get_from_args(args, face.height) + tab_width) / 2
              )[
                #tab(
                  get_from_args(args, face.width),
                  tab_width,
                  tab_width,
                  180deg,
                  color,
                  cut_stroke,
                  fold_stroke,
                  glue_pattern_p
                )
              ]
            } else if orientation == "right" {
              place(
                center + horizon,
                dx: offset.at(0) + (get_from_args(args, face.width) + tab_width) / 2,
                dy: offset.at(1)
              )[
                #tab(
                  get_from_args(args, face.height),
                  tab_width,
                  tab_width,
                  90deg,
                  color,
                  cut_stroke,
                  fold_stroke,
                  glue_pattern_p
                )
              ]
            }
          }

          continue
        }

        let next_comes_from = none

        if orientation == "top" {
          add_offset = (
            0mm, -(get_from_args(args, face.height) + get_from_args(args, child.at(1).height)) / 2
          )
          next_comes_from = "bottom"
        } else if orientation == "left" {
          add_offset = (
            -(get_from_args(args, face.width) + get_from_args(args, child.at(1).width)) / 2, 0mm
          )
          next_comes_from = "right"
        } else if orientation == "bottom" {
          add_offset = (
            0mm, (get_from_args(args, face.height) + get_from_args(args, child.at(1).height)) / 2
          )
          next_comes_from = "top"
        } else if orientation == "right" {
          add_offset = (
            (get_from_args(args, face.width) + get_from_args(args, child.at(1).width)) / 2, 0mm
          )
          next_comes_from = "left"
        }

        render_face(
          child.at(1),
          color,
          fold_stroke,
          cut_stroke,
          glue_pattern_p,
          args,
          offset: (offset.at(0) + add_offset.at(0), offset.at(1) + add_offset.at(1)),
          comes_from: next_comes_from
        )
      }
    }
  } else {
    assert(false, message: "Unknown face type: " + face.type)
  }

  if not has_child.at("top") {
    place(
      center + horizon,
      dx: offset.at(0),
      dy: offset.at(1)
    )[
      #line(
        start: (0mm, -get_from_args(args, face.height) / 2),
        end: (get_from_args(args, face.width), -get_from_args(args, face.height) / 2),
        stroke: if comes_from == "top" {fold_stroke} else {cut_stroke}
      )
    ]
  }

  if not has_child.at("left") {
    place(
      center + horizon,
      dx: offset.at(0),
      dy: offset.at(1)
    )[
      #line(
        start: (-get_from_args(args, face.width) / 2, 0mm),
        end: (-get_from_args(args, face.width) / 2, get_from_args(args, face.height)),
        stroke: if comes_from == "left" {fold_stroke} else {cut_stroke}
      )
    ]
  }

  if not has_child.at("bottom") {
    place(
      center + horizon,
      dx: offset.at(0),
      dy: offset.at(1)
    )[
      #line(
        start: (0mm, get_from_args(args, face.height)),
        end: (get_from_args(args, face.width), get_from_args(args, face.height)),
        stroke: if comes_from == "bottom" {fold_stroke} else {cut_stroke}
      )
    ]
  }

  if not has_child.at("right") {
    place(
      center + horizon,
      dx: offset.at(0),
      dy: offset.at(1)
    )[
      #line(
        start: (get_from_args(args, face.width), 0mm),
        end: (get_from_args(args, face.width), get_from_args(args, face.height)),
        stroke: if comes_from == "right" {fold_stroke} else {cut_stroke}
      )
    ]
  }
}

#let get_structure_size(structure, args) = {
  let size = (0mm, 0mm)

  for width in structure.width {
    size.at(0) = size.at(0) + get_from_args(args, width)
  }

  for height in structure.height {
    size.at(1) = size.at(1) + get_from_args(args, height)
  }

  return size
}

#let get_structure_offset(structure, args) = {
  let offset = (0mm, 0mm)

  for width in structure.offset_x {
    offset.at(0) = offset.at(0) + get_from_args(args, width)
  }

  for height in structure.offset_y {
    offset.at(1) = offset.at(1) + get_from_args(args, height)
  }

  return offset
}

#let render_structure(structure_path, color: none, fold_stroke: 0.3mm + gray, cut_stroke: 0.3mm + black, glue_pattern_p: none, ..args) = {
  if glue_pattern_p == none {
    glue_pattern_p = glue_pattern(gray)
  }

  let structure = json(structure_path + ".json")

  for variable in structure.variables {
    assert(args.named().keys().contains(variable), message: structure_path + " needs variable: " + variable)
  }

  let structure_size = get_structure_size(structure, args)
  let structure_offset = get_structure_offset(structure, args)

  block(
    width: structure_size.at(0),
    height: structure_size.at(1),
    //stroke: cut_stroke
  )[
    #place(
      center + horizon,
      dx: (structure_offset.at(0)) / 2,
      dy: (structure_offset.at(1)) / 2
    )[
      #render_face(structure.root, color, fold_stroke, cut_stroke, glue_pattern_p, args)
    ]
  ]
}