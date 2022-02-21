{-# LANGUAGE TemplateHaskell #-}

module Main where

import Hedgehog
import Hedgehog.Main
import GameDemo

prop_test :: Property
prop_test = property $ do
  doGameDemo === "GameDemo"

main :: IO ()
main = defaultMain [checkParallel $$(discover)]
