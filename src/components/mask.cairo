use blob_arena::components::stats::{Stats, StatsTrait};

const MASK_COUNT: u8 = 26;

#[derive(Copy, Drop, Print, Serde, SerdeLen, Introspect)]
enum Mask {
    Blobert,
    Doge,
    Dojo,
    Ducks,
    Kevin,
    Milady,
    Pepe,
    Pudgy,
    _3dGlasses,
    _1337Skulls,
    AncientHelm,
    Bane,
    BraavosHelm,
    Bulbhead,
    DealWithItGlasses,
    DemonCrown,
    DivineHood,
    Ekubo,
    HyperlootCrown,
    InfluenceHelmet,
    LordsHelm,
    Nostrahat,
    NounsGlasses,
    PopeHat,
    TaprootWizardHat,
    WifHat,
}


impl MaskImpl of StatsTrait<Mask> {
    fn stats(self: Mask) -> Stats {
        match self {
            Mask::Blobert => Stats { attack: 0, defense: 0, speed: 4, strength: 4, },
            Mask::Doge => Stats { attack: 0, defense: 0, speed: 4, strength: 2, },
            Mask::Dojo => Stats { attack: 0, defense: 0, speed: 4, strength: 4, },
            Mask::Ducks => Stats { attack: 0, defense: 0, speed: 3, strength: 5, },
            Mask::Kevin => Stats { attack: 0, defense: 0, speed: 2, strength: 5, },
            Mask::Milady => Stats { attack: 0, defense: 0, speed: 2, strength: 2, },
            Mask::Pepe => Stats { attack: 0, defense: 0, speed: 3, strength: 3, },
            Mask::Pudgy => Stats { attack: 0, defense: 0, speed: 1, strength: 3, },
            Mask::_3dGlasses => Stats { attack: 0, defense: 0, speed: 2, strength: 2, },
            Mask::_1337Skulls => Stats { attack: 0, defense: 0, speed: 4, strength: 3, },
            Mask::AncientHelm => Stats { attack: 0, defense: 3, speed: 2, strength: 4, },
            Mask::Bane => Stats { attack: 0, defense: 0, speed: 5, strength: 5, },
            Mask::BraavosHelm => Stats { attack: 0, defense: 3, speed: 3, strength: 3, },
            Mask::Bulbhead => Stats { attack: 0, defense: 0, speed: 5, strength: 2, },
            Mask::DealWithItGlasses => Stats { attack: 0, defense: 0, speed: 5, strength: 2, },
            Mask::DemonCrown => Stats { attack: 0, defense: 0, speed: 3, strength: 5, },
            Mask::DivineHood => Stats { attack: 0, defense: 0, speed: 4, strength: 3, },
            Mask::Ekubo => Stats { attack: 0, defense: 0, speed: 4, strength: 3, },
            Mask::HyperlootCrown => Stats { attack: 0, defense: 0, speed: 3, strength: 4, },
            Mask::InfluenceHelmet => Stats { attack: 0, defense: 4, speed: 2, strength: 3, },
            Mask::LordsHelm => Stats { attack: 0, defense: 0, speed: 2, strength: 5, },
            Mask::Nostrahat => Stats { attack: 0, defense: 0, speed: 2, strength: 4, },
            Mask::NounsGlasses => Stats { attack: 0, defense: 0, speed: 4, strength: 3, },
            Mask::PopeHat => Stats { attack: 0, defense: 0, speed: 2, strength: 5, },
            Mask::TaprootWizardHat => Stats { attack: 0, defense: 0, speed: 5, strength: 4, },
            Mask::WifHat => Stats { attack: 0, defense: 2, speed: 3, strength: 3, },
        }
    }
    fn index(self: Mask) -> u8 {
        match self {
            Mask::Blobert => 0,
            Mask::Doge => 1,
            Mask::Dojo => 2,
            Mask::Ducks => 3,
            Mask::Kevin => 4,
            Mask::Milady => 5,
            Mask::Pepe => 6,
            Mask::Pudgy => 7,
            Mask::_3dGlasses => 8,
            Mask::_1337Skulls => 9,
            Mask::AncientHelm => 10,
            Mask::Bane => 11,
            Mask::BraavosHelm => 12,
            Mask::Bulbhead => 13,
            Mask::DealWithItGlasses => 14,
            Mask::DemonCrown => 15,
            Mask::DivineHood => 16,
            Mask::Ekubo => 17,
            Mask::HyperlootCrown => 18,
            Mask::InfluenceHelmet => 19,
            Mask::LordsHelm => 20,
            Mask::Nostrahat => 21,
            Mask::NounsGlasses => 22,
            Mask::PopeHat => 23,
            Mask::TaprootWizardHat => 24,
            Mask::WifHat => 25,
        }
    }
}

impl U8IntoMask of Into<u8, Mask> {
    fn into(self: u8) -> Mask {
        match self {
            0 => Mask::Blobert,
            1 => Mask::Doge,
            2 => Mask::Dojo,
            3 => Mask::Ducks,
            4 => Mask::Kevin,
            5 => Mask::Milady,
            6 => Mask::Pepe,
            7 => Mask::Pudgy,
            8 => Mask::_3dGlasses,
            9 => Mask::_1337Skulls,
            10 => Mask::AncientHelm,
            11 => Mask::Bane,
            12 => Mask::BraavosHelm,
            13 => Mask::Bulbhead,
            14 => Mask::DealWithItGlasses,
            15 => Mask::DemonCrown,
            16 => Mask::DivineHood,
            17 => Mask::Ekubo,
            18 => Mask::HyperlootCrown,
            19 => Mask::InfluenceHelmet,
            20 => Mask::LordsHelm,
            21 => Mask::Nostrahat,
            22 => Mask::NounsGlasses,
            23 => Mask::PopeHat,
            24 => Mask::TaprootWizardHat,
            25 => Mask::WifHat,
            _ => panic!("wrong mask index")
        }
    }
}

impl SU8IntoMask of Into<@u8, Mask> {
    fn into(self: @u8) -> Mask {
        (*self).into()
    }
}


impl MaskIntoByteArray of Into<Mask, ByteArray> {
    fn into(self: Mask) -> ByteArray {
        match self {
            Mask::Blobert => "Blobert",
            Mask::Doge => "Doge",
            Mask::Dojo => "Dojo",
            Mask::Ducks => "Ducks",
            Mask::Kevin => "Kevin",
            Mask::Milady => "Milady",
            Mask::Pepe => "Pepe",
            Mask::Pudgy => "Pudgy",
            Mask::_3dGlasses => "_3dGlasses",
            Mask::_1337Skulls => "_1337Skulls",
            Mask::AncientHelm => "AncientHelm",
            Mask::Bane => "Bane",
            Mask::BraavosHelm => "BraavosHelm",
            Mask::Bulbhead => "Bulbhead",
            Mask::DealWithItGlasses => "DealWithItGlasses",
            Mask::DemonCrown => "DemonCrown",
            Mask::DivineHood => "DivineHood",
            Mask::Ekubo => "Ekubo",
            Mask::HyperlootCrown => "HyperlootCrown",
            Mask::InfluenceHelmet => "InfluenceHelmet",
            Mask::LordsHelm => "LordsHelm",
            Mask::Nostrahat => "Nostrahat",
            Mask::NounsGlasses => "NounsGlasses",
            Mask::PopeHat => "PopeHat",
            Mask::TaprootWizardHat => "TaprootWizardHat",
            Mask::WifHat => "WifHat",
        }
    }
}
