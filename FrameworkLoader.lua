--!strict

--//Imports
local _Extra = require(script._Extra)

--//Services
local Players : Players = game:GetService("Players")

--//Variables
local frameworkFolder = script.Parent
local DependenciesFolder = frameworkFolder:WaitForChild("Dependencies")
local clientDependenciesFolder = DependenciesFolder:WaitForChild("Client")

--//Types
type serviceType = {[string]: any} 
type moduleType = {[string]: {any}?} 
type dependencieSetter<Key, Value> = {[Key]: Value}
type loadedDependencie = {[string] : {}}

--//Setup
local _Services: serviceType = {
	Players = Players
}

local Library = {
	Services = _Services
}

local function unpackLoadedDependencie(loadedModules: loadedDependencie) : ()
	--> Unpack loaded modules in main framework table
	
	for moduleName: string, userdata: {}? in loadedModules do
		Library[moduleName] = userdata
	end
	
end

local function compileDependencie(Dependencies: {[number]: Folder}) : () 
	--> Require and save dependencies modules
	
	local loadedModulesFromDependencie: loadedDependencie = {}
	
	for _, Folder: Folder in Dependencies do
		local dependencieModules: dependencieSetter<number, ModuleScript> = Folder:GetChildren() :: {}
		
		for _,moduleScript: ModuleScript in dependencieModules do
			
			local Return = require(moduleScript) :: any
			
			loadedModulesFromDependencie[moduleScript.Name] = Return :: typeof(Return)
		end
	end
	
	unpackLoadedDependencie(loadedModulesFromDependencie)
end

compileDependencie(clientDependenciesFolder:GetChildren())
unpackLoadedDependencie(_Extra)

return Library
