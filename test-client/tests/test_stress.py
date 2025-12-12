"""
Stress tests for LSP server under high request load.

These tests reproduce issues where the server freezes or stops responding
when bombarded with many concurrent requests.
"""

import asyncio

import pytest
from lsprotocol.types import (
    DidChangeTextDocumentParams,
    DidOpenTextDocumentParams,
    HoverParams,
    Position,
    TextDocumentIdentifier,
    TextDocumentItem,
    VersionedTextDocumentIdentifier,
)
from pytest_lsp import LanguageClient

@pytest.mark.asyncio
async def test_extreme_concurrent_requests(client: LanguageClient):
    """
    Stress test: 75 concurrent requests.

    This test specifically targets the deadlock issue where the server
    freezes under high contention.
    """
    uri = "file:///stress_extreme.txt"

    client.text_document_did_open(
        DidOpenTextDocumentParams(
            text_document=TextDocumentItem(
                uri=uri,
                language_id="plaintext",
                version=1,
                text="content " * 100 + "\n" * 50,
            )
        )
    )

    # Fire 75 requests at once
    tasks = []
    for i in range(75):
        line = i % 50
        char = i % 20
        tasks.append(
            client.text_document_hover_async(
                HoverParams(
                    text_document=TextDocumentIdentifier(uri=uri),
                    position=Position(line=line, character=char),
                )
            )
        )

    # This is where the deadlock would manifest - requests never complete
    results = await asyncio.wait_for(
        asyncio.gather(*tasks, return_exceptions=True), timeout=30.0
    )

    # If we get here, server didn't deadlock - all 75 requests completed
    assert len(results) == 75
