use core::num::traits::Bounded;
use blob_arena::core::{
    SaturatingAdd, SaturatingSub, SaturatingMul, BoundedT, SaturatingInto, BoundedTImpl
};

#[test]
fn test_unsigned_bounded_as_unsigned_min() {
    assert_eq!(0_u8, BoundedT::<u8, u8>::min());
    assert_eq!(0_u16, BoundedT::<u8, u16>::min());
    assert_eq!(0_u32, BoundedT::<u8, u32>::min());
    assert_eq!(0_u64, BoundedT::<u8, u64>::min());
    assert_eq!(0_u128, BoundedT::<u8, u128>::min());
    assert_eq!(0_u256, BoundedT::<u8, u256>::min());
    assert_eq!(0_u8, BoundedT::<u16, u8>::min());
    assert_eq!(0_u16, BoundedT::<u16, u16>::min());
    assert_eq!(0_u32, BoundedT::<u16, u32>::min());
    assert_eq!(0_u64, BoundedT::<u16, u64>::min());
    assert_eq!(0_u128, BoundedT::<u16, u128>::min());
    assert_eq!(0_u256, BoundedT::<u16, u256>::min());
    assert_eq!(0_u8, BoundedT::<u32, u8>::min());
    assert_eq!(0_u16, BoundedT::<u32, u16>::min());
    assert_eq!(0_u32, BoundedT::<u32, u32>::min());
    assert_eq!(0_u64, BoundedT::<u32, u64>::min());
    assert_eq!(0_u128, BoundedT::<u32, u128>::min());
    assert_eq!(0_u256, BoundedT::<u32, u256>::min());
    assert_eq!(0_u8, BoundedT::<u64, u8>::min());
    assert_eq!(0_u16, BoundedT::<u64, u16>::min());
    assert_eq!(0_u32, BoundedT::<u64, u32>::min());
    assert_eq!(0_u64, BoundedT::<u64, u64>::min());
    assert_eq!(0_u128, BoundedT::<u64, u128>::min());
    assert_eq!(0_u256, BoundedT::<u64, u256>::min());
    assert_eq!(0_u8, BoundedT::<u128, u8>::min());
    assert_eq!(0_u16, BoundedT::<u128, u16>::min());
    assert_eq!(0_u32, BoundedT::<u128, u32>::min());
    assert_eq!(0_u64, BoundedT::<u128, u64>::min());
    assert_eq!(0_u128, BoundedT::<u128, u128>::min());
    assert_eq!(0_u256, BoundedT::<u128, u256>::min());
    assert_eq!(0_u8, BoundedT::<u256, u8>::min());
    assert_eq!(0_u16, BoundedT::<u256, u16>::min());
    assert_eq!(0_u32, BoundedT::<u256, u32>::min());
    assert_eq!(0_u64, BoundedT::<u256, u64>::min());
    assert_eq!(0_u128, BoundedT::<u256, u128>::min());
    assert_eq!(0_u256, BoundedT::<u256, u256>::min());
}

#[test]
fn test_unsigned_bounded_as_unsigned_max() {
    assert_eq!(0xff_u8, BoundedT::<u8, u8>::max());
    assert_eq!(0xff_u16, BoundedT::<u8, u16>::max());
    assert_eq!(0xff_u32, BoundedT::<u8, u32>::max());
    assert_eq!(0xff_u64, BoundedT::<u8, u64>::max());
    assert_eq!(0xff_u128, BoundedT::<u8, u128>::max());
    assert_eq!(0xff_u256, BoundedT::<u8, u256>::max());
    assert_eq!(0xffff_u16, BoundedT::<u16, u16>::max());
    assert_eq!(0xffff_u32, BoundedT::<u16, u32>::max());
    assert_eq!(0xffff_u64, BoundedT::<u16, u64>::max());
    assert_eq!(0xffff_u128, BoundedT::<u16, u128>::max());
    assert_eq!(0xffff_u256, BoundedT::<u16, u256>::max());
    assert_eq!(0xffffffff_u32, BoundedT::<u32, u32>::max());
    assert_eq!(0xffffffff_u64, BoundedT::<u32, u64>::max());
    assert_eq!(0xffffffff_u128, BoundedT::<u32, u128>::max());
    assert_eq!(0xffffffff_u256, BoundedT::<u32, u256>::max());
    assert_eq!(0xffffffffffffffff_u64, BoundedT::<u64, u64>::max());
    assert_eq!(0xffffffffffffffff_u128, BoundedT::<u64, u128>::max());
    assert_eq!(0xffffffffffffffff_u256, BoundedT::<u64, u256>::max());
    assert_eq!(0xffffffffffffffffffffffffffffffff_u128, BoundedT::<u128, u128>::max());
    assert_eq!(0xffffffffffffffffffffffffffffffff_u256, BoundedT::<u128, u256>::max());
    assert_eq!(
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff_u256,
        BoundedT::<u256, u256>::max()
    );
}

#[test]
fn test_signed_bounded_as_signed_min() {
    assert_eq!(-0x80_i8, BoundedT::<i8, i8>::min());
    assert_eq!(-0x80_i16, BoundedT::<i8, i16>::min());
    assert_eq!(-0x80_i32, BoundedT::<i8, i32>::min());
    assert_eq!(-0x80_i64, BoundedT::<i8, i64>::min());
    assert_eq!(-0x80_i128, BoundedT::<i8, i128>::min());
    assert_eq!(-0x8000_i16, BoundedT::<i16, i16>::min());
    assert_eq!(-0x8000_i32, BoundedT::<i16, i32>::min());
    assert_eq!(-0x8000_i64, BoundedT::<i16, i64>::min());
    assert_eq!(-0x8000_i128, BoundedT::<i16, i128>::min());
    assert_eq!(-0x80000000_i32, BoundedT::<i32, i32>::min());
    assert_eq!(-0x80000000_i64, BoundedT::<i32, i64>::min());
    assert_eq!(-0x80000000_i128, BoundedT::<i32, i128>::min());
    assert_eq!(-0x8000000000000000_i64, BoundedT::<i64, i64>::min());
    assert_eq!(-0x8000000000000000_i128, BoundedT::<i64, i128>::min());
    assert_eq!(-0x80000000000000000000000000000000_i128, BoundedT::<i128, i128>::min());
}

