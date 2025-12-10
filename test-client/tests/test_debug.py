import asyncio

import pytest
from lsprotocol.types import (
    WINDOW_SHOW_MESSAGE,
    DidOpenTextDocumentParams,
    TextDocumentItem,
)


@pytest.mark.asyncio
async def test_server_responds_to_didopen(client):
    """Test that server responds when document is opened."""
    uri = "file:///test.txt"

    # Open a document
    client.text_document_did_open(
        DidOpenTextDocumentParams(
            text_document=TextDocumentItem(
                uri=uri,
                language_id="plaintext",
                version=1,
                text="This is a TODO comment",
            )
        )
    )

    # Wait for the showInfo message that the server sends
    try:
        await asyncio.wait_for(
            client.wait_for_notification(WINDOW_SHOW_MESSAGE), timeout=5.0
        )
        print("SUCCESS: Got window/showMessage notification")
    except asyncio.TimeoutError:
        pytest.fail("Timed out waiting for window/showMessage. Handler not executing?")

    # Check if we got the message
    assert len(client.messages) > 0, "Expected at least one window message"
    assert "opened" in client.messages[0].message.lower()
