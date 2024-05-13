use blob_arena::components::stats::{Stats, StatsTrait};

const ARMOUR_COUNT: u8 = 17;

#[derive(Copy, Drop, Print, Serde, SerdeLen, Introspect)]
enum Armour {
    SheepsWool,
    Kigurumi,
    DivineRobeDark,
    DivineRobe,
    DojoRobe,
    HolyChestplate,
    DemonHusk,
    LeatherArmour,
    LeopardSkin,
    LinenRobe,
    LordsArmor,
    SecretTattoo,
    Chainmail,
    Suit,
    Underpants,
    WenShirt,
    WsbTankTop,
}

impl ArmourImpl of StatsTrait<Armour> {
    fn stats(self: Armour) -> Stats {
        match self {
            Armour::SheepsWool => Stats { attack: 0, defense: 2, speed: 2, strength: 4, },
            Armour::Kigurumi => Stats { attack: 0, defense: 2, speed: 5, strength: 2, },
            Armour::DivineRobeDark => Stats { attack: 0, defense: 4, speed: 2, strength: 4, },
            Armour::DivineRobe => Stats { attack: 0, defense: 4, speed: 3, strength: 5, },
            Armour::DojoRobe => Stats { attack: 0, defense: 3, speed: 4, strength: 3, },
            Armour::HolyChestplate => Stats { attack: 0, defense: 5, speed: 1, strength: 3, },
            Armour::DemonHusk => Stats { attack: 0, defense: 3, speed: 3, strength: 5, },
            Armour::LeatherArmour => Stats { attack: 0, defense: 3, speed: 3, strength: 3, },
            Armour::LeopardSkin => Stats { attack: 0, defense: 2, speed: 5, strength: 3, },
            Armour::LinenRobe => Stats { attack: 0, defense: 2, speed: 4, strength: 5, },
            Armour::LordsArmor => Stats { attack: 0, defense: 5, speed: 2, strength: 5, },
            Armour::SecretTattoo => Stats { attack: 0, defense: 2, speed: 4, strength: 4, },
            Armour::Chainmail => Stats { attack: 0, defense: 4, speed: 2, strength: 3, },
            Armour::Suit => Stats { attack: 0, defense: 2, speed: 3, strength: 2, },
            Armour::Underpants => Stats { attack: 0, defense: 0, speed: 5, strength: 1, },
            Armour::WenShirt => Stats { attack: 0, defense: 3, speed: 4, strength: 2, },
            Armour::WsbTankTop => Stats { attack: 0, defense: 2, speed: 5, strength: 4, },
        }
    }
    fn index(self: Armour) -> u8 {
        match self {
            Armour::SheepsWool => 0,
            Armour::Kigurumi => 1,
            Armour::DivineRobeDark => 2,
            Armour::DivineRobe => 3,
            Armour::DojoRobe => 4,
            Armour::HolyChestplate => 5,
            Armour::DemonHusk => 6,
            Armour::LeatherArmour => 7,
            Armour::LeopardSkin => 8,
            Armour::LinenRobe => 9,
            Armour::LordsArmor => 10,
            Armour::SecretTattoo => 11,
            Armour::Chainmail => 12,
            Armour::Suit => 13,
            Armour::Underpants => 14,
            Armour::WenShirt => 15,
            Armour::WsbTankTop => 16,
        }
    }
}

impl U8IntoArmour of Into<u8, Armour> {
    fn into(self: u8) -> Armour {
        match self {
            0 => Armour::SheepsWool,
            1 => Armour::Kigurumi,
            2 => Armour::DivineRobeDark,
            3 => Armour::DivineRobe,
            4 => Armour::DojoRobe,
            5 => Armour::HolyChestplate,
            6 => Armour::DemonHusk,
            7 => Armour::LeatherArmour,
            8 => Armour::LeopardSkin,
            9 => Armour::LinenRobe,
            10 => Armour::LordsArmor,
            11 => Armour::SecretTattoo,
            12 => Armour::Chainmail,
            13 => Armour::Suit,
            14 => Armour::Underpants,
            15 => Armour::WenShirt,
            16 => Armour::WsbTankTop,
            _ => panic!("wrong armour index")
        }
    }
}


impl ArmourIntoByteArray of Into<Armour, ByteArray> {
    fn into(self: Armour) -> ByteArray {
        match self {
            Armour::SheepsWool => "SheepsWool",
            Armour::Kigurumi => "Kigurumi",
            Armour::DivineRobeDark => "DivineRobeDark",
            Armour::DivineRobe => "DivineRobe",
            Armour::DojoRobe => "DojoRobe",
            Armour::HolyChestplate => "HolyChestplate",
            Armour::DemonHusk => "DemonHusk",
            Armour::LeatherArmour => "LeatherArmour",
            Armour::LeopardSkin => "LeopardSkin",
            Armour::LinenRobe => "LinenRobe",
            Armour::LordsArmor => "LordsArmor",
            Armour::SecretTattoo => "SecretTattoo",
            Armour::Chainmail => "Chainmail",
            Armour::Suit => "Suit",
            Armour::Underpants => "Underpants",
            Armour::WenShirt => "WenShirt",
            Armour::WsbTankTop => "WsbTankTop",
        }
    }
}


impl SU8IntoArmour of Into<@u8, Armour> {
    fn into(self: @u8) -> Armour {
        (*self).into()
    }
}
