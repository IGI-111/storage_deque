contract;

use storage_deque::*;

storage {
    queue: StorageDeque<u8> = StorageDeque {},
}

abi Example {
    #[storage(read, write)]
    fn test();
}

impl Example for Contract {
    #[storage(read, write)]
    fn test() {
      storage.queue.push_back(1);
      storage.queue.push_back(2);
      storage.queue.push_back(3);
      storage.queue.push_back(4);
      assert_eq(storage.queue.len(), 4);
      assert_eq(Some(4u8), storage.queue.pop_back());
      assert_eq(Some(1u8), storage.queue.pop_front());
      assert_eq(Some(2u8), storage.queue.pop_front());
      storage.queue.push_front(42);
      assert_eq(Some(3u8), storage.queue.pop_back());
      assert_eq(Some(42u8), storage.queue.pop_back());
      assert(storage.queue.is_empty());
      assert_eq(storage.queue.len(), 0);
      assert_eq(None, storage.queue.pop_back());
    }
}

#[test]
fn test_run() {
    let example = abi(Example, CONTRACT_ID);
    example.test();
}
