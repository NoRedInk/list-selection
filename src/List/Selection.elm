module List.Selection
    exposing
        ( Selection
        , decoder
        , deselect
        , fromList
        , map
        , mapSelected
        , select
        , selectBy
        , selected
        , toList
        , toListWithSelected
        )

{-| This module exposes a list that has at most one selected item.

The invariants here:

  - You can select _at most_ one item.
  - You can't select an item that isn't part of the list.

But, these only hold if there are no duplicates in your list.


## Converting

@docs Selection, fromList, toList, toListWithSelected, decoder


## Selecting

@docs select, selectBy, deselect, selected


## Transforming

@docs map, mapSelected

-}

import Json.Decode as Decode exposing (Decoder)


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


{-| Get a list of items, and if they're selected. Also useful in views.
-}
toListWithSelected : Selection a -> List ( a, Bool )
toListWithSelected (Selection selected items) =
    case selected of
        Nothing ->
            List.map
                (flip (,) False)
                items

        Just selection ->
            List.map
                (\item -> ( item, selection == item ))
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


{-| Apply a function to only the selected item, if any item is selected.
-}
mapSelected : (a -> a) -> Selection a -> Selection a
mapSelected fn (Selection selected items) =
    Selection
        (Maybe.map fn selected)
        (List.map
            (\item ->
                if Just item == selected then
                    fn item
                else
                    item
            )
            items
        )


{-| Decode a selection from JSON. The result won't have any item
selected.

If you need to decode the selection too, use `map2`. Here's an
example, assuming that you have "selected" and "items" in your JSON:

    import Json.Decode exposing (Decoder, decodeString, field, int, map2)


    yourDecoder : Decoder (Selection Int)
    yourDecoder =
        map2 select
            (field "selected" int)
            (field "items" (decoder int))


    result : Result String (Selection Int)
    result =
        decodeString yourDecoder
            """{"selected": 2, "items": [1, 2, 3]}"""

    Result.map selected result --> Ok (Just 2)

    Result.map toList result --> Ok [1, 2, 3]

-}
decoder : Decoder a -> Decoder (Selection a)
decoder =
    Decode.list >> Decode.map fromList