#[test]
fn test_signed_bounded_as_signed_max() {
    assert_eq!(0x7f_i8, BoundedT::<i8, i8>::max());
    assert_eq!(0x7f_i16, BoundedT::<i8, i16>::max());
    assert_eq!(0x7f_i32, BoundedT::<i8, i32>::max());
    assert_eq!(0x7f_i64, BoundedT::<i8, i64>::max());
    assert_eq!(0x7f_i128, BoundedT::<i8, i128>::max());
    assert_eq!(0x7fff_i16, BoundedT::<i16, i16>::max());
    assert_eq!(0x7fff_i32, BoundedT::<i16, i32>::max());
    assert_eq!(0x7fff_i64, BoundedT::<i16, i64>::max());
    assert_eq!(0x7fff_i128, BoundedT::<i16, i128>::max());
    assert_eq!(0x7fffffff_i32, BoundedT::<i32, i32>::max());
    assert_eq!(0x7fffffff_i64, BoundedT::<i32, i64>::max());
    assert_eq!(0x7fffffff_i128, BoundedT::<i32, i128>::max());
    assert_eq!(0x7fffffffffffffff_i64, BoundedT::<i64, i64>::max());
    assert_eq!(0x7fffffffffffffff_i128, BoundedT::<i64, i128>::max());
    assert_eq!(0x7fffffffffffffffffffffffffffffff_i128, BoundedT::<i128, i128>::max());
}

#[test]
fn test_unsigned_bounded_as_signed_min() {
    assert_eq!(0_i8, BoundedT::<u8, i8>::min());
    assert_eq!(0_i16, BoundedT::<u8, i16>::min());
    assert_eq!(0_i32, BoundedT::<u8, i32>::min());
    assert_eq!(0_i64, BoundedT::<u8, i64>::min());
    assert_eq!(0_i128, BoundedT::<u8, i128>::min());
    assert_eq!(0_i8, BoundedT::<u16, i8>::min());
    assert_eq!(0_i16, BoundedT::<u16, i16>::min());
    assert_eq!(0_i32, BoundedT::<u16, i32>::min());
    assert_eq!(0_i64, BoundedT::<u16, i64>::min());
    assert_eq!(0_i128, BoundedT::<u16, i128>::min());
    assert_eq!(0_i8, BoundedT::<u32, i8>::min());
    assert_eq!(0_i16, BoundedT::<u32, i16>::min());
    assert_eq!(0_i32, BoundedT::<u32, i32>::min());
    assert_eq!(0_i64, BoundedT::<u32, i64>::min());
    assert_eq!(0_i128, BoundedT::<u32, i128>::min());
    assert_eq!(0_i8, BoundedT::<u64, i8>::min());
    assert_eq!(0_i16, BoundedT::<u64, i16>::min());
    assert_eq!(0_i32, BoundedT::<u64, i32>::min());
    assert_eq!(0_i64, BoundedT::<u64, i64>::min());
    assert_eq!(0_i128, BoundedT::<u64, i128>::min());
    assert_eq!(0_i8, BoundedT::<u128, i8>::min());
    assert_eq!(0_i16, BoundedT::<u128, i16>::min());
    assert_eq!(0_i32, BoundedT::<u128, i32>::min());
    assert_eq!(0_i64, BoundedT::<u128, i64>::min());
    assert_eq!(0_i128, BoundedT::<u128, i128>::min());
}

#[test]
fn test_unsigned_bounded_as_signed_max() {
    assert_eq!(0xff_i16, BoundedT::<u8, i16>::max());
    assert_eq!(0xff_i32, BoundedT::<u8, i32>::max());
    assert_eq!(0xff_i64, BoundedT::<u8, i64>::max());
    assert_eq!(0xff_i128, BoundedT::<u8, i128>::max());
    assert_eq!(0xffff_i32, BoundedT::<u16, i32>::max());
    assert_eq!(0xffff_i64, BoundedT::<u16, i64>::max());
    assert_eq!(0xffff_i128, BoundedT::<u16, i128>::max());
    assert_eq!(0xffffffff_i64, BoundedT::<u32, i64>::max());
    assert_eq!(0xffffffff_i128, BoundedT::<u32, i128>::max());
    assert_eq!(0xffffffffffffffff_i128, BoundedT::<u64, i128>::max());
}

fn test_signed_bounded_as_unsigned_max() {
    assert_eq!(0x7f_u8, BoundedT::<i8, u8>::max());
    assert_eq!(0x7f_u16, BoundedT::<i8, u16>::max());
    assert_eq!(0x7f_u32, BoundedT::<i8, u32>::max());
    assert_eq!(0x7f_u64, BoundedT::<i8, u64>::max());
    assert_eq!(0x7f_u128, BoundedT::<i8, u128>::max());
    assert_eq!(0x7fff_u16, BoundedT::<i16, u16>::max());
    assert_eq!(0x7fff_u32, BoundedT::<i16, u32>::max());
    assert_eq!(0x7fff_u64, BoundedT::<i16, u64>::max());
    assert_eq!(0x7fff_u128, BoundedT::<i16, u128>::max());
    assert_eq!(0x7fffffff_u32, BoundedT::<i32, u32>::max());
    assert_eq!(0x7fffffff_u64, BoundedT::<i32, u64>::max());
    assert_eq!(0x7fffffff_u128, BoundedT::<i32, u128>::max());
    assert_eq!(0x7fffffffffffffff_u64, BoundedT::<i64, u64>::max());
    assert_eq!(0x7fffffffffffffff_u128, BoundedT::<i64, u128>::max());
    assert_eq!(0x7fffffffffffffffffffffffffffffff_u128, BoundedT::<i128, u128>::max());
}


