# Multi-Vendor Ecommerce Admin Panel

A comprehensive Flutter-based admin panel for managing a multi-vendor ecommerce platform. This application provides a robust interface for administrators to manage products, vendors, and overall marketplace operations.

## 🌟 Features

### Product Management
- View all products in a responsive grid layout
- Filter products by categories
- Detailed product information display including:
  - Multiple product images with carousel view
  - Price and stock information
  - Product descriptions
  - Category classification
  - Customer reviews and ratings
- Delete product functionality
- Real-time updates using Firebase

### User Interface
- Responsive design that adapts to different screen sizes
- Modern Material Design implementation
- Custom themed components
- Smooth animations and transitions
- Interactive product cards
- Dotted dividers for visual separation

### Firebase Integration
- Real-time database connectivity
- Cloud Firestore for data storage
- Firebase Authentication for secure access
- Multi-platform configuration (Android, iOS, Web, Windows)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (Latest stable version)
- Firebase account and project setup
- Dart SDK
- IDE (VS Code, Android Studio, or IntelliJ)

### Installation

1. Clone the repository


```bash
git clone https://github.com/yourusername/multi_vendor_ecommerce_app_admin_panel.git
```

2. Install dependencies


```bash
flutter pub get
```

4. Configure Firebase
- Create a new Firebase project
- Add your Firebase configuration files:
  - `google-services.json` for Android
  - Firebase configuration for Web
  - Configure iOS and macOS if needed

5. Run the application
```bash
flutter run
```

## 🏗️ Project Structure

```
lib/
├── screens/
│   └── manage_products_screen.dart    # Main product management interface
├── services/
│   └── admin_service.dart            # Firebase and backend services
├── widgets/
│   └── dotted_divider.dart          # Custom UI components
└── main.dart                        # Application entry point
```

## 🔧 Technical Details

### Dependencies
- `cloud_firestore`: Firebase database integration
- `firebase_auth`: Authentication services
- `google_fonts`: Custom typography
- `line_icons`: Modern icon set
- `intl`: Internationalization and formatting

### Platform Support
- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ Linux
- ✅ macOS

## 🎨 UI Components

### Product Grid
- Responsive grid layout
- Automatic column adjustment based on screen size
- Product cards with hover effects
- Image preview with fallback

### Product Details Dialog
- Full-screen modal
- Image carousel
- Detailed product information
- Review section with ratings
- User feedback display

## 🔐 Security

- Firebase Authentication integration
- Secure admin access
- Protected API endpoints
- Data validation and sanitization

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


## 📞 Support

For support, email edilayehu534027@example.com or create an issue in the repository.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- All contributors who have helped this project grow

---

Made with ❤️ by [Edilayehu](https://edilayehu.com/)