extends Node

# Sets two sprites to point towards a target
# Parameters:
#	Srpite sprite1: First sprite
#	Sprite sprite2: Second sprite
#	Float length1: Length of the first bone (distance from pivot to next pivot)
#	Float length2: Length of the second bone (distance from pivot to end)
#	Vector2 target: Vector2D representing the target position
#	Boolean solvePosAngle2: Solve for positive angle2 instead of negative angle2. Defaults to `true`
# 	Boolean move_limb: set it to false if your second limb is parented. Defaults to `true`
#	Float epsilon: cutoff value; under this value, angle will be considered 0. Defaults to `0.0001`
# Returns:
#	Boolean: if true, a valid solution was found; if false, an approximate solution was found
static func set(sprite1,sprite2,limb1_length,limb2_length,target,solvePosAngle=true,move_limb=true,epsilon = 0.0001):
	var origin = sprite1.get_pos()
	var solution = solve(limb1_length,limb2_length,origin,target,solvePosAngle,epsilon)
	var angle1 = solution[0]
	var angle2 = solution[1]
	var valid_solution = solution[2]
	sprite1.set_rot(angle1)
	sprite2.set_rot(angle2)
	if move_limb:
		sprite2.set_pos(origin+Vector2(cos(angle1)*limb1_length,sin(angle1)*limb1_length*-1))
	return valid_solution
	
# Computes an analytical ik solution for a given target and two bones
# Parameters:
#	Float length1: Length of the first bone (distance from pivot to next pivot)
#	Float length2: Length of the second bone (distance from pivot to end)
#	Float targetX: X position of the target
#	Float targetY: Y position of the target
#	Boolean solvePosAngle2: Solve for positive angle2 instead of negative angle2. Defaults to `true`
#	Float epsilon: cutoff value; under this value, angle will be considered 0. Defaults to `0.0001`
# Returns:
#	[number,number,boolean] an array with three elements: the angle of the first bone, the
#	angle of the second bone, and whether a valid solution was found
static func solve(length1,length2,origin,target,solvePosAngle2=true,epsilon = 0.0001):
	target = Vector2(1,-1)*target
	origin = Vector2(1,-1)*origin
	var angle1
	var angle2
	var foundValidSolution = true
	var sinAngle2
	var cosAngle2
	#var targetDistSqr = (targetX*targetX+targetY*targetY)
	var targetDistSqr = origin.distance_squared_to(target)
	var cosAngle2_denom = 2*length1*length2
	# No bone has a 0 length:
	if cosAngle2_denom > epsilon:
		cosAngle2 = (targetDistSqr - length1*length1 - length2*length2) / cosAngle2_denom
		# if our result is not in the legal cosine range, we can not find a legal solution for the target
		if cosAngle2 < -1 || cosAngle2 > 1:
			foundValidSolution = false
		# clamp our value into range so we can calculate the best solution when there are no valid ones
		cosAngle2 = max(-1,min(1,cosAngle2))
		
		# compute a new value for angle2
		angle2 = acos(cosAngle2)
		
		# adjust for the desired bend direction
		if !solvePosAngle2:
			angle2 = - angle2
		# compute the sine of our angle
		sinAngle2 = sin(angle2)
	# At least one of the bones had a zero length. This means our solvable domain is a circle around the origin with a radius
	# equal to the sum of our bone lengths
	else:
		var totalLenSqr = (length1+length2)*(length1+length2)
		if targetDistSqr < (totalLenSqr - epsilon) || targetDistSqr > (totalLenSqr + epsilon):
			foundValidSolution = false
		# Only the value of angle1 matters at this point. We can just set angle2 to 0
		angle2 = 0
		cosAngle2 = 1
		sinAngle2 = 0
	# Compute the value of angle1 based on the sine and cosine of angle2
	var triAdjacent = length1 + length2*cosAngle2
	var triOpposite = length2*sinAngle2
	var tanY = target.y*triAdjacent - target.x*triOpposite
	var tanX = target.x*triAdjacent - target.y*triOpposite
	angle1 = atan2(tanY,tanX)
	return [angle2,angle1,foundValidSolution]