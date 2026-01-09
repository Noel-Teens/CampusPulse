# Admin User Setup Guide

Since there is no "Sign Up" page for Admins (for security), you must manually create the first Admin user directly in the Firebase Console.

## Step 1: Create Auth User
1.  Go to the **Firebase Console** > **Authentication** > **Users** tab.
2.  Click **Add User**.
3.  Enter the admin email (e.g., `admin@campuspulse.com`) and a secure password.
4.  Click **Add User**.
5.  **Copy the User UID** of the newly created user (you will need this for Step 2).

## Step 2: Create Firestore Record
1.  Go to **Firebase Console** > **Firestore Database**.
2.  Click **Start collection** (if `users` doesn't exist) or click on the `users` collection.
    *   **Collection ID:** `users`
3.  Click **Add document**.
4.  **Document ID:** Paste the **User UID** you copied in Step 1.
5.  Add the following fields:

| Field | Type | Value |
| :--- | :--- | :--- |
| `email` | string | `admin@campuspulse.com` (Same as Auth) |
| `role` | string | `admin` |
| `campusId` | string | `campus_001` |
| `isVerified` | boolean | `true` |
| `createdAt` | timestamp | (Select today's date/time) |

## Step 3: Login
1.  Open the CampusPulse App.
2.  On the Welcome Screen, click **"Already have an account? Sign In"**.
3.  Login with the credentials you created (`admin@campuspulse.com`).
4.  You should be redirected to the **Admin Dashboard**.
