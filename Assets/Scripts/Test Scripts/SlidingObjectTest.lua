--!Type(Client)

--!SerializeField
local leftEndpoint: Vector3 = Vector3.zero
--!SerializeField
local rightEndpoint: Vector3 = Vector3.zero
--!SerializeField
local originalPosition: Vector3 = Vector3.zero
--!SerializeField
local button: GameObject = nil

function self:Awake()
    directionNumber = leftEndpoint - self.gameObject.transform.position
    directionNumber:Normalize()

end

function self:Update()
    self.gameObject.transform.position = self.gameObject.transform.position + directionNumber * 1 * Time.deltaTime
    if Vector3.Distance(self.gameObject.transform.position, leftEndpoint) < 0.1 then
        directionNumber = rightEndpoint - self.gameObject.transform.position
        directionNumber:Normalize()
        self.gameObject.transform.position = self.gameObject.transform.position + directionNumber * 1 * Time.deltaTime
    elseif Vector3.Distance(self.gameObject.transform.position, rightEndpoint) < 0.1 then
        directionNumber = leftEndpoint - self.gameObject.transform.position
        directionNumber:Normalize()
        self.gameObject.transform.position = self.gameObject.transform.position + directionNumber * 1 * Time.deltaTime
    end 
end

function self:OnTriggerEnter(other: Collider)
    print("Hit:" .. other.gameObject.name)
    currentCollider = other
end

function self:OnTriggerExit(other: Collider)
    if currentCollider == other then
        currentCollider = nil
        print("No more.")
    end
end

button.gameObject:GetComponent(TapHandler).Tapped:Connect(function()
    -- self.gameObject.transform.position = originalPosition
    if currentCollider then
        print("Tapped and colliding.")
        currentCollider.gameObject:SetActive(false)
    else
        print("Tapped but not colliding.")
    end
    -- self.gameObject:GetComponent(Collider).enabled = true
end)
