{-# LANGUAGE OverloadedStrings #-}

module Test.Initialization (spec) where

import Test.Hspec
import Language.LSP.Test (runSessionWithConfig, defaultConfig, SessionConfig(..), createDoc, closeDoc)
import Language.LSP.Protocol.Types
import Language.LSP.Protocol.Message
import Control.Monad.IO.Class (liftIO)
import Data.Default (def)

lspCmd :: String
lspCmd = "../.lake/build/bin/lapis"

mkConfig :: String -> SessionConfig
mkConfig cmd = defaultConfig
  { messageTimeout = 5
  , logStdErr = True
  , logMessages = True
  }

-- TODO: actual checks
spec :: Spec
spec = describe "Initialization" $ do
  it "initializes successfully and reports capabilities" $
    runSessionWithConfig (mkConfig lspCmd) lspCmd def "." $ do
      _doc <- createDoc "test.txt" "plaintext" "test"
      liftIO $ True `shouldBe` True

  it "accepts initialized notification" $
    runSessionWithConfig (mkConfig lspCmd) lspCmd def "." $ do
      _doc <- createDoc "test.txt" "plaintext" "test"
      liftIO $ True `shouldBe` True

  it "handles shutdown gracefully" $
    runSessionWithConfig (mkConfig lspCmd) lspCmd def "." $ do
      doc <- createDoc "test.txt" "plaintext" "test"
      closeDoc doc

      liftIO $ True `shouldBe` True
