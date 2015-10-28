config = {}

-- change to false to disable overwriting if no empty blueprint is found
config.overwrite = true

-- change to false to not require an electronic circuit when overwriting
config.useCircuit = true

-- which forces to ignore when upgrading from Foreman < 0.1.0 (so existing blueprints don't get copied to that force)

config.ignoreForces = {
  enemy = true,
  gate = true,
  neutral = true  
}