#[test]
fn test_saturating_unsigned_into_unsigned() {
    assert_eq!(1_u8, 1_u8.saturating_into());
    assert_eq!(1_u8, 1_u16.saturating_into());
    assert_eq!(1_u8, 1_u32.saturating_into());
    assert_eq!(1_u8, 1_u64.saturating_into());
    assert_eq!(1_u8, 1_u128.saturating_into());
    assert_eq!(1_u8, 1_u256.saturating_into());
    assert_eq!(1_u16, 1_u8.saturating_into());
    assert_eq!(1_u16, 1_u16.saturating_into());
    assert_eq!(1_u16, 1_u32.saturating_into());
    assert_eq!(1_u16, 1_u64.saturating_into());
    assert_eq!(1_u16, 1_u128.saturating_into());
    assert_eq!(1_u16, 1_u256.saturating_into());
    assert_eq!(1_u32, 1_u8.saturating_into());
    assert_eq!(1_u32, 1_u16.saturating_into());
    assert_eq!(1_u32, 1_u32.saturating_into());
    assert_eq!(1_u32, 1_u64.saturating_into());
    assert_eq!(1_u32, 1_u128.saturating_into());
    assert_eq!(1_u32, 1_u256.saturating_into());
    assert_eq!(1_u64, 1_u8.saturating_into());
    assert_eq!(1_u64, 1_u16.saturating_into());
    assert_eq!(1_u64, 1_u32.saturating_into());
    assert_eq!(1_u64, 1_u64.saturating_into());
    assert_eq!(1_u64, 1_u128.saturating_into());
    assert_eq!(1_u64, 1_u256.saturating_into());
    assert_eq!(1_u128, 1_u8.saturating_into());
    assert_eq!(1_u128, 1_u16.saturating_into());
    assert_eq!(1_u128, 1_u32.saturating_into());
    assert_eq!(1_u128, 1_u64.saturating_into());
    assert_eq!(1_u128, 1_u128.saturating_into());
    assert_eq!(1_u128, 1_u256.saturating_into());
    assert_eq!(1_u256, 1_u8.saturating_into());
    assert_eq!(1_u256, 1_u16.saturating_into());
    assert_eq!(1_u256, 1_u32.saturating_into());
    assert_eq!(1_u256, 1_u64.saturating_into());
    assert_eq!(1_u256, 1_u128.saturating_into());
    assert_eq!(1_u256, 1_u256.saturating_into());
}

#[test]
fn test_saturating_min_unsigned_into_unsigned() {
    assert_eq!(0_u8, Bounded::<u8>::MIN.saturating_into());
    assert_eq!(0_u16, Bounded::<u8>::MIN.saturating_into());
    assert_eq!(0_u32, Bounded::<u8>::MIN.saturating_into());
    assert_eq!(0_u64, Bounded::<u8>::MIN.saturating_into());
    assert_eq!(0_u128, Bounded::<u8>::MIN.saturating_into());
    assert_eq!(0_u256, Bounded::<u8>::MIN.saturating_into());
    assert_eq!(0_u8, Bounded::<u16>::MIN.saturating_into());
    assert_eq!(0_u16, Bounded::<u16>::MIN.saturating_into());
    assert_eq!(0_u32, Bounded::<u16>::MIN.saturating_into());
    assert_eq!(0_u64, Bounded::<u16>::MIN.saturating_into());
    assert_eq!(0_u128, Bounded::<u16>::MIN.saturating_into());
    assert_eq!(0_u256, Bounded::<u16>::MIN.saturating_into());
    assert_eq!(0_u8, Bounded::<u32>::MIN.saturating_into());
    assert_eq!(0_u16, Bounded::<u32>::MIN.saturating_into());
    assert_eq!(0_u32, Bounded::<u32>::MIN.saturating_into());
    assert_eq!(0_u64, Bounded::<u32>::MIN.saturating_into());
    assert_eq!(0_u128, Bounded::<u32>::MIN.saturating_into());
    assert_eq!(0_u256, Bounded::<u32>::MIN.saturating_into());
    assert_eq!(0_u8, Bounded::<u64>::MIN.saturating_into());
    assert_eq!(0_u16, Bounded::<u64>::MIN.saturating_into());
    assert_eq!(0_u32, Bounded::<u64>::MIN.saturating_into());
    assert_eq!(0_u64, Bounded::<u64>::MIN.saturating_into());
    assert_eq!(0_u128, Bounded::<u64>::MIN.saturating_into());
    assert_eq!(0_u256, Bounded::<u64>::MIN.saturating_into());
    assert_eq!(0_u8, Bounded::<u128>::MIN.saturating_into());
    assert_eq!(0_u16, Bounded::<u128>::MIN.saturating_into());
    assert_eq!(0_u32, Bounded::<u128>::MIN.saturating_into());
    assert_eq!(0_u64, Bounded::<u128>::MIN.saturating_into());
    assert_eq!(0_u128, Bounded::<u128>::MIN.saturating_into());
    assert_eq!(0_u256, Bounded::<u128>::MIN.saturating_into());
    assert_eq!(0_u8, Bounded::<u256>::MIN.saturating_into());
    assert_eq!(0_u16, Bounded::<u256>::MIN.saturating_into());
    assert_eq!(0_u32, Bounded::<u256>::MIN.saturating_into());
    assert_eq!(0_u64, Bounded::<u256>::MIN.saturating_into());
    assert_eq!(0_u128, Bounded::<u256>::MIN.saturating_into());
    assert_eq!(0_u256, Bounded::<u256>::MIN.saturating_into());
}

