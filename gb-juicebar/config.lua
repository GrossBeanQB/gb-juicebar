Config = {}

Config.Stash = {
    coords = vector3(-1251.21, -749.57, 20.13),
    stashName = "juicebar_stash",
    maxWeight = 50000,
    slots = 20
}

Config.JuiceBarVehicleSpawner = {
    label = 'Juice Bar Vehicles',
    coords = vector4(-1255.44, -747.81, 20.82, 216.15),
    ped = 'a_m_m_ktown_01',
    scenario = 'WORLD_HUMAN_CLIPBOARD',
    radius = 1.5,
    targetIcon = 'fas fa-car',
    targetLabel = 'Spawn or Return Juice Bar Vehicle',
    vehicles = {
        { model = 'rumpo', label = 'Juice Bar Van', color = {88, 88, 0} },
        { model = 'faggio', label = 'Juice Bar Scooter', color = {88, 88, 0} }
    },
    spawnLocation = vector4(-1257.24, -749.1, 20.74, 214.76),
    requiredJob = 'juicebar',
}

Config.FruitShop = {
    shopLabel = "Fruit Shop",
    coords = vector4(-2510.0, 3614.48, 13.72, 258.58),
    ped = "a_m_m_farmer_01",
    products = {
        { name = "pineapple", price = 5, amount = 100 },
        { name = "orange", price = 3, amount = 100 },
        { name = "lemon", price = 4, amount = 100 }
    },
    job = "juicebar"
}
