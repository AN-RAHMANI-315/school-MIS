#!/usr/bin/env python3
"""
Backend API Testing for Smart School Management System
Tests all student-related endpoints with comprehensive validation
"""

import requests
import json
import sys
from datetime import datetime

# Backend URL from frontend/.env
BACKEND_URL = "https://f132d147-952b-4f72-9896-d06208fd992e.preview.emergentagent.com/api"

# Test data as specified in the review request
TEST_STUDENTS = [
    {
        "name": "John Doe",
        "age": 15,
        "class_name": "10A",
        "gender": "male",
        "contact_info": "john@example.com",
        "parent_name": "Jane Doe",
        "parent_phone": "+1234567890",
        "address": "123 Main St"
    },
    {
        "name": "Maria Schmidt",
        "age": 16,
        "class_name": "10B",
        "gender": "female",
        "contact_info": "maria@example.com",
        "parent_name": "Klaus Schmidt",
        "parent_phone": "+4987654321",
        "address": "456 Oak Ave"
    }
]

class BackendTester:
    def __init__(self):
        self.base_url = BACKEND_URL
        self.created_student_ids = []
        self.test_results = []
        
    def log_test(self, test_name, success, message, details=None):
        """Log test results"""
        status = "✅ PASS" if success else "❌ FAIL"
        print(f"{status} {test_name}: {message}")
        if details:
            print(f"   Details: {details}")
        
        self.test_results.append({
            "test": test_name,
            "success": success,
            "message": message,
            "details": details
        })
    
    def test_root_endpoint(self):
        """Test GET /api/ - Root endpoint"""
        try:
            response = requests.get(f"{self.base_url}/")
            if response.status_code == 200:
                data = response.json()
                if "message" in data and "Smart School Management System" in data["message"]:
                    self.log_test("Root Endpoint", True, "Root endpoint working correctly")
                    return True
                else:
                    self.log_test("Root Endpoint", False, "Unexpected response format", data)
                    return False
            else:
                self.log_test("Root Endpoint", False, f"HTTP {response.status_code}", response.text)
                return False
        except Exception as e:
            self.log_test("Root Endpoint", False, f"Connection error: {str(e)}")
            return False
    
    def test_create_student(self, student_data, expect_success=True):
        """Test POST /api/students - Create student"""
        try:
            response = requests.post(f"{self.base_url}/students", json=student_data)
            
            if expect_success:
                if response.status_code == 200:
                    data = response.json()
                    if "id" in data and data["name"] == student_data["name"]:
                        self.created_student_ids.append(data["id"])
                        self.log_test("Create Student", True, f"Student '{student_data['name']}' created successfully")
                        return data["id"]
                    else:
                        self.log_test("Create Student", False, "Invalid response format", data)
                        return None
                else:
                    self.log_test("Create Student", False, f"HTTP {response.status_code}", response.text)
                    return None
            else:
                # Expecting failure
                if response.status_code != 200:
                    self.log_test("Create Student (Validation)", True, f"Correctly rejected invalid data: HTTP {response.status_code}")
                    return None
                else:
                    self.log_test("Create Student (Validation)", False, "Should have rejected invalid data but didn't")
                    return None
                    
        except Exception as e:
            self.log_test("Create Student", False, f"Connection error: {str(e)}")
            return None
    
    def test_get_all_students(self):
        """Test GET /api/students - Get all students"""
        try:
            response = requests.get(f"{self.base_url}/students")
            if response.status_code == 200:
                data = response.json()
                if isinstance(data, list):
                    self.log_test("Get All Students", True, f"Retrieved {len(data)} students")
                    return data
                else:
                    self.log_test("Get All Students", False, "Response is not a list", data)
                    return None
            else:
                self.log_test("Get All Students", False, f"HTTP {response.status_code}", response.text)
                return None
        except Exception as e:
            self.log_test("Get All Students", False, f"Connection error: {str(e)}")
            return None
    
    def test_get_student_by_id(self, student_id, expect_success=True):
        """Test GET /api/students/{student_id} - Get specific student"""
        try:
            response = requests.get(f"{self.base_url}/students/{student_id}")
            
            if expect_success:
                if response.status_code == 200:
                    data = response.json()
                    if "id" in data and data["id"] == student_id:
                        self.log_test("Get Student by ID", True, f"Retrieved student {student_id}")
                        return data
                    else:
                        self.log_test("Get Student by ID", False, "Invalid response format", data)
                        return None
                else:
                    self.log_test("Get Student by ID", False, f"HTTP {response.status_code}", response.text)
                    return None
            else:
                # Expecting failure (non-existent ID)
                if response.status_code == 404:
                    self.log_test("Get Student by ID (Non-existent)", True, "Correctly returned 404 for non-existent student")
                    return None
                else:
                    self.log_test("Get Student by ID (Non-existent)", False, f"Expected 404 but got {response.status_code}")
                    return None
                    
        except Exception as e:
            self.log_test("Get Student by ID", False, f"Connection error: {str(e)}")
            return None
    
    def test_update_student(self, student_id, update_data):
        """Test PUT /api/students/{student_id} - Update student"""
        try:
            response = requests.put(f"{self.base_url}/students/{student_id}", json=update_data)
            if response.status_code == 200:
                data = response.json()
                if "id" in data and data["id"] == student_id:
                    # Check if update was applied
                    for key, value in update_data.items():
                        if data.get(key) == value:
                            continue
                        else:
                            self.log_test("Update Student", False, f"Update not applied for field {key}")
                            return None
                    self.log_test("Update Student", True, f"Student {student_id} updated successfully")
                    return data
                else:
                    self.log_test("Update Student", False, "Invalid response format", data)
                    return None
            else:
                self.log_test("Update Student", False, f"HTTP {response.status_code}", response.text)
                return None
        except Exception as e:
            self.log_test("Update Student", False, f"Connection error: {str(e)}")
            return None
    
    def test_get_students_by_class(self, class_name):
        """Test GET /api/students/class/{class_name} - Get students by class"""
        try:
            response = requests.get(f"{self.base_url}/students/class/{class_name}")
            if response.status_code == 200:
                data = response.json()
                if isinstance(data, list):
                    # Verify all students belong to the specified class
                    for student in data:
                        if student.get("class_name") != class_name:
                            self.log_test("Get Students by Class", False, f"Student {student.get('name')} not in class {class_name}")
                            return None
                    self.log_test("Get Students by Class", True, f"Retrieved {len(data)} students from class {class_name}")
                    return data
                else:
                    self.log_test("Get Students by Class", False, "Response is not a list", data)
                    return None
            else:
                self.log_test("Get Students by Class", False, f"HTTP {response.status_code}", response.text)
                return None
        except Exception as e:
            self.log_test("Get Students by Class", False, f"Connection error: {str(e)}")
            return None
    
    def test_delete_student(self, student_id):
        """Test DELETE /api/students/{student_id} - Delete student"""
        try:
            response = requests.delete(f"{self.base_url}/students/{student_id}")
            if response.status_code == 200:
                data = response.json()
                if "message" in data and "deleted" in data["message"].lower():
                    self.log_test("Delete Student", True, f"Student {student_id} deleted successfully")
                    return True
                else:
                    self.log_test("Delete Student", False, "Unexpected response format", data)
                    return False
            else:
                self.log_test("Delete Student", False, f"HTTP {response.status_code}", response.text)
                return False
        except Exception as e:
            self.log_test("Delete Student", False, f"Connection error: {str(e)}")
            return False
    
    def test_validation_scenarios(self):
        """Test various validation scenarios"""
        print("\n=== VALIDATION TESTS ===")
        
        # Test missing required fields
        invalid_student = {"name": "Test Student"}  # Missing required fields
        self.test_create_student(invalid_student, expect_success=False)
        
        # Test negative age
        invalid_age_student = {
            "name": "Invalid Age Student",
            "age": -5,
            "class_name": "10A",
            "gender": "male",
            "contact_info": "test@example.com"
        }
        self.test_create_student(invalid_age_student, expect_success=False)
        
        # Test non-existent student ID
        self.test_get_student_by_id("non-existent-id", expect_success=False)
    
    def run_all_tests(self):
        """Run comprehensive test suite"""
        print("=== SMART SCHOOL MANAGEMENT SYSTEM - BACKEND API TESTS ===")
        print(f"Testing backend at: {self.base_url}")
        print(f"Test started at: {datetime.now()}\n")
        
        # Test 1: Root endpoint
        print("=== BASIC CONNECTIVITY TESTS ===")
        if not self.test_root_endpoint():
            print("❌ Root endpoint failed - aborting further tests")
            return False
        
        # Test 2: Create students
        print("\n=== STUDENT CREATION TESTS ===")
        student_ids = []
        for i, student in enumerate(TEST_STUDENTS):
            student_id = self.test_create_student(student)
            if student_id:
                student_ids.append(student_id)
        
        if not student_ids:
            print("❌ No students created - aborting further tests")
            return False
        
        # Test 3: Get all students
        print("\n=== STUDENT RETRIEVAL TESTS ===")
        all_students = self.test_get_all_students()
        
        # Test 4: Get individual students
        for student_id in student_ids:
            self.test_get_student_by_id(student_id)
        
        # Test 5: Update student
        print("\n=== STUDENT UPDATE TESTS ===")
        if student_ids:
            update_data = {"age": 17, "class_name": "11A"}
            self.test_update_student(student_ids[0], update_data)
        
        # Test 6: Get students by class
        print("\n=== CLASS FILTERING TESTS ===")
        self.test_get_students_by_class("10A")
        self.test_get_students_by_class("10B")
        self.test_get_students_by_class("11A")  # Should include updated student
        
        # Test 7: Validation scenarios
        self.test_validation_scenarios()
        
        # Test 8: Test duplicate name creation
        print("\n=== DUPLICATE NAME TESTS ===")
        if TEST_STUDENTS:
            self.test_create_student(TEST_STUDENTS[0], expect_success=False)  # Should fail due to duplicate name
        
        # Test 9: Delete students (cleanup)
        print("\n=== STUDENT DELETION TESTS ===")
        for student_id in student_ids:
            self.test_delete_student(student_id)
        
        # Final summary
        self.print_summary()
        return True
    
    def print_summary(self):
        """Print test summary"""
        print("\n" + "="*60)
        print("TEST SUMMARY")
        print("="*60)
        
        total_tests = len(self.test_results)
        passed_tests = sum(1 for result in self.test_results if result["success"])
        failed_tests = total_tests - passed_tests
        
        print(f"Total Tests: {total_tests}")
        print(f"Passed: {passed_tests}")
        print(f"Failed: {failed_tests}")
        print(f"Success Rate: {(passed_tests/total_tests)*100:.1f}%")
        
        if failed_tests > 0:
            print("\nFAILED TESTS:")
            for result in self.test_results:
                if not result["success"]:
                    print(f"  ❌ {result['test']}: {result['message']}")
                    if result["details"]:
                        print(f"     Details: {result['details']}")
        
        print("\n" + "="*60)

if __name__ == "__main__":
    tester = BackendTester()
    success = tester.run_all_tests()
    sys.exit(0 if success else 1)