# Origination-Inventory Brand Assets

This directory contains all brand assets for the Origination-Inventory application.

## Directory Structure

```
assets/
├── logos/
│   ├── origination-logo.png          # Main logo file (replaces marble-logo.png)
│   ├── origination-favicon.ico       # Favicon for web browsers
│   ├── origination-splash.png        # Splash screen image
│   ├── origination-icon-192.png      # Web app icon 192x192
│   └── origination-icon-512.png      # Web app icon 512x512
└── README.md                          # This file
```

## Logo Usage

### Main Logo
- **File**: `origination-logo.png`
- **Usage**: Primary logo for headers, navigation, and branding
- **Colors**: White (#FFFFFF), Gold (#D4AF37), Black (#000000)
- **Design**: Circular design with gold/black wave form and "Origination STORE" text

### Favicon
- **File**: `origination-favicon.ico`
- **Usage**: Browser tab icon and bookmarks
- **Size**: 16x16, 32x32, 48x48 pixels (multi-size ICO format)

### Splash Screen
- **File**: `origination-splash.png`
- **Usage**: Mobile app loading screen
- **Placement**: Android app splash screens (all orientations and densities)

### Web App Icons
- **Files**: `origination-icon-192.png`, `origination-icon-512.png`
- **Usage**: Progressive Web App (PWA) icons
- **Sizes**: 192x192px and 512x512px for different display contexts

## Mobile App Assets

### Android Icons
All Android app icons have been updated in the following locations:
- `android/app/src/main/res/mipmap-*/ic_launcher.png`
- `android/app/src/main/res/mipmap-*/ic_launcher_round.png`

### Android Splash Screens
All Android splash screens have been updated in:
- `android/app/src/main/res/drawable*/splash.png`

## Brand Colors

- **Primary White**: #FFFFFF
- **Accent Gold**: #D4AF37
- **Primary Black**: #000000

## Wave Form Design Elements

The logo features an "S" wave design element that should be incorporated throughout the UI:
- Wave-inspired borders and dividers
- Wave form animations for loading states
- Wave-based button and interactive element styling

## File Replacements

This asset structure replaces all references to:
- `marble-logo.png` → `origination-logo.png`
- Old blue color scheme (#007AFF) → New white/gold/black scheme
- "Marble POS" branding → "Origination-Inventory" branding

## Notes

- All logo files maintain the same aspect ratio and design consistency
- Files are optimized for web and mobile usage
- The circular design works well for both square and round icon contexts
- Wave form elements can be extracted for CSS implementation