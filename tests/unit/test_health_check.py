"""Unit tests for the MCP server health check endpoint."""
import unittest
from unittest.mock import patch, MagicMock
from mcp_server import app

class TestHealthCheck(unittest.TestCase):
    """Test cases for the health check endpoint."""

    def setUp(self):
        """Set up test client before each test."""
        self.app = app.test_client()
        self.app.testing = True

    def test_health_check_success(self):
        """Test that the health check endpoint returns expected response."""
        # Act
        response = self.app.get('/health')
        
        # Assert
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'status', response.data)
        self.assertIn(b'version', response.data)

    @patch('mcp_server.health_check')
    def test_health_check_failure(self, mock_health_check):
        """Test health check when there's an error."""
        # Arrange
        mock_health_check.side_effect = Exception("Test error")
        
        # Act
        response = self.app.get('/health')
        
        # Assert
        self.assertEqual(response.status_code, 500)
        self.assertIn(b'error', response.data)

if __name__ == '__main__':
    unittest.main()
