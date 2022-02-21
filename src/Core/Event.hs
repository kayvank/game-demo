{-# LANGUAGE PackageImports #-}

module Core.Event where

import Core.Geometry ( Pos )
import Data.Time.Clock.System (SystemTime)
import "GLFW-b" Graphics.UI.GLFW (Key (..), KeyState (..), MouseButton (..), MouseButtonState (..))
import Protolude

data Event
  = RenderEvent SystemTime
  | MouseEvent MouseButton MouseButtonState
  | KeyEvent Key KeyState
  | CursorPosEvent Pos
  | WindowSizeEvent Int Int
  | WindowCloseEvent
  deriving (Show)
