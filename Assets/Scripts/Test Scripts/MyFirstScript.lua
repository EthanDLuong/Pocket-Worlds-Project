--!Type(Client)

-- This Lua script is called when the script is first loaded
function self:Awake()
    -- Print a message to the console
    print("Hello World!")
end

-- This Lua script moves a GameObject up every frame
function self:Update()
    self.gameObject.transform.position = self.gameObject.transform.position + Vector3.up * Time.deltaTime
end
