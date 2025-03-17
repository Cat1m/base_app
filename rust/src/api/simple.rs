use rayon::prelude::*;
use std::time::Instant;

#[flutter_rust_bridge::frb(sync)]
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

#[flutter_rust_bridge::frb(sync)]
pub fn calculate_power(base: i32, exponent: i32) -> i32 {
    let mut result = 1;
    for _ in 0..exponent {
        // Thêm dấu gạch dưới _ cho unused variable
        result *= base;
    }
    result
}

#[derive(Debug, Clone)]
pub struct BenchmarkResult {
    pub execution_time_ms: f64,
    pub summary: String,
}

// Cải tiến hàm benchmark Fibonacci
#[flutter_rust_bridge::frb(sync)]
pub fn benchmark_fibonacci(n: i32) -> BenchmarkResult {
    let start = Instant::now();

    // Thêm một số loop để kéo dài thời gian thực thi
    let mut result = 0i64;
    // Lặp lại nhiều lần để tăng thời gian đo
    for _ in 0..10000 {
        result = if n <= 1 {
            n as i64
        } else {
            let mut a = 0i64;
            let mut b = 1i64;
            for _ in 1..n {
                let temp = a + b;
                a = b;
                b = temp;
            }
            b
        };
    }

    let duration = start.elapsed();
    let time_ms = duration.as_micros() as f64 / 1000.0;

    // Sau đó chia thời gian cho 10000 để có thời gian cho 1 lần tính
    let time_per_op = time_ms / 10000.0;

    BenchmarkResult {
        execution_time_ms: time_per_op,
        summary: format!("Fibonacci({}) = {} in {:.6} ms", n, result, time_per_op),
    }
}

// Cải tiến hàm benchmark sắp xếp mảng
#[flutter_rust_bridge::frb(sync)]
pub fn benchmark_sorting(size: i32) -> BenchmarkResult {
    // Khởi tạo mảng ngẫu nhiên
    let mut vec: Vec<i32> = (0..size).map(|_| rand::random::<i32>()).collect();

    // Đo thời gian sắp xếp
    let start = Instant::now();
    vec.sort_unstable();
    let duration = start.elapsed();

    let time_ms = duration.as_micros() as f64 / 1000.0;

    BenchmarkResult {
        execution_time_ms: time_ms,
        summary: format!("Sorted array of {} elements in {:.2} ms", size, time_ms),
    }
}

// Cải tiến hàm benchmark nhân ma trận
#[flutter_rust_bridge::frb(sync)]
pub fn benchmark_matrix_multiplication(size: i32) -> BenchmarkResult {
    let size = size as usize;
    let matrix1 = vec![vec![1; size]; size];
    let matrix2 = vec![vec![2; size]; size];

    // Đo thời gian nhân ma trận
    let start = Instant::now();

    // Thực hiện phép nhân
    let _result: Vec<Vec<i32>> = (0..size)
        .into_par_iter()
        .map(|i| {
            let mut row_result = vec![0; size];
            let row1 = &matrix1[i];

            for k in 0..size {
                let val = row1[k];
                let row2 = &matrix2[k];

                for j in 0..size {
                    row_result[j] += val * row2[j];
                }
            }

            row_result
        })
        .collect();

    let duration = start.elapsed();
    let time_ms = duration.as_micros() as f64 / 1000.0;

    BenchmarkResult {
        execution_time_ms: time_ms,
        summary: format!("Multiplied {}x{} matrices in {:.2} ms", size, size, time_ms),
    }
}

// Giữ các hàm gốc để tương thích ngược
#[flutter_rust_bridge::frb(sync)]
pub fn calculate_fibonacci(n: i32) -> i64 {
    if n <= 1 {
        return n as i64;
    }
    let mut a = 0i64;
    let mut b = 1i64;
    for _ in 1..n {
        let temp = a + b;
        a = b;
        b = temp;
    }
    b
}

#[flutter_rust_bridge::frb(sync)]
pub fn sort_large_array(size: i32) -> Vec<i32> {
    let mut vec: Vec<i32> = (0..size).map(|_| rand::random::<i32>()).collect();
    vec.sort_unstable();
    vec
}

#[flutter_rust_bridge::frb(sync)]
pub fn matrix_multiplication(size: i32) -> Vec<Vec<i32>> {
    let size = size as usize;
    let matrix1 = vec![vec![1; size]; size];
    let matrix2 = vec![vec![2; size]; size];

    let result: Vec<Vec<i32>> = (0..size)
        .into_par_iter()
        .map(|i| {
            let mut row_result = vec![0; size];
            let row1 = &matrix1[i];

            for k in 0..size {
                let val = row1[k];
                let row2 = &matrix2[k];

                for j in 0..size {
                    row_result[j] += val * row2[j];
                }
            }

            row_result
        })
        .collect();

    result
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}
