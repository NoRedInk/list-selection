# Selection List [![Build Status](https://travis-ci.org/NoRedInk/list-selection.svg?branch=master)](https://travis-ci.org/NoRedInk/list-selection)

Create a list which may have one (but no more than one) item selected.
You can never select an item that isn't in the list.
Selections are optional, so this is slightly different than a zipper.

## Usage

Create a Selection list from a regular list by using `fromList`.
Let's use this to choose what we'd like for lunch.

```elm
import List.Selection exposing (Selection)


type Lunch
    = Burrito
    | ChickenWrap
    | TacoSalad
    | DonerKebab


todaysMenu : Selection Lunch
todaysMenu =
    [ Burrito, ChickenWrap, TacoSalad ]
        |> List.Selection.fromList       -- create a new Selection list
        |> List.Selection.select Burrito -- now let's see, I think I'd like a burrito (yum, monads!)
```

Since I already chose what I want for lunch, I can get it with `selected`:

```elm
List.Selection.selected todaysMenu -- `Just Burrito`
```

But what if you try and select something that doesn't exist in the list?
The shop was out of doner kebab today, but what if we ask for it?

```elm
todaysMenu
    |> List.Selection.select DonerKebab -- this doesn't exist in our menu, so...
    |> List.Selection.selected          -- `Just Burrito` (selection unchanged)
```

And if I change my mind, I can remove my choice with `deselect`:

```elm
todaysMenu
    |> List.Selection.deselect -- deselect any current selection
    |> List.Selection.selected -- `Nothing`
```

## Developing

Install Elm and `elm-test` and `elm-verify-examples` from NPM, then run `make` to run tests and generate documentation.

## License

Licensed under a BSD 3-Clause license
