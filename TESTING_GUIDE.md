# Hushnav Testing Guide

## 🚀 **App is Running!**

Your Hushnav app is now running with real Supabase credentials at:
**http://localhost:3000**

## 🧪 **Testing Checklist**

### **1. Basic App Functionality**
- [ ] **Compass Tab**: Should show a functional compass with needle and cardinal directions
- [ ] **Level Tab**: Should show a bubble level that responds to device tilt
- [ ] **Navigation**: Switch between Compass and Level tabs
- [ ] **UI**: Clean, professional appearance like a real utility app

### **2. Hidden Unlock System**
Since we're testing on web (no accelerometer), use the **demo shortcut**:

- [ ] **Demo Unlock Button**: Click the small floating action button (🔓) on the home screen
- [ ] **PIN Setup**: First time should prompt to set a 4-digit PIN
- [ ] **PIN Entry**: Use the number pad to enter your PIN
- [ ] **Access Granted**: Should navigate to the secure chat screen

### **3. Chat System Testing**
Once unlocked:

- [ ] **Chat Interface**: Should show a clean chat interface with tabs
- [ ] **Message Input**: Text field at bottom for typing messages
- [ ] **Media Button**: Plus (+) button for adding media
- [ ] **Memories Tab**: Second tab for saved messages
- [ ] **Partner Notify**: Notification button in app bar

### **4. Security Features**
- [ ] **Panic Mode**: Long press the chat title or tap shield icon
- [ ] **Auto Return**: Should immediately return to Compass tab
- [ ] **Lock State**: Chat should be locked again after panic mode

### **5. Backend Integration**
With your Supabase credentials configured:

- [ ] **No Configuration Errors**: Console should show successful Supabase connection
- [ ] **Authentication Ready**: Sign-in functionality should be available
- [ ] **Database Connection**: No connection errors in browser console

## 🔍 **What to Look For**

### **✅ Success Indicators**
- App loads without errors
- Compass shows realistic compass interface
- Level shows bubble that moves (simulated on web)
- Demo unlock button works
- PIN setup flows correctly
- Chat interface appears after unlock
- Panic mode returns to compass immediately

### **❌ Potential Issues**
- **Firebase Errors**: Expected on web without proper Firebase config (notifications won't work)
- **Sensor Warnings**: Expected on web platform (no real sensors)
- **Authentication Prompts**: May appear if trying to use real chat features

## 🎯 **Key Features to Demonstrate**

### **Stealth Mode**
- App looks completely normal as "Compass & Level" utility
- No visible indication of hidden chat functionality
- Professional UI that would pass casual inspection

### **Hidden Access**
- Unlock mechanism is completely hidden
- Demo button simulates the real tilt detection
- PIN security protects access

### **Chat System**
- Full messaging interface (ready for backend integration)
- Media support framework in place
- Memories system for saving important messages

### **Security**
- Instant panic mode activation
- Automatic return to utility mode
- No traces of chat functionality when locked

## 🛠 **Testing on Mobile Device**

For full functionality testing:

1. **Connect Mobile Device**:
   ```bash
   flutter devices
   flutter run -d [device-id]
   ```

2. **Real Sensor Testing**:
   - Tilt detection at ~127° angle
   - Gyroscope motion validation
   - 3-second hold requirement

3. **Background Testing**:
   - Auto-lock when app goes to background
   - Notification handling (with Firebase setup)

## 📱 **Browser Testing Tips**

### **Chrome DevTools**
- Open DevTools (F12)
- Check Console for any errors
- Use Device Simulation for mobile view
- Test responsive design

### **Simulated Mobile Experience**
- Toggle device toolbar in DevTools
- Select mobile device (iPhone/Android)
- Test touch interactions
- Verify mobile-friendly UI

## 🔧 **Next Steps**

1. **Test Basic Functionality**: Verify compass and level work
2. **Test Hidden Access**: Use demo unlock button
3. **Explore Chat Interface**: Navigate through all screens
4. **Test Security**: Try panic mode functionality
5. **Check Backend**: Verify Supabase connection in console

## 📞 **Troubleshooting**

### **Common Issues**
- **App won't load**: Check browser console for errors
- **Unlock not working**: Use the demo floating button
- **Chat errors**: Expected without full backend setup
- **Firebase errors**: Normal on web without proper config

### **Debug Information**
- Browser console shows detailed logs
- Supabase connection status displayed
- Configuration validation messages
- Error details for troubleshooting

The app is designed to work seamlessly as a hidden communication system while maintaining perfect cover as a utility app. Test the stealth aspects and security features to see how effectively it conceals its true purpose!