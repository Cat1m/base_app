use rayon::prelude::*;

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

#[flutter_rust_bridge::frb(sync)]
pub fn calculate_fibonacci(n: i32) -> i64 {
    if n <= 1 {
        return n as i64;
    }
    let mut a = 0i64;
    let mut b = 1i64;
    for _ in 1..n {
        // Thêm dấu gạch dưới _ cho unused variable
        let temp = a + b;
        a = b;
        b = temp;
    }
    b
}

#[flutter_rust_bridge::frb(sync)]
pub fn sort_large_array(size: i32) -> Vec<i32> {
    let mut vec: Vec<i32> = (0..size).map(|_| rand::random::<i32>()).collect(); // Sửa |_| thay vì ||
    vec.sort_unstable();
    vec
}

#[flutter_rust_bridge::frb(sync)]
pub fn matrix_multiplication(size: i32) -> Vec<Vec<i32>> {
    let size = size as usize;
    let matrix1 = vec![vec![1; size]; size];
    let matrix2 = vec![vec![2; size]; size];

    // Tính toán song song và thu thập kết quả
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
