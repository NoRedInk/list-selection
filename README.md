# Selection List

Create a list which may have one (but no more than one) item selected.
You can never select an item that isn't in the list.

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


todaysLunch : Selection Lunch
todaysLunch =
    List.Selection.fromList [ Burrito, ChickenWrap, TacoSalad ]
```

Choose what you want, and set it with `List.Selection.select`.
Then we can check what we chose with `selected`.
I think I feel like a `Burrito` today (monads, yum!):

```elm
List.Selection.select Burrito todaysLunch -- try to select `Burrito`...
    |> List.Selection.selected            -- it worked! We get `Just Burrito`
```

&hellip; and if we change our minds we can `deselect`:

```elm
List.Selection.deselect todaysLunch -- now `selected` will return `Nothing`
```

Unfortunately, the shop was out of doner kebab today, so you can't select it!

```elm
List.Selection.select DonerKebab todaysLunch -- try to select `DonerKebab`...
    |> List.Selection.selected               -- it didn't work, so we get `Nothing`
```

## License

Licensed under a BSD 3-Clause license
