Bullet = {
	bullets = {},
	mesh = nil,
	speed = 200,
	radius = 12,
	fly_time = 3,
	shoot_gap = 0.5,
	timer = 0,
}
function Bullet:init()
	local segments = 60
	local vertices = {}

	table.insert(vertices, { 0, 0, 0.5, 0.5, 1, 1, 1, 0.6 })

	for i = 0, segments do
		local a = (i / segments) * math.pi * 2

		local x = math.cos(a)
		local y = math.sin(a)

		local u = (x + 1) * 0.5
		local v = (y + 1) * 0.5
		table.insert(vertices, { x, y, u, v })
	end
	self.mesh = love.graphics.newMesh(vertices, "fan")
end

function Bullet:add_trait(object, shoot_gap)
	object.bullet = {
		shoot_gap = shoot_gap,
		timer = love.timer.getTime(),
		radius = self.radius,
		speed = self.speed,
	}
end

function Bullet.shoot(object, name)
	if love.timer.getTime() - object.bullet.timer < object.bullet.shoot_gap then
		return
	end

	object.bullet.timer = love.timer.getTime()
	local bullet = {
		name = name,
		info = {
			_x = object.info._x,
			_y = object.info._y,
			rot = object.info.rot,
		},
		radius = object.bullet.radius,
		speed = object.bullet.speed + object.speed,
		color = object.color,
		timer = 0,
		harm = 12 + math.random() * 12,
	}
	table.insert(Bullet.bullets, bullet)
end

function Bullet:move(dt)
	for i, bullet in ipairs(self.bullets) do
		local rot = bullet.info.rot
		bullet.info._x = bullet.info._x + bullet.speed * dt * math.cos(rot)
		bullet.info._y = bullet.info._y + bullet.speed * dt * math.sin(rot)
		bullet.timer = bullet.timer + dt
		if bullet.timer > self.fly_time then
			table.remove(self.bullets, i)
		end
	end
end

function Bullet:draw()
	for _, bullet in ipairs(self.bullets) do
		love.graphics.setColor(bullet.color)
		love.graphics.draw(self.mesh, bullet.info._x, bullet.info._y, bullet.info.rot, self.radius, self.radius)
	end
end

return Bullet
