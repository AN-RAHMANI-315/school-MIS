import React, { useState, useEffect, createContext, useContext } from "react";
import "./App.css";
import axios from "axios";

const BACKEND_URL = process.env.REACT_APP_BACKEND_URL;
const API = `${BACKEND_URL}/api`;

// Language Context
const LanguageContext = createContext();

// Translation dictionary
const translations = {
  en: {
    // Header
    title: "Smart School Management System",
    tagline: "Manage students efficiently and professionally",
    
    // Navigation
    registerStudent: "Register Student",
    viewStudents: "View Students",
    
    // Form Labels
    studentName: "Student Name",
    age: "Age",
    className: "Class",
    gender: "Gender",
    contactInfo: "Contact Info",
    parentName: "Parent Name",
    parentPhone: "Parent Phone",
    address: "Address",
    
    // Form Placeholders
    enterName: "Enter student name",
    enterAge: "Enter age",
    enterClass: "Enter class (e.g., 5A, 10B)",
    enterContact: "Enter contact information",
    enterParentName: "Enter parent name",
    enterParentPhone: "Enter parent phone",
    enterAddress: "Enter address",
    
    // Buttons
    submit: "Register Student",
    cancel: "Cancel",
    edit: "Edit",
    delete: "Delete",
    back: "Back",
    
    // Gender options
    male: "Male",
    female: "Female",
    other: "Other",
    
    // Messages
    success: "Student registered successfully!",
    error: "Error occurred while registering student",
    loading: "Loading...",
    noStudents: "No students found",
    confirmDelete: "Are you sure you want to delete this student?",
    
    // Student List
    studentList: "Student List",
    totalStudents: "Total Students",
    
    // Form validation
    nameRequired: "Name is required",
    ageRequired: "Age is required",
    classRequired: "Class is required",
    genderRequired: "Gender is required",
    contactRequired: "Contact information is required"
  },
  de: {
    // Header
    title: "Intelligentes Schulverwaltungssystem",
    tagline: "Schüler effizient und professionell verwalten",
    
    // Navigation
    registerStudent: "Schüler registrieren",
    viewStudents: "Schüler anzeigen",
    
    // Form Labels
    studentName: "Schülername",
    age: "Alter",
    className: "Klasse",
    gender: "Geschlecht",
    contactInfo: "Kontaktinformationen",
    parentName: "Name der Eltern",
    parentPhone: "Telefon der Eltern",
    address: "Adresse",
    
    // Form Placeholders
    enterName: "Schülername eingeben",
    enterAge: "Alter eingeben",
    enterClass: "Klasse eingeben (z.B. 5A, 10B)",
    enterContact: "Kontaktinformationen eingeben",
    enterParentName: "Name der Eltern eingeben",
    enterParentPhone: "Telefon der Eltern eingeben",
    enterAddress: "Adresse eingeben",
    
    // Buttons
    submit: "Schüler registrieren",
    cancel: "Abbrechen",
    edit: "Bearbeiten",
    delete: "Löschen",
    back: "Zurück",
    
    // Gender options
    male: "Männlich",
    female: "Weiblich",
    other: "Andere",
    
    // Messages
    success: "Schüler erfolgreich registriert!",
    error: "Fehler beim Registrieren des Schülers",
    loading: "Laden...",
    noStudents: "Keine Schüler gefunden",
    confirmDelete: "Sind Sie sicher, dass Sie diesen Schüler löschen möchten?",
    
    // Student List
    studentList: "Schülerliste",
    totalStudents: "Gesamtzahl der Schüler",
    
    // Form validation
    nameRequired: "Name ist erforderlich",
    ageRequired: "Alter ist erforderlich",
    classRequired: "Klasse ist erforderlich",
    genderRequired: "Geschlecht ist erforderlich",
    contactRequired: "Kontaktinformationen sind erforderlich"
  }
};

// Language Provider Component
const LanguageProvider = ({ children }) => {
  const [language, setLanguage] = useState('en');
  
  const switchLanguage = (lang) => {
    setLanguage(lang);
  };
  
  const t = (key) => {
    return translations[language][key] || key;
  };
  
  return (
    <LanguageContext.Provider value={{ language, switchLanguage, t }}>
      {children}
    </LanguageContext.Provider>
  );
};

