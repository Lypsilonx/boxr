# Boxr
Boxr is a modular, and easy to use, package for creating cardboard cutouts in Typst.

## Usage
Create a boxr structure in your project with the following code:
```
#import "@preview/boxr:0.1.0": render_structure

#render_structure(
  "box",
  width: 100pt,
  height: 100pt,
  depth: 100pt,
  tab_size: 20pt,
  [
    Hello from boxr!
  ]
)
```
The `render_structure` function is the main function for boxr. It either takes a path to one of the default structures provided by boxr (e.g.: `"box"`) or an unpacked json file with your own custom structure (e.g.: `json(my_structure.json)`). These describe the structure of the cutout.\
The other named arguments depend on the structure you are rendering. All unnamed arguments are passed to the structure as content and will be rendered on each box face (not triangles or tabs).

## Creating your own structures
Structures are defined in `.json` files. An example structure that just shows a box with a tab on one face is shown below:
```
{
  "variables": ["height", "width", "tab_size"],
  "width": "width",
  "height": "height + tab_size",
  "offset_x": "",
  "offset_y": "tab_size",
  "root": {
    "type": "box",
    "id": 0,
    "width": "width",
    "height": "height",
    "children": {
      "top": "tab|tab_size|tab_size"
    }
  }
}
```
The `variables` key is a list of variable names that can be passed to the structure. These will be required to be passed to the `render_structure` function.\
The `width` and `height` keys are evaluated to calculate the width and height of the structure.\
The `offset_x` and `offset_y` keys are evaluated to place the structure in the middle of its bounds. It is relative to the root node. In this case for example, the top tab adds a `tab_size` on top of the box as opposed to the bottom, where there is no tab. So this `tab_size` is added to the `offset_y`.\
`root` denotes the first node in the structure.\
A node can be of the following types:
- `box`:
  - The root node has a `width` and a `height`. All following nodes have a `size`. Child nodes use `size` and the parent node's `width` and `height` to calculate their own width and height.
  - Can have `children` nodes.
  - Can have an `id` key that is used to place content on the face of the box. The id-th unnamed argument is placed on the face. Multiple faces can have the same id.
  - Can have a `no-fold` key. If this exists, no fold stroke will be drawn between this box and its parent.
- `triangle_<left|right>`:
  - Has a `width` and `height`.
  - `left` and `right` denote the direction the other right angled line is facing relative to the base.
  - Can have `children` nodes.
  - Can have a `no-fold` key. If this exists, no fold stroke will be drawn between this triangle and its parent.
- `tab`:
  - Is not a json object, but a string that denotes a tab. The tab is placed on the parent node.
  - Has a tab_size after the first `|` and a cutin_size after the second `|`.
- `none`:
  - Is not a json object, but a string that denotes no node. This is useful for deleting a cut_stroke between two nodes.

Every string value in the json file (`width: "__", height: "__", ... offset_x/y: "__"` and the values between the `|` for tabs) is evaluated as regular typst code. This means that you can use all named variables (these have to be lengths) passed to the structure. All inputs are converted to points and the result of the evaluation will be converted back to a length.

