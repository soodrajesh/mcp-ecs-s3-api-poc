"""Unit tests for the MCP server health check endpoint."""
import unittest
from unittest.mock import patch, MagicMock
from mcp_server import app, check_health

class TestHealthCheck(unittest.TestCase):
    """Test cases for the health check endpoint."""

    def setUp(self):
        """Set up test client before each test."""
        self.app = app.test_client()
        self.app.testing = True

    @patch('mcp_server.check_health')
    def test_health_check_success(self, mock_check_health):
        """Test that the health check endpoint returns expected response."""
        # Arrange
        test_app = app.test_client()
        mock_check_health.return_value = ({
            "status": "healthy",
            "service": "mcp-server",
            "version": "1.0.0"
        }, 200)
        
        # Act
        with app.app_context():
            response = test_app.get('/health')
        
        # Assert
        self.assertEqual(response.status_code, 200)
        response_data = response.get_json()
        self.assertEqual(response_data['status'], 'healthy')
        self.assertEqual(response_data['service'], 'mcp-server')
        self.assertEqual(response_data['version'], '1.0.0')

    @patch('mcp_server.check_health')
    def test_health_check_failure(self, mock_check_health):
        """Test health check when there's an error returns 500 with unhealthy status."""
        # Arrange
        test_app = app.test_client()
        mock_check_health.return_value = ({
            "status": "unhealthy",
            "error": "Test error"
        }, 500)
        
        # Act
        with app.app_context():
            response = test_app.get('/health')
        
        # Assert
        self.assertEqual(response.status_code, 500)
        response_data = response.get_json()
        self.assertEqual(response_data['status'], 'unhealthy')
        self.assertEqual(response_data['error'], 'Test error')

if __name__ == '__main__':
    unittest.main()
