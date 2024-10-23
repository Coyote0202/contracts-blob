use core::{
    num::traits::Bounded, hash::{HashStateTrait, HashStateExTrait, Hash},
    poseidon::{PoseidonTrait, HashState}
};

use blob_arena::utils::ArrayHash;

#[test]
fn test_array_hash() {
    let mut hash = 0;
    let hash_state = PoseidonTrait::new();
    let mut n = 0;
    let mut array: Array<u8> = array![];
    while n < 10 {
        array.append(n);
        let new_hash = hash_state.update_with(array.clone()).finalize();
        assert_ne!(hash, new_hash);
        println!("Hash: {}, New Hash: {}", hash, new_hash);
        hash = new_hash;
        n += 1;
    }
}
