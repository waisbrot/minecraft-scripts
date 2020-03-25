SAFE = {
  ["minecraft:clay"] = true,
  ["minecraft:coal_ore"] = true,
  ["minecraft:deadbush"] = true,
  ["minecraft:diamond_ore"] = true,
  ["minecraft:dirt"] = true,
  ["minecraft:glowstone"] = true,
  ["minecraft:gold_ore"] = true,
  ["minecraft:grass"] = true,
  ["minecraft:gravel"] = true,
  ["minecraft:ice"] = true,
  ["minecraft:iron_ore"] = true,
  ["minecraft:lapis_ore"] = true,
  ["minecraft:lit_redstone_ore"] = true,
  ["minecraft:netherrack"] = true,
  ["minecraft:redstone_ore"] = true,
  ["minecraft:sand"] = true,
  ["minecraft:sandstone"] = true,
  ["minecraft:snow"] = true,
  ["minecraft:snow_layer"] = true,
  ["minecraft:soul_sand"] = true,
  ["minecraft:stone"] = true,
  ["minecraft:tallgrass"] = true,
  ["minecraft:web"] = true,

  ["projectred-exploration:ore"] = true,
  ["techreborn:ore"] = true,
  ["thermalfoundation:ore"] = true,
  ["modularforcefieldsystem:monazit_ore"] = true,
}

-- Everything not listed above is unsafe!
setmetatable(SAFE, {__index = function () return false end})
