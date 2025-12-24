#!/usr/bin/env ruby

# Usage:
#   which-portal.rb from 175.3/145.4 to 468.1/091.6
#   which-portal.rb from "175.3 / 145.4" to "468.1 / 091.6"

# Portal data: name => [destination_x, destination_y]
PORTALS = {
  'Q521/514' => [11.2, 940.9],
  'Q544/533' => [36.8, 633.0],
  'Q530/528' => [775.2, 890.6],
  'Q520/540' => [584.7, 621.1],
  'Q488/538' => [973.5, 315.3],
  'Q466/514' => [230.2, 398.8],
  'Q448/504' => [565.8, 971.2],
  'Q476/496' => [611.7, 413.1],
  'Q458/492' => [860.7, 15.1],
  'Q492/492' => [5.0, 164.7],
  'Q468/464' => [921.1, 610.4],
  'Q476/458' => [409.1, 774.8],
  'Q502/460' => [318.4, 490.6],
  'Q506/474' => [191.0, 92.6],
  'Q516/466' => [567.3, 120.7]
}.freeze

PORTAL_COST = 10.0

def distance(x1, y1, x2, y2)
  Math.sqrt((x2 - x1)**2 + (y2 - y1)**2)
end

def round_up_to_tenth(value)
  (value * 10).ceil / 10.0
end

def format_coordinate(coord)
  # Format as 3 digits before decimal, 1 after (e.g., "036.8")
  parts = format('%.1f', coord).split('.')
  integer_part = parts[0].to_i
  decimal_part = parts[1]
  format('%03d.%s', integer_part, decimal_part)
end

def parse_coordinates(coord_string)
  # Parse coordinates like "175.3/145.4" or "175.3 / 145.4"
  parts = coord_string.split('/').map(&:strip)
  if parts.length != 2
    raise ArgumentError, "Invalid coordinate format: #{coord_string}"
  end
  [parts[0].to_f, parts[1].to_f]
end

# Parse command-line arguments
if ARGV.length != 4 || ARGV[0] != 'from' || ARGV[2] != 'to'
  puts "Usage: #{$0} from <start_x>/<start_y> to <target_x>/<target_y>"
  exit 1
end

start_x, start_y = parse_coordinates(ARGV[1])
target_x, target_y = parse_coordinates(ARGV[3])

# Calculate direct travel cost
direct_distance = distance(start_x, start_y, target_x, target_y)
direct_fuel = round_up_to_tenth(direct_distance / 10.0)
direct_total = direct_fuel

# Find the portal with the closest destination to the target
closest_portal = nil
closest_distance = Float::INFINITY

PORTALS.each do |name, (dest_x, dest_y)|
  dist = distance(dest_x, dest_y, target_x, target_y)
  if dist < closest_distance
    closest_distance = dist
    closest_portal = { name: name, dest_x: dest_x, dest_y: dest_y }
  end
end

# Calculate portal travel fuel costs
portal_travel_fuel = round_up_to_tenth(closest_distance / 10.0)
portal_total = PORTAL_COST + portal_travel_fuel

# Choose the cheaper option
if direct_total <= portal_total
  # Direct travel is cheaper or equal
  puts "Travel #{format('%.1f', direct_distance)} directly to #{format_coordinate(target_x)} / #{format_coordinate(target_y)} (cost: #{format('%.1f', direct_fuel)} units of fuel)"
  puts "Total fuel cost: #{format('%.1f', direct_total)} units of fuel"
else
  # Portal travel is cheaper
  puts "Use portal #{closest_portal[:name]} (cost: #{format('%.1f', PORTAL_COST)} units of fuel)"
  puts "Emerge at #{format_coordinate(closest_portal[:dest_x])} / #{format_coordinate(closest_portal[:dest_y])}"
  puts "Travel #{format('%.1f', closest_distance)} to #{format_coordinate(target_x)} / #{format_coordinate(target_y)} (cost: #{format('%.1f', portal_travel_fuel)} units of fuel)"
  puts "Total fuel cost: #{format('%.1f', portal_total)} units of fuel"
end

