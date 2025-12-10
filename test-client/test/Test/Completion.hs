{-# LANGUAGE OverloadedStrings #-}

module Test.Completion (spec) where

import Test.Hspec
import Language.LSP.Test (runSessionWithConfig, defaultConfig, SessionConfig(..), createDoc, closeDoc, getCompletions)
import Language.LSP.Protocol.Types
import Control.Monad.IO.Class (liftIO)
import Control.Lens ((^.))
import Language.LSP.Protocol.Lens
import qualified Data.Text as T
import Data.Default (def)

lspCmd :: String
lspCmd = "../.lake/build/bin/lapis"

mkConfig :: String -> SessionConfig
mkConfig cmd = defaultConfig
  { messageTimeout = 5
  , logStdErr = True
  , logMessages = True
  }

spec :: Spec
spec = describe "Completion" $ do
  it "returns completion items" $
    runSessionWithConfig (mkConfig lspCmd) lspCmd def "." $ do
      doc <- createDoc "test.txt" "plaintext" "h"

      let pos = Position 0 1
      completions <- getCompletions doc pos

      liftIO $ do
        completions `shouldSatisfy` (not . null)

        let labels = map (^. label) completions
        labels `shouldSatisfy` elem "hello"
        labels `shouldSatisfy` elem "world"

      closeDoc doc

  it "includes completion item details" $
    runSessionWithConfig (mkConfig lspCmd) lspCmd def "." $ do
      doc <- createDoc "test.txt" "plaintext" ""

      let pos = Position 0 0
      completions <- getCompletions doc pos

      liftIO $ do
        let helloItem = filter (\c -> (c ^. label) == "hello") completions
        helloItem `shouldSatisfy` (not . null)

        case helloItem of
          (item:_) -> do
            (item ^. detail) `shouldBe` Just "A greeting"
            (item ^. kind) `shouldBe` Just CompletionItemKind_Text
          [] -> expectationFailure "No hello completion found"

      closeDoc doc

  it "returns all static completions" $
    runSessionWithConfig (mkConfig lspCmd) lspCmd def "." $ do
      doc <- createDoc "test.txt" "plaintext" ""

      let pos = Position 0 0
      completions <- getCompletions doc pos

      liftIO $ do
        Prelude.length completions `shouldBe` 2

        let labels = map (^. label) completions
        labels `shouldContain` ["hello"]
        labels `shouldContain` ["world"]

      closeDoc doc

  it "works at different positions" $
    runSessionWithConfig (mkConfig lspCmd) lspCmd def "." $ do
      doc <- createDoc "test.txt" "plaintext" "some text here"

      let pos = Position 0 5
      completions <- getCompletions doc pos

      liftIO $ do
        completions `shouldSatisfy` (not . null)
        let labels = map (^. label) completions
        labels `shouldSatisfy` elem "hello"

      closeDoc doc

  it "works on multiple lines" $
    runSessionWithConfig (mkConfig lspCmd) lspCmd def "." $ do
      doc <- createDoc "test.txt" "plaintext" "line1\nline2\nline3"

      let pos = Position 1 3
      completions <- getCompletions doc pos

      liftIO $ do
        completions `shouldSatisfy` (not . null)

      closeDoc doc

  it "completion list is not marked incomplete" $
    runSessionWithConfig (mkConfig lspCmd) lspCmd def "." $ do
      doc <- createDoc "test.txt" "plaintext" ""

      let pos = Position 0 0
      completions <- getCompletions doc pos

      liftIO $ completions `shouldSatisfy` (not . null)

      closeDoc doc
