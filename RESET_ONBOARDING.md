# Reset Onboarding

If you want to see the onboarding screen again, you can reset it by clearing the browser's local storage:

## Method 1: Browser Console (Quick)
1. Press **F12** to open DevTools
2. Go to **Console** tab
3. Type: `localStorage.clear()` and press Enter
4. Refresh the page (F5)

## Method 2: Application Storage
1. Press **F12** to open DevTools
2. Go to **Application** tab (Chrome) or **Storage** tab (Firefox)
3. Expand **Local Storage**
4. Click on your app's URL
5. Find `flutter.has_seen_onboarding` and delete it
6. Refresh the page

## Method 3: Clear All Site Data
1. Press **Ctrl + Shift + Delete**
2. Select "Cookies and other site data"
3. Click "Clear data"
4. Refresh the page

After clearing, the app will show the onboarding screen again on next launch.

