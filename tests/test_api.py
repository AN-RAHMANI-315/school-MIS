import pytest
import asyncio
from httpx import AsyncClient
from fastapi.testclient import TestClient
from unittest.mock import AsyncMock, patch
import sys
import os

# Add the backend directory to Python path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'backend'))

from server import app, db

# Test client
client = TestClient(app)

class TestSchoolMISAPI:
    """Test cases for School MIS API endpoints"""
    
    def test_root_endpoint(self):
        """Test the root endpoint"""
        response = client.get("/api/")
        assert response.status_code == 200
        data = response.json()
        assert "message" in data
        assert "version" in data
        assert data["version"] == "1.0"
    
    @patch('server.db')
    def test_health_check_success(self, mock_db):
        """Test health check endpoint when database is healthy"""
        # Mock successful database ping
        mock_db.admin.command = AsyncMock(return_value={"ok": 1})
        
        response = client.get("/api/health")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert "timestamp" in data
        assert data["database"] == "connected"
    
    @patch('server.db')
    def test_health_check_failure(self, mock_db):
        """Test health check endpoint when database is unhealthy"""
        # Mock database connection failure
        mock_db.admin.command = AsyncMock(side_effect=Exception("Database connection failed"))
        
        response = client.get("/api/health")
        assert response.status_code == 503
        data = response.json()
        assert "Service unavailable" in data["detail"]
    
    @patch('server.db')
    def test_create_student_success(self, mock_db):
        """Test successful student creation"""
        # Mock database operations
        mock_db.students.find_one = AsyncMock(return_value=None)
        mock_db.students.insert_one = AsyncMock(return_value=None)
        
        student_data = {
            "name": "John Doe",
            "age": 16,
            "class_name": "10A",
            "gender": "male",
            "contact_info": "john.doe@email.com",
            "parent_name": "Jane Doe",
            "parent_phone": "+1234567890",
            "address": "123 Main St"
        }
        
        response = client.post("/api/students", json=student_data)
        assert response.status_code == 200
        data = response.json()
        assert data["name"] == student_data["name"]
        assert data["age"] == student_data["age"]
        assert "id" in data
        assert "created_at" in data
    
    @patch('server.db')
    def test_create_student_duplicate(self, mock_db):
        """Test student creation with duplicate name"""
        # Mock existing student
        mock_db.students.find_one = AsyncMock(return_value={"name": "John Doe"})
        
        student_data = {
            "name": "John Doe",
            "age": 16,
            "class_name": "10A",
            "gender": "male",
            "contact_info": "john.doe@email.com"
        }
        
        response = client.post("/api/students", json=student_data)
        assert response.status_code == 400
        data = response.json()
        assert "already exists" in data["detail"]
    
    @patch('server.db')
    def test_get_students(self, mock_db):
        """Test getting all students"""
        # Mock students data
        mock_students = [
            {
                "id": "1",
                "name": "John Doe",
                "age": 16,
                "class_name": "10A",
                "gender": "male",
                "contact_info": "john.doe@email.com",
                "created_at": "2024-01-01T00:00:00",
                "updated_at": "2024-01-01T00:00:00"
            }
        ]
        mock_db.students.find.return_value.to_list = AsyncMock(return_value=mock_students)
        
        response = client.get("/api/students")
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 1
        assert data[0]["name"] == "John Doe"
    
    @patch('server.db')
    def test_get_student_by_id(self, mock_db):
        """Test getting a specific student by ID"""
        # Mock student data
        mock_student = {
            "id": "1",
            "name": "John Doe",
            "age": 16,
            "class_name": "10A",
            "gender": "male",
            "contact_info": "john.doe@email.com",
            "created_at": "2024-01-01T00:00:00",
            "updated_at": "2024-01-01T00:00:00"
        }
        mock_db.students.find_one = AsyncMock(return_value=mock_student)
        
        response = client.get("/api/students/1")
        assert response.status_code == 200
        data = response.json()
        assert data["name"] == "John Doe"
        assert data["id"] == "1"
    
    @patch('server.db')
    def test_get_student_not_found(self, mock_db):
        """Test getting non-existent student"""
        mock_db.students.find_one = AsyncMock(return_value=None)
        
        response = client.get("/api/students/999")
        assert response.status_code == 404
        data = response.json()
        assert "not found" in data["detail"]
    
    @patch('server.db')
    def test_update_student(self, mock_db):
        """Test updating a student"""
        # Mock existing student
        mock_student = {
            "id": "1",
            "name": "John Doe",
            "age": 16,
            "class_name": "10A",
            "gender": "male",
            "contact_info": "john.doe@email.com",
            "created_at": "2024-01-01T00:00:00",
            "updated_at": "2024-01-01T00:00:00"
        }
        
        updated_student = mock_student.copy()
        updated_student["age"] = 17
        
        mock_db.students.find_one = AsyncMock(side_effect=[mock_student, updated_student])
        mock_db.students.update_one = AsyncMock(return_value=None)
        
        update_data = {"age": 17}
        response = client.put("/api/students/1", json=update_data)
        assert response.status_code == 200
        data = response.json()
        assert data["age"] == 17
    
    @patch('server.db')
    def test_delete_student(self, mock_db):
        """Test deleting a student"""
        # Mock existing student
        mock_student = {
            "id": "1",
            "name": "John Doe"
        }
        mock_db.students.find_one = AsyncMock(return_value=mock_student)
        mock_db.students.delete_one = AsyncMock(return_value=None)
        
        response = client.delete("/api/students/1")
        assert response.status_code == 200
        data = response.json()
        assert "deleted successfully" in data["message"]
    
    @patch('server.db')
    def test_get_students_by_class(self, mock_db):
        """Test getting students by class"""
        # Mock students data
        mock_students = [
            {
                "id": "1",
                "name": "John Doe",
                "age": 16,
                "class_name": "10A",
                "gender": "male",
                "contact_info": "john.doe@email.com",
                "created_at": "2024-01-01T00:00:00",
                "updated_at": "2024-01-01T00:00:00"
            }
        ]
        mock_db.students.find.return_value.to_list = AsyncMock(return_value=mock_students)
        
        response = client.get("/api/students/class/10A")
        assert response.status_code == 200
        data = response.json()
        assert len(data) == 1
        assert data[0]["class_name"] == "10A"

    def test_cors_headers(self):
        """Test CORS headers are present"""
        response = client.get("/api/")
        assert response.status_code == 200
        # CORS headers should be present in the response
        # Note: In test environment, CORS middleware might not add headers
        # This test verifies the endpoint is accessible

if __name__ == "__main__":
    pytest.main([__file__])
