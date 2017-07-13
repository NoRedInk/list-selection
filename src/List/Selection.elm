module List.Selection
    exposing
        ( Selection
        , deselect
        , fromList
        , map
        , select
        , selected
        , toList
        )

{-| This module exposes a list that has at most one selected item.

The invariants here:

  - You can select _at most_ one item.
  - You can't select an item that isn't part of the list.

@docs Selection, fromList, toList, select, deselect, selected, map

-}


{-| A list of items, one of which _might_ be selected.
-}
type Selection a
    = Selection (Maybe a) (List a)


{-| Create a `Selection a` with nothing selected.
-}
fromList : List a -> Selection a
fromList items =
    Selection Nothing items


{-| Convert a Selection list back to a regular list. This is useful for creating
view functions, for example.
-}
toList : Selection a -> List a
toList (Selection _ items) =
    items


{-| Mark an item as selected. This will select at most one item. Any previously
selected item will be unselected.

    fromList ["Burrito", "Chicken Wrap", "Taco Salad"]
        |> select "Burrito"
        |> selected --> Just "Burrito"

Attempting to select an item that doesn't exist is a no-op.

    fromList ["Burrito", "Chicken Wrap", "Taco Salad"]
        |> select "Doner Kebab"
        |> selected --> Nothing

-}
select : a -> Selection a -> Selection a
select el (Selection original items) =
    Selection
        (items
            |> List.filter ((==) el)
            |> List.head
            |> Maybe.map Just
            |> Maybe.withDefault original
        )
        items


{-| Deselect any selected item. This is a no-op if nothing is selected in the
first place.
-}
deselect : Selection a -> Selection a
deselect (Selection _ items) =
    Selection Nothing items


{-| Get the selected item, which might not exist.

    fromList ["Burrito", "Chicken Wrap", "Taco Salad"]
        |> select "Burrito"
        |> selected --> Just "Burrito"

-}
selected : Selection a -> Maybe a
selected (Selection selected _) =
    selected


{-| Apply a function to all the items, including the currently selected item.

    fromList [1, 2, 3]
        |> map ((*) 2)
        |> toList --> [2, 4, 6]

-}
map : (a -> b) -> Selection a -> Selection b
map fn (Selection selected items) =
    Selection
        (Maybe.map fn selected)
        (List.map fn items)
