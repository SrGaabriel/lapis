{-# LANGUAGE OverloadedStrings #-}

module Test.DocumentSync (spec) where

import Test.Hspec
import Language.LSP.Test (runSessionWithConfig, defaultConfig, SessionConfig(..), createDoc, closeDoc)
import Language.LSP.Protocol.Types
import Control.Monad.IO.Class (liftIO)
import Data.Default (def)

lspCmd :: String
lspCmd = "../.lake/build/bin/lapis"

mkConfig :: String -> SessionConfig
mkConfig _cmd = defaultConfig
  { messageTimeout = 5
  , logStdErr = True
  , logMessages = True
  }

  
-- todo: actual checks
spec :: Spec
spec = describe "Document Synchronization" $ do
  it "opens a document" $
    runSessionWithConfig (mkConfig lspCmd) lspCmd def "." $ do
      doc <- createDoc "test.txt" "plaintext" "Hello, world!"

      liftIO $ True `shouldBe` True

      closeDoc doc

  it "closes a document" $
    runSessionWithConfig (mkConfig lspCmd) lspCmd def "." $ do
      doc <- createDoc "test.txt" "plaintext" "Content"

      closeDoc doc

      liftIO $ True `shouldBe` True

  it "handles multiple documents simultaneously" $
    runSessionWithConfig (mkConfig lspCmd) lspCmd def "." $ do
      doc1 <- createDoc "file1.txt" "plaintext" "File 1"
      doc2 <- createDoc "file2.txt" "plaintext" "File 2"
      doc3 <- createDoc "file3.txt" "plaintext" "File 3"

      closeDoc doc2

      liftIO $ True `shouldBe` True

      closeDoc doc1
      closeDoc doc3
