# 🧠 Axon Vision - Frontend (Flutter)

Axon Vision is the user interface (Frontend) for the **3D Brain Tumor Detection System**. Built with Flutter, this application is specifically designed for Web platforms, providing an interactive experience for MRI data analysis, patient management, and real-time 3D visualization.

## ✨ Key Features

- 🔐 **Multi-Role Authentication**: Secure login system with role-based access control for **Admin**, **Doctors (Sp.S)**, and **Radiologists (Sp.Rad)**.
- 👥 **User & Patient Management**: Full CRUD (Create, Read, Update, Disable) functionality with a responsive UI and automated ID generation for medical records.
- 🩻 **Interactive 2D Slices**: View MRI slices (Sagittal, Coronal, Axial) with intuitive Zoom, Rotate, and Contrast Inversion controls.
- 🧊 **3D Volume Rendering**: Seamless 3D visualization of brain structures and tumors (NETC, SNFH, ET, RC) integrated via an embedded web viewer.
- 📊 **System Log Monitoring**: A comprehensive audit trail for Admins to track user activities with multi-parameter filtering (Role & Date Range).

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Channel Stable, SDK >=3.0.0)
- **State Management**: [GetX](https://pub.dev/packages/get)
- **Networking**: `http`
- **Local Storage**: `get_storage`
- **Key Packages**: `calendar_date_picker2`, `google_fonts`, `webview_flutter`

## ⚙️ Prerequisites

Before running this project, ensure you have installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.0.0 or higher).
- Google Chrome (recommended for optimal web performance).
- An IDE like VS Code or Android Studio.

## 🚀 Getting Started

Follow these steps to run Axon Vision locally:

1. **Clone the Repository**
   ```bash
   git clone <your-repository-url>
   cd axon_vision

2. **Install Dependencies**
   ```bash
   flutter pub get

3. **Run the Application**
   ```bash
   flutter run -d chrome

## 🛡️ License
Copyright © 2026 Axon Vision. All rights Reserved.
