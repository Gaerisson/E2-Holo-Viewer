----- E2 ------
surface.CreateFont( "E2_Holo_Font", {
	font = "Roboto Bk",
	size = 15,
	weight = 500,
	outline = true,
} )


local function WireHologramsShowOwners()
	for _,ent in pairs( ents.FindByClass( "gmod_wire_hologram" ) ) do
		local id = ent:GetNWInt( "ownerid" )

		for _,ply in pairs( player.GetAll() ) do
			if ply:UserID() == id then
				local vec = ent:GetPos():ToScreen()

		            cam.Start3D(EyePos(),EyeAngles())
		            	render.SetColorModulation( 1, 0.2, 0 ) 
		            	render.SetBlend(0.7)
			            ent:DrawModel()
			            --render.SetBlend(1)
			            render.SuppressEngineLighting( false )
			            render.MaterialOverride( )
			         cam.End3D()
	            
				draw.RoundedBox( 10, vec.x, vec.y, 7, 7, Color(255,0,0,200) ) 
				draw.DrawText( ply:Name() .. "\n" .."("..ply:SteamID()..")", "E2_Holo_Font", vec.x, vec.y+9, Color(255,0,0,200	), 1 )
				break
			end
		end
	end
end


local display_owners = false
concommand.Add( "wire_holograms_display_owners", function()
	display_owners = !display_owners
	if display_owners then
		hook.Add( "HUDPaint", "wire_holograms_showowners", WireHologramsShowOwners)
	else
		hook.Remove("HUDPaint", "wire_holograms_showowners")
	end
end )

