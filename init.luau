--!strict
--!optimize 2

-- Services
local RunService = game:GetService("RunService")

-- Constants
local IS_SERVER = RunService:IsServer()

-- Private Functions
local function createOrWaitForInstance(classname: string, name: string, parent: Instance): Instance & any
    local inst = parent:FindFirstChild(name)
    if inst then
        if inst.ClassName ~= classname then
            error(("Expected %s to be a %s, but found %s"):format(name, classname, inst.ClassName))
        end
        return inst
    elseif IS_SERVER then
        local newInst = Instance.new(classname)
        newInst.Name = name
        if parent then
            newInst.Parent = parent
        end
        return newInst
    else
        return parent:WaitForChild(name, 9e9) :: Instance
    end
end

-- Module

--[=[
    @class Remote
    A utility module for working with RemoteFunctions and RemoteEvents in Roblox. Provides type-safe interfaces for server-client communication.

    This module includes functions to create or retrieve RemoteFunctions and RemoteEvents, as well as type definitions for server and client signals.

    Example usage:

    ```lua
    local Remote = require(path.to.Remote)

    -- Create a RemoteFunction
    local myFunction = Remote.Function("MyFunction")

    -- Set up a server-side handler
    myFunction.OnServerInvoke:Connect(function(player, arg1, arg2)
        print(player.Name, arg1, arg2)
        return "Response from server"
    end)

    -- Create a RemoteEvent
    local myEvent = Remote.Event("MyEvent")

    -- Fire the event to all clients
    myEvent:FireAllClients("Hello, clients!")
    ```
]=]
local Remote = {}

-- Types
export type ServerSignal<T...> = {
    Connect: (self: ServerSignal<T...>, callback: (player: Player, T...) -> ()) -> RBXScriptConnection,
    ConnectParallel: (self: ServerSignal<T...>, callback: (player: Player, T...) -> ()) -> RBXScriptConnection,
    Once: (self: ServerSignal<T...>, callback: (player: Player, T...) -> ()) -> RBXScriptConnection,
    Wait: (self: ServerSignal<T...>) -> (Player, T...),
}

export type ClientSignal<T...> = {
    Connect: (self: ClientSignal<T...>, callback: (T...) -> ()) -> RBXScriptConnection,
    ConnectParallel: (self: ClientSignal<T...>, callback: (T...) -> ()) -> RBXScriptConnection,
    Once: (self: ClientSignal<T...>, callback: (T...) -> ()) -> RBXScriptConnection,
    Wait: (self: ClientSignal<T...>) -> (T...),
}

export type Function<T..., U...> = {
    InvokeServer: (self: Function<T..., U...>, T...) -> (U...),
    OnServerInvoke: (player: Player, T...) -> (U...),
}

export type Event<T...> = {
    FireServer: (self: Event<T...>, T...) -> (),
    FireClient: (self: Event<T...>, player: Player, T...) -> (),
    FireAllClients: (self: Event<T...>, T...) -> (),
    OnServerEvent: ServerSignal<T...>,
    OnClientEvent: ClientSignal<T...>,
}

-- Public

--[=[
    Creates or retrieves a RemoteFunction with the given name and parent.

    @param name The name of the RemoteFunction.
    @param parent The parent instance for the RemoteFunction. Defaults to the script.
    @return The RemoteFunction instance.
]=]
function Remote.Function<T..., U...>(name: string, parent: Instance?): Function<T..., U...>
    return createOrWaitForInstance("RemoteFunction", name, parent or script) :: any
end

--[=[
    Creates or retrieves a RemoteEvent with the given name and parent.

    @param name The name of the RemoteEvent.
    @param parent The parent instance for the RemoteEvent. Defaults to the script.
    @return The RemoteEvent instance.
]=]
function Remote.Event<T...>(name: string, parent: Instance?): Event<T...>
    return createOrWaitForInstance("RemoteEvent", name, parent or script) :: any
end

--[=[
    Creates or retrieves an UnreliableRemoteEvent with the given name and parent.

    @param name The name of the UnreliableRemoteEvent.
    @param parent The parent instance for the UnreliableRemoteEvent. Defaults to the script.
    @return The UnreliableRemoteEvent instance.
]=]
function Remote.Unreliable<T...>(name: string, parent: Instance?): Event<T...>
    return createOrWaitForInstance("UnreliableRemoteEvent", name, parent or script) :: any
end

table.freeze(Remote)
return Remote
