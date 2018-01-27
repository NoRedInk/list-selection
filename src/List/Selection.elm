module List.Selection
    exposing
        ( Selection
        , deselect
        , filter
        , fromList
        , map
        , mapSelected
        , select
        , selectBy
        , selected
        , toList
        )

{-| This module exposes a list that has at most one selected item.

The invariants here:

  - You can select _at most_ one item.
  - You can't select an item that isn't part of the list.

But, these only hold if there are no duplicates in your list.


## Converting

@docs Selection, fromList, toList


## Selecting

@docs select, selectBy, deselect, selected


## Transforming

@docs map, mapSelected, filter

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


{-| Convert a Selection list back to a regular list. This is useful
for creating view functions, for example. If you want a list that has
the selected item, use `mapSelected` like this:

    [ 1, 2, 3 ]
        |> fromList
        |> select 2
        |> mapSelected
            { selected = (,) True
            , rest = (,) False
            }
        |> toList
        --> [ (False, 1), (True, 2), (False, 3) ]

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
select el selection =
    selectBy ((==) el) selection


{-| Mark an item as selected by specifying a function. This will select the
first item for which the function returns `True`. Any previously selected item
will be unselected.

    fromList ["Burrito", "Chicken Wrap", "Taco Salad"]
        |> selectBy (String.startsWith "B")
        |> selected --> Just "Burrito"

-}
selectBy : (a -> Bool) -> Selection a -> Selection a
selectBy query (Selection original items) =
    Selection
        (items
            |> List.filter query
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


{-| Apply a function to all the items.

    fromList [1, 2, 3]
        |> map ((*) 2)
        |> toList --> [2, 4, 6]

-}
map : (a -> b) -> Selection a -> Selection b
map fn (Selection selected items) =
    Selection
        (Maybe.map fn selected)
        (List.map fn items)


{-| Apply a function to all the items, treating the selected item
specially.

    fromList [1, 2, 3]
        |> select 2
        |> mapSelected { selected = (*) 2, rest = identity }
        |> toList --> [1, 4, 3]

-}
mapSelected : { selected : a -> b, rest : a -> b } -> Selection a -> Selection b
mapSelected mappers (Selection selected items) =
    Selection
        (Maybe.map mappers.selected selected)
        (List.map
            (\item ->
                if Just item == selected then
                    mappers.selected item
                else
                    mappers.rest item
            )
            items
        )


{-| Filter all items where predicate evaluates to false, preserving unfiltered
selected item.

    fromList [1, 2, 3]
        |> select 2
        |> filter ((>) 2)
        |> toList --> [1]

    fromList [1, 2, 3]
        |> select 2
        |> filter ((>) 2)
        |> selected --> Nothing

    fromList [1, 2, 3]
        |> select 2
        |> filter ((<) 1)
        |> toList --> [2, 3]

    fromList [1, 2, 3]
        |> select 2
        |> filter ((<) 1)
        |> selected --> Just 2

-}
filter : (a -> Bool) -> Selection a -> Selection a
filter predicate (Selection selected items) =
    let
        filteredSelection =
            items
                |> List.filter predicate
                |> fromList
    in
        case selected of
            Just selection ->
                filteredSelection
                    |> select selection

            Nothing ->
                filteredSelection
