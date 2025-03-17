# base_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


# Flutter Rust Bridge - Prompt Guide

## Khi cần thêm logic mới

```
Tôi cần thêm [mô tả chức năng] vào project Flutter Rust Bridge. 
Project hiện tại có cấu trúc:

1. Rust side (rust/src/api/simple.rs):
[Paste code hiện tại của simple.rs]

2. Flutter side example usage:
[Paste ví dụ code Flutter đang dùng]

Yêu cầu:
1. Tên function: [đề xuất tên]
2. Input parameters: [mô tả input]
3. Output: [mô tả output mong muốn]
4. Performance requirements: [yêu cầu về performance nếu có]

Xin hãy:
1. Thêm logic xử lý vào simple.rs
2. Cho ví dụ cách gọi function trong Flutter
```

## Khi cần optimize performance

```
Tôi cần optimize performance cho function [tên function] trong project Flutter Rust Bridge.
Code hiện tại:

[Paste code cần optimize]

Hiện tại function đang:
1. Input size: [mô tả kích thước input]
2. Processing time: [thời gian xử lý hiện tại]
3. Resource usage: [resource đang dùng]

Xin hãy:
1. Analyze performance bottlenecks
2. Đề xuất cách optimize (ví dụ: dùng Rayon cho parallel processing)
3. Cung cấp code đã optimize
```

## Khi cần debug

```
Tôi đang gặp vấn đề khi sử dụng Flutter Rust Bridge:

1. Code đang dùng:
Rust side:
[Paste Rust code]

Flutter side:
[Paste Flutter code]

2. Error message:
[Paste error message]

3. Expected behavior:
[Mô tả behavior mong muốn]

4. Steps to reproduce:
[Các bước để reproduce lỗi]

Xin hãy giúp:
1. Phân tích nguyên nhân
2. Đề xuất cách fix
3. Cung cấp code đã sửa
```

## Khi cần xử lý data types mới

```
Tôi cần thêm support cho data type mới trong Flutter Rust Bridge:

1. Rust type: [mô tả Rust type]
2. Expected Flutter type: [mô tả Flutter type tương ứng]
3. Use case: [mô tả use case]

Current code:
[Paste relevant code]

Xin hãy:
1. Đề xuất cách implement
2. Cung cấp code ví dụ cho cả Rust và Flutter side
3. Giải thích cách data được serialize/deserialize
```

## Tips khi viết prompt
1. Luôn cung cấp code hiện tại của simple.rs
2. Mô tả rõ input/output mong muốn
3. Nêu rõ yêu cầu về performance nếu có
4. Cung cấp error message đầy đủ khi gặp lỗi
5. Mô tả use case cụ thể để nhận được solution phù hợp

## Khi thêm module mới

```
Tôi cần thêm module mới [tên module] vào project Flutter Rust Bridge để xử lý [mô tả chức năng].

Cấu trúc hiện tại:
rust/src/
  ├── mod.rs           # Current content: pub mod simple;
  ├── simple.rs
  └── frb_generated.rs

Xin hãy:
1. Tạo file module mới và cấu trúc nó
2. Update mod.rs để include module mới
3. Cho ví dụ một số function cơ bản trong module
4. Hướng dẫn cách gọi các function của module mới từ Flutter

Yêu cầu cho module mới:
1. Module name: [tên module]
2. Các function cần có: [liệt kê function]
3. Kiểu dữ liệu đặc thù: [nếu có]
4. Cách tổ chức code: [structure mong muốn]
```

### Example Module Structure

Ví dụ khi thêm module `math_utils`:

1. Tạo file `rust/src/math_utils.rs`:
```rust
use rayon::prelude::*;

#[flutter_rust_bridge::frb(sync)]
pub fn complex_calculation(data: Vec<f64>) -> f64 {
    // Implementation
}

#[flutter_rust_bridge::frb(sync)]
pub fn matrix_operations(matrix: Vec<Vec<f64>>) -> Vec<Vec<f64>> {
    // Implementation
}
```

2. Update `mod.rs`:
```rust
pub mod simple;
pub mod math_utils;  // Thêm dòng này
```

3. Sau khi chạy generator, cấu trúc mới:
```
lib/src/rust/api/
  ├── simple.dart
  ├── math_utils.dart  // Generated mới
  └── frb_generated.dart
```

4. Sử dụng trong Flutter:
```dart
import 'package:your_app/src/rust/api/math_utils.dart';

void someFunction() {
  final result = complexCalculation(data: [1.0, 2.0, 3.0]);
}
```

## Best Practices
1. Test code trên cả mobile và web platform
2. Xem xét sử dụng Rayon cho heavy computation
3. Handle errors appropriately cả hai phía
4. Đặt tên function và types rõ ràng, dễ hiểu
5. Comment code khi logic phức tạp

# 1. Clone repo base_app và đổi tên thành food_app
git clone https://github.com/Cat1m/base_app.git food_app

# 2. Di chuyển vào thư mục dự án mới
cd food_app

# 3. Cài đặt và active package rename
flutter pub global activate rename

# 4. Tạo và chạy script đổi tên dự án
python rename_project.py food_app

# 5. Cài đặt và chạy flutter_rust_bridge_codegen
cargo install flutter_rust_bridge_codegen
flutter_rust_bridge_codegen generate

# 6. Hoàn tất thiết lập
flutter clean
flutter pub get
# (Nếu phát triển cho iOS)
cd ios && pod install && cd ..

# 7. Chạy ứng dụng để kiểm tra
flutter run