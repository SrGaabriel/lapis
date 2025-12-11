"""
Tests for server-initiated LSP features:
- Progress reporting ($/progress)
- Workspace edits (workspace/applyEdit)
- Dynamic capability registration (client/registerCapability)
"""

import asyncio

import pytest
from lsprotocol.types import (
    ApplyWorkspaceEditParams,
    ApplyWorkspaceEditResult,
    RegistrationParams,
)
from pytest_lsp import LanguageClient


@pytest.mark.asyncio
async def test_progress_reporting(client: LanguageClient):
    """
    Test that the server can send $/progress notifications.

    This test:
    1. Sends a custom test/progress request to the server
    2. Verifies the server sends begin/report/end progress notifications

    Note: The server sends progress notifications with a test token.
    pytest-lsp logs a warning about unknown tokens, but the notifications
    are still sent successfully.
    """
    # Track progress notifications we receive
    progress_notifications = []
    all_received = asyncio.Event()

    # We need to intercept notifications at a lower level since
    # pytest-lsp's built-in handler requires token pre-registration
    original_handle = client.protocol._handle_notification

    def track_progress(method, params):
        if method == "$/progress":
            progress_notifications.append(params)
            # Check if we have all 3 (begin, report, end)
            if len(progress_notifications) >= 3:
                all_received.set()
        return original_handle(method, params)

    client.protocol._handle_notification = track_progress

    try:
        # Trigger the test handler that sends progress notifications
        result = await client.protocol.send_request_async("test/progress", {})

        # Wait for notifications
        try:
            await asyncio.wait_for(all_received.wait(), timeout=5.0)
        except asyncio.TimeoutError:
            # Even if we timeout, check what we got
            pass

        # Verify we got progress notifications (begin, report, end)
        assert len(progress_notifications) >= 3, (
            f"Expected at least 3 progress notifications, got {len(progress_notifications)}"
        )

        # Check the content of notifications
        kinds = []
        for notif in progress_notifications:
            value = (
                notif.get("value", {})
                if isinstance(notif, dict)
                else getattr(notif, "value", {})
            )
            if isinstance(value, dict):
                kinds.append(value.get("kind"))
            elif hasattr(value, "kind"):
                kinds.append(value.kind)

        assert "begin" in kinds, f"Missing 'begin' progress notification. Got: {kinds}"
        assert "report" in kinds, (
            f"Missing 'report' progress notification. Got: {kinds}"
        )
        assert "end" in kinds, f"Missing 'end' progress notification. Got: {kinds}"

        # Verify the request succeeded
        success = getattr(result, "success", None)
        assert success is True, f"Request failed: {result}"
    finally:
        # Restore original handler
        client.protocol._handle_notification = original_handle


@pytest.mark.asyncio
async def test_workspace_apply_edit(client: LanguageClient):
    """
    Test that the server can send workspace/applyEdit requests.

    This test:
    1. Registers a handler for workspace/applyEdit
    2. Sends a custom test/applyEdit request to the server
    3. Verifies the server sends the applyEdit request and handles the response
    """
    edits_received: list[ApplyWorkspaceEditParams] = []
    edit_received = asyncio.Event()

    # Register handler for workspace/applyEdit requests from server
    @client.feature("workspace/applyEdit")
    def on_apply_edit(params: ApplyWorkspaceEditParams) -> ApplyWorkspaceEditResult:
        edits_received.append(params)
        edit_received.set()
        # Return success
        return ApplyWorkspaceEditResult(applied=True)

    # Trigger the test handler
    result = await client.protocol.send_request_async(
        "test/applyEdit", {"uri": "file:///test-edit.txt", "newText": "Hello, World!"}
    )

    # Wait for the edit request
    try:
        await asyncio.wait_for(edit_received.wait(), timeout=5.0)
    except asyncio.TimeoutError:
        pytest.fail("Timed out waiting for workspace/applyEdit request")

    # Verify we received the edit
    assert len(edits_received) == 1, f"Expected 1 edit, got {len(edits_received)}"

    edit = edits_received[0]
    assert edit.label == "Test Edit"
    assert edit.edit is not None

    # Verify the request succeeded (result is an Object, check attribute)
    success = getattr(result, "success", None)
    assert success is True, f"Request failed: {result}"


@pytest.mark.asyncio
async def test_dynamic_capability_registration(client: LanguageClient):
    """
    Test that the server can send client/registerCapability requests.

    This test:
    1. Registers a handler for client/registerCapability
    2. Sends a custom test/registerCapability request to the server
    3. Verifies the server sends the registration request
    """
    registrations_received: list[RegistrationParams] = []
    registration_received = asyncio.Event()

    # Register handler for client/registerCapability requests from server
    @client.feature("client/registerCapability")
    def on_register_capability(params: RegistrationParams) -> None:
        registrations_received.append(params)
        registration_received.set()
        # Return None (success)
        return None

    # Trigger the test handler
    result = await client.protocol.send_request_async("test/registerCapability", {})

    # Wait for the registration request
    try:
        await asyncio.wait_for(registration_received.wait(), timeout=5.0)
    except asyncio.TimeoutError:
        pytest.fail("Timed out waiting for client/registerCapability request")

    # Verify we received the registration
    assert len(registrations_received) == 1, (
        f"Expected 1 registration, got {len(registrations_received)}"
    )

    reg = registrations_received[0]
    assert len(reg.registrations) == 1

    registration = reg.registrations[0]
    assert registration.id == "test-file-watcher-1"
    assert registration.method == "workspace/didChangeWatchedFiles"

    # Verify the request succeeded (result is an Object, check attribute)
    success = getattr(result, "success", None)
    assert success is True, f"Request failed: {result}"
