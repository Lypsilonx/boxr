# Boxr
Boxr is a modular, and easy to use, package for creating cardboard cutouts in Typst.

## Usage
Create a boxr structure in your project by with the following code:
```
#import "@preview/boxr:0.1.0"

#render_structure(
  "structures/box",
  width: 100pt,
  height: 100pt,
  depth: 100pt,
  tab_size: 20pt,
  [
    Hello from boxr!
  ]
)
```
The `render_structure` function is the main function for boxr. It takes a path to a `.json` (without the file extension) file that describes the structure of the cutout. The other named arguments depend on the structure you are rendering. All unnamed arguments are passed to the structure as content and will be rendered on each box face (not triangles or tabs).

## Creating your own structures
Structures are defined in `.json` files. An example structure that just shows a box with a tab on one face is shown below:
```
{
  "variables": ["height", "width", "tab_size"],
  "width": ["width"],
  "height": ["height", "tab_size"],
  "offset_x": [],
  "offset_y": ["tab_size"],
  "root": {
    "type": "box",
    "id": 0,
    "width": "width",
    "height": "height",
    "children": {
      "top": "tab|tab_size"
    }
  }
}
```
The `variables` key is a list of variables that can be passed to the structure.
The `width` and `height` keys are lists of variables that are used to calculate the width and height of the structure.
The `offset_x` and `offset_y` keys are lists of variables that are used to place the structure in the middle of its bounds. It is relative to the root node. In this case for example, the top tab adds a `tab_size` on top of the box as opposed to the bottom, where there is no tab. So one `tab_size` is added to the `offset_y`.
`root` denotes the first node in the structure.
A node can be of the following types:
- `box`:
  - Has a `width` and `height` key that can be a number or a variable.
  - Can have `children` nodes
  - Can have an `id` key that is used to place content on the face of the box. The id-th unnamed argument is placed on the face. Multiple faces can have the same id.
  - Can have a `no-fold` key. If this exists, no fold stroke will be drawn between this box and its parent.
- `triangle_<left|right>`:
  - Has a `width` and `height` key that can be a number or a variable.
  - `left` and `right` denote the direction the other right angled line is facing relative to the base.
  - Can have `children` nodes
  - Can have a `no-fold` key. If this exists, no fold stroke will be drawn between this triangle and its parent.
- `tab`:
  - Is not a json object, but a string that denotes a tab. The tab is placed on the parent node.
  - Has a size after the `|` character. This can be a number or a variable.
