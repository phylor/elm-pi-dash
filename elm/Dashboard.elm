module Dashboard exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Messages exposing (..)


viewCountdown model =
    div [ onClick CancelCountdown ]
        [ p [ class "status" ]
            [ div [ class "status-icon active" ]
                [ div []
                    [ i [ class "fa fa-lock fa-spin" ] []
                    ]
                ]
            , text (toString model.countdown)
            ]
        ]


