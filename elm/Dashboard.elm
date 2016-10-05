module Dashboard exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Messages exposing (..)


viewCountdown : Msg -> Int -> Html Msg
viewCountdown cancelMessage countdown =
    div [ onClick cancelMessage ]
        [ p [ class "status" ]
            [ div [ class "status-icon active" ]
                [ div []
                    [ i [ class "fa fa-lock fa-spin" ] []
                    ]
                ]
            , text (toString countdown)
            ]
        ]