// Custom hook to use language context
const useLanguage = () => {
  const context = useContext(LanguageContext);
  if (!context) {
    throw new Error('useLanguage must be used within a LanguageProvider');
  }
  return context;
};

// Header Component
const Header = () => {
  const { language, switchLanguage, t } = useLanguage();
  
  return (
    <header className="bg-gradient-to-r from-blue-600 to-purple-600 text-white shadow-lg">
      <div className="container mx-auto px-6 py-4">
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-3xl font-bold">{t('title')}</h1>
            <p className="text-blue-100 mt-1">{t('tagline')}</p>
          </div>
          <div className="flex items-center space-x-4">
            <div className="flex bg-white/20 rounded-lg p-1">
              <button
                onClick={() => switchLanguage('en')}
                className={`px-3 py-1 rounded-md transition-all ${
                  language === 'en' 
                    ? 'bg-white text-blue-600 shadow-md' 
                    : 'text-white hover:bg-white/10'
                }`}
              >
                EN
              </button>
              <button
                onClick={() => switchLanguage('de')}
                className={`px-3 py-1 rounded-md transition-all ${
                  language === 'de' 
                    ? 'bg-white text-blue-600 shadow-md' 
                    : 'text-white hover:bg-white/10'
                }`}
              >
                DE
              </button>
            </div>
          </div>
        </div>
      </div>
    </header>
  );
};

