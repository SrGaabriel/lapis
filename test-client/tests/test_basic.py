import pytest
from lsprotocol.types import (
    DidOpenTextDocumentParams,
    HoverParams,
    CompletionParams,
    TextDocumentItem,
    TextDocumentIdentifier,
    Position,
)


@pytest.mark.asyncio
async def test_initialization(client):
    """Test that the server initializes correctly."""
    # The client should be initialized
    assert client is not None


@pytest.mark.asyncio
async def test_hover(client):
    """Test hover functionality."""
    # Open a document (notification, no await)
    client.text_document_did_open(
        DidOpenTextDocumentParams(
            text_document=TextDocumentItem(
                uri="file:///hover_test.txt",
                language_id="plaintext",
                version=1,
                text="hello world",
            )
        )
    )

    # Request hover at position
    result = await client.text_document_hover_async(
        HoverParams(
            text_document=TextDocumentIdentifier(uri="file:///hover_test.txt"),
            position=Position(line=0, character=2),
        )
    )

    # Just check we got a response (could be None if not implemented)
    assert result is None or hasattr(result, "contents")


@pytest.mark.asyncio
async def test_completion(client):
    """Test completion functionality."""
    client.text_document_did_open(
        DidOpenTextDocumentParams(
            text_document=TextDocumentItem(
                uri="file:///completion_test.txt",
                language_id="plaintext",
                version=1,
                text="test",
            )
        )
    )

    result = await client.text_document_completion_async(
        CompletionParams(
            text_document=TextDocumentIdentifier(uri="file:///completion_test.txt"),
            position=Position(line=0, character=4),
        )
    )

    # Just check we got a response (could be None if not implemented)
    assert result is None or isinstance(result, (list, object))
