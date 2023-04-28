-- Date 28.01.2023

RFPvari = {}

local RFPvari_mt = Class(RFPvari, Event)
InitEventClass(RFPvari, "RFPvari")




---Create instance of Event class
-- @return table self instance of class event
function RFPvari.emptyNew()
    local self = Event.new(RFPvari_mt)
    return self
end


---Create new instance of event
-- @param table vehicle vehicle
-- @param integer state state
function RFPvari.new(newDP, newAB, newMT, newEL)
    local self = RFPvari.emptyNew()
    self.newDP = newDP
    self.newAB = newAB
    self.newMT = newMT
    self.newEL = newEL
    return self
end


---Called on client side on join
-- @param integer streamId streamId
-- @param integer connection connection
function RFPvari:readStream(streamId, connection)
    -- self.vehicle = NetworkUtil.readNodeObject(streamId)
    self.newDP = streamReadFloat32(streamId)
    self.newAB = streamReadFloat32(streamId)
    self.newMT = streamReadFloat32(streamId)
    self.newEL = streamReadFloat32(streamId)
    self:run(connection)
end


---Called on server side on join
-- @param integer streamId streamId
-- @param integer connection connection
function RFPvari:writeStream(streamId, connection)
    -- NetworkUtil.writeNodeObject(streamId, self.vehicle)
    streamWriteFloat32(streamId, self.newDP, self.newAB, self.newMT, self.newEL)
end


---Run action on receiving side
-- @param integer connection connection
function RFPvari:run(connection)
    if self.vehicle ~= nil and self.vehicle:getIsSynchronized() then -- dont need vehicle ????
        -- CVTaddon.SyncClientServer(self.newDP, self.newAB, self.newMT, self.newEL)
		
		if not connection:getIsServer() then
			-- g_server:broadcastEvent(RFPvari.new(self.newDP, self.newAB, self.newMT, self.newEL), nil, connection, self.????)
			g_server:broadcastEvent(self, false, connection)
		end
    end
end