#[test]
fn test_saturating_max_unsigned_into_unsigned() {
    assert_eq!(0xff_u8, Bounded::<u8>::MAX.saturating_into());
    assert_eq!(0xff_u16, Bounded::<u8>::MAX.saturating_into());
    assert_eq!(0xff_u32, Bounded::<u8>::MAX.saturating_into());
    assert_eq!(0xff_u64, Bounded::<u8>::MAX.saturating_into());
    assert_eq!(0xff_u128, Bounded::<u8>::MAX.saturating_into());
    assert_eq!(0xff_u256, Bounded::<u8>::MAX.saturating_into());
    assert_eq!(0xff_u8, Bounded::<u16>::MAX.saturating_into());
    assert_eq!(0xffff_u16, Bounded::<u16>::MAX.saturating_into());
    assert_eq!(0xffff_u32, Bounded::<u16>::MAX.saturating_into());
    assert_eq!(0xffff_u64, Bounded::<u16>::MAX.saturating_into());
    assert_eq!(0xffff_u128, Bounded::<u16>::MAX.saturating_into());
    assert_eq!(0xffff_u256, Bounded::<u16>::MAX.saturating_into());
    assert_eq!(0xff_u8, Bounded::<u32>::MAX.saturating_into());
    assert_eq!(0xffff_u16, Bounded::<u32>::MAX.saturating_into());
    assert_eq!(0xffffffff_u32, Bounded::<u32>::MAX.saturating_into());
    assert_eq!(0xffffffff_u64, Bounded::<u32>::MAX.saturating_into());
    assert_eq!(0xffffffff_u128, Bounded::<u32>::MAX.saturating_into());
    assert_eq!(0xffffffff_u256, Bounded::<u32>::MAX.saturating_into());
    assert_eq!(0xff_u8, Bounded::<u64>::MAX.saturating_into());
    assert_eq!(0xffff_u16, Bounded::<u64>::MAX.saturating_into());
    assert_eq!(0xffffffff_u32, Bounded::<u64>::MAX.saturating_into());
    assert_eq!(0xffffffffffffffff_u64, Bounded::<u64>::MAX.saturating_into());
    assert_eq!(0xffffffffffffffff_u128, Bounded::<u64>::MAX.saturating_into());
    assert_eq!(0xffffffffffffffff_u256, Bounded::<u64>::MAX.saturating_into());
    assert_eq!(0xff_u8, Bounded::<u128>::MAX.saturating_into());
    assert_eq!(0xffff_u16, Bounded::<u128>::MAX.saturating_into());
    assert_eq!(0xffffffff_u32, Bounded::<u128>::MAX.saturating_into());
    assert_eq!(0xffffffffffffffff_u64, Bounded::<u128>::MAX.saturating_into());
    assert_eq!(0xffffffffffffffffffffffffffffffff_u128, Bounded::<u128>::MAX.saturating_into());
    assert_eq!(0xffffffffffffffffffffffffffffffff_u256, Bounded::<u128>::MAX.saturating_into());
    assert_eq!(0xff_u8, Bounded::<u256>::MAX.saturating_into());
    assert_eq!(0xffff_u16, Bounded::<u256>::MAX.saturating_into());
    assert_eq!(0xffffffff_u32, Bounded::<u256>::MAX.saturating_into());
    assert_eq!(0xffffffffffffffff_u64, Bounded::<u256>::MAX.saturating_into());
    assert_eq!(0xffffffffffffffffffffffffffffffff_u128, Bounded::<u256>::MAX.saturating_into());
    assert_eq!(
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff_u256,
        Bounded::<u256>::MAX.saturating_into()
    );
}

#[test]
fn test_saturating_signed_into_signed() {
    assert_eq!(1_i8, 1_i8.saturating_into());
    assert_eq!(1_i8, 1_i16.saturating_into());
    assert_eq!(1_i8, 1_i32.saturating_into());
    assert_eq!(1_i8, 1_i64.saturating_into());
    assert_eq!(1_i8, 1_i128.saturating_into());
    assert_eq!(1_i16, 1_i8.saturating_into());
    assert_eq!(1_i16, 1_i16.saturating_into());
    assert_eq!(1_i16, 1_i32.saturating_into());
    assert_eq!(1_i16, 1_i64.saturating_into());
    assert_eq!(1_i16, 1_i128.saturating_into());
    assert_eq!(1_i32, 1_i8.saturating_into());
    assert_eq!(1_i32, 1_i16.saturating_into());
    assert_eq!(1_i32, 1_i32.saturating_into());
    assert_eq!(1_i32, 1_i64.saturating_into());
    assert_eq!(1_i32, 1_i128.saturating_into());
    assert_eq!(1_i64, 1_i8.saturating_into());
    assert_eq!(1_i64, 1_i16.saturating_into());
    assert_eq!(1_i64, 1_i32.saturating_into());
    assert_eq!(1_i64, 1_i64.saturating_into());
    assert_eq!(1_i64, 1_i128.saturating_into());
    assert_eq!(1_i128, 1_i8.saturating_into());
    assert_eq!(1_i128, 1_i16.saturating_into());
    assert_eq!(1_i128, 1_i32.saturating_into());
    assert_eq!(1_i128, 1_i64.saturating_into());
    assert_eq!(1_i128, 1_i128.saturating_into());
}

#[test]
fn test_saturating_negative_signed_into_signed() {
    assert_eq!(-1_i8, -1_i8.saturating_into());
    assert_eq!(-1_i8, -1_i16.saturating_into());
    assert_eq!(-1_i8, -1_i32.saturating_into());
    assert_eq!(-1_i8, -1_i64.saturating_into());
    assert_eq!(-1_i8, -1_i128.saturating_into());
    assert_eq!(-1_i16, -1_i8.saturating_into());
    assert_eq!(-1_i16, -1_i16.saturating_into());
    assert_eq!(-1_i16, -1_i32.saturating_into());
    assert_eq!(-1_i16, -1_i64.saturating_into());
    assert_eq!(-1_i16, -1_i128.saturating_into());
    assert_eq!(-1_i32, -1_i8.saturating_into());
    assert_eq!(-1_i32, -1_i16.saturating_into());
    assert_eq!(-1_i32, -1_i32.saturating_into());
    assert_eq!(-1_i32, -1_i64.saturating_into());
    assert_eq!(-1_i32, -1_i128.saturating_into());
    assert_eq!(-1_i64, -1_i8.saturating_into());
    assert_eq!(-1_i64, -1_i16.saturating_into());
    assert_eq!(-1_i64, -1_i32.saturating_into());
    assert_eq!(-1_i64, -1_i64.saturating_into());
    assert_eq!(-1_i64, -1_i128.saturating_into());
    assert_eq!(-1_i128, -1_i8.saturating_into());
    assert_eq!(-1_i128, -1_i16.saturating_into());
    assert_eq!(-1_i128, -1_i32.saturating_into());
    assert_eq!(-1_i128, -1_i64.saturating_into());
    assert_eq!(-1_i128, -1_i128.saturating_into());
}

