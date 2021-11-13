--// Bachelor of Software Engineering
--// Media Design School
--// Auckland
--// New Zealand
--// 
--// (c) 2021 Media Design School
--//
--// File Name   : utils.lua
--// Description : A collection of utility functions
--// Author      : Nerys Thamm
--// Mail        : nerys.thamm@mds.ac.nz 

Utils = {}
Utils.__index = Utils

--Lerps between two values
function Utils:lerp(a, b, t) return a * (1-t) + b * t end

