
class Player

  @@just_hit = false
  @@ship_found = false
  @@moves_since_hit = 0
  @@last_hit = nil
  @@last_move = nil
  @@first_hit = nil
  @@direction = :up
  @@previous_ships_remaining = nil

  def name
    # Uniquely identify your player
    "Death Boat"
  end

  def new_game
    # return an array of 5 arrays containing
    # [x,y, length, orientation]
    # e.g.
     [
       [1, 1, 5, :down],
       [5, 5, 4, :across],
       [9, 3, 3, :down],
       [2, 2, 3, :across],
       [9, 7, 2, :down]
     ]
  end

  def test_board
  end

  def get_likelyhood(state, ships_remaining)
    # init
    likelyhood = 10.times.map do 10.times.map do 0 end end
    
    # avoid even squares
    likelyhood.each_with_index do |a, y|
      a.each_with_index do |p, x|
        if state[y][x] != :unknown
        elsif (y*10+x+y) % 2 == 0
          # even squares only
          #fit the ships here
          ships_remaining.each do |ship_length|
            ship_length.times do |ship_configuration_pos|
              likelyhood[y][x] += 1 if can_ship_be_here_like_this?(state, ships_remaining, ship_length, x, y, ship_configuration_pos, :across)
              likelyhood[y][x] += 1 if can_ship_be_here_like_this?(state, ships_remaining, ship_length, x, y, ship_configuration_pos, :down)
            end
          end
        end
      end
    end
    likelyhood
  end

  def can_ship_be_here_like_this?(state, ships_remaining, ship_length, x, y, ship_configuration_pos, orientation)
    # is this possible *orientation*ally
    all_not_misses = true
    ship_length.times do |ship_pos|
      if orientation == :across
        p = x-ship_configuration_pos+ship_pos
        return false if p < 0 || p >= 10
        here_state = state[y][p]
      else
        p = y-ship_configuration_pos+ship_pos
        return false if p < 0 || p >= 10
        here_state = state[p][x]
      end
      if here_state == :miss
        all_not_misses = false # The ship can't be here
      end
    end
    #if all_not_misses the ship can be here in this configuration
    return all_not_misses
  end

  def take_turn(state, ships_remaining)
    # state is the known state of opponents fleet
    # ships_remaining is an array of the remaining opponents ships
    lmax = -1
    mlx = 0 ; mly = 0

    reverse_direction = {:up => :down, :left => :right, :down => :up, :right => :left}
    rotate_direction = {:up => :left, :left => :down, :down => :right, :right => :up}

    (puts "LAST MOVE #{@@last_move[0]}, #{@@last_move[1]}" ; ) if @@last_move


    @@just_hit = (@@last_move && state[@@last_move[0]][@@last_move[1]] == :hit)

    if @@just_hit && @@ship_found == false
      @@first_hit = @@last_move
      @@ship_found = true
    end

    if @@previous_ships_remaining != ships_remaining && @@ship_found == true
      @@ship_found = false
    end



    if @@ship_found
      # Change direction on miss
      if !@@just_hit
        @@direction = reverse_direction[@@direction]
        @@last_move = @@first_hit
        @@just_hit = true
        puts "REVERSING"
      end
      # Change direction on out of bounds
    puts "JUST_HIT: #{@@just_hit}"
      # increment in *direction*
      valid_move = false
      until valid_move
        lx = @@last_move[1]
        ly = @@last_move[0]
        mly = ly ; mlx = lx
        if @@direction == :up
          mly = ly - 1
        elsif @@direction == :left
          mlx = lx - 1
        elsif @@direction == :down
          mly = ly + 1
        else # :right
          mlx = lx +1
        end
        puts "ABOUT TO MOVE TO #{mly}, #{mlx}, FIRST HIT: #{@@first_hit.inspect}"
        valid_move = true
        if mlx < 0 || mlx >= 10 || mly < 0 || mly >= 10
          valid_move = false
        elsif state[mly][mlx] != :unknown
          valid_move = false
        end
        unless valid_move
          @@direction = rotate_direction[@@direction]
          @@last_move = @@first_hit
          puts "ROTATING"
        end
      end
    else
      likelyhood = get_likelyhood(state, ships_remaining)
      # find ML
      likelyhood.each_with_index do |lrow, y|
        lrow.each_with_index do |lc, x|
          if lc >= lmax
            lmax = lc
            mlx = x ; mly = y
          end
        end
      end
      puts "ML: #{lmax} x: #{mlx} y: #{mly}"
    end

    @@previous_ships_remaining = ships_remaining
    @@last_move = [mly, mlx]


    return [mlx,mly] # your next shot co-ordinates
  end

  # you're free to create your own methods to figure out what to do next
end
