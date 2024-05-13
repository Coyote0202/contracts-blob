use blob_arena::components::stats::{Stats, StatsTrait};
#[derive(Copy, Drop, Print, Serde, SerdeLen, Size, Introspect)]
enum Jewelry {
    Amulet,
    BronzeRing,
    GoldRing,
    Necklace,
    Pendant,
    PlatinumRing,
    SilverRing,
    TitaniumRing,
}

const JEWELRY_COUNT: u8 = 8;

impl JewelryImpl of StatsTrait<Jewelry> {
    fn stats(self: Jewelry) -> Stats {
        match self {
            Jewelry::Amulet => Stats { attack: 0, defense: 0, speed: 5, strength: 5, },
            Jewelry::BronzeRing => Stats { attack: 0, defense: 0, speed: 1, strength: 3, },
            Jewelry::GoldRing => Stats { attack: 0, defense: 0, speed: 5, strength: 3, },
            Jewelry::Necklace => Stats { attack: 0, defense: 0, speed: 1, strength: 1, },
            Jewelry::Pendant => Stats { attack: 0, defense: 0, speed: 3, strength: 4, },
            Jewelry::PlatinumRing => Stats { attack: 0, defense: 0, speed: 5, strength: 4, },
            Jewelry::SilverRing => Stats { attack: 0, defense: 0, speed: 4, strength: 4, },
            Jewelry::TitaniumRing => Stats { attack: 0, defense: 0, speed: 3, strength: 5, },
        }
    }
    fn index(self: Jewelry) -> u8 {
        match self {
            Jewelry::Amulet => 0,
            Jewelry::BronzeRing => 1,
            Jewelry::GoldRing => 2,
            Jewelry::Necklace => 3,
            Jewelry::Pendant => 4,
            Jewelry::PlatinumRing => 5,
            Jewelry::SilverRing => 6,
            Jewelry::TitaniumRing => 7,
        }
    }
}

impl U8IntoJewelry of Into<u8, Jewelry> {
    fn into(self: u8) -> Jewelry {
        match self {
            0 => Jewelry::Amulet,
            1 => Jewelry::BronzeRing,
            2 => Jewelry::GoldRing,
            3 => Jewelry::Necklace,
            4 => Jewelry::Pendant,
            5 => Jewelry::PlatinumRing,
            6 => Jewelry::SilverRing,
            7 => Jewelry::TitaniumRing,
            _ => panic!("wrong jewelry index")
        }
    }
}


impl StatsU8IntoJewelry of Into<@u8, Jewelry> {
    fn into(self: @u8) -> Jewelry {
        (*self).into()
    }
}

impl JewelryIntoByteArray of Into<Jewelry, ByteArray> {
    fn into(self: Jewelry) -> ByteArray {
        match self {
            Jewelry::Amulet => "Amulet",
            Jewelry::BronzeRing => "BronzeRing",
            Jewelry::GoldRing => "GoldRing",
            Jewelry::Necklace => "Necklace",
            Jewelry::Pendant => "Pendant",
            Jewelry::PlatinumRing => "PlatinumRing",
            Jewelry::SilverRing => "SilverRing",
            Jewelry::TitaniumRing => "TitaniumRing",
        }
    }
}
