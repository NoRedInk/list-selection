module List.SelectionSpec exposing (..)

import Expect
import Fuzz exposing (Fuzzer)
import List.Extra
import List.Selection as Selection exposing (Selection)
import Maybe.Extra
import Set
import Test exposing (..)


selection : Fuzzer comparable -> Fuzzer (Selection comparable)
selection =
    Fuzz.list
        -- our invariants only hold for lists with unique items, so remove those.
        >> Fuzz.map Set.fromList
        >> Fuzz.map Set.toList
        -- construct our Selection!
        >> Fuzz.map Selection.fromList


nonemptySelection : Fuzzer comparable -> Fuzzer ( comparable, Selection comparable )
nonemptySelection kind =
    Fuzz.map2
        (\item items ->
            ( item
            , (item :: items)
                |> Set.fromList
                |> Set.toList
                |> Selection.fromList
            )
        )
        kind
        (Fuzz.list kind)


spec : Test
spec =
    describe "List.Selection"
        [ describe "conversions"
            [ fuzz (Fuzz.list Fuzz.int) "every list should be constructable" <|
                \xs ->
                    Selection.fromList xs
                        |> Selection.toList
                        |> Expect.equal xs
            , fuzz2 Fuzz.int (Fuzz.list Fuzz.int) "selection doesn't effect toList output" <|
                \a items ->
                    Selection.fromList items
                        |> Selection.select a
                        |> Selection.toList
                        |> Expect.equal items
            , fuzz2 Fuzz.int (selection Fuzz.int) "toListWithSelected has at most one selected item" <|
                \a items ->
                    items
                        |> Selection.select a
                        |> Selection.toListWithSelected
                        |> List.filter (Tuple.second >> (==) True)
                        |> List.length
                        |> Expect.atMost 1
            ]
        , describe "selections"
            [ fuzz (nonemptySelection Fuzz.int) "selecting an item works" <|
                \( item, items ) ->
                    items
                        |> Selection.select item
                        |> Selection.selected
                        |> Expect.equal (Just item)
            , fuzz (nonemptySelection Fuzz.int) "selecting an item and then deselecting it unsets the selection" <|
                \( item, items ) ->
                    items
                        |> Selection.select item
                        |> Selection.deselect
                        |> Selection.selected
                        |> Expect.equal Nothing
            ]
        , describe "mapping"
            [ fuzz (selection Fuzz.int) "identity" <|
                \items ->
                    items
                        |> Selection.map identity
                        |> Expect.equal items
            , fuzz (selection Fuzz.int) "composition" <|
                \items ->
                    items
                        |> Selection.map ((+) 1 >> (*) 2)
                        |> Expect.equal
                            (items
                                |> Selection.map ((+) 1)
                                |> Selection.map ((*) 2)
                            )
            , fuzz (selection Fuzz.int) "map and mapSelected are identical with identical functions" <|
                \items ->
                    Expect.equal
                        (Selection.map ((*) 2) items)
                        (Selection.mapSelected { selected = (*) 2, rest = (*) 2 } items)
            , fuzz (nonemptySelection Fuzz.int) "only maps the selected item" <|
                \( item, items ) ->
                    items
                        |> Selection.select item
                        |> Selection.mapSelected { selected = (*) 2, rest = identity }
                        |> Selection.selected
                        |> Expect.equal (Just (item * 2))
            , fuzz (nonemptySelection Fuzz.int) "maps the original value of the selected item" <|
                \( item, items ) ->
                    items
                        |> Selection.select item
                        |> Selection.mapSelected { selected = (*) 2, rest = identity }
                        |> Selection.toList
                        |> List.member (item * 2)
                        |> Expect.true "list should contain mapped original item (and it didn't)"
            , fuzz (selection Fuzz.int) "doesn't map anything else" <|
                \items ->
                    items
                        |> Selection.mapSelected { selected = (*) 2, rest = identity }
                        |> Expect.equal items
            ]
        ]
