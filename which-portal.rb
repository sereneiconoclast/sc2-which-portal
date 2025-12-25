#!/usr/bin/env ruby

# Usage:
#   which-portal.rb from 175.3/145.4 to 468.1/091.6
#   which-portal.rb from "175.3 / 145.4" to "468.1 / 091.6"

# Quasi-space address => [destination_x, destination_y]
PORTALS = {
  'Q521 / 514' => [ 11.2, 940.9],
  'Q544 / 533' => [ 36.8, 633.0],
  'Q530 / 528' => [775.2, 890.6],
  'Q520 / 540' => [584.7, 621.1],
  'Q488 / 538' => [973.5, 315.3],
  'Q466 / 514' => [230.2, 398.8],
  'Q448 / 504' => [565.8, 971.2],
  'Q476 / 496' => [611.7, 413.1],
  'Q458 / 492' => [860.7,  15.1],
  'Q492 / 492' => [  5.0, 164.7],
  'Q468 / 464' => [921.1, 610.4],
  'Q476 / 458' => [409.1, 774.8],
  'Q502 / 460' => [318.4, 490.6],
  'Q506 / 474' => [191.0,  92.6],
  'Q516 / 466' => [567.3, 120.7]
}.freeze

PORTAL_COST = 10.0

def distance(x1, y1, x2, y2)
  Math.sqrt((x2 - x1)**2 + (y2 - y1)**2)
end

def round_up_to_tenth(value)
  (value * 10).ceil / 10.0
end

# Format as 3 digits before decimal, 1 after (e.g., "036.8")
def format_coordinate(coord)
  format('%04d', (coord * 10.0).round).tap { |s| s[3, 0] = '.' }
end

# Parse coordinates like "175.3/145.4" or "175.3 / 145.4"
def parse_coordinates(coord_string)
  if %r{^(?<x>\d{3}\.\d) ?/ ?(?<y>\d{3}\.\d)$} =~ coord_string
    return [x, y].map(&:to_f)
  end
  raise ArgumentError, "Invalid coordinate format: #{coord_string}"
end

def total_fuel_cost(start_x:, start_y:, end_x:, end_y:, extra_cost:)
  travel_distance = distance(start_x, start_y, end_x, end_y)
  travel_fuel = round_up_to_tenth(travel_distance / 10.0)
  extra_cost + travel_fuel
end

def answer(
  portal_name:, portal_destination_x:, portal_destination_y:,
  hyperspace_travel_distance:, target_x:, target_y:
)
  portal_cost = portal_name ? PORTAL_COST : 0.0
  hyperspace_fuel = round_up_to_tenth(hyperspace_travel_distance / 10.0)
  total_fuel = portal_cost + hyperspace_fuel

  directly_or_not_to = portal_name ? 'to' : 'directly through hyperspace to'
  hyperspace_travel_part = "Travel #{format('%.1f', hyperspace_travel_distance)} #{directly_or_not_to} #{format_coordinate(target_x)} / #{format_coordinate(target_y)} (cost: #{format('%.1f', hyperspace_fuel)} units of fuel)"
  total_fuel_cost_part = "Total fuel cost: #{format('%.1f', total_fuel)} units of fuel"

  answer = ''
  if portal_name
    answer << <<~QUASISPACE_PART
      Use quasi-space portal at #{portal_name} (cost: #{format('%.1f', portal_cost)} units of fuel to use portal spawner)
      Emerge in hyperspace at #{format_coordinate(portal_destination_x)} / #{format_coordinate(portal_destination_y)}
    QUASISPACE_PART
  end
  answer << hyperspace_travel_part << "\n" << total_fuel_cost_part << "\n"
end

# Parse command-line arguments
if ARGV.length != 4 || ARGV[0] != 'from' || ARGV[2] != 'to'
  puts "Usage: #{$0} from <start_x>/<start_y> to <target_x>/<target_y>"
  exit 1
end

start_x, start_y = parse_coordinates(ARGV[1])
target_x, target_y = parse_coordinates(ARGV[3])

# Create augmented hash with costs
starting_points_with_costs = PORTALS.dup
starting_points_with_costs.transform_values! { |coords| coords + [PORTAL_COST] }
starting_points_with_costs[nil] = [start_x, start_y, 0.0]

# Find the cheapest option
best_option = nil
best_cost = Float::INFINITY

starting_points_with_costs.each do |portal_name, (dest_x, dest_y, extra_cost)|
  cost = total_fuel_cost(
    start_x: dest_x,
    start_y: dest_y,
    end_x: target_x,
    end_y: target_y,
    extra_cost: extra_cost
  )

  if cost < best_cost
    best_cost = cost
    best_option = {
      portal_name: portal_name,
      portal_destination_x: dest_x,
      portal_destination_y: dest_y,
      hyperspace_travel_distance: distance(dest_x, dest_y, target_x, target_y)
    }
  end
end

puts answer(
  portal_name: best_option[:portal_name],
  portal_destination_x: best_option[:portal_destination_x],
  portal_destination_y: best_option[:portal_destination_y],
  hyperspace_travel_distance: best_option[:hyperspace_travel_distance],
  target_x: target_x,
  target_y: target_y
)