#[test]
fn test_saturating_min_signed_into_signed() {
    assert_eq!(Bounded::<i8>::MIN, Bounded::<i8>::MIN.saturating_into());
    assert_eq!(BoundedT::<i8, i16>::min(), Bounded::<i8>::MIN.saturating_into());
    assert_eq!(BoundedT::<i8, i32>::min(), Bounded::<i8>::MIN.saturating_into());
    assert_eq!(BoundedT::<i8, i64>::min(), Bounded::<i8>::MIN.saturating_into());
    assert_eq!(BoundedT::<i8, i128>::min(), Bounded::<i8>::MIN.saturating_into());
    assert_eq!(Bounded::<i8>::MIN, Bounded::<i16>::MIN.saturating_into());
    assert_eq!(Bounded::<i16>::MIN, Bounded::<i16>::MIN.saturating_into());
    assert_eq!(BoundedT::<i16, i32>::min(), Bounded::<i16>::MIN.saturating_into());
    assert_eq!(BoundedT::<i16, i64>::min(), Bounded::<i16>::MIN.saturating_into());
    assert_eq!(BoundedT::<i16, i128>::min(), Bounded::<i16>::MIN.saturating_into());
    assert_eq!(Bounded::<i8>::MIN, Bounded::<i32>::MIN.saturating_into());
    assert_eq!(Bounded::<i16>::MIN, Bounded::<i32>::MIN.saturating_into());
    assert_eq!(Bounded::<i32>::MIN, Bounded::<i32>::MIN.saturating_into());
    assert_eq!(BoundedT::<i32, i64>::min(), Bounded::<i32>::MIN.saturating_into());
    assert_eq!(BoundedT::<i32, i128>::min(), Bounded::<i32>::MIN.saturating_into());
    assert_eq!(Bounded::<i8>::MIN, Bounded::<i64>::MIN.saturating_into());
    assert_eq!(Bounded::<i16>::MIN, Bounded::<i64>::MIN.saturating_into());
    assert_eq!(Bounded::<i32>::MIN, Bounded::<i64>::MIN.saturating_into());
    assert_eq!(Bounded::<i64>::MIN, Bounded::<i64>::MIN.saturating_into());
    assert_eq!(BoundedT::<i64, i128>::min(), Bounded::<i64>::MIN.saturating_into());
    assert_eq!(Bounded::<i8>::MIN, Bounded::<i128>::MIN.saturating_into());
    assert_eq!(Bounded::<i16>::MIN, Bounded::<i128>::MIN.saturating_into());
    assert_eq!(Bounded::<i32>::MIN, Bounded::<i128>::MIN.saturating_into());
    assert_eq!(Bounded::<i64>::MIN, Bounded::<i128>::MIN.saturating_into());
    assert_eq!(Bounded::<i128>::MIN, Bounded::<i128>::MIN.saturating_into());
}

#[test]
fn test_saturating_max_signed_into_signed() {
    assert_eq!(0x7f_i8, 0x7f_i8.saturating_into());
    assert_eq!(0x7f_i16, 0x7f_i8.saturating_into());
    assert_eq!(0x7f_i32, 0x7f_i8.saturating_into());
    assert_eq!(0x7f_i64, 0x7f_i8.saturating_into());
    assert_eq!(0x7f_i128, 0x7f_i8.saturating_into());
    assert_eq!(0x7f_i8, 0x7fff_i16.saturating_into());
    assert_eq!(0x7fff_i16, 0x7fff_i16.saturating_into());
    assert_eq!(0x7fff_i32, 0x7fff_i16.saturating_into());
    assert_eq!(0x7fff_i64, 0x7fff_i16.saturating_into());
    assert_eq!(0x7fff_i128, 0x7fff_i16.saturating_into());
    assert_eq!(0x7f_i8, 0x7fffffff_i32.saturating_into());
    assert_eq!(0x7fff_i16, 0x7fffffff_i32.saturating_into());
    assert_eq!(0x7fffffff_i32, 0x7fffffff_i32.saturating_into());
    assert_eq!(0x7fffffff_i64, 0x7fffffff_i32.saturating_into());
    assert_eq!(0x7fffffff_i128, 0x7fffffff_i32.saturating_into());
    assert_eq!(0x7f_i8, 0x7fffffffffffffff_i64.saturating_into());
    assert_eq!(0x7fff_i16, 0x7fffffffffffffff_i64.saturating_into());
    assert_eq!(0x7fffffff_i32, 0x7fffffffffffffff_i64.saturating_into());
    assert_eq!(0x7fffffffffffffff_i64, 0x7fffffffffffffff_i64.saturating_into());
    assert_eq!(0x7fffffffffffffff_i128, 0x7fffffffffffffff_i64.saturating_into());
    assert_eq!(0x7f_i8, 0x7fffffffffffffffffffffffffffffff_i128.saturating_into());
    assert_eq!(0x7fff_i16, 0x7fffffffffffffffffffffffffffffff_i128.saturating_into());
    assert_eq!(0x7fffffff_i32, 0x7fffffffffffffffffffffffffffffff_i128.saturating_into());
    assert_eq!(0x7fffffffffffffff_i64, 0x7fffffffffffffffffffffffffffffff_i128.saturating_into());
    assert_eq!(
        0x7fffffffffffffffffffffffffffffff_i128,
        0x7fffffffffffffffffffffffffffffff_i128.saturating_into()
    );
}

#[test]
fn test_saturating_unsigned_into_signed() {
    assert_eq!(1_i8, 1_u8.saturating_into());
    assert_eq!(1_i8, 1_u16.saturating_into());
    assert_eq!(1_i8, 1_u32.saturating_into());
    assert_eq!(1_i8, 1_u64.saturating_into());
    assert_eq!(1_i8, 1_u128.saturating_into());
    assert_eq!(1_i16, 1_u8.saturating_into());
    assert_eq!(1_i16, 1_u16.saturating_into());
    assert_eq!(1_i16, 1_u32.saturating_into());
    assert_eq!(1_i16, 1_u64.saturating_into());
    assert_eq!(1_i16, 1_u128.saturating_into());
    assert_eq!(1_i32, 1_u8.saturating_into());
    assert_eq!(1_i32, 1_u16.saturating_into());
    assert_eq!(1_i32, 1_u32.saturating_into());
    assert_eq!(1_i32, 1_u64.saturating_into());
    assert_eq!(1_i32, 1_u128.saturating_into());
    assert_eq!(1_i64, 1_u8.saturating_into());
    assert_eq!(1_i64, 1_u16.saturating_into());
    assert_eq!(1_i64, 1_u32.saturating_into());
    assert_eq!(1_i64, 1_u64.saturating_into());
    assert_eq!(1_i64, 1_u128.saturating_into());
    assert_eq!(1_i128, 1_u8.saturating_into());
    assert_eq!(1_i128, 1_u16.saturating_into());
    assert_eq!(1_i128, 1_u32.saturating_into());
    assert_eq!(1_i128, 1_u64.saturating_into());
    assert_eq!(1_i128, 1_u128.saturating_into());
}

