"""Tests for Lapis LSP diagnostics."""

import asyncio

import pytest
from lsprotocol.types import (
    TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS,
    DiagnosticSeverity,
    DidChangeTextDocumentParams,
    DidOpenTextDocumentParams,
    TextDocumentContentChangeEvent,
    TextDocumentItem,
    VersionedTextDocumentIdentifier,
)


@pytest.mark.asyncio
async def test_todo_diagnostic(client):
    """Test that TODO comments generate warnings."""
    uri = "file:///test.txt"

    # Open a document with a TODO (notification, no await)
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

    # Wait for diagnostics with a timeout
    try:
        await asyncio.wait_for(
            client.wait_for_notification(TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS), timeout=5.0
        )
    except asyncio.TimeoutError:
        pytest.fail(
            "Timed out waiting for diagnostics. Server may not be sending them."
        )

    # Check diagnostics
    diagnostics = client.diagnostics.get(uri, [])
    assert len(diagnostics) >= 1, (
        f"Expected at least 1 diagnostic, got {len(diagnostics)}: {diagnostics}"
    )
    assert diagnostics[0].severity == DiagnosticSeverity.Warning
    assert diagnostics[0].message == "TODO comment found"


@pytest.mark.asyncio
async def test_fixme_diagnostic(client):
    """Test that FIXME comments generate errors."""
    uri = "file:///test2.txt"

    client.text_document_did_open(
        DidOpenTextDocumentParams(
            text_document=TextDocumentItem(
                uri=uri,
                language_id="plaintext",
                version=1,
                text="This is a FIXME comment",
            )
        )
    )

    try:
        await asyncio.wait_for(
            client.wait_for_notification(TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS), timeout=5.0
        )
    except asyncio.TimeoutError:
        pytest.fail("Timed out waiting for diagnostics")

    diagnostics = client.diagnostics.get(uri, [])
    assert len(diagnostics) == 1
    assert diagnostics[0].severity == DiagnosticSeverity.Error
    assert "FIXME" in diagnostics[0].message


@pytest.mark.asyncio
async def test_multiple_diagnostics(client):
    """Test multiple diagnostics in one file."""
    uri = "file:///test3.txt"

    client.text_document_did_open(
        DidOpenTextDocumentParams(
            text_document=TextDocumentItem(
                uri=uri,
                language_id="plaintext",
                version=1,
                text="TODO: something\nFIXME: urgent",
            )
        )
    )

    try:
        await asyncio.wait_for(
            client.wait_for_notification(TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS), timeout=5.0
        )
    except asyncio.TimeoutError:
        pytest.fail("Timed out waiting for diagnostics")

    diagnostics = client.diagnostics.get(uri, [])
    assert len(diagnostics) == 2


@pytest.mark.asyncio
async def test_diagnostics_clear_on_fix(client):
    """Test that diagnostics are cleared when content is fixed."""
    uri = "file:///test4.txt"

    # Open with TODO
    client.text_document_did_open(
        DidOpenTextDocumentParams(
            text_document=TextDocumentItem(
                uri=uri, language_id="plaintext", version=1, text="TODO: something"
            )
        )
    )

    try:
        await asyncio.wait_for(
            client.wait_for_notification(TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS), timeout=5.0
        )
    except asyncio.TimeoutError:
        pytest.fail("Timed out waiting for initial diagnostics")

    diagnostics = client.diagnostics.get(uri, [])
    assert len(diagnostics) == 1

    # Change to clean content
    client.text_document_did_change(
        DidChangeTextDocumentParams(
            text_document=VersionedTextDocumentIdentifier(uri=uri, version=2),
            content_changes=[{"text": "Clean content"}],
        )
    )

    try:
        await asyncio.wait_for(
            client.wait_for_notification(TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS), timeout=5.0
        )
    except asyncio.TimeoutError:
        pytest.fail("Timed out waiting for updated diagnostics")

    diagnostics = client.diagnostics.get(uri, [])
    assert len(diagnostics) == 0


@pytest.mark.asyncio
async def test_diagnostics_update_on_change(client):
    """Test that diagnostics update when content changes."""
    uri = "file:///test5.txt"

    # Start with clean content
    client.text_document_did_open(
        DidOpenTextDocumentParams(
            text_document=TextDocumentItem(
                uri=uri, language_id="plaintext", version=1, text="Clean content"
            )
        )
    )

    try:
        await asyncio.wait_for(
            client.wait_for_notification(TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS), timeout=5.0
        )
    except asyncio.TimeoutError:
        pytest.fail("Timed out waiting for initial diagnostics")

    diagnostics = client.diagnostics.get(uri, [])
    assert len(diagnostics) == 0

    # Add a TODO
    client.text_document_did_change(
        DidChangeTextDocumentParams(
            text_document=VersionedTextDocumentIdentifier(uri=uri, version=2),
            content_changes=[{"text": "TODO: add feature"}],
        )
    )

    try:
        await asyncio.wait_for(
            client.wait_for_notification(TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS), timeout=5.0
        )
    except asyncio.TimeoutError:
        pytest.fail("Timed out waiting for updated diagnostics")

    diagnostics = client.diagnostics.get(uri, [])
    assert len(diagnostics) == 1
