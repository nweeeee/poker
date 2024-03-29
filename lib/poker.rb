class Card

  attr_accessor :val, :suit

  def initialize(val, suit)
    @val = val
    @suit = suit
  end

  def render
    if @val > 10
      pic = {11 => "J", 12 => "Q", 13 => "K", 14 => "A"}
      output = "#{pic[@val]} of #{suit}"
    else
      output = "#{val} of #{suit}"
    end

  end


end

class Deck

  attr_accessor :all_cards, :dealt_cards, :unused_cards

  def initialize
    @all_cards = []
    (2..14).each do |value|
      [:hearts, :clubs, :spades, :diamonds].each do |suit|
        @all_cards << Card.new(value, suit)
      end
    end
    @dealt_cards = []
    @unused_cards = @all_cards.dup
  end

  def deal(num)
    this_hand = []
    num.times do |i|
      random_card = @unused_cards.sample
      this_hand << random_card
      @dealt_cards << random_card
      @unused_cards.delete(random_card)
    end
    this_hand #an array of one or more dealt cards
  end


end

class Hand

  attr_accessor :hand_cards, :hand_type

  def initialize
    @hand_cards = []
  end

  def new_hand(deck)
    @hand_cards = deck.deal(5)
    @hand_cards
  end

  def sort_by_value!
    @hand_cards = @hand_cards.sort_by {|card| card.val}.reverse

  end




  def straight?
    is_straight = true
    switched_ace_pos = 0
    self.sort_by_value!
    4.times do |i|
      is_straight = false if (self.hand_cards[i].val - self.hand_cards[i + 1].val) != 1
    end

    #also check that if you convert A to a 1 instead of a 14 whether that makes a straight
    if is_straight == false && self.hand_cards.any? {|card| card.val == 14}
      self.hand_cards.each_with_index do |card, i|
        if card.val == 14
          card.val = 1
          switched_ace_pos += 1
        end
      end
      self.sort_by_value!
      is_straight = true
      4.times do |i|
        is_straight = false if (self.hand_cards[i].val - self.hand_cards[i + 1].val) != 1
      end
      
    end
    if is_straight && switched_ace_pos > 0
      self.hand_cards[4].val = 14 #give the ace the value of 14 again
      sort_by_value!
    elsif switched_ace_pos > 0 && is_straight == false
      sort_by_value!
      switched_ace_pos.times do |i|
        self.hand_cards[((i + 1) * -1)].val = 14
      end

    end
      
    is_straight
  end

  def flush?
    is_flush = false
    test_suit = @hand_cards[0].suit
    is_flush = true if @hand_cards.all? {|card| card.suit == test_suit}
    if is_flush
      self.sort_by_value!
    end
    is_flush
  end

  def straight_flush?
    return true if straight? && flush?
    false
  end

  def royal_flush?
    return true if straight_flush? && self.hand_cards[0].val == 14
    false
  end

  def four_of_a_kind?
    is_four_of_a_kind = false
    self.sort_by_value!
    values_hash = create_values_hash
    if values_hash.has_value?(4)
      is_four_of_a_kind = true
    end
    if self.hand_cards[0] != self.hand_cards[1] #then the odd card out is higher than the four others
      self.hand_cards[0], self.hand_cards[4] = self.hand_cards[4], self.hand_cards[0]
    end
    is_four_of_a_kind
  end

  def full_house?
    is_full_house = false
    self.sort_by_value!
    values_hash = create_values_hash
    if values_hash.has_value?(3) && values_hash.has_value?(2)
      is_full_house = true
    end
    if self.hand_cards[1] != self.hand_cards[2] #then the pair is of a higher value than the three so you need to switch the order
      self.hand_cards.reverse!
    end

    is_full_house
  end

  def create_values_hash #see how many of each value card is in the hand
    values_hash = Hash.new(0)
    self.hand_cards.each do |card|
      values_hash[card.val] += 1
    end
    values_hash
  end

  def three_of_a_kind?
    is_three_of_a_kind = false
    self.sort_by_value!
    values_hash = create_values_hash
    if values_hash.length == 3 && values_hash.has_value?(3) && values_hash.has_value?(1)
      is_three_of_a_kind = true
    end
    #reorder the cards
    if @hand_cards[0].val > @hand_cards[1].val && @hand_cards[1].val == @hand_cards[2].val #then the order of the cards is something like 8 7 7 7 6
      temp = @hand_cards.shift
      @hand_cards << temp
      @hand_cards[3], @hand_cards[4] = @hand_cards[4], @hand_cards[3]
    elsif @hand_cards[0].val > @hand_cards[1].val && @hand_cards[1].val > @hand_cards[2].val #then the order of is something like this 8 7 6 6 6
      2.times do
        temp = @hand_cards.shift
        @hand_cards << temp
      end
    end
    is_three_of_a_kind
  end

  def two_pair?
    is_two_pair = false

    self.sort_by_value!

    values_hash = create_values_hash
    if values_hash.length == 3 && values_hash.has_value?(2) && values_hash.has_value?(1)
      is_two_pair = true
    end
    #reorder the cards
    if @hand_cards[0].val > @hand_cards[1].val #then the highest card is the single card
      temp = @hand_cards.shift
      @hand_cards << temp
    end
    is_two_pair

  end

  def one_pair?
    is_one_pair = false
    sort_by_value!

    values_hash = create_values_hash
    if values_hash.length == 4 && values_hash.has_value?(2) && values_hash.has_value?(1)
      is_one_pair = true
    end

    if @hand_cards[0].val == @hand_cards[1].val
      #don't need to reorder them
    elsif @hand_cards[0].val > @hand_cards[1].val && @hand_cards[1].val == @hand_cards[2].val #then the order is something like this 6 5 5 4 3
      temp = @hand_cards.shift
      @hand_cards << temp
      @hand_cards[3], @hand_cards[4] = @hand_cards[4], @hand_cards[3]
      @hand_cards[2], @hand_cards[3] = @hand_cards[3], @hand_cards[2]
    elsif @hand_cards[2].val == @hand_cards[3].val #then the order is something like this 6 5 4 4 3
      @hand_cards[0], @hand_cards[2] = @hand_cards[2], @hand_cards[0]
      @hand_cards[1], @hand_cards[3] = @hand_cards[3], @hand_cards[1]
    else #the order is something like this 6 5 4 3 3 
      3.times do 
        temp = @hand_cards.shift
        @hand_cards << temp
      end
    end
    is_one_pair
  end




