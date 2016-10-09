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
                    [ i [ class ("fa-spin " ++ iconClass) ] []
                    ]
                ]
            , text (toString countdown)
            ]
        ]


viewAction label onClickMessage iconClasses =
    div [ class "pure-u-1-3" ]
        [ div [ class "icon-box", onClick onClickMessage ]
            [ div [ class "fa" ] []
            , div [ class "title" ] [ text label ]
            , p [ class "icon" ]
                [ i [ class iconClasses ] []
                ]
            ]
        ]


viewCountdownAction label countdownActive countdownSeconds cancelMessage startMessage iconClasses =
    div [ class "box" ]
        [ div [ class "fa" ] []
        , div [ class "title" ] [ text label ]
        , viewCountdownContent countdownActive countdownSeconds cancelMessage startMessage iconClasses
        ]


viewCountdownContent countdownActive countdownSeconds cancelMessage startMessage iconClasses =
    if countdownActive then
        p [ class "status" ]
            [ viewCountdown cancelMessage countdownSeconds iconClasses
            ]
    else
        p [ class "status", onClick startMessage ]
            [ div [ class "status-icon inactive" ]
                [ div []
                    [ i [ class iconClasses ] []
                    ]
                ]
            ]