// Student Registration Form Component
const StudentRegistrationForm = ({ onSubmit, onCancel }) => {
  const { t } = useLanguage();
  const [formData, setFormData] = useState({
    name: '',
    age: '',
    class_name: '',
    gender: '',
    contact_info: '',
    parent_name: '',
    parent_phone: '',
    address: ''
  });
  const [errors, setErrors] = useState({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
    // Clear error when user starts typing
    if (errors[name]) {
      setErrors(prev => ({
        ...prev,
        [name]: ''
      }));
    }
  };

  const validateForm = () => {
    const newErrors = {};
    
    if (!formData.name.trim()) newErrors.name = t('nameRequired');
    if (!formData.age) newErrors.age = t('ageRequired');
    if (!formData.class_name.trim()) newErrors.class_name = t('classRequired');
    if (!formData.gender) newErrors.gender = t('genderRequired');
    if (!formData.contact_info.trim()) newErrors.contact_info = t('contactRequired');
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!validateForm()) return;
    
    setIsSubmitting(true);
    try {
      await onSubmit({
        ...formData,
        age: parseInt(formData.age)
      });
      // Reset form
      setFormData({
        name: '',
        age: '',
        class_name: '',
        gender: '',
        contact_info: '',
        parent_name: '',
        parent_phone: '',
        address: ''
      });
    } catch (error) {
      console.error('Error submitting form:', error);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="max-w-2xl mx-auto bg-white rounded-xl shadow-lg p-8">
      <h2 className="text-2xl font-bold text-gray-800 mb-6 text-center">
        {t('registerStudent')}
      </h2>
      
      <form onSubmit={handleSubmit} className="space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Student Name */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              {t('studentName')} *
            </label>
            <input
              type="text"
              name="name"
              value={formData.name}
              onChange={handleChange}
              placeholder={t('enterName')}
              className={`w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent ${
                errors.name ? 'border-red-500' : 'border-gray-300'
              }`}
            />
            {errors.name && <p className="text-red-500 text-sm mt-1">{errors.name}</p>}
          </div>

          {/* Age */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              {t('age')} *
            </label>
            <input
              type="number"
              name="age"
              value={formData.age}
              onChange={handleChange}
              placeholder={t('enterAge')}
              min="1"
              max="100"
              className={`w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent ${
                errors.age ? 'border-red-500' : 'border-gray-300'
              }`}
            />
            {errors.age && <p className="text-red-500 text-sm mt-1">{errors.age}</p>}
          </div>

          {/* Class */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              {t('className')} *
            </label>
            <input
              type="text"
              name="class_name"
              value={formData.class_name}
              onChange={handleChange}
              placeholder={t('enterClass')}
              className={`w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent ${
                errors.class_name ? 'border-red-500' : 'border-gray-300'
              }`}
            />
            {errors.class_name && <p className="text-red-500 text-sm mt-1">{errors.class_name}</p>}
          </div>

          {/* Gender */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              {t('gender')} *
            </label>
            <select
              name="gender"
              value={formData.gender}
              onChange={handleChange}
              className={`w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent ${
                errors.gender ? 'border-red-500' : 'border-gray-300'
              }`}
            >
              <option value="">{t('gender')}</option>
              <option value="male">{t('male')}</option>
              <option value="female">{t('female')}</option>
              <option value="other">{t('other')}</option>
            </select>
            {errors.gender && <p className="text-red-500 text-sm mt-1">{errors.gender}</p>}
          </div>
        </div>

        {/* Contact Info */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            {t('contactInfo')} *
          </label>
          <input
            type="text"
            name="contact_info"
            value={formData.contact_info}
            onChange={handleChange}
            placeholder={t('enterContact')}
            className={`w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent ${
              errors.contact_info ? 'border-red-500' : 'border-gray-300'
            }`}
          />
          {errors.contact_info && <p className="text-red-500 text-sm mt-1">{errors.contact_info}</p>}
        </div>

        {/* Parent Name */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            {t('parentName')}
          </label>
          <input
            type="text"
            name="parent_name"
            value={formData.parent_name}
            onChange={handleChange}
            placeholder={t('enterParentName')}
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>

        {/* Parent Phone */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            {t('parentPhone')}
          </label>
          <input
            type="tel"
            name="parent_phone"
            value={formData.parent_phone}
            onChange={handleChange}
            placeholder={t('enterParentPhone')}
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>

        {/* Address */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            {t('address')}
          </label>
          <textarea
            name="address"
            value={formData.address}
            onChange={handleChange}
            placeholder={t('enterAddress')}
            rows="3"
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>

        {/* Buttons */}
        <div className="flex justify-end space-x-4">
          <button
            type="button"
            onClick={onCancel}
            className="px-6 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
          >
            {t('cancel')}
          </button>
          <button
            type="submit"
            disabled={isSubmitting}
            className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 transition-colors"
          >
            {isSubmitting ? t('loading') : t('submit')}
          </button>
        </div>
      </form>
    </div>
  );
};

// Student List Component
const StudentList = ({ students, onBack }) => {
  const { t } = useLanguage();

  return (
    <div className="max-w-6xl mx-auto">
      <div className="bg-white rounded-xl shadow-lg">
        <div className="p-6 border-b border-gray-200">
          <div className="flex justify-between items-center">
            <div>
              <h2 className="text-2xl font-bold text-gray-800">{t('studentList')}</h2>
              <p className="text-gray-600 mt-1">
                {t('totalStudents')}: {students.length}
              </p>
            </div>
            <button
              onClick={onBack}
              className="px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors"
            >
              {t('back')}
            </button>
          </div>
        </div>
        
        <div className="p-6">
          {students.length === 0 ? (
            <div className="text-center py-12">
              <p className="text-gray-500 text-lg">{t('noStudents')}</p>
            </div>
          ) : (
            <div className="grid gap-4">
              {students.map((student) => (
                <div key={student.id} className="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow">
                  <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                    <div>
                      <p className="text-sm font-medium text-gray-500">{t('studentName')}</p>
                      <p className="text-lg font-semibold text-gray-800">{student.name}</p>
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-500">{t('age')} / {t('className')}</p>
                      <p className="text-lg text-gray-800">{student.age} / {student.class_name}</p>
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-500">{t('gender')}</p>
                      <p className="text-lg text-gray-800">{t(student.gender)}</p>
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-500">{t('contactInfo')}</p>
                      <p className="text-lg text-gray-800">{student.contact_info}</p>
                    </div>
                  </div>
                  {(student.parent_name || student.parent_phone || student.address) && (
                    <div className="mt-4 pt-4 border-t border-gray-100">
                      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                        {student.parent_name && (
                          <div>
                            <p className="text-sm font-medium text-gray-500">{t('parentName')}</p>
                            <p className="text-gray-800">{student.parent_name}</p>
                          </div>
                        )}
                        {student.parent_phone && (
                          <div>
                            <p className="text-sm font-medium text-gray-500">{t('parentPhone')}</p>
                            <p className="text-gray-800">{student.parent_phone}</p>
                          </div>
                        )}
                        {student.address && (
                          <div>
                            <p className="text-sm font-medium text-gray-500">{t('address')}</p>
                            <p className="text-gray-800">{student.address}</p>
                          </div>
                        )}
                      </div>
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

// Main App Component
const MainApp = () => {
  const { t } = useLanguage();
  const [currentView, setCurrentView] = useState('home');
  const [students, setStudents] = useState([]);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');

  const showMessage = (msg, type = 'success') => {
    setMessage({ text: msg, type });
    setTimeout(() => setMessage(''), 3000);
  };

  const handleRegisterStudent = async (studentData) => {
    try {
      setLoading(true);
      const response = await axios.post(`${API}/students`, studentData);
      console.log('Student registered:', response.data);
      showMessage(t('success'), 'success');
      setCurrentView('home');
      // Refresh students list if we're viewing it
      if (currentView === 'students') {
        await fetchStudents();
      }
    } catch (error) {
      console.error('Error registering student:', error);
      showMessage(t('error'), 'error');
    } finally {
      setLoading(false);
    }
  };

  const fetchStudents = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`${API}/students`);
      setStudents(response.data);
    } catch (error) {
      console.error('Error fetching students:', error);
      showMessage(t('error'), 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleViewStudents = async () => {
    await fetchStudents();
    setCurrentView('students');
  };

  const renderContent = () => {
    if (currentView === 'register') {
      return (
        <StudentRegistrationForm
          onSubmit={handleRegisterStudent}
          onCancel={() => setCurrentView('home')}
        />
      );
    }
    
    if (currentView === 'students') {
      return (
        <StudentList
          students={students}
          onBack={() => setCurrentView('home')}
        />
      );
    }
    
    // Home view
    return (
      <div className="max-w-4xl mx-auto text-center">
        <div className="bg-white rounded-xl shadow-lg p-8">
          <div className="mb-8">
            <h2 className="text-3xl font-bold text-gray-800 mb-4">
              {t('title')}
            </h2>
            <p className="text-gray-600 text-lg">
              {t('tagline')}
            </p>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <button
              onClick={() => setCurrentView('register')}
              className="p-8 bg-gradient-to-r from-blue-500 to-blue-600 text-white rounded-xl hover:from-blue-600 hover:to-blue-700 transform hover:scale-105 transition-all duration-200 shadow-lg"
            >
              <div className="text-4xl mb-4">👨‍🎓</div>
              <h3 className="text-xl font-semibold mb-2">{t('registerStudent')}</h3>
              <p className="text-blue-100">Add new students to the system</p>
            </button>
            
            <button
              onClick={handleViewStudents}
              className="p-8 bg-gradient-to-r from-purple-500 to-purple-600 text-white rounded-xl hover:from-purple-600 hover:to-purple-700 transform hover:scale-105 transition-all duration-200 shadow-lg"
            >
              <div className="text-4xl mb-4">📋</div>
              <h3 className="text-xl font-semibold mb-2">{t('viewStudents')}</h3>
              <p className="text-purple-100">View all registered students</p>
            </button>
          </div>
        </div>
      </div>
    );
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <Header />
      
      {/* Message Display */}
      {message && (
        <div className={`fixed top-20 right-4 z-50 px-6 py-3 rounded-lg shadow-lg ${
          message.type === 'success' ? 'bg-green-500' : 'bg-red-500'
        } text-white`}>
          {message.text}
        </div>
      )}
      
      {/* Loading Overlay */}
      {loading && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white p-6 rounded-lg shadow-xl">
            <div className="animate-spin h-8 w-8 border-4 border-blue-500 border-t-transparent rounded-full mx-auto"></div>
            <p className="mt-4 text-gray-700">{t('loading')}</p>
          </div>
        </div>
      )}
      
      <main className="container mx-auto px-6 py-8">
        {renderContent()}
      </main>
    </div>
  );
};

// Root App Component
function App() {
  return (
    <LanguageProvider>
      <MainApp />
    </LanguageProvider>
  );
}

export default App;