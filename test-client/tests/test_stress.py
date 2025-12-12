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
async def test_rapid_hover_requests(client: LanguageClient):
    """
    Test server handles rapid hover requests without freezing.

    Simulates user quickly moving cursor around, generating many hover requests.
    """
    # Open a document
    client.text_document_did_open(
        DidOpenTextDocumentParams(
            text_document=TextDocumentItem(
                uri="file:///stress_hover.txt",
                language_id="plaintext",
                version=1,
                text="hello world\nfoo bar baz\ntest line here\n" * 10,
            )
        )
    )

    # Fire off many hover requests concurrently
    tasks = []
    for i in range(50):
        line = i % 10
        char = (i * 3) % 15
        tasks.append(
            client.text_document_hover_async(
                HoverParams(
                    text_document=TextDocumentIdentifier(
                        uri="file:///stress_hover.txt"
                    ),
                    position=Position(line=line, character=char),
                )
            )
        )

    # Wait for all with timeout - if this times out, server is deadlocked
    results = await asyncio.wait_for(
        asyncio.gather(*tasks, return_exceptions=True), timeout=30.0
    )

    # All requests should complete (success or error, but no timeout)
    assert len(results) == 50


@pytest.mark.asyncio
async def test_rapid_hover_different_positions(client: LanguageClient):
    """
    Test server handles rapid hover requests at many different positions.

    Simulates user quickly moving cursor around the document.
    """
    client.text_document_did_open(
        DidOpenTextDocumentParams(
            text_document=TextDocumentItem(
                uri="file:///stress_positions.txt",
                language_id="plaintext",
                version=1,
                text="function foo() {}\nfunction bar() {}\ncall foo\ncall bar\n" * 5,
            )
        )
    )

    # Fire off many hover requests at different positions concurrently
    tasks = []
    for i in range(50):
        line = i % 20
        char = (i * 2) % 10
        tasks.append(
            client.text_document_hover_async(
                HoverParams(
                    text_document=TextDocumentIdentifier(
                        uri="file:///stress_positions.txt"
                    ),
                    position=Position(line=line, character=char),
                )
            )
        )

    results = await asyncio.wait_for(
        asyncio.gather(*tasks, return_exceptions=True), timeout=30.0
    )

    assert len(results) == 50


@pytest.mark.asyncio
async def test_rapid_typing_simulation(client: LanguageClient):
    """
    Test server handles rapid document changes without freezing.

    Simulates user typing very quickly, generating many didChange notifications.
    """
    uri = "file:///stress_typing.txt"

    client.text_document_did_open(
        DidOpenTextDocumentParams(
            text_document=TextDocumentItem(
                uri=uri,
                language_id="plaintext",
                version=1,
                text="",
            )
        )
    )

    # Simulate rapid typing - each keystroke is a change notification
    text = ""
    for i in range(100):
        char = chr(ord("a") + (i % 26))
        text += char

        client.text_document_did_change(
            DidChangeTextDocumentParams(
                text_document=VersionedTextDocumentIdentifier(
                    uri=uri,
                    version=i + 2,
                ),
                content_changes=[{"text": text}],
            )
        )

    # Small delay to let notifications process
    await asyncio.sleep(0.5)

    # Now try a hover request to verify server is still responsive
    result = await asyncio.wait_for(
        client.text_document_hover_async(
            HoverParams(
                text_document=TextDocumentIdentifier(uri=uri),
                position=Position(line=0, character=0),
            )
        ),
        timeout=5.0,
    )

    # Server responded - test passes
    assert True


@pytest.mark.asyncio
async def test_sustained_load(client: LanguageClient):
    """
    Test server handles sustained load over time without degrading.

    Sends requests in waves to simulate sustained editor usage.
    """
    uri = "file:///stress_sustained.txt"

    client.text_document_did_open(
        DidOpenTextDocumentParams(
            text_document=TextDocumentItem(
                uri=uri,
                language_id="plaintext",
                version=1,
                text="line of text\n" * 50,
            )
        )
    )

    # Multiple waves of requests
    for wave in range(5):
        tasks = []
        for i in range(20):
            line = (wave * 10 + i) % 50
            tasks.append(
                client.text_document_hover_async(
                    HoverParams(
                        text_document=TextDocumentIdentifier(uri=uri),
                        position=Position(line=line, character=5),
                    )
                )
            )

        # Each wave should complete without timeout
        results = await asyncio.wait_for(
            asyncio.gather(*tasks, return_exceptions=True), timeout=15.0
        )

        assert len(results) == 20

        # Brief pause between waves
        await asyncio.sleep(0.1)


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
