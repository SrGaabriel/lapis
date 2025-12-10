{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE LambdaCase #-}

module Test.Hover (spec) where

import Test.Hspec
import Language.LSP.Test (runSessionWithConfig, defaultConfig, SessionConfig(..), openDoc, createDoc, closeDoc, getHover)
import Language.LSP.Protocol.Types
import Control.Monad.IO.Class (liftIO)
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
spec = describe "Hover" $ do
  it "returns hover info for a word" $
    runSessionWithConfig (mkConfig lspCmd) lspCmd def "." $ do
      doc <- createDoc "test.txt" "plaintext" "hello world"

      let pos = Position 0 2
      hover' <- getHover doc pos

      liftIO $ do
        hover' `shouldSatisfy` \case
          Just (Hover (InL (MarkupContent MarkupKind_Markdown content)) _) ->
            "hello" `T.isInfixOf` content
          _ -> False

      closeDoc doc

  it "returns Nothing for whitespace" $
    runSessionWithConfig (mkConfig lspCmd) lspCmd def "." $ do
      doc <- createDoc "test.txt" "plaintext" "hello   world"

      let pos = Position 0 6
      hover' <- getHover doc pos

      liftIO $ hover' `shouldBe` Nothing

      closeDoc doc

  it "handles hover at start of word" $
    runSessionWithConfig (mkConfig lspCmd) lspCmd def "." $ do
      doc <- createDoc "test.txt" "plaintext" "example"

      let pos = Position 0 0
      hover' <- getHover doc pos

      liftIO $ do
        hover' `shouldSatisfy` \case
          Just (Hover (InL (MarkupContent _ content)) _) ->
            "example" `T.isInfixOf` content
          _ -> False

      closeDoc doc

  it "handles hover at middle of word" $
    runSessionWithConfig (mkConfig lspCmd) lspCmd def "." $ do
      doc <- createDoc "test.txt" "plaintext" "example"

      let pos = Position 0 3
      hover' <- getHover doc pos

      liftIO $ do
        hover' `shouldSatisfy` \case
          Just (Hover (InL (MarkupContent _ content)) _) ->
            "example" `T.isInfixOf` content
          _ -> False

      closeDoc doc

  it "shows position information in hover" $
    runSessionWithConfig (mkConfig lspCmd) lspCmd def "." $ do
      doc <- createDoc "test.txt" "plaintext" "hello"

      let pos = Position 0 2
      hover' <- getHover doc pos

      liftIO $ do
        hover' `shouldSatisfy` \case
          Just (Hover (InL (MarkupContent _ content)) _) ->
            ("line 0" `T.isInfixOf` content) && ("char 2" `T.isInfixOf` content)
          _ -> False

      closeDoc doc

  it "handles multiline documents" $
    runSessionWithConfig (mkConfig lspCmd) lspCmd def "." $ do
      doc <- createDoc "test.txt" "plaintext" "line1\nline2\nline3"

      let pos = Position 1 2
      hover' <- getHover doc pos

      liftIO $ do
        hover' `shouldSatisfy` \case
          Just (Hover (InL (MarkupContent _ content)) _) ->
            ("line2" `T.isInfixOf` content) && ("line 1" `T.isInfixOf` content)
          _ -> False

      closeDoc doc

  it "returns Nothing for out of bounds position" $
    runSessionWithConfig (mkConfig lspCmd) lspCmd def "." $ do
      doc <- createDoc "test.txt" "plaintext" "short"

      let pos = Position 5 0
      hover' <- getHover doc pos

      liftIO $ hover' `shouldBe` Nothing

      closeDoc doc

  it "handles words with underscores" $
    runSessionWithConfig (mkConfig lspCmd) lspCmd def "." $ do
      doc <- createDoc "test.txt" "plaintext" "hello_world"

      let pos = Position 0 7
      hover' <- getHover doc pos

      liftIO $ do
        hover' `shouldSatisfy` \case
          Just (Hover (InL (MarkupContent _ content)) _) ->
            "hello_world" `T.isInfixOf` content
          _ -> False

      closeDoc doc
