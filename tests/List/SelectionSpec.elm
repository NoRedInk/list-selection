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
            [ fuzz3 Fuzz.int Fuzz.int (Fuzz.list Fuzz.int) "when we have a selection, the last selected item that exists will be selected" <|
                \a b items ->
                    Selection.fromList items
                        |> Selection.select a
                        |> Selection.select b
                        |> Selection.selected
                        |> Expect.equal
                            (Maybe.Extra.or
                                (List.Extra.find ((==) b) items)
                                (List.Extra.find ((==) a) items)
                            )
            , fuzz2 Fuzz.int (selection Fuzz.int) "selecting an item and then deselecting it unsets the selection" <|
                \a items ->
                    items
                        |> Selection.select a
                        |> Selection.deselect
                        |> Selection.selected
                        |> Expect.equal Nothing
            ]
        , describe "mapping"
            [ fuzz (Fuzz.list Fuzz.int) "identity" <|
                \xs ->
                    Selection.fromList xs
                        |> Selection.map identity
                        |> Expect.equal (Selection.fromList xs)
            , fuzz (Fuzz.list Fuzz.int) "composition" <|
                \xs ->
                    Selection.fromList xs
                        |> Selection.map ((+) 1 >> (*) 2)
                        |> Expect.equal
                            (Selection.fromList xs
                                |> Selection.map ((+) 1)
                                |> Selection.map ((*) 2)
                            )
            ]
        ]
