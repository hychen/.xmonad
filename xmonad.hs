-- Author: hychen
-- License: public domain
import Data.Ratio ((%))

import XMonad
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

--------------------------------------------------------------------------
-- Common
--------------------------------------------------------------------------
myWorkspaces = ["Web", "Dev", "Stage", "File", "Read", "IM", "IRC", "Mail"]
myFadeAmount = 0.8

-- Prefer Applications (class name)
appIM   = "pidgin"
appIRC  = "Xchat"
appMail = "Thunderbird"
appFileM = "Nautilus"

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

-- contexts
myCode = myWide ||| Full

perWS = onWorkspace "Dev" myCode $ 
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

--------------------------------------------------------------------------
-- Main
--------------------------------------------------------------------------
main = do
  xmonad $ gnomeConfig 
         { manageHook = myManageHook
         , logHook    = myLogHook
         , layoutHook = myLayoutHook
         , workspaces = myWorkspaces
         , modMask    = mod4Mask 
         }