#[test]
fn test_saturating_min_unsigned_into_signed() {
    assert_eq!(0_i8, 0_u8.saturating_into());
    assert_eq!(0_i16, 0_u8.saturating_into());
    assert_eq!(0_i32, 0_u8.saturating_into());
    assert_eq!(0_i64, 0_u8.saturating_into());
    assert_eq!(0_i128, 0_u8.saturating_into());
    assert_eq!(0_i8, 0_u16.saturating_into());
    assert_eq!(0_i16, 0_u16.saturating_into());
    assert_eq!(0_i32, 0_u16.saturating_into());
    assert_eq!(0_i64, 0_u16.saturating_into());
    assert_eq!(0_i128, 0_u16.saturating_into());
    assert_eq!(0_i8, 0_u32.saturating_into());
    assert_eq!(0_i16, 0_u32.saturating_into());
    assert_eq!(0_i32, 0_u32.saturating_into());
    assert_eq!(0_i64, 0_u32.saturating_into());
    assert_eq!(0_i128, 0_u32.saturating_into());
    assert_eq!(0_i8, 0_u64.saturating_into());
    assert_eq!(0_i16, 0_u64.saturating_into());
    assert_eq!(0_i32, 0_u64.saturating_into());
    assert_eq!(0_i64, 0_u64.saturating_into());
    assert_eq!(0_i128, 0_u64.saturating_into());
    assert_eq!(0_i8, 0_u128.saturating_into());
    assert_eq!(0_i16, 0_u128.saturating_into());
    assert_eq!(0_i32, 0_u128.saturating_into());
    assert_eq!(0_i64, 0_u128.saturating_into());
    assert_eq!(0_i128, 0_u128.saturating_into());
}

#[test]
fn test_saturating_max_unsigned_into_signed() {
    assert_eq!(0x7f_i8, 0xff_u8.saturating_into());
    assert_eq!(0xff_i16, 0xff_u8.saturating_into());
    assert_eq!(0xff_i32, 0xff_u8.saturating_into());
    assert_eq!(0xff_i64, 0xff_u8.saturating_into());
    assert_eq!(0xff_i128, 0xff_u8.saturating_into());
    assert_eq!(0x7f_i8, 0xffff_u16.saturating_into());
    assert_eq!(0x7fff_i16, 0xffff_u16.saturating_into());
    assert_eq!(0xffff_i32, 0xffff_u16.saturating_into());
    assert_eq!(0xffff_i64, 0xffff_u16.saturating_into());
    assert_eq!(0xffff_i128, 0xffff_u16.saturating_into());
    assert_eq!(0x7f_i8, 0xffffffff_u32.saturating_into());
    assert_eq!(0x7fff_i16, 0xffffffff_u32.saturating_into());
    assert_eq!(0x7fffffff_i32, 0xffffffff_u32.saturating_into());
    assert_eq!(0xffffffff_i64, 0xffffffff_u32.saturating_into());
    assert_eq!(0xffffffff_i128, 0xffffffff_u32.saturating_into());
    assert_eq!(0x7f_i8, 0xffffffffffffffff_u64.saturating_into());
    assert_eq!(0x7fff_i16, 0xffffffffffffffff_u64.saturating_into());
    assert_eq!(0x7fffffff_i32, 0xffffffffffffffff_u64.saturating_into());
    assert_eq!(0x7fffffffffffffff_i64, 0xffffffffffffffff_u64.saturating_into());
    assert_eq!(0xffffffffffffffff_i128, 0xffffffffffffffff_u64.saturating_into());
    assert_eq!(0x7f_i8, 0xffffffffffffffffffffffffffffffff_u128.saturating_into());
    assert_eq!(0x7fff_i16, 0xffffffffffffffffffffffffffffffff_u128.saturating_into());
    assert_eq!(0x7fffffff_i32, 0xffffffffffffffffffffffffffffffff_u128.saturating_into());
    assert_eq!(0x7fffffffffffffff_i64, 0xffffffffffffffffffffffffffffffff_u128.saturating_into());
    assert_eq!(
        0x7fffffffffffffffffffffffffffffff_i128,
        0xffffffffffffffffffffffffffffffff_u128.saturating_into()
    );
}

#[test]
fn test_saturating_signed_into_unsigned() {
    assert_eq!(1_u8, 1_i8.saturating_into());
    assert_eq!(1_u8, 1_i16.saturating_into());
    assert_eq!(1_u8, 1_i32.saturating_into());
    assert_eq!(1_u8, 1_i64.saturating_into());
    assert_eq!(1_u8, 1_i128.saturating_into());
    assert_eq!(1_u16, 1_i8.saturating_into());
    assert_eq!(1_u16, 1_i16.saturating_into());
    assert_eq!(1_u16, 1_i32.saturating_into());
    assert_eq!(1_u16, 1_i64.saturating_into());
    assert_eq!(1_u16, 1_i128.saturating_into());
    assert_eq!(1_u32, 1_i8.saturating_into());
    assert_eq!(1_u32, 1_i16.saturating_into());
    assert_eq!(1_u32, 1_i32.saturating_into());
    assert_eq!(1_u32, 1_i64.saturating_into());
    assert_eq!(1_u32, 1_i128.saturating_into());
    assert_eq!(1_u64, 1_i8.saturating_into());
    assert_eq!(1_u64, 1_i16.saturating_into());
    assert_eq!(1_u64, 1_i32.saturating_into());
    assert_eq!(1_u64, 1_i64.saturating_into());
    assert_eq!(1_u64, 1_i128.saturating_into());
    assert_eq!(1_u128, 1_i8.saturating_into());
    assert_eq!(1_u128, 1_i16.saturating_into());
    assert_eq!(1_u128, 1_i32.saturating_into());
    assert_eq!(1_u128, 1_i64.saturating_into());
    assert_eq!(1_u128, 1_i128.saturating_into());
}

