# Troubleshooting Blank Screen

## If you see a blank screen:

### Step 1: Check Browser Console
1. Press **F12** in Chrome
2. Click **Console** tab
3. Look for **red error messages**
4. Copy and paste them here

### Step 2: Check Network Tab
1. Press **F12** in Chrome
2. Click **Network** tab
3. Refresh the page (F5)
4. Look for **failed requests** (red entries)
5. Check if `flutter_bootstrap.js` loads

### Step 3: Try Minimal Test
Run this command to test if Flutter web works at all:
```bash
flutter run -d chrome -t lib/main_test.dart
```

If the test file shows a green screen with "Flutter Web Works!", then Flutter is working and the issue is with our app code.

### Step 4: Check Terminal Output
Look at the terminal where you ran `flutter run`:
- Are there any error messages?
- Does it say "Waiting for connection from debug service"?
- Does it show compilation errors?

### Common Issues:

1. **JavaScript errors** - Check browser console (F12)
2. **Firebase not configured** - Make sure Firebase is set up
3. **Build errors** - Check terminal output
4. **Port conflicts** - Try a different port: `flutter run -d chrome --web-port=8080`

### Quick Fixes:

1. **Clear browser cache**: Ctrl+Shift+Delete → Clear cached images and files
2. **Hard refresh**: Ctrl+Shift+R or Ctrl+F5
3. **Try incognito mode**: Open Chrome in incognito and navigate to localhost
4. **Check if port is in use**: The terminal will show the URL (usually localhost:xxxxx)

