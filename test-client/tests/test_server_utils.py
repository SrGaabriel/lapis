"""
Tests for the new server utility features:
- Progress reporting
- Workspace edits
- Debounced diagnostics
- Dynamic capability registration

Note: These tests verify the types compile and the server starts correctly.
Full end-to-end testing of progress/workspace edits requires client support
for those specific LSP features.
"""

import asyncio

import pytest
from lsprotocol.types import (
    TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS,
    DiagnosticSeverity,
    DidChangeTextDocumentParams,
    DidOpenTextDocumentParams,
    HoverParams,
    Position,
    TextDocumentIdentifier,
    TextDocumentItem,
    VersionedTextDocumentIdentifier,
)


@pytest.mark.asyncio
async def test_server_starts_with_new_utils(client):
    """Test that the server starts correctly with the new utility imports."""
    # If we get here, the server initialized successfully with all new imports
    assert client is not None


@pytest.mark.asyncio
async def test_diagnostic_builder_output(client):
    """
    Test that diagnostics are properly formatted.
    This indirectly tests DiagnosticBuilder since the server uses it.
    """
    uri = "file:///diag_builder_test.txt"

    # Open a document with TODO and FIXME
    client.text_document_did_open(
        DidOpenTextDocumentParams(
            text_document=TextDocumentItem(
                uri=uri,
                language_id="plaintext",
                version=1,
                text="TODO: task one\nFIXME: urgent bug",
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
    assert len(diagnostics) == 2, f"Expected 2 diagnostics, got {len(diagnostics)}"

    # Check that diagnostics have proper structure
    for diag in diagnostics:
        assert diag.range is not None
        assert diag.message is not None
        assert diag.severity is not None
        assert diag.source == "example-server"


@pytest.mark.asyncio
async def test_diagnostics_update_quickly(client):
    """
    Test that diagnostics update on document changes.
    This tests the diagnostic publishing flow.
    """
    uri = "file:///quick_update_test.txt"

    # Open with one TODO
    client.text_document_did_open(
        DidOpenTextDocumentParams(
            text_document=TextDocumentItem(
                uri=uri,
                language_id="plaintext",
                version=1,
                text="TODO: first",
            )
        )
    )

    await asyncio.wait_for(
        client.wait_for_notification(TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS), timeout=5.0
    )

    diagnostics = client.diagnostics.get(uri, [])
    assert len(diagnostics) == 1

    # Change to have two TODOs
    client.text_document_did_change(
        DidChangeTextDocumentParams(
            text_document=VersionedTextDocumentIdentifier(uri=uri, version=2),
            content_changes=[{"text": "TODO: first\nTODO: second"}],
        )
    )

    await asyncio.wait_for(
        client.wait_for_notification(TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS), timeout=5.0
    )

    diagnostics = client.diagnostics.get(uri, [])
    assert len(diagnostics) == 2, (
        f"Expected 2 diagnostics after change, got {len(diagnostics)}"
    )


@pytest.mark.asyncio
async def test_diagnostic_range_accuracy(client):
    """Test that diagnostic ranges are accurate."""
    uri = "file:///range_test.txt"

    # TODO at specific position
    client.text_document_did_open(
        DidOpenTextDocumentParams(
            text_document=TextDocumentItem(
                uri=uri,
                language_id="plaintext",
                version=1,
                text="prefix TODO suffix",
            )
        )
    )

    await asyncio.wait_for(
        client.wait_for_notification(TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS), timeout=5.0
    )

    diagnostics = client.diagnostics.get(uri, [])
    assert len(diagnostics) == 1

    diag = diagnostics[0]
    # "prefix " is 7 characters, so TODO starts at character 7
    assert diag.range.start.line == 0
    assert diag.range.start.character == 7
    assert diag.range.end.character == 11  # 7 + 4 (length of "TODO")


@pytest.mark.asyncio
async def test_hover_still_works_with_new_imports(client):
    """Verify hover functionality still works after adding new utility imports."""
    uri = "file:///hover_utils_test.txt"

    client.text_document_did_open(
        DidOpenTextDocumentParams(
            text_document=TextDocumentItem(
                uri=uri,
                language_id="plaintext",
                version=1,
                text="hello world",
            )
        )
    )

    # Small delay for document to be registered
    await asyncio.sleep(0.1)

    result = await client.text_document_hover_async(
        HoverParams(
            text_document=TextDocumentIdentifier(uri=uri),
            position=Position(line=0, character=2),
        )
    )

    assert result is not None
    assert hasattr(result, "contents")
    # The hover should contain the word "hello"
    content_value = (
        result.contents.value
        if hasattr(result.contents, "value")
        else str(result.contents)
    )
    assert "hello" in content_value


@pytest.mark.asyncio
async def test_multiple_documents_independent_diagnostics(client):
    """Test that diagnostics for multiple documents are independent."""
    uri1 = "file:///multi_doc_1.txt"
    uri2 = "file:///multi_doc_2.txt"

    # Open first doc with TODO
    client.text_document_did_open(
        DidOpenTextDocumentParams(
            text_document=TextDocumentItem(
                uri=uri1,
                language_id="plaintext",
                version=1,
                text="TODO: in doc 1",
            )
        )
    )

    await asyncio.wait_for(
        client.wait_for_notification(TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS), timeout=5.0
    )

    # Open second doc with FIXME
    client.text_document_did_open(
        DidOpenTextDocumentParams(
            text_document=TextDocumentItem(
                uri=uri2,
                language_id="plaintext",
                version=1,
                text="FIXME: in doc 2",
            )
        )
    )

    await asyncio.wait_for(
        client.wait_for_notification(TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS), timeout=5.0
    )

    diag1 = client.diagnostics.get(uri1, [])
    diag2 = client.diagnostics.get(uri2, [])

    assert len(diag1) == 1
    assert len(diag2) == 1
    assert diag1[0].severity == DiagnosticSeverity.Warning  # TODO
    assert diag2[0].severity == DiagnosticSeverity.Error  # FIXME