#[test]
fn test_saturating_negative_signed_into_unsigned() {
    assert_eq!(0_u8, (-1_i8).saturating_into());
    assert_eq!(0_u16, (-1_i8).saturating_into());
    assert_eq!(0_u32, (-1_i8).saturating_into());
    assert_eq!(0_u64, (-1_i8).saturating_into());
    assert_eq!(0_u128, (-1_i8).saturating_into());
    assert_eq!(0_u8, (-1_i16).saturating_into());
    assert_eq!(0_u16, (-1_i16).saturating_into());
    assert_eq!(0_u32, (-1_i16).saturating_into());
    assert_eq!(0_u64, (-1_i16).saturating_into());
    assert_eq!(0_u128, (-1_i16).saturating_into());
    assert_eq!(0_u8, (-1_i32).saturating_into());
    assert_eq!(0_u16, (-1_i32).saturating_into());
    assert_eq!(0_u32, (-1_i32).saturating_into());
    assert_eq!(0_u64, (-1_i32).saturating_into());
    assert_eq!(0_u128, (-1_i32).saturating_into());
    assert_eq!(0_u8, (-1_i64).saturating_into());
    assert_eq!(0_u16, (-1_i64).saturating_into());
    assert_eq!(0_u32, (-1_i64).saturating_into());
    assert_eq!(0_u64, (-1_i64).saturating_into());
    assert_eq!(0_u128, (-1_i64).saturating_into());
    assert_eq!(0_u8, (-1_i128).saturating_into());
    assert_eq!(0_u16, (-1_i128).saturating_into());
    assert_eq!(0_u32, (-1_i128).saturating_into());
    assert_eq!(0_u64, (-1_i128).saturating_into());
    assert_eq!(0_u128, (-1_i128).saturating_into());
}

#[test]
fn test_saturating_min_signed_into_unsigned() {
    assert_eq!(0_u8, Bounded::<i8>::MIN.saturating_into());
    assert_eq!(0_u16, Bounded::<i8>::MIN.saturating_into());
    assert_eq!(0_u32, Bounded::<i8>::MIN.saturating_into());
    assert_eq!(0_u64, Bounded::<i8>::MIN.saturating_into());
    assert_eq!(0_u128, Bounded::<i8>::MIN.saturating_into());
    assert_eq!(0_u8, Bounded::<i16>::MIN.saturating_into());
    assert_eq!(0_u16, Bounded::<i16>::MIN.saturating_into());
    assert_eq!(0_u32, Bounded::<i16>::MIN.saturating_into());
    assert_eq!(0_u64, Bounded::<i16>::MIN.saturating_into());
    assert_eq!(0_u128, Bounded::<i16>::MIN.saturating_into());
    assert_eq!(0_u8, Bounded::<i32>::MIN.saturating_into());
    assert_eq!(0_u16, Bounded::<i32>::MIN.saturating_into());
    assert_eq!(0_u32, Bounded::<i32>::MIN.saturating_into());
    assert_eq!(0_u64, Bounded::<i32>::MIN.saturating_into());
    assert_eq!(0_u128, Bounded::<i32>::MIN.saturating_into());
    assert_eq!(0_u8, Bounded::<i64>::MIN.saturating_into());
    assert_eq!(0_u16, Bounded::<i64>::MIN.saturating_into());
    assert_eq!(0_u32, Bounded::<i64>::MIN.saturating_into());
    assert_eq!(0_u64, Bounded::<i64>::MIN.saturating_into());
    assert_eq!(0_u128, Bounded::<i64>::MIN.saturating_into());
    assert_eq!(0_u8, Bounded::<i128>::MIN.saturating_into());
    assert_eq!(0_u16, Bounded::<i128>::MIN.saturating_into());
    assert_eq!(0_u32, Bounded::<i128>::MIN.saturating_into());
    assert_eq!(0_u64, Bounded::<i128>::MIN.saturating_into());
    assert_eq!(0_u128, Bounded::<i128>::MIN.saturating_into());
}

#[test]
fn test_saturating_max_signed_into_unsigned() {
    assert_eq!(0x7f_u8, 0x7f_i8.saturating_into());
    assert_eq!(0x7f_u16, 0x7f_i8.saturating_into());
    assert_eq!(0x7f_u32, 0x7f_i8.saturating_into());
    assert_eq!(0x7f_u64, 0x7f_i8.saturating_into());
    assert_eq!(0x7f_u128, 0x7f_i8.saturating_into());
    assert_eq!(0xff_u8, 0x7fff_i16.saturating_into());
    assert_eq!(0x7fff_u16, 0x7fff_i16.saturating_into());
    assert_eq!(0x7fff_u32, 0x7fff_i16.saturating_into());
    assert_eq!(0x7fff_u64, 0x7fff_i16.saturating_into());
    assert_eq!(0x7fff_u128, 0x7fff_i16.saturating_into());
    assert_eq!(0xff_u8, 0x7fffffff_i32.saturating_into());
    assert_eq!(0xffff_u16, 0x7fffffff_i32.saturating_into());
    assert_eq!(0x7fffffff_u32, 0x7fffffff_i32.saturating_into());
    assert_eq!(0x7fffffff_u64, 0x7fffffff_i32.saturating_into());
    assert_eq!(0x7fffffff_u128, 0x7fffffff_i32.saturating_into());
    assert_eq!(0xff_u8, 0x7fffffffffffffff_i64.saturating_into());
    assert_eq!(0xffff_u16, 0x7fffffffffffffff_i64.saturating_into());
    assert_eq!(0xffffffff_u32, 0x7fffffffffffffff_i64.saturating_into());
    assert_eq!(0x7fffffffffffffff_u64, 0x7fffffffffffffff_i64.saturating_into());
    assert_eq!(0x7fffffffffffffff_u128, 0x7fffffffffffffff_i64.saturating_into());
    assert_eq!(0xff_u8, 0x7fffffffffffffffffffffffffffffff_i128.saturating_into());
    assert_eq!(0xffff_u16, 0x7fffffffffffffffffffffffffffffff_i128.saturating_into());
    assert_eq!(0xffffffff_u32, 0x7fffffffffffffffffffffffffffffff_i128.saturating_into());
    assert_eq!(0xffffffffffffffff_u64, 0x7fffffffffffffffffffffffffffffff_i128.saturating_into());
    assert_eq!(
        0x7fffffffffffffffffffffffffffffff_u128,
        0x7fffffffffffffffffffffffffffffff_i128.saturating_into()
    );
}


#[test]
fn test_saturating_add_unsigned_integers() {
    assert_eq!(1_u8.saturating_add(2), 3);
    assert_eq!(Bounded::<u8>::MAX.saturating_add(1), Bounded::<u8>::MAX);
    assert_eq!(1_u16.saturating_add(2), 3);
    assert_eq!(Bounded::<u16>::MAX.saturating_add(1), Bounded::<u16>::MAX);
    assert_eq!(1_u32.saturating_add(2), 3);
    assert_eq!(Bounded::<u32>::MAX.saturating_add(1), Bounded::<u32>::MAX);
    assert_eq!(1_u64.saturating_add(2), 3);
    assert_eq!(Bounded::<u64>::MAX.saturating_add(1), Bounded::<u64>::MAX);
    assert_eq!(1_u128.saturating_add(2), 3);
    assert_eq!(Bounded::<u128>::MAX.saturating_add(1), Bounded::<u128>::MAX);
    assert_eq!(1_u256.saturating_add(2), 3);
    assert_eq!(Bounded::<u256>::MAX.saturating_add(1), Bounded::<u256>::MAX);
}

