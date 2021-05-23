-------------------------------------------------------------
-- ADDITIONS TO THE CoreRPG campaign/scripts/image_overrides.lua below
-------------------------------------------------------------

-- sub in the measurement text for our custom varient for height
function onMeasurePointer(pixellength,pointertype,startx,starty,endx,endy)
	return RangeFinder.onMeasurePointer(self, pixellength,pointertype,startx,starty,endx,endy);
end
