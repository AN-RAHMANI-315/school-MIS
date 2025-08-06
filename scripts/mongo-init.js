// MongoDB initialization script
db = db.getSiblingDB('school_mis');

// Create a user for the application
db.createUser({
  user: 'app_user',
  pwd: 'app_password',
  roles: [
    {
      role: 'readWrite',
      db: 'school_mis'
    }
  ]
});

// Create collections and indexes
db.createCollection('students');

// Create indexes for better performance
db.students.createIndex({ "name": 1 });
db.students.createIndex({ "class_name": 1 });
db.students.createIndex({ "id": 1 }, { unique: true });

print('Database initialized successfully!');
