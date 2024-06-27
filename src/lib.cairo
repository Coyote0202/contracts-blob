mod models;
mod core;
mod collections;
mod utils;
mod world;
mod components {
    mod attack;
    // mod warrior;
    mod stats;
    mod combatant;
    mod item;
    mod commitment;
    mod pvp_combat;
    mod combat;
    mod utils;
    mod pvp_challenge;
}
mod systems {
    mod combat;
    // mod attack;
    mod pvp_combat;
// mod weapon;
// mod arcade {
//     mod blobert;
// }
// mod combat;
// mod knockout;
// mod blobert;
// mod challenge;
// mod stake;
// mod warrior;
}
mod contracts {
    mod attack;
    mod item;
    mod pvp;
    mod pvp_admin;
}
// mod constants;

#[cfg(test)]
mod tests {
    mod pvp_test;
}

