use rust_template::greet;

#[test]
fn greets_by_name() {
    assert_eq!(greet("integration"), "Hello, integration!");
}
