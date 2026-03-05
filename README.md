# Remote

A lightweight, type-safe utility module for working with RemoteFunctions and RemoteEvents in Roblox. Simplifies server-client communication with a clean API and full Luau type support.

## Installation

Add to your `wally.toml`:

```toml
[dependencies]
Remote = "stackyzdev/remote@0.1.0"
```

Then run:

```bash
wally install
```

## API

```lua
local Remote = require(path.to.Remote)
```

### `Remote.Function<T..., U...>(name: string, parent: Instance?): Function<T..., U...>`

Creates or retrieves a `RemoteFunction` with the given name.

### `Remote.Event<T...>(name: string, parent: Instance?): Event<T...>`

Creates or retrieves a `RemoteEvent` with the given name.

### `Remote.Unreliable<T...>(name: string, parent: Instance?): Event<T...>`

Creates or retrieves an `UnreliableRemoteEvent` with the given name.

> If no `parent` is provided, it defaults to the module's script instance. On the server, instances are created automatically; on the client, the module waits for them to replicate.

## Usage

### RemoteEvent

```lua
local Remote = require(path.to.Remote)

local myEvent = Remote.Event("MyEvent")

-- Server
myEvent.OnServerEvent:Connect(function(player, message)
    print(player.Name, message)
end)

-- Client
myEvent:FireServer("Hello from client!")
```

### RemoteFunction

```lua
local Remote = require(path.to.Remote)

local myFunction = Remote.Function("MyFunction")

-- Server
myFunction:OnServerInvoke(function(player, arg1)
    return "Got: " .. tostring(arg1)
end)

-- Client
local result = myFunction:InvokeServer("ping")
print(result) -- "Got: ping"
```

### UnreliableRemoteEvent

```lua
local Remote = require(path.to.Remote)

local positionUpdate = Remote.Unreliable("PositionUpdate")

-- Server
positionUpdate:FireAllClients(Vector3.new(0, 10, 0))
```

## Types

The module exports the following types for use in typed Luau code:

| Type | Description |
|------|-------------|
| `Remote.ServerSignal<T...>` | Server-side event signal (includes `Connect`, `ConnectParallel`, `Once`, `Wait`) |
| `Remote.ClientSignal<T...>` | Client-side event signal |
| `Remote.Function<T..., U...>` | Typed RemoteFunction with `InvokeServer` and `OnServerInvoke` |
| `Remote.Event<T...>` | Typed RemoteEvent with `FireServer`, `FireClient`, `FireAllClients`, and signal properties |