local function DrawE2Panel()
	--surface.SetDrawColor( 0, 0, 0, 150 )
	--surface.DrawRect( 35, ScrH()/3, ScrW()/9, ScrH()/5 )
	draw.SimpleText( "### E2 List ###", "ConText" , ScrW()/80, (ScrH()/3.83), Color(255,255,255,255) )
	local function E2Line(idp,str,idx,prfbench,ops,ops1,cpu_time,owner)
		local idp = tonumber(idp)*40
		
		local getcolor = Color(255,255,255)
		local o_name="Unknown"
		local o_tcol=Color(255,255,255)
		if(IsValid(owner))then
			getcolor = owner:GetPlayerColor()
			o_name=owner:Nick()
			o_tcol=team.GetColor(owner:Team())
		end
		--team.GetColor(owner:Team())
		local colBox = Color(getcolor.r * 255, getcolor.g * 255, getcolor.b * 255, 100) 
		surface.SetDrawColor( colBox )
		surface.DrawRect( ScrW()/95, (ScrH()/3.95)+idp, ScrW()/10, 40 )
		
		surface.SetDrawColor( o_tcol )
		surface.DrawRect( ScrW()/95, (ScrH()/3.95)+idp, 5, 40 )
		
		draw.SimpleText( ""..str, "ConText" , ScrW()/80, (ScrH()/3.93)+idp, Color(255,255,255,255) )
		draw.SimpleText( "  "..o_name, "ConText" , ScrW()/80, (ScrH()/3.82)+idp, Color(255,255,255,255) )
		draw.SimpleText( " "..math.Round(cpu_time).." ups", "ConText" , ScrW()/80*6, (ScrH()/3.82)+idp, Color(255,255,255,255) )
		draw.SimpleText( " "..math.Round(prfbench).." ops", "ConText" , ScrW()/80*7.2, (ScrH()/3.82)+idp, Color(255,255,255,255) )
	end
	
	local function E2LineSc(str,idx,owner,vec)
		local getcolor = Color(255,255,255)
		local o_name="Unknown"
		local o_tcol=Color(255,255,255)
		if(IsValid(owner))then
			getcolor = owner:GetPlayerColor()
			o_name=owner:Nick()
			o_tcol=team.GetColor(owner:Team())
		end
		--team.GetColor(owner:Team())
		local colBox = Color(getcolor.r * 255, getcolor.g * 255, getcolor.b * 255, 150) 
		surface.SetDrawColor( colBox )
		surface.DrawRect( vec.x-50, vec.y-50, 170, 35 )
		
		surface.SetDrawColor( o_tcol )
		surface.DrawRect( vec.x-50, vec.y-50, 2, 35 )
		
		surface.DrawLine( vec.x+6, vec.y, vec.x+6, vec.y-15 ) 
		
		draw.SimpleText( ""..str, "ConText" , vec.x-42, vec.y-50, Color(255,255,255,255) )
		draw.SimpleText( "  "..o_name, "ConText" , vec.x-40, vec.y-34, Color(255,255,255,255) )
	end
	
	
	local E2s = ents.FindByClass("gmod_wire_expression2")
	local size = 0
	for _, v in pairs(E2s) do
		local ply = v:GetNWEntity("player", NULL)

			local nick
			if not ply or not ply:IsValid() then nick = null else nick = ply end
			local name = v:GetNWString("name", "generic")
			local name2 = v:GetNWString("name", "generic")

			local singleline = string.match( name, "(.-)\n" )
			if singleline then name = singleline .. "..." end

			local max = 50
			if #name > max then name = string.sub(name,1,max) .. "..." end
			if #name > 22 then name2 = string.sub(name,1,22) .. "..." end
			local idx = v:EntIndex()
			local vec = v:GetPos():ToScreen()
			E2LineSc(name2,idx,nick,vec)
			
			if _>20 then continue end
			
			local data1 = v:GetOverlayData()
			if data1 then
				local hardquota = GetConVar("wire_expression2_quotahard")
				local softquota = GetConVar("wire_expression2_quotasoft")
				local prfbench = data1.prfbench
				local prfcount = data1.prfcount
				local timebench = data1.timebench
				local e2_hardquota = hardquota:GetInt()
				local e2_softquota = softquota:GetInt()
				local hardtext = (prfcount / e2_hardquota > 0.33) and "(+" .. tostring(math.Round(prfcount / e2_hardquota * 100)) .. "%)" or ""
				E2Line(_,name,idx,prfbench,prfbench / e2_softquota * 100,hardtext,timebench*1000000,nick)
			else
				E2Line(_,name,idx,0,0,"",0,nick)
			end
				

			local p_col_e2 = Color(0,0,0,255)
			local p_name="Unknown"
			if(IsValid(ply))then
				p_col_e2=Color(team.GetColor(ply:Team()).r,team.GetColor(ply:Team()).g,team.GetColor(ply:Team()).b,255)	
				p_name=ply:Nick()
			end
			draw.RoundedBox( 0, vec.x, vec.y, 15, 15, p_col_e2 )
			draw.RoundedBox( 0, vec.x+2, vec.y+2, 11, 11, Color(0,0,0,200) )
			--draw.RoundedBox( 0, vec.x+7, vec.y+2, 2, 11, Color(255,0,0,150) )
			--draw.RoundedBox( 0, vec.x+2, vec.y+7, 11, 2, Color(255,0,0,150) )
			--draw.DrawText( p_name, "ConText", vec.x, vec.y+9, p_col_e2, 1 )

	end
	
end

hook.Remove("HUDPaint", "DrawE2Panel")
-- hook.Add("HUDPaint", "DrawE2Panel", DrawE2Panel)	

hook.Add( "OnContextMenuOpen", "DrawE2Panel", function()
	hook.Add("HUDPaint", "DrawE2Panel", DrawE2Panel)	
	hook.Add( "HUDPaint", "wire_holograms_showowners", WireHologramsShowOwners)
end)

hook.Add( "OnContextMenuClose", "DrawE2Panel", function()
	hook.Remove("HUDPaint", "DrawE2Panel")
	hook.Remove("HUDPaint", "wire_holograms_showowners")
end)
