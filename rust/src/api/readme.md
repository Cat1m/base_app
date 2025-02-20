# Flutter Rust Bridge Notes

## Cấu trúc Project
```
rust/src/
  ├── mod.rs           # Khai báo các modules (pub mod simple;)
  ├── simple.rs        # Logic implementation 
  └── frb_generated.rs # Code được generate tự động
```

## Cách hoạt động

1. **Wire Function Pattern**
```rust
wire__crate__api__simple__calculate_fibonacci_impl
^     ^      ^   ^      ^                    ^
|     |      |   |      |                    |
|     |      |   |      |                    +-- Hậu tố impl
|     |      |   |      +------------------- Tên hàm
|     |      |   +-------------------------- Tên module (từ mod.rs)
|     |      +---------------------------- Namespace api
|     +---------------------------------- crate
+--------------------------------------- Prefix wire
```

2. **Flow làm việc**
- Viết logic trong file Rust (ví dụ `simple.rs`)
- Chạy `flutter_rust_bridge_codegen generate`
- Code được generate vào:
  - `lib/src/rust/api/simple.dart` (Dart side)
  - `rust/src/frb_generated.rs` (Rust side)

3. **Macro Annotations**
```rust
#[flutter_rust_bridge::frb(sync)]  // Đánh dấu hàm có thể gọi từ Flutter
pub fn your_function() { ... }

#[flutter_rust_bridge::frb(init)]  // Đánh dấu hàm khởi tạo
pub fn init_app() { ... }
```

4. **Parallel Processing với Rayon**
```rust
use rayon::prelude::*;

// Ví dụ về xử lý song song
.into_par_iter()
.map(|i| {
    // Processing logic
})
.collect()
```

## Lưu ý
- File `frb_generated.rs` sẽ tự động phình to khi thêm nhiều logic
- Mỗi hàm mới cần được đánh dấu với macro phù hợp
- Code generated không nên sửa trực tiếp
- Sử dụng Rayon cho xử lý song song khi cần thiết

## Các kiểu dữ liệu thường dùng
- `String` -> `String`
- `i32` -> `int`
- `i64` -> `Int64`
- `Vec<i32>` -> `Int32List`
- `Vec<Vec<i32>>` -> `List<Int32List>`

## Tham khảo
- [Flutter Rust Bridge Documentation](https://cjycode.com/flutter_rust_bridge/)
- [Rayon Documentation](https://docs.rs/rayon)