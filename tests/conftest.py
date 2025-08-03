"""Pytest configuration and fixtures for MCP Server tests."""
import pytest
from mcp_server import app

@pytest.fixture
def client():
    """Create a test client for the application."""
    with app.test_client() as test_client:
        with app.app_context():
            yield test_client
