ENT.Type 			= "anim" 
 ENT.Base 			= "base_gmodentity" 
   
 ENT.PrintName		= "" 
 ENT.Author			= "" 
 ENT.Contact			= "" 
 ENT.Purpose			= "" 
 ENT.Instructions	= "" 
   
 ENT.Spawnable			= false 
 ENT.AdminSpawnable		= false 
   
   
   
   
 /*--------------------------------------------------------- 
 ---------------------------------------------------------*/ 
 function ENT:SetEffect( name ) 
 	self:SetNetworkedString( "Effect", name ) 
 end 
   
 /*--------------------------------------------------------- 
 ---------------------------------------------------------*/ 
 function ENT:GetEffect( name ) 
 	return self:GetNetworkedString( "Effect", "" ) 
 end 

   
 /*--------------------------------------------------------- 
 ---------------------------------------------------------*/ 
 function ENT:SetOn( boolon ) 
 	self:SetNetworkedBool( "On", boolon, true ) 
 end 
   
 /*--------------------------------------------------------- 
 ---------------------------------------------------------*/ 
 function ENT:IsOn( name ) 
 	return self:GetNetworkedBool( "On", false ) 
 end 
   
   
 /*--------------------------------------------------------- 
 ---------------------------------------------------------*/ 
 function ENT:SetOffset( v ) 
 	self:SetNetworkedVector( "Offset", v, true ) 
 end 
   
 /*--------------------------------------------------------- 
 ---------------------------------------------------------*/ 
 function ENT:GetOffset( name ) 
 	return self:GetNetworkedVector( "Offset" ) 
 end 
   
 /*--------------------------------------------------------- 
 ---------------------------------------------------------*/ 
 function ENT:SetSound( snd ) 
 	self.SoundOn = snd 
 end 
   
 /*--------------------------------------------------------- 
 ---------------------------------------------------------*/ 
 function ENT:GetSound() 
 	if ( !self.SoundOn ) then return false end 
 	return self.SoundOn ~= 0
end