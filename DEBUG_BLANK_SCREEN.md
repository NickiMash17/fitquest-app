# Debugging Blank Screen

## Quick Fixes (Try These First):

### 1. Hard Refresh Browser
- Press **Ctrl + Shift + R** (Windows) or **Cmd + Shift + R** (Mac)
- Or press **F12** → Right-click refresh button → "Empty Cache and Hard Reload"

### 2. Check Browser Console
1. Press **F12** to open DevTools
2. Click **Console** tab
3. Look for **red error messages**
4. Copy any errors you see

### 3. Check Terminal Output
Look at the terminal where you ran `flutter run`:
- Are there any compilation errors?
- Does it say "Waiting for connection from debug service"?
- What's the last message you see?

### 4. Try Hot Restart
In the terminal where Flutter is running:
- Press **R** (capital R) for hot restart
- Or press **r** (lowercase) for hot reload

### 5. Clear Browser Data
1. Press **Ctrl + Shift + Delete**
2. Select "Cached images and files"
3. Click "Clear data"
4. Refresh the page

### 6. Try Incognito Mode
1. Open Chrome in incognito mode (Ctrl + Shift + N)
2. Navigate to the URL shown in terminal (usually `localhost:xxxxx`)

## If Still Blank:

### Check if App is Running
The terminal should show something like:
```
Flutter run key commands.
r Hot reload.
R Hot restart.
```

If you don't see this, the app might not be running. Try:
```bash
flutter run -d chrome
```

### Check for JavaScript Errors
1. Open browser console (F12)
2. Look for errors in red
3. Common errors:
   - `Uncaught TypeError`
   - `Failed to load`
   - `Cannot read property`

### Check Network Tab
1. Press **F12** → **Network** tab
2. Refresh the page
3. Look for failed requests (red entries)
4. Check if `main.dart.js` loads successfully

## Still Not Working?

Please share:
1. What you see in the browser console (F12 → Console)
2. The last few lines from the terminal
3. Any error messages

