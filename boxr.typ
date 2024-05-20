#import "util.typ": *

#let get_from_args(args, name, default: 0mm) = {
  if args.named().keys().contains(name) {
    return args.named().at(name)
  } else {
    return default
  }

}

#let render_face(face, color, fold_stroke, cut_stroke, glue_pattern_p, args, offset: (0mm,0mm), comes_from: none) = {
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

    let has_child = (
      top: false,
      left: false,
      bottom: false,
      right: false
    )

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
  } else {
    assert(false, message: "Unknown face type: " + face.type)
  }
}

#let get_structure_size(structure_path, args) = {
  let structure = json("structures/" + structure_path + ".json")

  let size = (0mm, 0mm)

  for width in structure.width {
    size.at(0) = size.at(0) + get_from_args(args, width)
  }

  for height in structure.height {
    size.at(1) = size.at(1) + get_from_args(args, height)
  }

  return size
}

#let get_structure_offset(structure_path, args) = {
  let structure = json("structures/" + structure_path + ".json")

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

  let structure = json("structures/" + structure_path + ".json")

  for variable in structure.variables {
    assert(args.named().keys().contains(variable), message: structure_path + " needs variable: " + variable)
  }

  let structure_size = get_structure_size(structure_path, args)
  let structure_offset = get_structure_offset(structure_path, args)

  block(
    width: structure_size.at(0),
    height: structure_size.at(1),
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