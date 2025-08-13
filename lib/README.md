# `StorageDeque`


An efficient double ended queue for storage values.

Values are stored using index hashes for constant time retreival, and head and tail insertion.
The queue can be at most 2^64 large.


```
forc add storage_deque@0.1.1
```

```sway

contract;

use storage_deque::*;

storage {
    queue: StorageDeque<u8> = StorageDeque {},
}

impl Contract {
    #[storage(read, write)]
    fn test() {
      storage.queue.push_back(1);
      storage.queue.push_back(2);
      storage.queue.push_back(3);
      storage.queue.push_back(4);
      assert_eq(Some(4u8), storage.queue.pop_back());
      assert_eq(Some(1u8), storage.queue.pop_front());
      assert_eq(Some(2u8), storage.queue.pop_front());
      storage.queue.push_front(42);
      assert_eq(Some(3u8), storage.queue.pop_back());
      assert_eq(Some(42u8), storage.queue.pop_back());
      assert(storage.queue.is_empty());
      assert_eq(None, storage.queue.pop_back());
    }
}
```

