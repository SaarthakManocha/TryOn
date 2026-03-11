# TryOn App - Design Brief for Figma Team

## 📱 App Overview

**TryOn** is a virtual try-on fashion app that lets users:

- Upload a garment photo → See themselves wearing it
- Shop for similar products
- Save favorites to wardrobe

---

## 🎯 Design Deliverables Required

### Part 1: Design System (Priority: Critical)

Create a **Design System page** with:

#### Colors

| Token          | Purpose               | Example               |
| -------------- | --------------------- | --------------------- |
| Primary        | Main actions, buttons | Purple/Indigo         |
| Secondary      | Accents, highlights   | Pink/Magenta          |
| Background     | App background        | Dark (near black)     |
| Surface        | Cards, dialogs        | Slightly lighter dark |
| Text Primary   | Main text             | White                 |
| Text Secondary | Subtitles             | Gray                  |
| Text Muted     | Hints, placeholders   | Dim gray              |
| Success        | Confirmations         | Green                 |
| Error          | Errors, warnings      | Red                   |

#### Typography

| Style      | Usage           | Suggested Size |
| ---------- | --------------- | -------------- |
| H1         | Screen titles   | 32px bold      |
| H2         | Section headers | 24px semibold  |
| H3         | Card titles     | 20px semibold  |
| Body       | Regular text    | 16px regular   |
| Body Small | Descriptions    | 14px regular   |
| Caption    | Labels, hints   | 12px regular   |
| Button     | Button text     | 16px semibold  |

#### Components to Design

1. **Buttons**: Primary, Secondary, Outline, Ghost (with pressed states)
2. **Input Fields**: Text, Password (with error state)
3. **Cards**: Standard card, Glass card, Product card
4. **Checkboxes & Toggles**
5. **Bottom Navigation Bar**
6. **Loading States**: Spinner, Shimmer skeleton

---

### Part 2: Screens to Design (13 Total)

---

## 🔐 AUTH SCREENS (4 screens)

### Screen 1: Login

**Elements needed:**

- App logo/branding
- Email input field
- Password input field (with show/hide toggle)
- "Forgot Password?" link
- "Sign In" button (primary)
- "Sign in with Google" button (outline with Google icon)
- "Don't have an account? Sign Up" link
- Terms and Privacy links

**States:** Default, Loading, Error

---

### Screen 2: Sign Up

**Elements needed:**

- App logo/branding
- Full Name input
- Email input
- Password input
- Password strength indicator (Weak/Medium/Strong bar)
- Checkbox: "I agree to Terms and Conditions"
- "Create Account" button
- "Sign up with Google" button
- "Already have an account? Sign In" link

**States:** Default, Loading, Error, Terms modal

---

### Screen 3: Forgot Password

**Elements needed:**

- Back arrow
- Title: "Reset Password"
- Subtitle explaining the process
- Email input
- "Send Reset Link" button
- Success state (email sent confirmation)

---

### Screen 4: Email Verification

**Elements needed:**

- Mail icon/illustration
- Title: "Verify Your Email"
- User's email displayed
- "Resend Verification Email" button
- "Open Email App" button
- "Already Verified? Continue" link
- Timer showing when resend is available

---

## 👤 ONBOARDING SCREENS (3 screens)

### Screen 5: Style Preferences

**Elements needed:**

- Progress indicator (Step 1 of 3)
- Title: "What's Your Style?"
- Grid of style options with images:
  - Casual, Formal, Streetwear, Bohemian
  - Minimalist, Athletic, Classic, Trendy
- Each option: selectable with checkbox overlay
- "Continue" button
- "Skip" option

---

### Screen 6: Body Info

**Elements needed:**

- Progress indicator (Step 2 of 3)
- Title: "Tell Us About Yourself"
- Gender selector (Male/Female/Non-binary - cards or buttons)
- Body type selector (Slim/Average/Athletic/Chubby - with icons)
- Height slider (140cm - 210cm)
- "Continue" button
- "Back" button

**Note:** This data is critical for the backend. Keep these exact options.

---

### Screen 7: Profile Photo

**Elements needed:**

- Progress indicator (Step 3 of 3)
- Title: "Add Your Photo"
- Subtitle: "This helps create your virtual try-on model"
- Large photo placeholder (circular or square)
- Two buttons: "Take Photo" (📷) and "Choose from Gallery" (🖼️)
- Preview of uploaded photo
- "Get Started" button
- "Skip for Now" option

---

## 🏠 MAIN SCREENS (6 screens)

### Screen 8: Dashboard (Home)

**Elements needed:**

