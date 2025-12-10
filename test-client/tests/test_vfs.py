import asyncio

import pytest
from lsprotocol.types import (
    TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS,
    DidChangeTextDocumentParams,
    DidOpenTextDocumentParams,
    Position,
    Range,
    TextDocumentContentChangeEvent,
    TextDocumentItem,
    VersionedTextDocumentIdentifier,
)


@pytest.mark.asyncio
async def test_incremental_edit_insert(client):
    """Test inserting text with incremental edits."""
    uri = "file:///vfs_test1.txt"

    # Open with initial content
    client.text_document_did_open(
        DidOpenTextDocumentParams(
            text_document=TextDocumentItem(
                uri=uri,
                language_id="plaintext",
                version=1,
                text="Hello World",
            )
        )
    )

    try:
        await asyncio.wait_for(
            client.wait_for_notification(TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS), timeout=5.0
        )
    except asyncio.TimeoutError:
        pytest.fail("Timed out waiting for diagnostics")

    # No diagnostics initially
    diagnostics = client.diagnostics.get(uri, [])
    assert len(diagnostics) == 0

    # Insert "TODO " at position 0 using incremental edit
    client.text_document_did_change(
        DidChangeTextDocumentParams(
            text_document=VersionedTextDocumentIdentifier(uri=uri, version=2),
            content_changes=[
                {
                    "range": {
                        "start": {"line": 0, "character": 0},
                        "end": {"line": 0, "character": 0},
                    },
                    "text": "TODO ",
                }
            ],
        )
    )

    try:
        await asyncio.wait_for(
            client.wait_for_notification(TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS), timeout=5.0
        )
    except asyncio.TimeoutError:
        pytest.fail("Timed out waiting for diagnostics after edit")

    # Should now have TODO diagnostic
    diagnostics = client.diagnostics.get(uri, [])
    assert len(diagnostics) == 1
    assert diagnostics[0].message == "TODO comment found"


