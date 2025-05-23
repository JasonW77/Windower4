--[[    BSD License Disclaimer
        Copyright © 2020, Hamhand
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of checklist nor the
              names of its contributors may be used to endorse or promote products
              derived from this software without specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
        ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
        WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        DISCLAIMED. IN NO EVENT SHALL Hamhand BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
		
		
]]

_addon.name = 'Checklist'
_addon.author = 'Hamhand'
_addon.version = '1.0.0'
_addon.language = 'English'
_addon.commands = {'checklist', 'cl'}

config = require ('config')
texts = require ('texts')

defaults = {}
defaults.pos = {}
defaults.pos.x = 1000
defaults.pos.y = 200
defaults.color = {}
defaults.color.alpha = 200
defaults.color.red = 200
defaults.color.green = 200
defaults.color.blue = 200
defaults.bg = {}
defaults.bg.alpha = 200
defaults.bg.red = 30
defaults.bg.green = 30
defaults.bg.blue = 30

settings = config.load(defaults)

cl = texts.new('Check List', settings) 
list = {"hello","Vana'diel","welcome","to","Check List!"}

local function print_list()
	for i = 1, #list do
		local list = print( list[i])	
	end

end
local function add_to_list()

end

local function remove_from_list()
		
end
local function clear_list()
		
end

windower.register_event('addon command', function(command, ...)
    command = command and command:lower()
    local args = {...}
	
    if command == 'pos' then
        local posx, posy = tonumber(params[2]), tonumber(params[3])
        if posx and posy then
            cl:pos(posx, posy)
        end
    elseif command == 'hide' then
        cl:hide()
    elseif command == 'show' then
        cl:show()
		print_list(list)
	elseif command == 'add' then
		local list, str = tonumber(list[2]), tostring(list[3])
		if list and str then
			cl.add_to_list()
			cl.show()
		end
    else
        print('cl help : Shows help message')
        print('cl pos <x> <y> : Positions the list')
        print('cl hide : Hides the list')
        print('cl show : Shows the list')
		print('cl add <list priority> <list description> : add item to the list')
    end
end)