# NOTE: when checking for any of the card combinations, 
# you're always calling self.sort_by_value! first, so there's
# probably a better way to do that...
# make a find_card_combination method that calls sort_by_value!
# before checking flush, straight, etc.
# if this method below works well, then you can get rid of the
# self.sort_by_value! in each of those hand checking methods
  def find_card_combo
    self.sort_by_value!

    while true
      if royal_flush?
        @hand_type = :royal_flush
        return
      elsif straight_flush?
        @hand_type = :straight_flush
        return
      elsif four_of_a_kind?
        @hand_type = :four_of_a_kind
        return
      elsif full_house?
        @hand_type = :full_house
        return
      elsif flush?
        @hand_type = :flush
        return
      elsif straight?
        @hand_type = :straight
        return
      elsif three_of_a_kind?
        @hand_type = :three_of_a_kind
        return
      elsif two_pair?
        @hand_type = :two_pair
        return
      elsif one_pair?
        @hand_type = :one_pair
        return
      else
        @hand_type = :high_card
        sort_by_value!
        return "high_card"
      end
          
    end

  end

  def render
    @hand_cards.each.map {|card| card.render + ", "}.join(" ") + @hand_type.to_s

  end

  def hand_rank
    self.find_card_combo

    case @hand_type

    when :royal_flush
      10
    when :straight_flush
      9
    when :four_of_a_kind
      8
    when :full_house
      7
    when :flush
      6
    when :straight
      5
    when :three_of_a_kind
      4
    when :two_pair
      3
    when :one_pair
      2
    when :high_card
      1
    end

  end


  def beats?(other_hand)
    case self.hand_rank <=> other_hand.hand_rank
    when 1
      return true
    when 0
      tie_breaker(other_hand)
    when -1
      return false
    end

  end

  def discard(indices, deck)
    indices.each do |i|
      original_card = @hand_cards[i]
      @hand_cards[i] = deck.deal(1)[0]
      deck.unused_cards << original_card

    end

  end

  def tie_breaker(other_hand)
    self.hand_cards.each_with_index do |card, i|
      if card.val > other_hand.hand_cards[i].val
        return true
      end
    end
    false
  end

end

class Player

  attr_accessor :hand, :pot, :name, :folded

  def initialize(name, pot)
    @name = name
    @pot = pot
    @folded = false
  end

  def discard(deck)
    puts "player #{@name}: which cards do you want to discard? (e.g. 0,2,3)"
    input = gets.chomp
    unless input == ""
      indices = input.split(",").map(&:to_i)
      self.hand.discard(indices, deck)

    end

  end


  def place_bet(game)
    
    puts "player #{@name}: do you want to fold, see, or raise? (to fold, say fold. otherwise, just enter your bet amount)"
    choice = gets.chomp
    if choice == "fold"
      self.folded = true
    else
      bet_amt = choice.to_i
    
      @pot -= bet_amt
      game.process_bet(bet_amt)
    end
    

  
  end

  def beats?(other_player)
    self.hand.beats?(other_player.hand)
  end



end

class Game

  attr_accessor :pot, :deck, :players

  def initialize(players)
    @players = players
    @deck = Deck.new
    @pot = 0
  end

  def deal_cards
    @players.each do |player|
      player.hand = Hand.new
      player.hand.new_hand(@deck)
      p "player: #{player.name}, this is your hand: #{player.hand}"
      p player.hand.render
    end
    
  end

  

  def play
    deal_cards
    p "cards dealt"
    
    place_bets
    p "pot total: #{@pot}"

    switch_cards

    place_bets
    p "pot total: #{@pot}"

    reveal_cards

    p "winning player is #{winner.name}"


  end

  def place_bets
    @players.each do |player|
      next if player.folded == true

      player.place_bet(self)

    end
  end

  def reveal_cards
    @players.each do |player|
      p "player #{player.name}'s hand:"
      p "FOLDED" if player.folded == true
      player.hand.find_card_combo
      p player.hand.render

    end
  end

  def switch_cards
    @players.each do |player|
      next if player.folded == true

      player.discard(@deck)
      p "player #{player.name}'s hand:"
      p player.hand.render
      
    end
  end

  def process_bet(amt)
    @pot += amt
  end

  def winner
    winning_player = @players[0]
    
    1.upto(@players.count - 1) do |i|
      next if @players[i].folded == true

      if @players[i].beats?(winning_player)
        winning_player = @players[i]
      end
    
    end

    "player #{winning_player.name} is the winner!"
    winning_player
  end

end