- Header with greeting ("Good Morning, Name 👋")
- User avatar (tap to go to profile)
- **Main CTA Card**: Large gradient card with "Virtual Try-On" call to action
- **Stats Row**: 3 small cards showing:
  - Number of try-ons
  - Favorites count
  - Style preferences count
- **Quick Actions Row**: 3 icon buttons (Camera, Gallery, URL)
- **Recent Try-Ons Section**: Horizontal scroll of recent results
- **Style Tips Section**: 2 tip cards with icons

**Navigation:** Bottom nav bar (Home, Try-On, Wardrobe, Profile)

---

### Screen 9: Try-On Flow (Critical - Multi-step)

**Step 1: Choose Garment**

- Title: "Choose an Outfit"
- Three option cards:
  - 📷 Take Photo
  - 🖼️ From Gallery
  - 🔗 From URL
- Tips section with best practices
- "Cancel" button

**Step 2: Choose Your Photo**

- Title: "Now, Add Your Photo"
- Preview of selected garment
- Three option cards:
  - 🤳 Take Selfie
  - 🖼️ From Gallery
  - 👤 Use Saved Photo (if available)
- "Back" button

**Step 3: Processing**

- Animated loading screen
- Step indicators:
  - Analyzing your photo...
  - Creating virtual model...
  - Generating try-on...
- Progress percentage or animation
- "Cancel" button

**Step 4: Result**

- Large result image
- Before/After comparison toggle
- Four action buttons in a row:
  - 💾 Save
  - 🛍️ Shop Similar
  - ↗️ Share
  - 🔄 Try Another
- "Back to Home" button

---

### Screen 10: Wardrobe

**Elements needed:**

- Title: "My Wardrobe"
- Filter tabs: All, Favorites
- Grid of saved try-ons (2 columns)
- Each card shows:
  - Try-on result image
  - Heart icon for favorites
  - Date saved
- Empty state: "No saved items yet" with CTA

---

### Screen 11: Profile

**Elements needed:**

- User avatar (large, with edit button)
- User name and email
- **Stats cards**: Try-ons, Favorites, Joined date
- **Settings list**:
  - Edit Profile
  - Body Information
  - Style Preferences
  - Settings ⚙️
- "Sign Out" button

---

### Screen 12: Shopping Results

**Elements needed:**

- Header with garment preview image
- Title: "Shop Similar Items"
- Search time badge ("Found X items in Y seconds")
- Product list (vertical scroll):
  - Product thumbnail
  - Product title
  - Price (₹ format)
  - Store name
  - Rating stars
  - "Buy" button or tap to open link
- Filter/Sort options (optional)
- Empty state: "No products found"

---

### Screen 13: Settings

**Elements needed:**

- Title: "Settings"
- Sections:
  - **Account**: Edit Profile, Change Password
  - **Preferences**: Notifications toggle, Dark mode toggle
  - **About**: Version, Terms, Privacy Policy
  - **Danger Zone**: Delete Account
- Sign Out button

---

## 📐 Screen Dimensions & Guidelines

| Spec              | Value                      |
| ----------------- | -------------------------- |
| Design for        | iPhone 14 Pro (393 x 852)  |
| Scale factor      | 1x                         |
| Safe area top     | 59px                       |
| Safe area bottom  | 34px                       |
| Bottom nav height | 80px                       |
| Grid margins      | 24px left/right            |
| Card padding      | 16px                       |
| Button height     | 48-56px                    |
| Corner radius     | Buttons: 12px, Cards: 16px |

---

## 📤 How to Deliver

1. **Figma Link**: Share view access link
2. **Export Icons**: SVG format, 24x24px base size
3. **Export Images**: PNG @3x for assets
4. **Color Codes**: Include exact HEX values

---

## ✅ Checklist

- [ ] Design System page complete
- [ ] All 13 screens designed
- [ ] Mobile responsive (393px width)
- [ ] Dark theme
- [ ] Loading/Error states for key screens
- [ ] Icons exported as SVG
- [ ] Figma link shared

---

## 🗓️ Timeline Suggestion

| Phase    | Deliverable                  | Duration |
| -------- | ---------------------------- | -------- |
| Week 1   | Design System + Auth Screens | 3-4 days |
| Week 1-2 | Onboarding + Dashboard       | 3-4 days |
| Week 2   | Try-On Flow + Results        | 3-4 days |
| Week 2-3 | Remaining screens + Polish   | 2-3 days |

---

## 📬 Questions?

The developer (me) will convert these designs into code. Feel free to be creative with the visual style - I'll handle making it work with the existing backend!
