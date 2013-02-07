-- Author: hychen
-- License: public domain
import Data.Ratio ((%))

import XMonad
import XMonad.Util.EZConfig
import XMonad.Config.Gnome
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.FadeInactive
import XMonad.Layout.NoBorders
import XMonad.Layout.Grid
import XMonad.Layout.Dishes
import XMonad.Layout.LayoutHints
import XMonad.Layout.PerWorkspace
import XMonad.Layout.LimitWindows
import XMonad.Layout.IM
import XMonad.Layout.Reflect

import qualified XMonad.Prompt         as P
import qualified XMonad.Actions.Submap as SM
import qualified XMonad.Actions.Search as S

--------------------------------------------------------------------------
-- Common
--------------------------------------------------------------------------
myWorkspaces = ["Web", "Dev", "Stage", "File", "Read", "IM", "IRC", "Mail"]
myFadeAmount = 0.8

-- Prefer Applications (class name)
appIM   = "Pidgin"
appIRC  = "Xchat"
appMail = "Thunderbird"
appFileM = "Nautilus"

-- Enabled Search Engine
searchList :: [(String, S.SearchEngine)]
searchList = [ ("g", S.google)
             , ("d", S.dictionary)
             , ("w", S.wikipedia)
             ]
--------------------------------------------------------------------------
-- Manage
--------------------------------------------------------------------------
myManageHook = composeAll
               [ manageHook gnomeConfig
               , manageDocks
               , className =? appFileM         --> doShift "File"
               , className =? appIM            --> doShift "IM"
               , className =? appIRC           --> doShift "IRC"
               , className =? appMail          --> doShift "Mail"
               , resource  =? "Do"             --> doIgnore
               , resource  =? "desktop_window" --> doIgnore
               , isFullscreen                  --> doFullFloat
               , isDialog                      --> doCenterFloat
               ]

--------------------------------------------------------------------------
-- Layout
--------------------------------------------------------------------------

-- ref: http://joeyh.name/blog/entry/xmonad_layouts_for_netbooks/
myWide = Mirror $ Tall nmaster delta ratio
    where
        -- The default number of windows in the master pane
        nmaster = 1
        -- Percent of screen to increment by when resizing panes
        delta   = 3/100
        -- Default proportion of screen occupied by master pane
        ratio   = 80/100

myDish = limitWindows 5 $ Dishes nmaster ratio
    where
        -- The default number of windows in the master pane
        nmaster = 1
        -- Default proportion of screen occupied by other panes
        ratio = 1/5

myCode = myWide ||| Full

myChat' l = reflectHoriz $ withIM size roster $ reflectHoriz $ l
    where
        -- Ratio of screen roster will occupy
        size = 1%5
        -- Match roster window
        roster = Title "Buddy List"
myChat = myChat' Grid

perWS = onWorkspace "Dev" myCode $ 
        onWorkspace "IM" myChat $ 
        onWorkspaces ["Misc", "Stage"] (myDish) $       
        (layoutHook gnomeConfig)
myLayoutHook = smartBorders . avoidStruts . layoutHints $ perWS

--------------------------------------------------------------------------
-- Log
--------------------------------------------------------------------------
myLogHook = composeAll
            [ logHook gnomeConfig
            , fadeInactiveLogHook myFadeAmount
            ] 

myKeys =
 -- Regurlar commands
 []
 -- Search commands
 ++ [("M-f " ++ k, S.promptSearch P.defaultXPConfig f) | (k,f) <- searchList ]
 ++ [("M-d " ++ k, S.selectSearch f) | (k,f) <- searchList ]

--------------------------------------------------------------------------
-- Main
--------------------------------------------------------------------------
main = do
  xmonad $ gnomeConfig 
         { manageHook = myManageHook
         , logHook    = myLogHook
         , layoutHook = myLayoutHook
         , workspaces = myWorkspaces
         , modMask    = mod4Mask }
         `additionalKeysP` myKeys

