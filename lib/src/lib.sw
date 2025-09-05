library;

use std::hash::sha256;
use std::storage::storage_key::StorageKey;

const STORAGE_DEQUE_DOMAIN: u8 = 39;

pub struct StorageDeque<T> {}

impl<T> StorageKey<StorageDeque<T>> {
    fn front_key(self) -> StorageKey<u64> {
        StorageKey::new(self.slot(), self.offset() + 0, self.field_id())
    }
    #[storage(read)]
    pub fn front_index(self) -> u64 {
        self.front_key().try_read().unwrap_or(0)
    }
    fn tail_key(self) -> StorageKey<u64> {
        StorageKey::new(self.slot(), self.offset() + 1, self.field_id())
    }
    #[storage(read)]
    pub fn tail_index(self) -> u64 {
        self.tail_key().try_read().unwrap_or(0)
    }

    #[storage(read)]
    pub fn back_index(self) -> u64 {
        wrapping_sub(self.tail_index(), 1)
    }

    fn get_key(self, index: u64) -> StorageKey<T> {
        StorageKey::new(sha256((STORAGE_DEQUE_DOMAIN, index)), self.offset(), self.field_id())
    }

    #[storage(read)]
    pub fn is_empty(self) -> bool {
        self.tail_index() == self.front_index()
    }

    #[storage(read)]
    pub fn front(self) -> Option<T> {
        if self.is_empty() {
            None
        } else {
            Some(self.get_key(self.front_index()).read())
        }
    }

    #[storage(read)]
    pub fn back(self) -> Option<T> {
        if self.is_empty() {
            None
        } else {
            Some(self.get_key(self.back_index()).read())
        }
    }

    #[storage(read, write)]
    pub fn push_back(self, val: T) {
        let tail_index = self.tail_index();
        self.tail_key().write(wrapping_add(tail_index, 1));
        self.get_key(tail_index).write(val);
    }

    #[storage(read, write)]
    pub fn push_front(self, val: T) {
        let front_index =  wrapping_sub(self.front_index(), 1);
        self.front_key().write(front_index);
        self.get_key(front_index).write(val);
    }


    #[storage(read, write)]
    pub fn pop_back(self) -> Option<T> {
        if self.is_empty() {
            None
        } else {
            let tail_index = self.tail_index();
            let back_index = wrapping_sub(tail_index, 1);
            let key = self.get_key(back_index);
            let res = key.read();
            let _ = key.clear();
            self.tail_key().write(back_index);
            Some(res)
        }
    }
    
    #[storage(read, write)]
    pub fn pop_front(self) -> Option<T> {
        if self.is_empty() {
            None
        } else {
            let front_index = self.front_index();
            let key = self.get_key(front_index);
            let res = key.read();
            let _ = key.clear();
            self.front_key().write(wrapping_add(front_index, 1));
            Some(res)
        }
    }

    #[storage(read)]
    pub fn get(self, index: u64) -> Option<T> {
        // TODO: store len to invalidate immediately
        let real_index = wrapping_add(self.front_index(), index);
        self.get_key(real_index).try_read()
    }
}

fn wrapping_add(a: u64, b: u64) -> u64 {
    use std::flags::F_WRAPPING_DISABLE_MASK;
    let flags = asm() {
        flag
    };

    // Get the current value of the flags register and mask it, setting the
    // masked bit. Flags are inverted, so set = off.
    asm(flag_val: __or(flags, F_WRAPPING_DISABLE_MASK)) {
        flag flag_val;
    }

    let res = a + b;

    asm(new_flags: flags) {
        flag new_flags;
    }
    res
}
fn wrapping_sub(a: u64, b: u64) -> u64 {
    use std::flags::F_WRAPPING_DISABLE_MASK;
    let flags = asm() {
        flag
    };

    // Get the current value of the flags register and mask it, setting the
    // masked bit. Flags are inverted, so set = off.
    asm(flag_val: __or(flags, F_WRAPPING_DISABLE_MASK)) {
        flag flag_val;
    }

    let res = a - b;

    asm(new_flags: flags) {
        flag new_flags;
    }
    res
}