#[test]
fn test_saturating_add_signed_integers() {
    assert_eq!(1_i8.saturating_add(2), 3);
    assert_eq!(Bounded::<i8>::MAX.saturating_add(1), Bounded::<i8>::MAX);
    assert_eq!(1_i16.saturating_add(2), 3);
    assert_eq!(Bounded::<i16>::MAX.saturating_add(1), Bounded::<i16>::MAX);
    assert_eq!(1_i32.saturating_add(2), 3);
    assert_eq!(Bounded::<i32>::MAX.saturating_add(1), Bounded::<i32>::MAX);
    assert_eq!(1_i64.saturating_add(2), 3);
    assert_eq!(Bounded::<i64>::MAX.saturating_add(1), Bounded::<i64>::MAX);
    assert_eq!(1_i128.saturating_add(2), 3);
    assert_eq!(Bounded::<i128>::MAX.saturating_add(1), Bounded::<i128>::MAX);
}

#[test]
fn test_saturating_add_signed_negative_integers() {
    assert_eq!(Bounded::<i8>::MIN.saturating_add(-1), Bounded::<i8>::MIN);
    assert_eq!((-1_i8).saturating_add(-2), -3);
    assert_eq!(Bounded::<i16>::MIN.saturating_add(-1), Bounded::<i16>::MIN);
    assert_eq!((-1_i16).saturating_add(-2), -3);
    assert_eq!(Bounded::<i32>::MIN.saturating_add(-1), Bounded::<i32>::MIN);
    assert_eq!((-1_i32).saturating_add(-2), -3);
    assert_eq!(Bounded::<i64>::MIN.saturating_add(-1), Bounded::<i64>::MIN);
    assert_eq!((-1_i64).saturating_add(-2), -3);
    assert_eq!(Bounded::<i128>::MIN.saturating_add(-1), Bounded::<i128>::MIN);
    assert_eq!((-1_i128).saturating_add(-2), -3);
}

#[test]
fn test_saturating_sub_unsigned_integers() {
    assert_eq!(3_u8.saturating_sub(2), 1);
    assert_eq!(0_u8.saturating_sub(1), 0);
    assert_eq!(3_u16.saturating_sub(2), 1);
    assert_eq!(0_u16.saturating_sub(1), 0);
    assert_eq!(3_u32.saturating_sub(2), 1);
    assert_eq!(0_u32.saturating_sub(1), 0);
    assert_eq!(3_u64.saturating_sub(2), 1);
    assert_eq!(0_u64.saturating_sub(1), 0);
    assert_eq!(3_u128.saturating_sub(2), 1);
    assert_eq!(0_u128.saturating_sub(1), 0);
    assert_eq!(3_u256.saturating_sub(2), 1);
    assert_eq!(0_u256.saturating_sub(1), 0);
}

#[test]
fn test_saturating_sub_signed_integers() {
    assert_eq!(3_i8.saturating_sub(2), 1);
    assert_eq!(Bounded::<i8>::MIN.saturating_sub(1), Bounded::<i8>::MIN);
    assert_eq!(3_i16.saturating_sub(2), 1);
    assert_eq!(Bounded::<i16>::MIN.saturating_sub(1), Bounded::<i16>::MIN);
    assert_eq!(3_i32.saturating_sub(2), 1);
    assert_eq!(Bounded::<i32>::MIN.saturating_sub(1), Bounded::<i32>::MIN);
    assert_eq!(3_i64.saturating_sub(2), 1);
    assert_eq!(Bounded::<i64>::MIN.saturating_sub(1), Bounded::<i64>::MIN);
    assert_eq!(3_i128.saturating_sub(2), 1);
    assert_eq!(Bounded::<i128>::MIN.saturating_sub(1), Bounded::<i128>::MIN);
}

#[test]
fn test_saturating_sub_signed_negative_integers() {
    assert_eq!(1_i8.saturating_sub(-2), 3);
    assert_eq!(Bounded::<i8>::MAX.saturating_sub(-1), Bounded::<i8>::MAX);
    assert_eq!(1_i16.saturating_sub(-2), 3);
    assert_eq!(Bounded::<i16>::MAX.saturating_sub(-1), Bounded::<i16>::MAX);
    assert_eq!(1_i32.saturating_sub(-2), 3);
    assert_eq!(Bounded::<i32>::MAX.saturating_sub(-1), Bounded::<i32>::MAX);
    assert_eq!(1_i64.saturating_sub(-2), 3);
    assert_eq!(Bounded::<i64>::MAX.saturating_sub(-1), Bounded::<i64>::MAX);
    assert_eq!(1_i128.saturating_sub(-2), 3);
    assert_eq!(Bounded::<i128>::MAX.saturating_sub(-1), Bounded::<i128>::MAX);
}

#[test]
fn test_saturating_mul_unsigned_integers() {
    assert_eq!(2_u8.saturating_mul(3), 6);
    assert_eq!(Bounded::<u8>::MAX.saturating_mul(2), Bounded::<u8>::MAX);
    assert_eq!(2_u16.saturating_mul(3), 6);
    assert_eq!(Bounded::<u16>::MAX.saturating_mul(2), Bounded::<u16>::MAX);
    assert_eq!(2_u32.saturating_mul(3), 6);
    assert_eq!(Bounded::<u32>::MAX.saturating_mul(2), Bounded::<u32>::MAX);
    assert_eq!(2_u64.saturating_mul(3), 6);
    assert_eq!(Bounded::<u64>::MAX.saturating_mul(2), Bounded::<u64>::MAX);
    assert_eq!(2_u128.saturating_mul(3), 6);
    assert_eq!(Bounded::<u128>::MAX.saturating_mul(2), Bounded::<u128>::MAX);
    assert_eq!(2_u256.saturating_mul(3), 6);
    assert_eq!(Bounded::<u256>::MAX.saturating_mul(2), Bounded::<u256>::MAX);
}
