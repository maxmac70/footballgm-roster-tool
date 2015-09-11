require './player'
require 'csv'
require 'json'

@create_free_agents = true # if true, the code will automatically trim each roster down to 53

@players = []
@player_id = 1
@free_agent_count = 0

@import_file = 'players_updated.csv'
@output_file = 'roster_file.json'

csv_data = File.read(@import_file)
csv = CSV.parse(csv_data, :headers => true)

@row_count = csv.count

csv.each do |row|
  team_name = row['Team'].strip.downcase
  first = row['First Name']
  last = row['Last Name']
  position = row['Position']
  number = row['Jersey Number']
  overall = row['OVR']
  speed = row['Speed']
  acceleration = row['Acceleration']
  strength = row['Strength']
  agility = row['Agility']
  awareness = row['Awareness']
  catching = row['Catching']
  carrying = row['Carrying']
  throw_pwr = row['Throw Power']
  throw_acc_short = row['Throw Accuracy Short']
  throw_acc_mid = row['Throw Accuracy Mid']
  throw_acc_deep = row['Throw Accuracy Deep']
  kick_pwr = row['Kick Power']
  kick_acc = row['Kick Accuracy']
  run_block = row['Run Block']
  pass_block = row['Pass Block']
  tackle = row['Tackle']
  jumping = row['Jumping']
  kick_return = row['Kick Return']
  injury = row['Injury']
  stamina = row['Stamina']
  toughness = row['Toughness']
  trucking = row['Trucking']
  elusiveness = row['Elusiveness']
  ball_carrier_vision = row['Ball Carrier Vision']
  stiff_arm = row['Stiff Arm']
  spin_move = row['Spin Move']
  juke_move = row['Juke Move']
  impact_block = row['Impact Block']
  power_moves = row['Power Moves']
  finesse_moves = row['Finesse Moves']
  block_shedding = row['Block Shedding']
  pursuit = row['Pursuit']
  play_recognition = row['Play Recognition']
  man_cov = row['Man Coverage']
  zone_cov = row['Zone Coverage']
  spectacular_catch = row['Spectacular Catch']
  catch_in_traffic = row['Catch In Traffic']
  route_running = row['Route Running']
  hit_power = row['Hit Power']
  press = row['Press']
  release = row['Release']
  play_action = row['Play Action']
  throw_on_run = row['Throw On The Run']
  height = row['Height']
  weight = row['Weight']
  team_id = row['Team ID'].to_i
  image_url = row['Image URL']
  age = row['Age']
  birth_year = row['Birth Year']
  birth_place = row['Birth Place']
  contract_exp = row['Contract Expiration']
  contract_val = row['Contract Value']
  draft_year = row['Draft Year']
  draft_team_id = row['Draft Team ID']
  draft_round = row['Draft Round']
  draft_pick = row['Draft Pick']

  if team_id
    p = Player.new(team_id, first, last, position, height, weight)
    p.id = @player_id

    p.endurance = (stamina.to_i + injury.to_i) / 2
    p.speed = speed.to_i
    p.strength = strength.to_i
    p.toughness = (toughness.to_i + injury.to_i) / 2
    p.awareness = awareness.to_i
    p.game_iq = awareness.to_i
    p.blocking = (pass_block.to_i + run_block.to_i + impact_block.to_i) / 3
    p.tackle = tackle.to_i
    p.coverage = (man_cov.to_i + zone_cov.to_i) / 2
    p.overall = overall.to_i
    p.potential = overall.to_i
    p.kicking = (kick_pwr.to_i + kick_acc.to_i) / 2
    p.strength = throw_pwr.to_i if position.downcase === 'qb'
    p.passing = (play_action.to_i + throw_acc_short.to_i + throw_acc_mid.to_i + throw_acc_deep.to_i) / 4
    p.def_rush = (block_shedding.to_i + pursuit.to_i) / 2
    p.receiving = (catching.to_i + catch_in_traffic.to_i + spectacular_catch.to_i) / 3
    p.hands = catching.to_i
    p.athleticism = (agility.to_i + acceleration.to_i + jumping.to_i + elusiveness.to_i) / 4
    p.athleticism = (agility.to_i + acceleration.to_i + jumping.to_i + elusiveness.to_i + throw_on_run.to_i) / 5 if position.downcase === 'qb'
    p.aggresiveness = (acceleration.to_i + tackle.to_i + pursuit.to_i) / 3
    p.motor = (block_shedding.to_i + power_moves.to_i + hit_power.to_i) / 2

    p.contract_amount = contract_val
    p.contract_expiration = contract_exp
    p.image_url = image_url
    p.birth_year = birth_year
    p.birth_location = birth_place
    p.draft_year = draft_year
    p.draft_team_id = draft_team_id
    p.draft_round = draft_round
    p.draft_pick = draft_pick

    @players.push(p)
    @player_id += 1
  else
    puts "Cannot find matching team: '#{team_name}'"
  end
end

if @create_free_agents
  (0..31).each do |tid|
    team_members = @players.select{|p| p.team_id === tid}
    team_count = team_members.count
    to_remove = team_count - 52
    sorted_team_members = team_members.sort_by(&:overall)
    (0..to_remove).each do |i|
      sorted_team_members[i].team_id = -1
      @free_agent_count += 1
    end
  end
end

puts "player count: #{@players.count}"
puts "free agents created: #{@free_agent_count}" if @create_free_agents

File.open(@output_file, 'w') do |f|
  players = @players.map{|p| p.json_format}

  output = {
    :startingSeason => 2016,
    :players => players
  }

  f.write output.to_json
end
