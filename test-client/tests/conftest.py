"""Pytest configuration for Lapis LSP tests."""

import os

import pytest_lsp
from lsprotocol.types import ClientCapabilities, InitializeParams
from pytest_lsp import ClientServerConfig, LanguageClient

# Get path to the test server executable
SERVER_PATH = os.path.join(
    os.path.dirname(__file__), "..", "..", ".lake", "build", "bin", "test"
)


@pytest_lsp.fixture(
    config=ClientServerConfig(server_command=[SERVER_PATH]),
)
async def client(lsp_client: LanguageClient):
    """LSP client fixture for testing Lapis server."""
    # Setup: Initialize the LSP session
    await lsp_client.initialize_session(
        InitializeParams(capabilities=ClientCapabilities())
    )

    yield

    # Teardown: Shutdown the LSP session
    await lsp_client.shutdown_session()
