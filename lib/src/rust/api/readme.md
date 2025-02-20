# Flutter Rust API Notes

## Cấu trúc thư mục
```
lib/src/rust/api/
  ├── simple.dart              # Generated Dart API từ Rust
  └── frb_generated.dart       # Generated helper code

lib/src/rust/
  ├── frb_generated.dart       # Generated main bridge code
  ├── frb_generated.io.dart    # Generated code cho mobile/desktop platforms
  └── frb_generated.web.dart   # Generated code cho web platform
```

## Cách sử dụng API

1. **Import API**
```dart
import 'api/simple.dart';
```

2. **Các hàm có sẵn**
```dart
// Greet function
String result = greet(name: "World"); // Returns: "Hello, World!"

// Calculate power
int power = calculatePower(base: 2, exponent: 3); // Returns: 8

// Calculate fibonacci
PlatformInt64 fib = calculateFibonacci(n: 10);

// Sort large array
Int32List sorted = sortLargeArray(size: 1000);

// Matrix multiplication
List<Int32List> result = matrixMultiplication(size: 100);
```

3. **Kiểu dữ liệu mapping**
| Rust          | Dart         |
|---------------|--------------|
| String        | String       |
| i32           | int          |
| i64           | Int64        |
| Vec<i32>      | Int32List    |
| Vec<Vec<i32>> | List<Int32List> |

## Lưu ý
- Tất cả hàm được generate đều là synchronous (sync)
- Kiểu dữ liệu được tự động chuyển đổi giữa Rust và Dart
- Code trong các file được generate không nên được sửa trực tiếp
- Để thêm hàm mới, hãy thêm vào `simple.rs` và chạy lại generator

## Platform-specific Implementation

Flutter Rust Bridge tự động tạo ra các file implementation khác nhau cho từng platform:

### Generated Files Structure

1. **frb_generated.dart** - File chính chứa:
   - Implementation đầy đủ của các API
   - Logic decode/encode dữ liệu
   - Xử lý các lời gọi hàm
   - Toàn bộ business logic
   - RustLib class để khởi tạo và quản lý bridge

2. **frb_generated.io.dart** - Platform-specific cho mobile/desktop:
   - Abstract class định nghĩa interface
   - Setup cho FFI (Foreign Function Interface)
   - Cấu hình đặc thù cho platform mobile/desktop

3. **frb_generated.web.dart** - Platform-specific cho web:
   - Setup cho WASM (Web Assembly)
   - Cấu hình đặc thù cho web platform
   - Các binding với JavaScript

Cấu trúc này tuân theo mô hình "platform channels" của Flutter, cho phép một codebase duy nhất có thể chạy trên nhiều platform khác nhau. File chính `.dart` chứa logic chung, trong khi các file `.io.dart` và `.web.dart` chỉ chứa code cần thiết để làm việc với từng platform cụ thể.

## Generator Command
```bash
flutter_rust_bridge_codegen generate
```

## Các bước khi thêm API mới
1. Thêm hàm mới vào `rust/src/api/simple.rs`
2. Chạy generator command
3. Kiểm tra file `simple.dart` để xem API mới được generate
4. Sử dụng API mới trong code Flutter

## Example Usage
```dart
void main() async {
  // Initialize
  await RustLib.init();

  // Use the API
  final result = greet(name: "World");
  print(result); // "Hello, World!"

  // Process large data
  final sortedArray = sortLargeArray(size: 1000000);
  print("Sorted ${sortedArray.length} numbers");
}
```