--[[
 --> Loads the game structure and returns it in an array.
 --> 02/15/2023
 --> @yLord <> @yLordGhost

@Framework Library
]]--

--!strict

--//Imports
local _Extra = require(script._Extra)

--//Services
local Players: Players = game:GetService("Players")
local RunService: RunService = game:GetService("RunService")

--//Variables
local frameworkFolder = script.Parent
local DependenciesFolder = frameworkFolder:WaitForChild("Dependencies")
local Side: string = (RunService:IsServer() and "Server" or "Client")   

--//Types
type serviceType = {[string]: any} 
type dependencieSetter<Key, Value> = {[Key]: Value}
type loadedDependencie = {[string] : {}}

--//Setup
local _Services: serviceType = {
	Players = Players,
	ServerScriptService = Side == "Server" and game:GetService("ServerScriptService")
}

local Library = {
	Services = _Services
}

local function cycleAvoider(): number
	return RunService.Heartbeat:Wait()
end

local function unpackLoadedDependencie(loadedModules: loadedDependencie, dependencieClass: string?): ()
	if dependencieClass then
		--> Create a new dependencieClass if none]
		Library[dependencieClass] = {}
	end
	
	--> Unpack loaded modules in main framework table
	for moduleName: string, userdata: {}? in loadedModules do
		if dependencieClass then
			Library[dependencieClass][moduleName] = userdata
		else
			Library[moduleName] = userdata :: any
		end
	end
end

local function compileDependencie(Dependencies: {[number]: Folder}, dependencieClass: string): () 
	--> Avoid de module cycle error
	cycleAvoider() 
	
	--> Require and save dependencies modules
	local loadedModulesFromDependencie: loadedDependencie = {}

	for _, Folder: Folder in Dependencies do
		local dependencieModules: dependencieSetter<number, ModuleScript> = Folder:GetChildren() :: {}

		for _,moduleScript: ModuleScript in dependencieModules do
			local Return = require(moduleScript) :: any
			loadedModulesFromDependencie[moduleScript.Name] = Return :: typeof(Return)
		end
	end

	unpackLoadedDependencie(loadedModulesFromDependencie, dependencieClass)
end

local function setupFramework(): ()
	--> Call loaders & compilers
	compileDependencie(Side == "Client" and DependenciesFolder.Client:GetChildren() or _Services.ServerScriptService:WaitForChild("Server"):GetChildren(), Side)
	compileDependencie(DependenciesFolder.Shared:GetChildren(), "Shared")
	unpackLoadedDependencie(_Extra)
	
	--> Setup Completed > Framework loaded
	Library.isFrameworkLoaded = true
end

coroutine.wrap(setupFramework)()

return Library
