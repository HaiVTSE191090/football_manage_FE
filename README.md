# Football Management FE

Ứng dụng Flutter frontend cho hệ thống quản lý sân bóng.

## Yêu cầu

- Flutter SDK
- Backend đang chạy

## Cài đặt

Clone project, sau đó chạy:

```powershell
flutter pub get
```

## Cấu hình môi trường

Tạo file `.env` ở thư mục gốc project:

```env
BASE_URL=http://localhost:8080
```

Nếu chạy bằng Android Emulator, dùng:

```env
BASE_URL=http://10.0.2.2:8080
```

Nếu chạy bằng điện thoại thật, dùng IP LAN của máy đang chạy backend, ví dụ:

```env
BASE_URL=http://192.168.1.10:8080
```

## Chạy app

```powershell
flutter run
```

## Kiểm tra code

```powershell
flutter analyze
flutter test
```
