{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Test.Hspec
import qualified Test.Initialization
import qualified Test.DocumentSync
import qualified Test.Hover
import qualified Test.Completion

main :: IO ()
main = hspec $ do
  describe "Lapis LSP Server" $ do
    Test.Initialization.spec
    Test.DocumentSync.spec
    Test.Hover.spec
    Test.Completion.spec