@pytest.mark.asyncio
async def test_incremental_edit_delete(client):
    """Test deleting text with incremental edits."""
    uri = "file:///vfs_test2.txt"

    # Open with TODO content
    client.text_document_did_open(
        DidOpenTextDocumentParams(
            text_document=TextDocumentItem(
                uri=uri,
                language_id="plaintext",
                version=1,
                text="TODO: fix this",
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

    # Delete "TODO" (first 4 characters) using incremental edit
    client.text_document_did_change(
        DidChangeTextDocumentParams(
            text_document=VersionedTextDocumentIdentifier(uri=uri, version=2),
            content_changes=[
                {
                    "range": {
                        "start": {"line": 0, "character": 0},
                        "end": {"line": 0, "character": 4},
                    },
                    "text": "",
                }
            ],
        )
    )

    try:
        await asyncio.wait_for(
            client.wait_for_notification(TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS), timeout=5.0
        )
    except asyncio.TimeoutError:
        pytest.fail("Timed out waiting for diagnostics after delete")

    # Should have no diagnostics now
    diagnostics = client.diagnostics.get(uri, [])
    assert len(diagnostics) == 0


@pytest.mark.asyncio
async def test_incremental_edit_replace(client):
    """Test replacing text with incremental edits."""
    uri = "file:///vfs_test3.txt"

    # Open with TODO content
    client.text_document_did_open(
        DidOpenTextDocumentParams(
            text_document=TextDocumentItem(
                uri=uri,
                language_id="plaintext",
                version=1,
                text="TODO: something",
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
    assert diagnostics[0].message == "TODO comment found"

    # Replace "TODO" with "FIXME"
    client.text_document_did_change(
        DidChangeTextDocumentParams(
            text_document=VersionedTextDocumentIdentifier(uri=uri, version=2),
            content_changes=[
                {
                    "range": {
                        "start": {"line": 0, "character": 0},
                        "end": {"line": 0, "character": 4},
                    },
                    "text": "FIXME",
                }
            ],
        )
    )

    try:
        await asyncio.wait_for(
            client.wait_for_notification(TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS), timeout=5.0
        )
    except asyncio.TimeoutError:
        pytest.fail("Timed out waiting for diagnostics after replace")

    # Should have FIXME diagnostic now
    diagnostics = client.diagnostics.get(uri, [])
    assert len(diagnostics) == 1
    assert "FIXME" in diagnostics[0].message


@pytest.mark.asyncio
async def test_multiline_document(client):
    """Test handling of multi-line documents."""
    uri = "file:///vfs_test4.txt"

    # Open with multi-line content
    content = """Line 1: normal
Line 2: TODO here
Line 3: normal
Line 4: FIXME here
Line 5: normal"""

    client.text_document_did_open(
        DidOpenTextDocumentParams(
            text_document=TextDocumentItem(
                uri=uri,
                language_id="plaintext",
                version=1,
                text=content,
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

    # Check line positions
    lines = [d.range.start.line for d in diagnostics]
    assert 1 in lines  # TODO on line 1
    assert 3 in lines  # FIXME on line 3


@pytest.mark.asyncio
async def test_multiline_edit(client):
    """Test edits that span multiple lines."""
    uri = "file:///vfs_test5.txt"

    # Open with multi-line content
    client.text_document_did_open(
        DidOpenTextDocumentParams(
            text_document=TextDocumentItem(
                uri=uri,
                language_id="plaintext",
                version=1,
                text="Line 1\nLine 2\nLine 3",
            )
        )
    )

    try:
        await asyncio.wait_for(
            client.wait_for_notification(TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS), timeout=5.0
        )
    except asyncio.TimeoutError:
        pytest.fail("Timed out waiting for diagnostics")

    # Replace lines 1-2 with TODO content
    client.text_document_did_change(
        DidChangeTextDocumentParams(
            text_document=VersionedTextDocumentIdentifier(uri=uri, version=2),
            content_changes=[
                {
                    "range": {
                        "start": {"line": 0, "character": 0},
                        "end": {"line": 1, "character": 6},
                    },
                    "text": "TODO: replaced",
                }
            ],
        )
    )

    try:
        await asyncio.wait_for(
            client.wait_for_notification(TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS), timeout=5.0
        )
    except asyncio.TimeoutError:
        pytest.fail("Timed out waiting for diagnostics after multiline edit")

    diagnostics = client.diagnostics.get(uri, [])
    assert len(diagnostics) == 1
    assert diagnostics[0].range.start.line == 0


@pytest.mark.asyncio
async def test_rapid_edits(client):
    """Test handling of rapid sequential edits."""
    uri = "file:///vfs_test6.txt"

    # Open with TODO content
    client.text_document_did_open(
        DidOpenTextDocumentParams(
            text_document=TextDocumentItem(
                uri=uri,
                language_id="plaintext",
                version=1,
                text="TODO Start",
            )
        )
    )

    try:
        await asyncio.wait_for(
            client.wait_for_notification(TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS), timeout=5.0
        )
    except asyncio.TimeoutError:
        pytest.fail("Timed out waiting for initial diagnostics")

    # Verify initial TODO diagnostic
    diagnostics = client.diagnostics.get(uri, [])
    assert len(diagnostics) == 1

    # Apply multiple rapid edits that prepend text
    for i in range(2, 7):
        client.text_document_did_change(
            DidChangeTextDocumentParams(
                text_document=VersionedTextDocumentIdentifier(uri=uri, version=i),
                content_changes=[
                    {
                        "range": {
                            "start": {"line": 0, "character": 0},
                            "end": {"line": 0, "character": 0},
                        },
                        "text": f"Edit{i} ",
                    }
                ],
            )
        )
        # Small delay between edits
        await asyncio.sleep(0.1)

    # Wait a bit for server to process
    await asyncio.sleep(0.5)

    # The TODO should still be in the document, just moved
    diagnostics = client.diagnostics.get(uri, [])
    assert len(diagnostics) == 1
    assert diagnostics[0].message == "TODO comment found"


@pytest.mark.asyncio
async def test_empty_document(client):
    """Test handling of empty document."""
    uri = "file:///vfs_test7.txt"

    # Open empty document
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

    try:
        await asyncio.wait_for(
            client.wait_for_notification(TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS), timeout=5.0
        )
    except asyncio.TimeoutError:
        pytest.fail("Timed out waiting for diagnostics")

    diagnostics = client.diagnostics.get(uri, [])
    assert len(diagnostics) == 0

    # Add content to empty document
    client.text_document_did_change(
        DidChangeTextDocumentParams(
            text_document=VersionedTextDocumentIdentifier(uri=uri, version=2),
            content_changes=[
                {
                    "range": {
                        "start": {"line": 0, "character": 0},
                        "end": {"line": 0, "character": 0},
                    },
                    "text": "TODO: new content",
                }
            ],
        )
    )

    try:
        await asyncio.wait_for(
            client.wait_for_notification(TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS), timeout=5.0
        )
    except asyncio.TimeoutError:
        pytest.fail("Timed out waiting for diagnostics after edit")

    diagnostics = client.diagnostics.get(uri, [])
    assert len(diagnostics) == 1


@pytest.mark.asyncio
async def test_unicode_content(client):
    """Test handling of unicode content."""
    uri = "file:///vfs_test8.txt"

    # Open with unicode content
    client.text_document_did_open(
        DidOpenTextDocumentParams(
            text_document=TextDocumentItem(
                uri=uri,
                language_id="plaintext",
                version=1,
                text="Hello 世界 🌍 TODO: unicode test",
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
    assert diagnostics[0].message == "TODO comment found"
