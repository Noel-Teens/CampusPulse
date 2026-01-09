# 🎨 CampusPulse – UI Color Theme Documentation

## Theme Name: **Calm Tech Blue**

The **Calm Tech Blue** theme is designed to provide a **modern, professional, and user-friendly experience** for students, faculty, and campus administrators. The color palette focuses on clarity, accessibility, and reduced eye strain, making it suitable for prolonged daily use in an educational environment.

This theme aligns well with **Google Material Design principles** and integrates seamlessly with **Flutter Material 3**.

---

## 🎯 Design Goals

- Create a **trustworthy and professional** look
- Ensure **high readability** across devices
- Maintain **visual consistency** across all modules
- Support **light and dark modes**
- Improve usability through clear status colors

---

## 🎨 Primary Color Palette (Light Theme)

| Usage | Color Name | Hex Code |
|------|----------|----------|
| Primary | Deep Blue | `#2563EB` |
| Primary Variant | Indigo Blue | `#1E40AF` |
| Secondary | Teal Accent | `#14B8A6` |
| Background | Soft White | `#F8FAFC` |
| Surface (Cards) | Pure White | `#FFFFFF` |
| Text – Primary | Dark Slate | `#0F172A` |
| Text – Secondary | Muted Gray | `#64748B` |
| Divider / Border | Light Gray | `#E2E8F0` |

---

## 🚦 Status & Feedback Colors

These colors are used consistently across the application for alerts, issue states, and feedback indicators.

| Status | Usage | Hex Code |
|------|------|----------|
| Success | Resolved issues, confirmations | `#22C55E` |
| Warning | Pending issues, alerts | `#F59E0B` |
| Error | Failed actions, critical alerts | `#EF4444` |
| Info | Informational messages | `#3B82F6` |

---

## 🌙 Dark Mode Palette

The dark theme is optimized for low-light environments while maintaining contrast and readability.

| Usage | Color Name | Hex Code |
|------|----------|----------|
| Background | Dark Navy | `#020617` |
| Surface (Cards) | Dark Slate | `#0F172A` |
| Primary | Soft Blue | `#60A5FA` |
| Secondary | Teal Accent | `#2DD4BF` |
| Text – Primary | Soft White | `#F8FAFC` |
| Text – Secondary | Gray Blue | `#94A3B8` |

---

## 📱 Module Accent Color Mapping

Each module uses a distinct accent color to improve feature recognition and navigation.

| Module | Accent Color | Hex Code |
|------|-------------|----------|
| Campus Map & Navigation | Blue | `#2563EB` |
| Issue Reporting | Amber | `#F59E0B` |
| AI Assistant | Teal | `#14B8A6` |
| Notices & Events | Purple | `#7C3AED` |
| Feedback & Polls | Green | `#22C55E` |

---

## 🧩 Flutter Theme Implementation (Reference)

```dart
ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFF2563EB),
    primary: Color(0xFF2563EB),
    secondary: Color(0xFF14B8A6),
    background: Color(0xFFF8FAFC),
  ),
  scaffoldBackgroundColor: Color(0xFFF8FAFC),
);
```

---

## 🧠 UX & Accessibility Guidelines

- Avoid pure black text on white backgrounds
- Maintain minimum contrast ratio for readability
- Use status colors only for their intended purpose
- Keep animations subtle and non-distracting
- Use rounded corners and consistent spacing

---

## 🏆 Why This Theme Works for CampusPulse

- Professional and education-friendly
- Easy to extend and customize
- Matches Google ecosystem design language
- Improves usability and user trust
- Hackathon-ready and production-capable

---

**CampusPulse UI Theme ensures clarity, consistency, and comfort — simplifying campus life through thoughtful design.**
