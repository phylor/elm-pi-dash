module Dashboard exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Messages exposing (..)


viewCountdown : Msg -> Int -> String -> Html Msg
viewCountdown cancelMessage countdown iconClass =
    div [ onClick cancelMessage ]
        [ p [ class "status" ]
            [ div [ class "status-icon active" ]
                [ div []
                    [ i [ class ("fa fa-spin " ++ iconClass) ] []
                    ]
                ]
            , text (toString countdown)
            ]
        ]


