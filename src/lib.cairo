mod components {
    mod traits {
        mod armour;
        mod background;
        mod jewelry;
        mod mask;
        mod weapon;
    }
    mod arcade;
    mod stats;
    mod blobert;
    mod combat;
    mod utils;
    mod world;
    mod knockout;
    mod stake;
    mod challenge;
}
mod systems {
    mod arcade {
        mod blobert;
    }
    mod combat;
    mod knockout;
    mod blobert;
    mod challenge;
    mod stake;
}

mod contracts {
    mod arcade {
        mod blobert;
    }
    mod challenge;
}

mod external {
    mod blobert;
}

mod constants;
mod utils;
mod tests {
    mod combat_test;
}
