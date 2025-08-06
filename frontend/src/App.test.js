import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import axios from 'axios';
import App from '../src/App';

// Mock axios
jest.mock('axios');
const mockedAxios = axios;

// Mock environment variables
process.env.REACT_APP_BACKEND_URL = 'http://localhost:8000';

describe('School MIS Frontend Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('renders header with title', () => {
    render(<App />);
    expect(screen.getByText('Smart School Management System')).toBeInTheDocument();
    expect(screen.getByText('Manage students efficiently and professionally')).toBeInTheDocument();
  });

  test('renders language switcher', () => {
    render(<App />);
    expect(screen.getByText('EN')).toBeInTheDocument();
    expect(screen.getByText('DE')).toBeInTheDocument();
  });

  test('switches language from English to German', () => {
    render(<App />);
    
    // Click German language button
    fireEvent.click(screen.getByText('DE'));
    
    // Check if German text appears
    expect(screen.getByText('Intelligentes Schulverwaltungssystem')).toBeInTheDocument();
  });

  test('renders home page with navigation buttons', () => {
    render(<App />);
    
    expect(screen.getByText('Register Student')).toBeInTheDocument();
    expect(screen.getByText('View Students')).toBeInTheDocument();
  });

  test('navigates to student registration form', () => {
    render(<App />);
    
    // Click register student button
    fireEvent.click(screen.getByText('Register Student'));
    
    // Check if form elements appear
    expect(screen.getByPlaceholderText('Enter student name')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('Enter age')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('Enter class (e.g., 5A, 10B)')).toBeInTheDocument();
  });

  test('validates required fields in registration form', async () => {
    render(<App />);
    
    // Navigate to registration form
    fireEvent.click(screen.getByText('Register Student'));
    
    // Try to submit empty form
    fireEvent.click(screen.getByRole('button', { name: /register student/i }));
    
    // Check for validation errors
    await waitFor(() => {
      expect(screen.getByText('Name is required')).toBeInTheDocument();
      expect(screen.getByText('Age is required')).toBeInTheDocument();
      expect(screen.getByText('Class is required')).toBeInTheDocument();
      expect(screen.getByText('Gender is required')).toBeInTheDocument();
      expect(screen.getByText('Contact information is required')).toBeInTheDocument();
    });
  });

  test('submits registration form with valid data', async () => {
    const mockStudentData = {
      id: '1',
      name: 'John Doe',
      age: 16,
      class_name: '10A',
      gender: 'male',
      contact_info: 'john.doe@email.com',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    mockedAxios.post.mockResolvedValueOnce({ data: mockStudentData });

    render(<App />);
    
    // Navigate to registration form
    fireEvent.click(screen.getByText('Register Student'));
    
    // Fill out the form
    fireEvent.change(screen.getByPlaceholderText('Enter student name'), {
      target: { value: 'John Doe' }
    });
    fireEvent.change(screen.getByPlaceholderText('Enter age'), {
      target: { value: '16' }
    });
    fireEvent.change(screen.getByPlaceholderText('Enter class (e.g., 5A, 10B)'), {
      target: { value: '10A' }
    });
    fireEvent.change(screen.getByDisplayValue('Gender'), {
      target: { value: 'male' }
    });
    fireEvent.change(screen.getByPlaceholderText('Enter contact information'), {
      target: { value: 'john.doe@email.com' }
    });
    
    // Submit the form
    fireEvent.click(screen.getByRole('button', { name: /register student/i }));
    
    // Wait for API call
    await waitFor(() => {
      expect(mockedAxios.post).toHaveBeenCalledWith(
        'http://localhost:8000/api/students',
        expect.objectContaining({
          name: 'John Doe',
          age: 16,
          class_name: '10A',
          gender: 'male',
          contact_info: 'john.doe@email.com'
        })
      );
    });
  });

  test('displays students list', async () => {
    const mockStudents = [
      {
        id: '1',
        name: 'John Doe',
        age: 16,
        class_name: '10A',
        gender: 'male',
        contact_info: 'john.doe@email.com',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      },
      {
        id: '2',
        name: 'Jane Smith',
        age: 15,
        class_name: '9B',
        gender: 'female',
        contact_info: 'jane.smith@email.com',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }
    ];

    mockedAxios.get.mockResolvedValueOnce({ data: mockStudents });

    render(<App />);
    
    // Click view students button
    fireEvent.click(screen.getByText('View Students'));
    
    // Wait for students to load
    await waitFor(() => {
      expect(screen.getByText('Student List')).toBeInTheDocument();
      expect(screen.getByText('Total Students: 2')).toBeInTheDocument();
      expect(screen.getByText('John Doe')).toBeInTheDocument();
      expect(screen.getByText('Jane Smith')).toBeInTheDocument();
    });
  });

  test('handles API error gracefully', async () => {
    mockedAxios.get.mockRejectedValueOnce(new Error('Network Error'));

    render(<App />);
    
    // Click view students button
    fireEvent.click(screen.getByText('View Students'));
    
    // Should handle error without crashing
    await waitFor(() => {
      expect(mockedAxios.get).toHaveBeenCalled();
    });
  });

  test('cancels form and returns to home', () => {
    render(<App />);
    
    // Navigate to registration form
    fireEvent.click(screen.getByText('Register Student'));
    
    // Click cancel button
    fireEvent.click(screen.getByText('Cancel'));
    
    // Should be back to home page
    expect(screen.getByText('Register Student')).toBeInTheDocument();
    expect(screen.getByText('View Students')).toBeInTheDocument();
  });

  test('displays success message after registration', async () => {
    const mockStudentData = {
      id: '1',
      name: 'John Doe',
      age: 16,
      class_name: '10A',
      gender: 'male',
      contact_info: 'john.doe@email.com',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    mockedAxios.post.mockResolvedValueOnce({ data: mockStudentData });

    render(<App />);
    
    // Navigate to registration form and submit
    fireEvent.click(screen.getByText('Register Student'));
    
    // Fill minimum required fields
    fireEvent.change(screen.getByPlaceholderText('Enter student name'), {
      target: { value: 'John Doe' }
    });
    fireEvent.change(screen.getByPlaceholderText('Enter age'), {
      target: { value: '16' }
    });
    fireEvent.change(screen.getByPlaceholderText('Enter class (e.g., 5A, 10B)'), {
      target: { value: '10A' }
    });
    fireEvent.change(screen.getByDisplayValue('Gender'), {
      target: { value: 'male' }
    });
    fireEvent.change(screen.getByPlaceholderText('Enter contact information'), {
      target: { value: 'john.doe@email.com' }
    });
    
    fireEvent.click(screen.getByRole('button', { name: /register student/i }));
    
    // Check for success message
    await waitFor(() => {
      expect(screen.getByText('Student registered successfully!')).toBeInTheDocument();
    });
  });
});
